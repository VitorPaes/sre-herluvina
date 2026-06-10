-- transform/models/marts/fct_order_items.sql
--
-- Riscos:
-- 1. Perda silenciosa de itens de pedidos se houver chaves de clientes ou transportadoras órfãs e a junção for INNER JOIN.
-- 2. Erros de cálculo centesimais ao acumular o lucro líquido de milhões de registros devido a limitações de precisão de ponto flutuante (double).
-- 3. Duplicação indesejada de registros se as dimensões gerarem chaves duplicadas acidentalmente nas camadas inferiores.
--
-- Ambiguidades:
-- 1. Se os pedidos inconsistentes de data (is_date_consistent = false) devem ser removidos da tabela analítica final ou apenas marcados.
-- 2. Se a receita líquida calculada deve considerar impostos de importação sobre o frete rateado.

with details as (
    select * from {{ ref('int_order_details_allocated') }}
),

orders as (
    select * from {{ ref('int_orders_calculated') }}
),

dim_customers as (
    select customer_id from {{ ref('dim_customers') }}
),

dim_products as (
    select product_id from {{ ref('dim_products') }}
),

dim_employees as (
    select employee_id from {{ ref('dim_employees') }}
),

dim_shippers as (
    select shipper_id from {{ ref('dim_shippers') }}
),

joined as (
    select
        -- Chaves de Negócios e Dimensões
        d.order_id,
        d.product_id,
        o.customer_id,
        o.employee_id,
        o.shipper_id,
        
        -- Datas e Prazos
        o.order_date,
        o.required_date,
        o.shipped_date,
        o.lead_time_days,
        o.delivery_deviation_days,
        o.is_date_consistent,
        
        -- Métricas de Venda
        d.quantity,
        d.unit_price,
        d.discount,
        d.item_gross_value,
        
        -- Cálculo do desconto em valor monetário
        (d.item_gross_value * d.discount) as discount_value,
        
        -- Custo logístico alocado
        d.allocated_freight,
        
        -- Receita Líquida (Venda Bruta - Desconto)
        (d.item_gross_value - (d.item_gross_value * d.discount)) as net_revenue,
        
        -- Lucro Líquido Real (Receita Líquida - Frete Rateado) (RF-02)
        (d.item_gross_value - (d.item_gross_value * d.discount) - d.allocated_freight) as net_profit
        
    from details d
    inner join orders o on d.order_id = o.order_id
    -- Validação de chaves estrangeiras para assegurar integridade no Star Schema
    left join dim_customers c on o.customer_id = c.customer_id
    left join dim_products p on d.product_id = p.product_id
    left join dim_employees e on o.employee_id = e.employee_id
    left join dim_shippers s on o.shipper_id = s.shipper_id
)

select * from joined

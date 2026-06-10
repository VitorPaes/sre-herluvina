-- transform/models/intermediate/int_order_details_allocated.sql
--
-- Riscos:
-- 1. Divisão por zero caso a soma do valor bruto de todos os itens do pedido seja zero (resolvido dividindo igualmente entre os itens).
-- 2. Diferenças centesimais de arredondamento (arredondamento em ponto flutuante) fazendo com que a soma do frete proporcional seja ligeiramente diferente do frete total da ordem.
-- 3. Inconsistência caso o pedido não possua valor de frete preenchido (frete nulo ou zero).
--
-- Ambiguidades:
-- 1. Se a base de cálculo proporcional "item's gross value" deve descontar o valor do desconto de linha (receita líquida) ou se refere-se estritamente à receita bruta (quantidade * unit_price).
-- 2. Se fretes nulos no cabeçalho do pedido devem ser imputados como zero ou se devem levantar um erro de qualidade de dados.

with order_details as (
    select * from {{ ref('stg_order_details') }}
),

orders as (
    select 
        order_id,
        freight_value
    from {{ ref('stg_orders') }}
),

joined as (
    select
        od.order_id,
        od.product_id,
        od.unit_price,
        od.quantity,
        od.discount,
        -- Venda bruta individual do item
        (od.quantity * od.unit_price) as item_gross_value,
        -- Frete total do cabeçalho
        coalesce(o.freight_value, 0.0) as total_order_freight,
        -- Soma da venda bruta de todos os itens do pedido
        sum(od.quantity * od.unit_price) over (partition by od.order_id) as total_order_gross_value,
        -- Contagem de itens no pedido (para rateio alternativo em caso de valor zero)
        count(od.product_id) over (partition by od.order_id) as total_items_count
    from order_details od
    left join orders o on od.order_id = o.order_id
),

allocated as (
    select
        order_id,
        product_id,
        unit_price,
        quantity,
        discount,
        item_gross_value,
        total_order_freight,
        total_order_gross_value,
        -- Lógica de alocação de frete (RF-03)
        case
            when total_order_gross_value = 0.0 then
                total_order_freight / total_items_count
            else
                total_order_freight * (item_gross_value / total_order_gross_value)
        end as allocated_freight
    from joined
)

select * from allocated

-- transform/models/intermediate/int_orders_calculated.sql
--
-- Riscos:
-- 1. Pedidos não enviados (shipped_date nulo) resultando em valores nulos de lead time e desvio, que precisam ser tratados na camada de negócio.
-- 2. Erros de digitação nas datas da origem (ex: shipped_date menor que order_date) que distorçam as estatísticas logísticas (resolvido com flag de consistência).
-- 3. Uso incorreto de tipos de dados de data no DuckDB que possa alterar a precisão do cálculo de diferença em dias.
--
-- Ambiguidades:
-- 1. Se a métrica de desvio de entrega (delivery_deviation_days) deve considerar apenas valores positivos como atraso ou se valores negativos (adiantamentos) também são de interesse.
-- 2. Se o desvio de entrega de pedidos não enviados cuja data requerida já passou deve ser calculado com base na data atual do sistema (execução).

with orders as (
    select * from {{ ref('stg_orders') }}
),

calculated as (
    select
        *,
        -- Lead time de envio em dias (data de envio - data do pedido)
        date_diff('day', order_date, shipped_date) as lead_time_days,
        
        -- Prazo contratado de entrega em dias (data limite - data do pedido)
        date_diff('day', order_date, required_date) as required_delivery_days,
        
        -- Desvio de entrega (data de envio - data limite). Se positivo, representa atraso.
        date_diff('day', required_date, shipped_date) as delivery_deviation_days,
        
        -- Validação de inconsistência temporal de datas (RF-08)
        case 
            when shipped_date < order_date then false
            when required_date < order_date then false
            else true
        end as is_date_consistent
    from orders
)

select * from calculated

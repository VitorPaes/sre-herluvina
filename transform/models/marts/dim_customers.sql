-- transform/models/marts/dim_customers.sql
--
-- Riscos:
-- 1. Clientes com múltiplos endereços de entrega nas ordens causando duplicação de registros de dimensão (resolvido com row_number).
-- 2. Nome do cliente inconsistente se houver pequenas variações de grafia no campo ship_name na origem.
-- 3. Erros de mapeamento geográfico se a coluna ship_region contiver dados nulos (tratado com valor padrão 'Desconhecido').
--
-- Ambiguidades:
-- 1. Se o nome oficial do cliente deve ser extraído de uma tabela de cadastro separada futuramente ou se o ship_name histórico é suficiente.
-- 2. Se a região do cliente deve ser normalizada de acordo com um padrão de abreviação internacional.

with orders as (
    select 
        customer_id,
        ship_name,
        ship_address,
        ship_city,
        ship_region,
        ship_postal_code,
        ship_country,
        order_date,
        row_number() over (
            partition by customer_id 
            order by order_date desc, order_id desc
        ) as rn
    from {{ ref('stg_orders') }}
    where customer_id is not null
),

unique_customers as (
    select
        customer_id,
        ship_name as customer_name,
        ship_address as address,
        ship_city as city,
        coalesce(nullif(trim(ship_region), ''), 'Sem Região') as region,
        ship_postal_code as postal_code,
        ship_country as country
    from orders
    where rn = 1
)

select * from unique_customers

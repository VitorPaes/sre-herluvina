-- transform/models/staging/stg_orders.sql
--
-- Riscos:
-- 1. Falha de conversão de data (cast para DATE) se o formato dos CSVs no MinIO sofrer alterações ou vier em formato regional inválido.
-- 2. Valores vazios na coluna shipped_date gerando erros de conversão se não mapeados para NULL antes do cast.
-- 3. Valores nulos ou não numéricos na coluna freight gerando falha de parse matemático.
--
-- Ambiguidades:
-- 1. Se chaves de negócios como customer_id ou employee_id ausentes devem ser removidas da staging ou tratadas nas camadas superiores.
-- 2. Se a conversão automática do DuckDB assume timezone UTC por padrão ao ler strings de datas.

with source as (
    select * from {{ source('minio', 'northwind_orders') }}
),

staged as (
    select
        cast(order_id as integer) as order_id,
        cast(customer_id as varchar) as customer_id,
        cast(employee_id as integer) as employee_id,
        cast(order_date as date) as order_date,
        cast(required_date as date) as required_date,
        cast(shipped_date as date) as shipped_date,
        cast(ship_via as integer) as shipper_id,
        cast(freight as double) as freight_value,
        cast(ship_name as varchar) as ship_name,
        cast(ship_address as varchar) as ship_address,
        cast(ship_city as varchar) as ship_city,
        cast(ship_region as varchar) as ship_region,
        cast(ship_postal_code as varchar) as ship_postal_code,
        cast(ship_country as varchar) as ship_country
    from source
)

select * from staged

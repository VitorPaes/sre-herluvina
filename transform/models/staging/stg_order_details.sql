-- transform/models/staging/stg_order_details.sql
--
-- Riscos:
-- 1. Preços unitários ou descontos inválidos (ex: negativos) gerando distorções de cálculo financeiro nas tabelas superiores.
-- 2. Descontos representados em percentual (> 100% ou < 0%) que violem regras de integridade de negócios.
-- 3. Quantidade vendida igual ou menor que zero distorcendo as contagens volumétricas reais de itens.
--
-- Ambiguidades:
-- 1. Se registros com o mesmo order_id e product_id devem ser agregados ou reportados como violação de chave primária composta.
-- 2. Se o unit_price nesta tabela já possui impostos embutidos ou se representa o valor líquido bruto.

with source as (
    select * from {{ source('minio', 'northwind_order_details') }}
),

staged as (
    select
        cast(order_id as integer) as order_id,
        cast(product_id as integer) as product_id,
        cast(unit_price as double) as unit_price,
        cast(quantity as integer) as quantity,
        cast(discount as double) as discount
    from source
)

select * from staged

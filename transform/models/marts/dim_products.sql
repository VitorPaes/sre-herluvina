-- transform/models/marts/dim_products.sql
--
-- Riscos:
-- 1. Classificação incorreta de novos IDs de produtos se o intervalo estipulado de categorias mudar na origem.
-- 2. Conflito de nomes se o catálogo real contiver nomes duplicados para IDs distintos de produtos.
-- 3. IDs negativos ou inválidos sendo aceitos e categorizados na regra genérica sem disparar erros.
--
-- Ambiguidades:
-- 1. Se a categorização determinística baseada em faixas de ID (ex: 1-15 para Bebidas) atende permanentemente ao negócio.
-- 2. Se a unidade de medida do produto ou embalagem deve ser incluída como metadado na dimensão.

with order_details as (
    select distinct product_id from {{ ref('stg_order_details') }}
    where product_id is not null
),

categorized as (
    select
        product_id,
        'Produto #' || cast(product_id as varchar) as product_name,
        case
            when product_id between 1 and 15 then 'Bebidas'
            when product_id between 16 and 30 then 'Condimentos'
            when product_id between 31 and 45 then 'Confeitos'
            when product_id between 46 and 60 then 'Laticínios'
            when product_id between 61 and 75 then 'Grãos/Cereais'
            else 'Frutos do Mar e Outros'
        end as category_name
    from order_details
)

select * from categorized

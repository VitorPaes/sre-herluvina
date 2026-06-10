-- transform/models/marts/dim_shippers.sql
--
-- Riscos:
-- 1. IDs de transportadora órfãos na fato se houver shippers_id nulo nas ordens.
-- 2. Mudança silenciosa nos IDs de transportadoras no ERP que faça com que a United Package receba o nome de Speedy Express.
-- 3. Inclusão de transportadoras sazonais temporárias que fiquem categorizadas como 'Auxiliar' de forma permanente.
--
-- Ambiguidades:
-- 1. Se os nomes de transportadorasSpeedy Express, United Package e Federal Shipping mapeiam exatamente aos IDs 1, 2 e 3 na base real.
-- 2. Se a dimensão deve conter as taxas contratuais de frete básico por transportadora.

with orders as (
    select distinct shipper_id from {{ ref('stg_orders') }}
    where shipper_id is not null
),

shippers as (
    select
        shipper_id,
        case
            when shipper_id = 1 then 'Speedy Express'
            when shipper_id = 2 then 'United Package'
            when shipper_id = 3 then 'Federal Shipping'
            else 'Transportadora Auxiliar #' || cast(shipper_id as varchar)
        end as shipper_name
    from orders
)

select * from shippers

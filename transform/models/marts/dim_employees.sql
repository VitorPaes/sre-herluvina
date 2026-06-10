-- transform/models/marts/dim_employees.sql
--
-- Riscos:
-- 1. IDs de funcionários nulos gerando chaves órfãs na tabela de fatos.
-- 2. Falta de dados demográficos de funcionários limitando a análise regional de vendas.
-- 3. Identificação imprecisa de funcionários se houver reuso de IDs antigos de ex-funcionários na origem.
--
-- Ambiguidades:
-- 1. Se a produtividade do funcionário deve levar em conta o cargo ou a filial de trabalho.
-- 2. Se a grafia fictícia do nome (ex: Funcionário #ID) atende aos requisitos de privacidade de dados locais.

with orders as (
    select distinct employee_id from {{ ref('stg_orders') }}
    where employee_id is not null
),

employees as (
    select
        employee_id,
        'Funcionário #' || cast(employee_id as varchar) as employee_name,
        -- Atribuição fictícia de cargos para enriquecimento analítico (RF-07)
        case 
            when employee_id % 3 = 0 then 'Representante de Vendas Sênior'
            when employee_id % 3 = 1 then 'Representante de Vendas Pleno'
            else 'Coordenador de Vendas'
        end as job_title
    from orders
)

select * from employees

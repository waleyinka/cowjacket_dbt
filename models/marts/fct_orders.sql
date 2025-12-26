{{ 
  config(
    materialized = 'table',
    schema = 'ANALYTICS_MARTS',
    enabled = target.name != 'dev'
  ) 
}}

with base as (

    select
        order_id,
        customer_id,
        order_date,
        quantity,
        line_total
    from {{ ref('int_customer_orders') }}

),

aggregated as (

    select
        order_id,
        customer_id,
        order_date,
        sum(line_total) as order_revenue,
        sum(quantity) as total_items,
        count(*) as order_line_count,
        avg(line_total) as avg_line_value
    from base
    group by
        order_id,
        customer_id,
        order_date

)

select *
from aggregated
with line_level as (

    select
        order_id,
        sum(line_total) as line_revenue
    from {{ ref('int_customer_orders') }}
    group by order_id

),

order_level as (

    select
        order_id,
        order_revenue
    from {{ ref('fct_orders') }}

)

select
    o.order_id,
    o.order_revenue,
    l.line_revenue
from order_level o
join line_level l
  on o.order_id = l.order_id
where o.order_revenue != l.line_revenue
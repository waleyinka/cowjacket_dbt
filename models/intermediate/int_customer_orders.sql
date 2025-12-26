with orders as (

    select
        order_id,
        customer_id,
        order_date,
        total_amount
    from {{ ref('stg_orders') }}

),

order_items as (

    select
        order_item_id,
        order_id,
        product_id,
        quantity,
        line_total
    from {{ ref('stg_order_items') }}

),

joined as (

    select
        oi.order_item_id,
        o.order_id,
        o.customer_id,
        o.order_date,
        o.total_amount,
        oi.product_id,
        oi.quantity,
        oi.line_total
    from order_items oi
    join orders o
        on oi.order_id = o.order_id

)

select *
from joined
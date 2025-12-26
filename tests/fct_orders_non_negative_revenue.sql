select *
from {{ ref('fct_orders') }}
where order_revenue < 0
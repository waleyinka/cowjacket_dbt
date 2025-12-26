with source as (

    select *
    from {{ source('raw', 'orders') }}

),

renamed as (

    select
        order_id,
        customer_id,
        order_date,
        total_amount
    from source

)

select *
from renamed
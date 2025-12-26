with source as (

    select *
    from {{ source('raw', 'loyalty_points') }}

),

renamed as (

    select
        loyalty_id,
        customer_id,
        points_earned,
        transaction_date,
        source as points_source
    from source

)

select *
from renamed
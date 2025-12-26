with source as (

    select *
    from {{ source('raw', 'customers') }}

),

renamed as (

    select
        customer_id,
        full_name,
        email,
        join_date
    from source

)

select *
from renamed
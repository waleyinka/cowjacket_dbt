with source as (

    select *
    from {{ source('raw', 'products') }}

),

renamed as (

    select
        product_id,
        product_name,
        category,
        price
    from source

)

select *
from renamed
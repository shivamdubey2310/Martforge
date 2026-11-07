with source as (
    select * from {{ source('tpch', 'orders') }}
),

renamed as (
    select
        o_orderkey as order_id,
        o_custkey as customer_id,
        o_orderstatus as order_status_code,
        cast(o_totalprice as numeric(12, 2)) as total_order_amount,
        cast(o_orderdate as date) as order_date,
        o_orderpriority as order_priority,
        o_clerk as clerk_name,
        o_shippriority as ship_priority,
        o_comment as comment,
        _loaded_at
    from source
)

select * from renamed

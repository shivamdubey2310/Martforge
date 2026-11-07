with source as (
    select * from {{ source('tpch', 'customers') }}
),

renamed as (
    select
        c_custkey as customer_id,
        c_nationkey as nation_id,
        c_name as customer_name,
        c_address as address,
        c_phone as phone_number,
        cast(c_acctbal as numeric(12, 2)) as account_balance,
        c_mktsegment as market_segment,
        c_comment as comment,
        _loaded_at
    from source
)

select * from renamed

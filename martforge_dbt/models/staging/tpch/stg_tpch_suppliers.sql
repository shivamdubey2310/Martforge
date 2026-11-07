with source as (
    select * from {{ source('tpch', 'supplier') }}
),

renamed as (
    select
        s_suppkey as supplier_id,
        s_nationkey as nation_id,
        s_name as supplier_name,
        s_address as address,
        s_phone as phone_number,
        cast(s_acctbal as numeric(12, 2)) as account_balance,
        s_comment as comment,
        _loaded_at
    from source
)

select * from renamed

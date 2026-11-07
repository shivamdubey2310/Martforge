with source as (
    select * from {{ source('tpch', 'lineitem') }}
),

renamed as (
    select
        {{ dbt_utils.generate_surrogate_key(['l_orderkey', 'l_linenumber']) }} as order_item_id,
        l_orderkey as order_id,
        l_partkey as part_id,
        l_suppkey as supplier_id,
        l_linenumber as line_number,
        cast(l_quantity as numeric(12, 2)) as quantity,
        cast(l_extendedprice as numeric(12, 2)) as gross_item_sales_amount,
        cast(l_discount as numeric(12, 4)) as discount_percentage,
        cast(l_tax as numeric(12, 4)) as tax_percentage,
        l_returnflag as return_flag,
        l_linestatus as line_status_code,
        cast(l_shipdate as date) as ship_date,
        cast(l_commitdate as date) as commit_date,
        cast(l_receiptdate as date) as receipt_date,
        l_shipinstruct as shipping_instructions,
        l_shipmode as shipping_mode,
        l_comment as comment,
        _loaded_at
    from source
)

select * from renamed

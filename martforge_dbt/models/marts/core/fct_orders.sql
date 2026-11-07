{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}

with orders as (
    select * from {{ ref('stg_tpch_orders') }}
    {% if is_incremental() %}
        -- Only process records that arrived since the latest loaded record in the existing table
        where _loaded_at > (select coalesce(max(_loaded_at), '1970-01-01') from {{ this }})
    {% endif %}
),

order_summary as (
    select * from {{ ref('int_order_items_summary') }}
),

final as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.order_status_code,
        o.order_priority,
        o.clerk_name,
        o.ship_priority,
        o.total_order_amount,
        coalesce(s.total_line_items, 0) as total_line_items,
        coalesce(s.total_quantity, 0) as total_quantity,
        coalesce(s.gross_sales_amount, 0) as gross_sales_amount,
        coalesce(s.net_sales_amount, 0) as net_sales_amount,
        coalesce(s.total_taxed_amount, 0) as total_taxed_amount,
        greatest(o._loaded_at, coalesce(s.max_item_loaded_at, o._loaded_at)) as _loaded_at
    from orders o
    left join order_summary s
        on o.order_id = s.order_id
)

select * from final

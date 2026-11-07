{{
    config(
        materialized='incremental',
        unique_key='order_item_id',
        incremental_strategy='merge',
        on_schema_change='fail'
    )
}}

with line_items as (
    select * from {{ ref('stg_tpch_line_items') }}
    {% if is_incremental() %}
        where _loaded_at > (select coalesce(max(_loaded_at), '1970-01-01') from {{ this }})
    {% endif %}
),

orders as (
    select
        order_id,
        customer_id,
        order_date,
        order_status_code
    from {{ ref('stg_tpch_orders') }}
),

final as (
    select
        li.order_item_id,
        li.order_id,
        li.line_number,
        o.customer_id,
        li.supplier_id,
        li.part_id,
        o.order_date,
        o.order_status_code,
        li.return_flag,
        li.line_status_code,
        li.ship_date,
        li.commit_date,
        li.receipt_date,
        li.shipping_mode,
        li.quantity,
        li.gross_item_sales_amount,
        li.discount_percentage,
        li.tax_percentage,
        round(li.gross_item_sales_amount * (1 - li.discount_percentage), 2) as net_item_sales_amount,
        round(li.gross_item_sales_amount * (1 - li.discount_percentage) * (1 + li.tax_percentage), 2) as total_item_amount,
        li._loaded_at
    from line_items li
    inner join orders o
        on li.order_id = o.order_id
)

select * from final

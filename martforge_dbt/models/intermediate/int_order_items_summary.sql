with line_items as (
    select * from {{ ref('stg_tpch_line_items') }}
),

aggregated as (
    select
        order_id,
        count(order_item_id) as total_line_items,
        sum(quantity) as total_quantity,
        sum(gross_item_sales_amount) as gross_sales_amount,
        sum(gross_item_sales_amount * (1 - discount_percentage)) as net_sales_amount,
        sum(gross_item_sales_amount * (1 - discount_percentage) * (1 + tax_percentage)) as total_taxed_amount,
        max(_loaded_at) as max_item_loaded_at
    from line_items
    group by 1
)

select * from aggregated

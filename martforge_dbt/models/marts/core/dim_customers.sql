with enriched_customers as (
    select * from {{ ref('int_customers_enriched') }}
),

final as (
    select
        customer_id,
        customer_name,
        address,
        nation_name,
        phone_number,
        account_balance,
        market_segment,
        customer_comment
    from enriched_customers
)

select * from final

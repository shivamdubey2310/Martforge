with customers as (
    select * from {{ ref('stg_tpch_customers') }}
),

nations as (
    select * from {{ ref('stg_tpch_nations') }}
),

joined as (
    select
        c.customer_id,
        c.customer_name,
        c.address,
        c.phone_number,
        c.account_balance,
        c.market_segment,
        c.comment as customer_comment,
        n.nation_id,
        n.nation_name,
        n.region_id,
        c._loaded_at
    from customers c
    left join nations n
        on c.nation_id = n.nation_id
)

select * from joined

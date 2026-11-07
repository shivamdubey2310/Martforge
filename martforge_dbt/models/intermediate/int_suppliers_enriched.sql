with suppliers as (
    select * from {{ ref('stg_tpch_suppliers') }}
),

nations as (
    select * from {{ ref('stg_tpch_nations') }}
),

joined as (
    select
        s.supplier_id,
        s.supplier_name,
        s.address,
        s.phone_number,
        s.account_balance,
        s.comment as supplier_comment,
        n.nation_id,
        n.nation_name,
        n.region_id,
        s._loaded_at
    from suppliers s
    left join nations n
        on s.nation_id = n.nation_id
)

select * from joined

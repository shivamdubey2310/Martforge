

with enriched_suppliers as (
    select * from {{ ref('int_suppliers_enriched') }}
),

final as (
    select
        supplier_id,
        supplier_name,
        address,
        nation_name,
        phone_number,
        account_balance,
        supplier_comment
    from enriched_suppliers
)

select * from final


-- slim ci test trigger

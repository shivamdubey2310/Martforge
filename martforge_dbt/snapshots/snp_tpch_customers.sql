{% snapshot snp_tpch_customers %}

{{
    config(
      target_database=target.database,
      target_schema=generate_schema_name('snapshots'),
      unique_key='customer_id',
      strategy='check',
      check_cols=['address', 'phone_number', 'account_balance', 'market_segment']
    )
}}

select
    customer_id,
    nation_id,
    customer_name,
    address,
    phone_number,
    account_balance,
    market_segment,
    comment,
    _loaded_at
from {{ ref('stg_tpch_customers') }}

{% endsnapshot %}

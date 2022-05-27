 {{
  config(
        alias='trades',
        materialized ='incremental',
        file_format ='delta',
        incremental_strategy='merge'
  )
}}

SELECT 
    'ethereum' as blockchain,
    evt_tx_hash as tx_hash,
    evt_block_time AS block_time,
    price / power(10, decimals) * p.price AS amount_usd,
    price / power(10, decimals) AS amount,
    price AS amount_raw,
    terc20.symbol as token_symbol,
    currency as token_address,
    maker,
    taker
FROM {{ source('looksrare_ethereum','looksrareexchange_evt_takerask') }}
UNION ALL
SELECT 
    'ethereum' as blockchain,
    evt_tx_hash as tx_hash,
    evt_block_time AS block_time,
    price / power(10, decimals) * p.price AS amount_usd,
    price / power(10, decimals) AS amount,
    price AS amount_raw,
    terc20.symbol as token_symbol,
    currency as token_address,
    maker,
    taker
FROM {{ source('looksrare_ethereum','looksrareexchange_evt_takerbid') }}
LEFT JOIN tokens_ethereum.erc20 terc20 ON terc20.contract_address = currency
LEFT JOIN {{ source('prices', 'usd') }} p ON p.minute = date_trunc('minute', evt_block_time)
      AND p.blockchain = 'ethereum'
      AND p.contract_address = wam.token_address
  AND maker != taker
  {% if is_incremental() %}
  -- this filter will only be applied on an incremental run
  WHERE evt_block_time > (select max(block_time) from {{ this }})
  {% endif %} 
{% macro alter_tblproperties_looksrare_trades() -%}
{%- if target.name == 'prod'-%}
ALTER VIEW looksrare.trades SET TBLPROPERTIES('dune.public'='true',
                                                    'dune.data_explorer.blockchains'='["ethereum"]',
                                                    'dune.data_explorer.category'='abstraction',
                                                    'dune.data_explorer.abstraction.type'='project',
                                                    'dune.data_explorer.abstraction.name'='looksrare',
                                                    'dune.data_explorer.contributors'='["soispoke"]');
{%- else -%}
{%- endif -%}
{%- endmacro %}

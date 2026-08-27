# Datasets — Olist Brazilian E-Commerce Public Dataset

Fonte: Olist, publicado no Kaggle (https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
Licença: CC BY-NC-SA 4.0 — uso educacional, com atribuição, sem fins comerciais.
~100 mil pedidos reais de 2016 a 2018, anonimizados.

| Arquivo | Linhas | Usado pela DAG principal? |
|---|---|---|
| olist_orders_dataset.csv | 99 441 | sim → BRONZE_ORDERS |
| olist_order_items_dataset.csv | 112 650 | sim → BRONZE_ORDER_ITEMS |
| olist_customers_dataset.csv | 99 441 | sim → BRONZE_CUSTOMERS |
| olist_products_dataset.csv | 32 951 | sim → BRONZE_PRODUCTS |
| olist_sellers_dataset.csv | 3 095 | sim → BRONZE_SELLERS |
| olist_order_payments_dataset.csv | 103 886 | sim → BRONZE_PAYMENTS |
| olist_order_reviews_dataset.csv | 99 224 | sim → BRONZE_REVIEWS |
| olist_geolocation_dataset.csv | 1 000 163 | não (61 MB; não entra em nenhuma métrica) |
| product_category_name_translation.csv | 71 | não (usado só pelo projeto dbt, se você quiser estender) |

A DAG lê os arquivos direto da URL raw do GitHub (`BASE_URL` em `dags/pipeline_olist.py`).
Se você fez fork, troque `rafsp` pelo seu usuário na `BASE_URL` — ou deixe como está: o repositório original é público.

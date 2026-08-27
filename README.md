# Data Integration e Pipelines — Aula 4 · Apache Airflow, Kubernetes e Orquestração

FIAP · MBA Data Engineering · Prof. Rafael S Novo Pereira

Última aula da disciplina (16 h): **Databricks (Aula 1) → Snowflake (Aula 2) → dbt (Aula 3) → Airflow (Aula 4)**.
Aqui o pipeline Olist roda de ponta a ponta sem ninguém apertar play: GitHub → Bronze → Silver → Gold → quality checks,
orquestrado pelo Airflow 3.3 no Astro (Astronomer), com cada task num pod Kubernetes.

## O que tem neste repositório

| Caminho | O que é |
|---|---|
| `datasets/` | 8 CSVs do Olist (Brazilian E-Commerce Public Dataset, Kaggle, CC BY-NC-SA 4.0). A DAG usa 7. |
| `dags/pipeline_olist.py` | **DAG principal do lab** — `pipeline_olist_completo`. 6 tasks, Python puro, schema `OLIST_LAB.PUBLIC`. |
| `dags/demo_backfill.py` | Demo da aula: `schedule="@daily"` + task que lê `logical_date`. Backfill pela UI do Airflow 3. |
| `dags/pipeline_olist_dbt.py` | **Desafio Ouro** — `pipeline_olist_dbt`: o projeto dbt da Aula 3 orquestrado via Cosmos (10 tasks, lineage na UI). Schemas `BRONZE/STAGING/SILVER/GOLD`. |
| `dags/dbt/olist/` | Projeto dbt da Aula 3 (staging → intermediate → marts). |
| `setup/01_snowflake_service_user.sql` | Plano B da Etapa 13: usuário de serviço com par de chaves (MFA). |
| `Dockerfile`, `requirements.txt`, `packages.txt` | Imagem do Astro: Runtime 3.3-6 (Airflow 3.3.1) + venv do dbt + Cosmos 1.15.1. |

## A DAG principal

```
inicio → download_and_load_bronze → transform_silver → build_gold → quality_checks → fim
              7 tabelas BRONZE_*      SILVER_PEDIDOS     2 tabelas GOLD_*   4 regras
              ~59 s                   ~7 s               ~6 s               ~5 s
```

- **Bronze**: `pandas.read_csv` da URL + `write_pandas(overwrite=True)`. Download e load na mesma task de propósito
  (no Astro cada task é um pod isolado — `/tmp` de uma task não existe para a próxima).
- **Silver**: `CREATE OR REPLACE TABLE SILVER_PEDIDOS` — pedido + cliente + soma dos pagamentos + soma dos itens, com tipos.
- **Gold**: `GOLD_RECEITA_ESTADO` (pedidos, receita, ticket médio, dias de entrega, % atraso por UF) e `GOLD_VENDAS_MENSAL`.
- **Quality**: Gold não vazia · sem receita negativa · `PCT_ATRASO` em [0, 100] · soma de pedidos na Gold == pedidos na Silver.
  Qualquer falha derruba a task e `fim` não roda.
- **Resiliência** (`default_args`): `retries=2`, `retry_delay=1 min`, `execution_timeout=30 min`.
- **Idempotência**: rodar duas vezes produz o mesmo resultado.

Resultado esperado (`SELECT * FROM OLIST_LAB.PUBLIC.GOLD_RECEITA_ESTADO ORDER BY RECEITA_TOTAL DESC LIMIT 3`):

| ESTADO | TOTAL_PEDIDOS | RECEITA_TOTAL | TICKET_MEDIO | DIAS_ENTREGA_MEDIO | PCT_ATRASO |
|---|---|---|---|---|---|
| SP | 41746 | 5998226.96 | 143.69 | 8.7 | 5.72 |
| RJ | 12852 | 2144379.69 | 166.85 | 15.2 | 12.95 |
| MG | 11635 | 1872257.26 | 160.92 | 11.9 | 5.48 |

## Como rodar (resumo — o passo a passo com screenshots está no Guia do Aluno)

1. Conta no Astro (trial 14 dias, sem cartão) → Deployment com template **Development**, **Google Cloud us-central1** (Azure e AWS ficaram presos em CREATING na preparação da aula, ago/2026).
2. Astro IDE → conectar este repositório (fork) → **Deploy Project**. Aguarde `HEALTHY`.
3. Airflow → Admin → Connections → `snowflake_default` (Etapa 13). Senha **ou** chave privada (`private_key_content`).
4. Trigger em `pipeline_olist_completo` → 6 tasks verdes → `SELECT` na Gold no Snowflake.

## Plano C — rodar local com o Astro CLI (se o Astro não criar o Deployment)

Docker Desktop aberto → `git clone` do seu fork → `astro dev start` na raiz → http://localhost:8080 (admin/admin).
Mesmas DAGs, mesma Connection, mesmos desafios. Diferença: tasks rodam no mesmo container (sem Kubernetes).
Detalhes no Apêndice do Guia do Aluno.

## Avisos que evitam 40 minutos perdidos

- **MFA no Snowflake** (marco final ago–out/2026): usuários humanos com senha precisam de MFA. Se a Connection falhar
  por MFA, use `setup/01_snowflake_service_user.sql` (usuário `TYPE = SERVICE` + par de chaves) — Etapa 13B do Guia.
- **Trial do Snowflake** dura 30 dias; **trial do Astro** dura 14. Crie o Astro no dia da aula, não antes.
- **Account Identifier** no formato `ORG-CONTA` (ex.: `ABCDEFG-XY12345`), sem `.snowflakecomputing.com`.

## Desafios

| Nível | Entrega | Vale |
|---|---|---|
| 🥉 Bronze (obrigatório) | Grid com 6 tasks verdes · `SELECT` na Gold · log da Bronze com as 7 tabelas | até 7,0 |
| 🥈 Prata (escolha 1 ou 2) | **A** quality check que falha de verdade + log + explicação · **B** `@daily` + `logical_date` + backfill de 3 dias · **C** alerta (Astro Alerts ou `on_failure_callback`) disparado | +1,5 cada |
| 🥇 Ouro (bônus) | `pipeline_olist_dbt` verde com lineage na UI **ou** Bronze particionada por `logical_date` | +1,0 (teto 10) |

Entrega individual: PDF com screenshots (seu usuário visível) + link do seu fork.

## Verificação feita antes da aula

As três DAGs foram carregadas com `DagBag` no Airflow **3.2.2** e no **3.3.1** (o do Astro Runtime 3.3-6; constraints oficiais, Python 3.12), sem import errors:
`pipeline_olist_completo` (6 tasks), `demo_backfill` (1), `pipeline_olist_dbt` (10, via `dbt ls` com dbt-core 1.12.3).
`astronomer-cosmos==1.12.1` não importa no Airflow 3.2+ (import circular) — por isso o pin é **1.15.1**.
O Astro não aceita deploy de imagem com runtime inferior ao do Deployment: trials criados em ago/2026 nascem em 3.3-6, e o Dockerfile acompanha.

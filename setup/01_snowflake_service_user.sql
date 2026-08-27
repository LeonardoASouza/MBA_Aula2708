-- =====================================================================
-- Aula 4 · Plano B para a Etapa 13 (MFA do Snowflake)
-- Cria um USUÁRIO DE SERVIÇO com autenticação por par de chaves.
-- Rode como ACCOUNTADMIN, em Projects > SQL File, no SEU trial.
--
-- Antes: gere o par de chaves no seu computador (ver Guia, Etapa 13B):
--   openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out rsa_key.p8 -nocrypt
--   openssl rsa -in rsa_key.p8 -pubout -out rsa_key.pub
-- Abra rsa_key.pub, copie SOMENTE o miolo (sem as linhas BEGIN/END, sem quebras)
-- e cole no RSA_PUBLIC_KEY abaixo.
-- =====================================================================

USE ROLE ACCOUNTADMIN;

-- 1. Role e warehouse que o Airflow vai usar (mínimo necessário)
CREATE ROLE IF NOT EXISTS AIRFLOW_ROLE;
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
  WAREHOUSE_SIZE = XSMALL AUTO_SUSPEND = 60 AUTO_RESUME = TRUE;
CREATE DATABASE IF NOT EXISTS OLIST_LAB;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE AIRFLOW_ROLE;
GRANT USAGE, OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE AIRFLOW_ROLE;
GRANT ALL PRIVILEGES ON DATABASE OLIST_LAB TO ROLE AIRFLOW_ROLE;
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE OLIST_LAB TO ROLE AIRFLOW_ROLE;
GRANT ALL PRIVILEGES ON FUTURE SCHEMAS IN DATABASE OLIST_LAB TO ROLE AIRFLOW_ROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN DATABASE OLIST_LAB TO ROLE AIRFLOW_ROLE;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN DATABASE OLIST_LAB TO ROLE AIRFLOW_ROLE;
GRANT ALL PRIVILEGES ON ALL VIEWS IN DATABASE OLIST_LAB TO ROLE AIRFLOW_ROLE;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN DATABASE OLIST_LAB TO ROLE AIRFLOW_ROLE;

-- 2. Usuário de serviço: TYPE = SERVICE não é humano, portanto não entra na
--    obrigatoriedade de MFA. Sem senha: só chave.
CREATE USER IF NOT EXISTS AIRFLOW_SVC
  TYPE = SERVICE
  DEFAULT_ROLE = AIRFLOW_ROLE
  DEFAULT_WAREHOUSE = COMPUTE_WH
  DEFAULT_NAMESPACE = OLIST_LAB.PUBLIC
  COMMENT = 'Usuario de servico do Airflow (Aula 4 FIAP)';

GRANT ROLE AIRFLOW_ROLE TO USER AIRFLOW_SVC;

-- 3. Chave pública (cole o miolo do rsa_key.pub entre as aspas, numa linha só)
ALTER USER AIRFLOW_SVC SET RSA_PUBLIC_KEY = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...COLE_AQUI...';

-- 4. Conferência: deve mostrar RSA_PUBLIC_KEY_FP preenchido
DESC USER AIRFLOW_SVC;

# Arquivos que faltam no rafsp/MBA_Aula2708 (copiar por cima, preservando as pastas)

| Caminho | Por quê |
|---|---|
| dags/dbt/olist/** | Sem isso, pipeline_olist_dbt fica em Import Error ("Could not find dbt_project.yml") |
| dags/pipeline_olist.py | BASE_URL agora aponta para rafsp/MBA_Aula2708 (antes: Aula3006_MBA) |
| dags/pipeline_olist_dbt.py | idem |
| .dockerignore | Deixa os 121 MB de CSV fora da imagem Docker |
| .gitignore | Bloqueia commit de chaves (*.p8) e de airflow_settings.yaml |
| .astro/config.yaml | Necessário para `astro dev start` (plano C) |
| airflow_settings.yaml.example | Connection pré-configurada no plano C |
| tests/dags/test_dag_integrity.py | `astro dev pytest` |
| datasets/README.md | Licença CC BY-NC-SA do Olist e tabela dos 9 arquivos |
| README.md | Cita o repositório MBA_Aula2708 |

Atenção: arquivos que começam com ponto (.astro, .dockerignore, .gitignore) ficam ocultos no Explorer/Finder — confira com `ls -a` ou `git status` antes do push.

"""Roda com `astro dev pytest` (plano C) ou `pytest tests/`.
Garante que as 3 DAGs da Aula 4 carregam sem erro e com a estrutura esperada."""
import os
from pathlib import Path

import pytest

DAGS = Path(__file__).resolve().parents[2] / "dags"


@pytest.fixture(scope="session")
def dagbag():
    from airflow.dag_processing.dagbag import DagBag
    return DagBag(dag_folder=str(DAGS), safe_mode=False)


def test_sem_import_errors(dagbag):
    assert dagbag.import_errors == {}, dagbag.import_errors


def test_tres_dags(dagbag):
    assert {"pipeline_olist_completo", "demo_backfill", "pipeline_olist_dbt"} <= set(dagbag.dags)


def test_pipeline_principal(dagbag):
    dag = dagbag.dags["pipeline_olist_completo"]
    ids = [t.task_id for t in dag.topological_sort()]
    assert ids == ["inicio", "download_and_load_bronze", "transform_silver", "build_gold", "quality_checks", "fim"]
    assert dag.catchup is False
    for t in dag.tasks:
        assert t.retries == 2

#!/bin/bash -e

source /srv/venv/bin/activate

exec jupyter-lab \
  --allow-root --no-browser \
  --ip="0.0.0.0" \
  --port="${LAB_PORT:-8080}" \
  --notebook-dir="${NOTEBOOKS_DIR}" \
  --NotebookApp.token='' \
  --NotebookApp.password='' \
  "$@"

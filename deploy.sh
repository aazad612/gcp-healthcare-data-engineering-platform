gcloud builds submit \
  --config=ci/cloudbuild-sql-ops.yaml \
  --substitutions=_OPS_PROJECT="prj-lbd-shared-np",_OPS_ENV="np",_SOURCE_DIR="src/ops",_FILES="standards_definition.sql"



gcloud builds submit data-platform \
  --config data-platform/ci/cloudbuild-sql-data.yaml \
  --project prj-shared-orch-np \
  --substitutions=_TARGET_PROJECT="prj-clin-syn-np",_TARGET_ENV="dev",_SOURCE_DIR="src/clinical/synthea/bronze",_OPS_PROJECT="prj-shared-orch-np",_FILES="patients.sql"
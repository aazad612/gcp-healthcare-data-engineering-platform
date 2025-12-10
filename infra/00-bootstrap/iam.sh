

gcloud projects add-iam-policy-binding prj-net-common-pd-host \
  --member="serviceAccount:johneysadmin@johneysadminproject.iam.gserviceaccount.com" \
  --role="roles/iap.tunnelResourceAccessor"


gcloud projects add-iam-policy-binding prj-net-common-pd-host \
  --member="serviceAccount:johneysadmin@johneysadminproject.iam.gserviceaccount.com" \
  --role="roles/compute.osAdminLogin"




gcloud projects add-iam-policy-binding prj-net-common-pd-host \
  --member="user:johneyaazad@gmail.com" \
  --role="roles/iap.tunnelResourceAccessor"


gcloud projects add-iam-policy-binding prj-net-common-pd-host \
  --member="user:johneyaazad@gmail.com" \
  --role="roles/compute.osAdminLogin"


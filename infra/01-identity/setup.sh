#!/usr/bin/env bash
set -euo pipefail

### --- CONFIG --- ###
ORG_ID="9139207439"
DEPLOY_PROJECT_ID="johneysadminproject"

# Cloud Identity super admin (used only inside Terraform provider impersonation)
ADMIN_USER="aazads@aazads.us"

# Deployment / automation service account
DEPLOY_SA_NAME="johneysadmin"
DEPLOY_SA_EMAIL="${DEPLOY_SA_NAME}@${DEPLOY_PROJECT_ID}.iam.gserviceaccount.com"

# Where to drop the JSON key for Terraform
SA_KEY_FILE="${HOME}/.config/gcloud/${DEPLOY_SA_NAME}-dwd.json"

echo "Using project:           ${DEPLOY_PROJECT_ID}"
echo "Org ID:                  ${ORG_ID}"
echo "Admin (impersonation):   ${ADMIN_USER}"
echo "Service account email:   ${DEPLOY_SA_EMAIL}"
echo "Key file output:         ${SA_KEY_FILE}"
echo

### 1. Set the active project
# gcloud config set project "${DEPLOY_PROJECT_ID}"

### 2. Enable needed APIs in the SA project
# Admin SDK is needed for Workspace / Cloud Identity directory,
# IAM is always needed for SA / keys etc.
# gcloud services enable \
#   iam.googleapis.com \
#   admin.googleapis.com

# echo
# echo "✅ Enabled IAM + Admin SDK APIs"

# ### 3. Ensure the service account exists
# if gcloud iam service-accounts describe "${DEPLOY_SA_EMAIL}" \
#     --project "${DEPLOY_PROJECT_ID}" >/dev/null 2>&1; then
#   echo "✅ Service account already exists: ${DEPLOY_SA_EMAIL}"
# else
#   echo "➡ Creating service account: ${DEPLOY_SA_EMAIL}"
#   gcloud iam service-accounts create "${DEPLOY_SA_NAME}" \
#     --project "${DEPLOY_PROJECT_ID}" \
#     --display-name "Org / Identity / Terraform automation"
#   echo "✅ Created service account"
# fi

### 4. Grant org-level roles so this SA can actually manage org resources
# echo
# echo "➡ Granting org-level roles to ${DEPLOY_SA_EMAIL}"

# gcloud organizations add-iam-policy-binding "${ORG_ID}" \
#   --member="serviceAccount:${DEPLOY_SA_EMAIL}" \
#   --role="roles/resourcemanager.organizationAdmin"

# gcloud organizations add-iam-policy-binding "${ORG_ID}" \
#   --member="serviceAccount:${DEPLOY_SA_EMAIL}" \
#   --role="roles/billing.user"

# gcloud organizations add-iam-policy-binding "${ORG_ID}" \
#   --member="serviceAccount:${DEPLOY_SA_EMAIL}" \
#   --role="roles/iam.securityAdmin"

# echo "✅ Org-level roles granted"

### 5. (Optional but useful) Allow your admin user to impersonate this SA via gcloud/TF
# echo
# echo "➡ Granting serviceAccountTokenCreator to ${ADMIN_USER} on ${DEPLOY_SA_EMAIL}"

# gcloud iam service-accounts add-iam-policy-binding "${DEPLOY_SA_EMAIL}" \
#   --member="user:${ADMIN_USER}" \
#   --role="roles/iam.serviceAccountTokenCreator" \
#   --project="${DEPLOY_PROJECT_ID}"

# echo "✅ ${ADMIN_USER} can now impersonate ${DEPLOY_SA_EMAIL}"

# ### 6. Create a JSON key for Terraform (if it doesn’t already exist)
# if [[ -f "${SA_KEY_FILE}" ]]; then
#   echo
#   echo "⚠️  Key file already exists at ${SA_KEY_FILE}"
#   echo "    Delete it first if you want to regenerate."
# else
#   echo
#   echo "➡ Creating JSON key for Terraform at ${SA_KEY_FILE}"
#   mkdir -p "$(dirname "${SA_KEY_FILE}")"
#   gcloud iam service-accounts keys create "${SA_KEY_FILE}" \
#     --iam-account="${DEPLOY_SA_EMAIL}" \
#     --project="${DEPLOY_PROJECT_ID}"
#   echo "✅ Key created"
# fi

### 7. Print the service account UNIQUE ID (this is the 'Client ID' for domain-wide delegation)
echo
echo "➡ Fetching service account uniqueId (Client ID for domain-wide delegation)..."
CLIENT_ID=$(gcloud iam service-accounts describe "${DEPLOY_SA_EMAIL}" \
  --project "${DEPLOY_PROJECT_ID}" \
  --format="value(uniqueId)")

echo
echo "============================================="
echo " Service Account for Cloud Identity DWD"
echo "============================================="
echo " Service Account Email: ${DEPLOY_SA_EMAIL}"
echo " Domain-wide Delegation Client ID: ${CLIENT_ID}"
echo
echo "➡ Next steps (manual in Admin Console as a super admin ${ADMIN_USER}):"
echo "   1. Go to https://admin.google.com"
echo "   2. Security → Access and data control → API controls"
echo "   3. 'Manage Domain Wide Delegation' → 'Add new'"
echo "   4. Client ID: ${CLIENT_ID}"
echo "   5. OAuth Scopes (comma-separated), e.g.:"
echo "      https://www.googleapis.com/auth/admin.directory.user,"
echo "      https://www.googleapis.com/auth/admin.directory.group,"
echo "      https://www.googleapis.com/auth/admin.directory.group.member"
echo
echo "➡ Terraform usage:"
echo "   export GOOGLE_APPLICATION_CREDENTIALS='${SA_KEY_FILE}'"
echo "   # and in infra/identity/terraform.tfvars:"
echo "   admin_impersonation_email = \"${ADMIN_USER}\""
echo
echo "✅ Done."



1️⃣ Finish Domain-Wide Delegation in Admin Console

Logged in as aazads@aazads.us:

Go to https://admin.google.com

Security → Access and data control → API controls

Scroll down to Domain-wide delegation → click Manage domain-wide delegation

Click Add new

Client ID:
116450638689255627948

OAuth scopes (comma-separated):

https://www.googleapis.com/auth/admin.directory.user,
https://www.googleapis.com/auth/admin.directory.group,
https://www.googleapis.com/auth/admin.directory.group.member
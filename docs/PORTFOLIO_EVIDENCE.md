# Portfolio Evidence Checklist

Capture evidence only after a real deployment. Keep the browser or terminal framing wide enough to show context and timestamps, but redact sensitive account details before publishing.

## 1. Successful GitHub Actions CI

- **Open:** GitHub repository → Actions → a completed `CI` run.
- **Show:** commit SHA, branch, all validation steps, and green job result.
- **Redact:** private repository URLs or actor details if personally sensitive. Never expose logs containing tokens.

## 2. Successful GitHub Actions deployment

- **Open:** Actions → the matching `Deploy` run.
- **Show:** immutable image build/push and successful US and EU rollout steps.
- **Redact:** any sensitive organization/repository metadata and unexpected credential output. Provider and service account identifiers are not secrets but can still be obscured for privacy.

## 3. Terraform plan/apply summary

- **Open:** terminal containing reviewed `terraform plan`, then the completed apply summary.
- **Show:** resource counts, both clusters, VPC/subnets, Artifact Registry, and WIF resources without truncating the summary.
- **Redact:** organization/folder/billing identifiers, state contents, access tokens, sensitive IP ranges, and local usernames/paths if desired.

## 4. GKE cluster list

- **Open:** Google Cloud Console → Kubernetes Engine → Clusters, or run `gcloud container clusters list --project PROJECT_ID`.
- **Show:** both cluster names, `RUNNING` status, regional locations, and release channel.
- **Redact:** project number/ID if it is not intended to be public, account identity, organization details, and endpoint IPs if considered sensitive.

## 5. Artifact Registry image

- **Open:** Artifact Registry → repository → `multi-region-gke-app` image.
- **Show:** repository location and an image version tagged with a commit SHA.
- **Redact:** project identifiers if private and any unrelated repository contents. Do not show credentials or command history with tokens.

## 6. Healthy US Kubernetes deployment

- **Open:** terminal after selecting the US cluster context.
- **Run:** `kubectl -n multi-region-gke-app get deployment,pods,hpa,pdb,service`.
- **Show:** current context/cluster, ready replica counts, running Pods, HPA, PDB, and Service.
- **Redact:** external IP if sensitive and local terminal/profile information.

## 7. Healthy EU Kubernetes deployment

- **Open:** terminal after selecting the EU cluster context.
- **Run:** the same namespaced `kubectl get` command.
- **Show:** EU context and healthy resources.
- **Redact:** external IP if sensitive and local terminal/profile information.

## 8. Running application

- **Open:** each regional Service endpoint in a browser or run `curl` against `/` and `/healthz`.
- **Show:** `status: ok` and separate root responses identifying `us` and `eu`.
- **Redact:** public IPs or DNS names if you do not want them discoverable. Do not publish session headers.

## 9. Cloud Logging / GKE observability

- **Open:** Logs Explorer filtered to resource type `k8s_container`, namespace `multi-region-gke-app`, and one cluster.
- **Show:** filter, cluster/namespace labels, recent application entries, and timestamp. Optionally repeat for the second cluster.
- **Redact:** unrelated logs, request payloads, user data, tokens, account identity, and sensitive labels.

## 10. Workload Identity Federation configuration

- **Open:** IAM & Admin → Workload Identity Federation → `github-actions` provider, or show a sanitized Terraform output plus the successful auth step.
- **Show:** GitHub issuer and repository/main-branch attribute condition.
- **Redact:** project number if desired, organization IDs, unrelated principals, email addresses considered personal, and all token content. A WIF provider resource name is an identifier, not a secret, but may be redacted for privacy.

## 11. Architecture diagram

- **Open:** rendered Mermaid diagram in `README.md` or `docs/architecture.md` on GitHub.
- **Show:** GitHub Actions, OIDC/WIF, Artifact Registry, VPC, and both independent GKE clusters.
- **Redact:** nothing in the repository diagram should be secret; confirm no private identifiers were added before capture.

## Publication check

Before publishing, inspect every image at full resolution. Never expose service account key JSON, access/refresh/identity tokens, GitHub secrets, Terraform state, billing account IDs, sensitive organization IDs, personal information, or private network details. Crop irrelevant browser tabs, notifications, and terminal history.

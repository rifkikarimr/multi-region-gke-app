# Operations

## Deployment flow

The `Deploy` workflow builds `GAR_LOCATION-docker.pkg.dev/PROJECT_ID/GAR_REPOSITORY/multi-region-gke-app:GIT_SHA`, pushes it once, then deploys that exact tag to the US and EU clusters in sequence. A failed US rollout stops the workflow before EU deployment. A failed EU rollout leaves US on the new revision and requires operator review.

Configure the GitHub `production` environment and repository variables listed in the README before running the workflow. Consider requiring manual approval for that environment.

## Cluster access

```bash
gcloud container clusters get-credentials CLUSTER_NAME \
  --region REGION \
  --project PROJECT_ID
```

Confirm the current context before every cluster-specific operation:

```bash
kubectl config current-context
kubectl --namespace multi-region-gke-app get deployment,pods,hpa,pdb,service
```

## Rollout verification

```bash
kubectl --namespace multi-region-gke-app rollout status \
  deployment/multi-region-gke-app --timeout=5m
kubectl --namespace multi-region-gke-app get pods \
  -l app.kubernetes.io/name=multi-region-gke-app
kubectl --namespace multi-region-gke-app describe deployment multi-region-gke-app
```

When the Service has an external address:

```bash
kubectl --namespace multi-region-gke-app get service multi-region-gke-app
curl "http://EXTERNAL_IP/healthz"
curl "http://EXTERNAL_IP/"
```

Repeat credential selection and verification separately for each cluster. The root response should report `us` or `eu` according to the overlay.

## Logs and troubleshooting

Application logs:

```bash
kubectl --namespace multi-region-gke-app logs \
  deployment/multi-region-gke-app --all-pods=true --tail=100
```

Recent events and scheduling/probe failures:

```bash
kubectl --namespace multi-region-gke-app get events \
  --sort-by=.metadata.creationTimestamp
kubectl --namespace multi-region-gke-app describe pod POD_NAME
```

GKE logging can also be queried in Logs Explorer with resource type `k8s_container`, namespace `multi-region-gke-app`, and cluster name. If an image cannot be pulled, verify the full Artifact Registry path and the node service account's `artifactregistry.reader` binding. If GitHub authentication fails, compare the repository/ref claim restrictions with the workflow run and verify `WIF_PROVIDER` and `WIF_SERVICE_ACCOUNT`.

## Manual deployment

After authenticating Docker and selecting the correct cluster context:

```bash
export IMAGE_URI="REGION-docker.pkg.dev/PROJECT_ID/REPOSITORY/multi-region-gke-app:GIT_SHA"
kubectl kustomize kubernetes/overlays/us \
  | sed "s|APP_IMAGE|${IMAGE_URI}|g" \
  | kubectl apply -f -
```

Use the EU overlay for the EU cluster. Do not use a mutable `latest` tag.

## Rollback

Kubernetes retains Deployment revisions:

```bash
kubectl --namespace multi-region-gke-app rollout history deployment/multi-region-gke-app
kubectl --namespace multi-region-gke-app rollout undo deployment/multi-region-gke-app
kubectl --namespace multi-region-gke-app rollout status deployment/multi-region-gke-app --timeout=5m
```

Rollback each cluster independently and verify both. For reproducibility, a preferred recovery is to rerun the workflow using a known-good commit SHA or explicitly deploy its immutable image tag.

## Cleanup

From the same Terraform directory and state used for creation:

```bash
terraform -chdir=terraform plan -destroy -out=destroy.tfplan
terraform -chdir=terraform apply destroy.tfplan
```

Alternatively, after reviewing the prompt:

```bash
terraform -chdir=terraform destroy
```

Before destroying, set `deletion_protection = false` and apply if protection was enabled. Afterward, verify that both clusters, forwarding rules/external addresses, and Artifact Registry repository are gone. Enabled project APIs deliberately remain enabled. Images, load balancer resources, or state created outside this Terraform state may require separate manual cleanup.

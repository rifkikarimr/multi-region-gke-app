# Portfolio Modernization Changelog

## Original problems

- The only workflow built a nonexistent `./webapp` directory.
- CI/CD pushed to `gcr.io`, while Terraform provisioned Artifact Registry and Kubernetes referenced a different Artifact Registry image.
- The workflow used deprecated action majors and a long-lived `GOOGLE_CREDENTIALS` JSON secret.
- Deployment used `kubectl set image` without first applying the Deployment and used an implicit current namespace.
- Terraform embedded a real project ID, lacked a Terraform version constraint, allowed any Google provider release after 4.0, and required undeclared Artifact Registry variables.
- GKE relied on default node pools, had no autoscaling, VPC-native secondary ranges, GKE Workload Identity, release channel, or explicit logging/monitoring configuration.
- The container ran as root, used an outdated base/dependency set, had no production WSGI server, health endpoint, ignore file, or tests.
- Kubernetes used a mutable `latest` image and lacked probes, resource boundaries, hardened security context, autoscaling, a disruption budget, and region-specific configuration.
- The Ingress referenced an unmanaged global static IP while the Service was already a `LoadBalancer`; it did not implement cross-region routing or failover.
- Documentation consisted of one sentence and did not cover architecture, security, operations, cost, validation, cleanup, evidence, or limitations.

## Technical improvements

- Standardized image build, push, and deployment on one configurable Artifact Registry path and immutable commit SHA tags.
- Split pull-request/main validation (`CI`) from authenticated delivery (`Deploy`).
- Added a minimal tested Flask application with `/healthz`, Gunicorn, a non-root image, and a constrained build context.
- Replaced flat Kubernetes YAML with a small Kustomize base and US/EU overlays.
- Added rolling updates, two replicas, probes, requests/limits, HPA, PDB, and restrictive Pod/container security settings.

## Terraform improvements

- Added Terraform and Google provider constraints, input types/validation, documented examples, consistent labels, and useful outputs.
- Added required API enablement, a custom-mode VPC, two regional subnets, and Pod/Service secondary ranges.
- Defined two regional GKE clusters with separate managed node pools, autoscaling, auto-repair/upgrade, a regular release channel, GKE Workload Identity, logging, monitoring, and managed Prometheus collection.
- Added a dedicated node service account with registry/logging/monitoring permissions.
- Added GitHub OIDC federation, a repository/ref-restricted provider, and a deployment service account with Artifact Registry writer and GKE developer roles.

## Security and CI/CD improvements

- Removed static Google Cloud JSON key authentication from the workflow.
- Limited GitHub token permissions and configured a named deployment environment.
- Added a `.gitignore` rule for generated Google authentication credentials, Terraform state/values, and local Python/editor artifacts.
- Made deployment sequential and explicit, with cluster credential selection, manifest apply, rollout timeout, and resource summaries in both regions.
- Added application, Docker, Terraform, and Kubernetes validation to CI.

## Documentation improvements

- Rebuilt the README as a technical portfolio landing page.
- Added architecture, security, operations, cost, portfolio evidence, and this factual change log.
- Documented cleanup, manual commands, current limitations, and future production considerations without claiming global failover.

## Remaining limitations

No real Google Cloud deployment was performed during repository modernization. Global traffic management, automated regional failover, TLS, private nodes, multi-zone worker placement, remote Terraform state, policy enforcement, application metrics/alerts, image signing, and backups remain outside this reference scope.

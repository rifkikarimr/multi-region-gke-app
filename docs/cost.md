# Cost considerations

This architecture creates billable Google Cloud resources. It is intended to be deployed temporarily for demonstration and validation, then destroyed.

## Main cost drivers

- **Two GKE clusters:** cluster management fees and two independent node pools are the largest baseline costs. Free-tier treatment, if any, depends on the active Google Cloud pricing terms and account.
- **Compute nodes and disks:** each cluster keeps at least one `e2-standard-2` node with a balanced persistent boot disk. Horizontal Pod Autoscaling can cause the cluster autoscaler to add nodes up to the configured maximum.
- **Load balancers and external IPv4 addresses:** each cluster creates its own public `LoadBalancer` Service, so forwarding rules, data processing, and addresses can incur charges.
- **Artifact Registry:** stored image layers and network transfer are billed. The EU cluster pulls from the default US repository, which may add cross-region transfer charges.
- **Networking:** internet egress, cross-region traffic, and image pulls vary with use. This reference does not create Cloud NAT or Cloud VPN.
- **Logging and monitoring:** ingestion and retention beyond included allocations can cost money, especially if application traffic or log volume grows.

## Cost controls in this repository

- One node zone per regional cluster keeps the demo footprint smaller, with the documented tradeoff that worker nodes are not zonally redundant.
- Node pools start at one node and use configurable autoscaling limits.
- The sample workload has modest resource requests/limits and two replicas.
- Node disks default to 30 GB.
- Cluster deletion protection defaults to `false` so temporary environments are easy to remove.
- Resources have portfolio/management labels for filtering where Google Cloud supports labels.

## Ways to minimize spend

1. Review `terraform plan` before applying.
2. Choose regions and machine types deliberately; verify current pricing in the Google Cloud Pricing Calculator.
3. Keep `node_max_count` low for demonstrations.
4. Avoid load testing and verbose logging unless they are part of validation.
5. Delete old image versions if retention is no longer useful.
6. Run `terraform destroy` immediately after capturing evidence.

```bash
terraform -chdir=terraform destroy
```

Google Cloud pricing changes and depends on region, usage, discounts, and account settings, so this document intentionally provides no fixed monthly estimate.

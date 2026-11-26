# kubeone-practitioner-labs

Companion lab files for the **KubeOne Practitioner** course on HubLMS.

The labs build one Kubernetes cluster with KubeOne 1.13 on Hetzner Cloud and take it through its whole life. The cluster starts with Terraform infrastructure and the first `kubeone apply`. It then covers worker management with MachineDeployments, a three-node control plane, workers in three locations, Helm releases with TLS, the cluster autoscaler, backup and restore with Velero, a Kubernetes upgrade, a KubeOne upgrade and teardown.

This directory will be published at [`kubermatic/kubermatic-academy/tree/main/kubeone`](https://github.com/kubermatic/kubermatic-academy/tree/main/kubeone).

## How to use it

```bash
git clone https://github.com/kubermatic/kubermatic-academy.git
cd kubermatic-academy/kubeone
```

Every lab runs from this folder, and the labs create their working files here. These are `tf-infra/` (Terraform state), `kubeone.yaml`, `kubeone-kubeconfig` and the exported `md-*.yaml` MachineDeployments. `.gitignore` keeps them out of Git, because they hold credentials and cluster state.

The course's `lab-setup.md` lists the tools and accounts you need. They are `kubectl`, `terraform`, the `hcloud` CLI, `helm`, `jq`, the AWS CLI (Chapter 12 only) and a Hetzner Cloud project with a Read & Write API token in `HCLOUD_TOKEN`.

## Attribution

The course started from Hubert Ströbitzer's in-person training [`cloudnativetrainings/advanced-operations-of-kubernetes-with-kubeone`](https://github.com/cloudnativetrainings/advanced-operations-of-kubernetes-with-kubeone), which runs on Google Cloud. The files here are reshaped for Hetzner Cloud and the self-paced course. Each adapted file's header names its source and what changed.

## Layout

Folders exist only for chapters that ship a file. The number prefix is the course chapter number. Chapters not listed type their files in the lab guide or generate them with `kubeone` and `kubectl`.

| Folder | Chapter | Files |
|--------|---------|-------|
| `03_terraform/` | Ch03 — Provision Infrastructure with Terraform | `terraform.tfvars.example` (values for KubeOne's `examples/terraform/hetzner`) |
| `10_helm-releases/` | Ch10 — Helm Releases & Real Apps | `helm-releases.yaml` (Envoy Gateway and cert-manager as KubeOne `helmReleases`), `gateway.yaml` (EnvoyProxy, GatewayClass, Gateway), `cluster-issuer.yaml`, `gateway-https.yaml` and `httproute.yaml` (both take `${DOMAIN}` through `envsubst`) |
| `12_backup/` | Ch12 — Backup & User Data | `storageclass.yaml` (`my-storageclass` on the hcloud CSI driver), `credentials-velero.template` |

## `.template` files

Files ending in `.template` contain `${VAR}` placeholders, which you fill in with `envsubst` after you export the variables the lab guide names. Write the result outside this repository. `umask 077` creates the file readable only by you.

```bash
(umask 077; envsubst '$S3_ACCESS_KEY $S3_SECRET_KEY' \
  < 12_backup/credentials-velero.template \
  > ~/.config/kubeone-lab/credentials-velero)
```

| Template | Env vars |
|----------|----------|
| `12_backup/credentials-velero.template` | `S3_ACCESS_KEY`, `S3_SECRET_KEY` |

## Versions

| Component | Version |
|-----------|---------|
| KubeOne | 1.13.7, upgraded to 1.13.8 in Chapter 14 |
| Kubernetes | 1.35.3, upgraded to 1.35.4 in Chapter 13 |
| Terraform example | `examples/terraform/hetzner` at KubeOne v1.13.7 (provider `hetznercloud/hcloud ~> 1.52`) |
| Velero | 1.18.4 with `velero-plugin-for-aws` v1.14.4 |

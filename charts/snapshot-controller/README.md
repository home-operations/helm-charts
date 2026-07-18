# snapshot-controller

Deploys the CSI external-snapshotter snapshot-controller together with the volume snapshot CRDs, shipped exactly as upstream publishes them. Snapshot controllers are often bundled with the Kubernetes distribution; this chart is for clusters where they are not.

**Homepage:** <https://github.com/home-operations/helm-charts>

## Usage

```sh
helm install snapshot-controller oci://ghcr.io/home-operations/charts/snapshot-controller \
  --namespace kube-system
```

The chart deploys the [external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter)
snapshot-controller with leader election and the CSIVolumeGroupSnapshot feature
gate enabled, and creates any VolumeSnapshotClass / VolumeGroupSnapshotClass
entries defined in `volumeSnapshotClasses` / `volumeGroupSnapshotClasses`.

## CRDs

The snapshot.storage.k8s.io and groupsnapshot.storage.k8s.io CRDs ship in the
chart's `crds/` directory, vendored byte-for-byte from the upstream release
pinned by the chart appVersion (`mise run crds`). In particular, no conversion
webhook is injected into the group snapshot CRDs; upstream ships them without
one, and adding it breaks VolumeGroupSnapshots (see
[piraeusdatastore/helm-charts#98](https://github.com/piraeusdatastore/helm-charts/issues/98),
the reason this chart exists).

Helm's native CRD handling applies: the CRDs are installed on first install
(skip with `--skip-crds`), and `helm upgrade` and `helm uninstall` never touch
them, so your snapshots survive chart removal. Because Helm does not upgrade
CRDs, apply the ones matching the chart after upgrading across an appVersion
bump:

```sh
helm show crds oci://ghcr.io/home-operations/charts/snapshot-controller | kubectl apply --server-side -f -
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| home-operations | <contact@home-operations.com> |  |

## Source Code

* <https://github.com/kubernetes-csi/external-snapshotter>

## Requirements

Kubernetes: `>=1.25.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod scheduling. |
| controller.extraArgs | list | `[]` | Additional arguments passed to the controller (e.g. "--retry-crd-interval-max=30s"). |
| controller.leaderElection.enabled | bool | `true` | Enable leader election (required to run more than one replica). The default probes hit /healthz/leader-election, which only exists while leader election is on; override livenessProbe/readinessProbe when disabling this. |
| controller.metrics.annotations | object | `{}` | Annotations for the metrics Service. |
| controller.metrics.port | int | `8080` | Operational port: /metrics plus the leader-election health check (plain HTTP; always on; restrict with a NetworkPolicy rather than disabling). |
| controller.verbosity | int | `2` |  |
| controller.volumeGroupSnapshots | bool | `true` | Enable the CSIVolumeGroupSnapshot feature gate (VolumeGroupSnapshot support). |
| env | list | `[]` | Extra environment variables passed to the container. |
| fullnameOverride | string | `""` | Override the full release name. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"registry.k8s.io/sig-storage/snapshot-controller"` | Image repository. |
| image.tag | string | `""` | Overrides the image tag; defaults to the chart appVersion. |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries. |
| livenessProbe | object | `{"httpGet":{"path":"/healthz/leader-election","port":"metrics"},"initialDelaySeconds":10,"periodSeconds":20}` | Liveness probe. |
| monitoring.serviceMonitor.annotations | object | `{}` | ServiceMonitor annotations. |
| monitoring.serviceMonitor.enabled | bool | `false` | Create a Prometheus Operator ServiceMonitor (requires its CRDs). |
| monitoring.serviceMonitor.interval | string | `"30s"` | Scrape interval. |
| monitoring.serviceMonitor.labels | object | `{}` | ServiceMonitor labels. |
| monitoring.serviceMonitor.metricRelabelings | list | `[]` | Prometheus metric relabelings. |
| monitoring.serviceMonitor.path | string | `"/metrics"` | Metrics path. |
| monitoring.serviceMonitor.podTargetLabels | list | `[]` | Pod target labels to copy from pods. |
| monitoring.serviceMonitor.relabelings | list | `[]` | Prometheus relabelings (applied before scraping). |
| monitoring.serviceMonitor.scrapeTimeout | string | `"10s"` | Scrape timeout. |
| monitoring.serviceMonitor.targetLabels | list | `[]` | Target labels to copy from the Service. |
| nameOverride | string | `""` | Override the chart name used in resource names. |
| nodeSelector | object | `{}` | Node selector for pod scheduling. |
| podAnnotations | object | `{}` | Annotations added to the pod. |
| podDisruptionBudget | object | `{}` | PodDisruptionBudget spec (e.g. `maxUnavailable: 1`); rendered when non-empty. |
| podLabels | object | `{}` | Labels added to the pod. |
| podSecurityContext | object | `{"fsGroup":65532,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod-level securityContext (runs as non-root uid/gid 65532). |
| priorityClassName | string | `"system-cluster-critical"` | Priority class name for pod scheduling (cluster infrastructure: keep it schedulable ahead of ordinary workloads). |
| rbac.annotations | object | `{}` | Annotations for the RBAC resources. |
| rbac.create | bool | `true` | Create the ClusterRole/ClusterRoleBinding and leader-election Role/RoleBinding (rules mirror the upstream rbac-snapshot-controller.yaml). |
| readinessProbe | object | `{"httpGet":{"path":"/healthz/leader-election","port":"metrics"},"initialDelaySeconds":5,"periodSeconds":10}` | Readiness probe. |
| replicaCount | int | `1` | Number of controller replicas; leader election picks the active instance. |
| resources | object | `{}` | Pod resource requests/limits. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":65532}` | Container securityContext (no privilege escalation, read-only root filesystem, drops ALL capabilities). |
| serviceAccount.annotations | object | `{}` | Annotations for the ServiceAccount (e.g. workload-identity bindings). |
| serviceAccount.automount | bool | `true` | Automount the API token (on by default: the controller talks to the cluster API). |
| serviceAccount.create | bool | `true` | Create a ServiceAccount. |
| serviceAccount.name | string | `""` | ServiceAccount name; generated from the release name if empty. |
| tolerations | list | `[]` | Tolerations for pod scheduling. |
| topologySpreadConstraints | list | `[]` | Topology spread constraints for the pods. |
| volumeGroupSnapshotClasses | list | `[]` | VolumeGroupSnapshotClasses to create (same shape as volumeSnapshotClasses; requires controller.volumeGroupSnapshots). |
| volumeSnapshotClasses | list | `[]` | VolumeSnapshotClasses to create (each entry: name, driver, deletionPolicy, and optional annotations, labels, parameters). |

---

_This README is generated by [helm-docs](https://github.com/norwoodj/helm-docs) from `Chart.yaml` and `values.yaml`. Edit those (or `README.md.gotmpl`) and run `mise run helm-docs`._

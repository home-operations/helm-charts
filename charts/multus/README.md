# multus

Deploys the Multus CNI meta-plugin together with the NetworkAttachmentDefinition CRD, allowing pods to attach to additional networks. Includes an optional init container that installs the reference CNI plugins on distributions that do not ship them (e.g. Talos Linux).

**Homepage:** <https://github.com/home-operations/helm-charts>

## Usage

```sh
helm install multus oci://ghcr.io/home-operations/charts/multus \
  --namespace kube-system
```

The chart deploys the [multus-cni](https://github.com/k8snetworkplumbingwg/multus-cni)
thin plugin as a DaemonSet. By default an init container installs the reference
[CNI plugins](https://github.com/containernetworking/plugins) into `cni.binDir`;
this is needed on distributions that do not ship them (e.g. Talos Linux) and can
be turned off with `cniPlugins.enabled=false` when the host already provides
them.

## CRDs

The NetworkAttachmentDefinition CRD ships in the chart's `crds/` directory,
vendored unmodified from the upstream release pinned by the chart appVersion
(`mise run crds`). Helm's native CRD handling applies: the CRD is installed on
first install (skip with `--skip-crds`), and `helm upgrade` and `helm uninstall`
never touch it, so your NetworkAttachmentDefinitions survive chart removal.
Because Helm does not upgrade CRDs, apply the one matching the chart after
upgrading across an appVersion bump:

```sh
helm show crds oci://ghcr.io/home-operations/charts/multus | kubectl apply --server-side -f -
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| home-operations | <contact@home-operations.com> |  |

## Source Code

* <https://github.com/k8snetworkplumbingwg/multus-cni>
* <https://github.com/containernetworking/plugins>

## Requirements

Kubernetes: `>=1.25.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod scheduling. |
| cni.binDir | string | `"/opt/cni/bin"` | Host directory with the CNI plugin binaries. |
| cni.netDir | string | `"/etc/cni/net.d"` | Host directory with the CNI network configurations. |
| cniPlugins.enabled | bool | `true` | Install the reference CNI plugins into `cni.binDir` via an init container. Needed on distributions that do not ship them (e.g. Talos Linux); disable when the host already provides them. |
| cniPlugins.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| cniPlugins.image.repository | string | `"ghcr.io/home-operations/cni-plugins"` | CNI plugins image repository (copies the plugin binaries to the host). |
| cniPlugins.image.tag | string | `"1.9.1"` | CNI plugins image tag. |
| cniPlugins.resources | object | `{}` | Init container resource requests/limits. |
| extraArgs | list | `[]` | Additional arguments passed to the multus entrypoint (the defaults `--cleanup-config-on-exit` and `--multus-cni-conf-dir=/tmp` are always set). |
| fullnameOverride | string | `""` | Override the full release name. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"ghcr.io/k8snetworkplumbingwg/multus-cni"` | Multus image repository. |
| image.tag | string | `""` | Overrides the image tag; defaults to the chart appVersion. |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries. |
| nameOverride | string | `""` | Override the chart name used in resource names. |
| nodeSelector | object | `{}` | Node selector for pod scheduling. |
| podAnnotations | object | `{}` | Annotations added to the pod. |
| podLabels | object | `{}` | Labels added to the pod. |
| podSecurityContext | object | `{}` | Pod-level securityContext (the entrypoint writes to host paths and must run as root). |
| priorityClassName | string | `"system-node-critical"` | Priority class name for pod scheduling (node infrastructure: must not be evicted from any node). |
| rbac.annotations | object | `{}` | Annotations for the RBAC resources. |
| rbac.create | bool | `true` | Create the ClusterRole/ClusterRoleBinding the CNI plugin needs to read pod network annotations and report status. |
| resources | object | `{}` | Pod resource requests/limits. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"add":["NET_ADMIN"],"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container securityContext (no privilege escalation, read-only root filesystem, NET_ADMIN only). |
| serviceAccount.annotations | object | `{}` | Annotations for the ServiceAccount. |
| serviceAccount.automount | bool | `true` | Automount the API token (on by default: the entrypoint generates a kubeconfig from it for the CNI plugin). |
| serviceAccount.create | bool | `true` | Create a ServiceAccount. |
| serviceAccount.name | string | `""` | ServiceAccount name; generated from the release name if empty. |
| tolerations | list | `[{"key":"CriticalAddonsOnly","operator":"Exists"}]` | Tolerations for pod scheduling (defaults keep the DaemonSet on critical-addons-only nodes). |

---

_This README is generated by [helm-docs](https://github.com/norwoodj/helm-docs) from `Chart.yaml` and `values.yaml`. Edit those (or `README.md.gotmpl`) and run `mise run helm-docs`._

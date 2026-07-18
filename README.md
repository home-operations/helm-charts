# helm-charts

Helm charts maintained to home-operations standards, published as OCI artifacts to
`ghcr.io/home-operations/charts` and signed with Cosign.

## Scope

A chart belongs here only when **both** conditions hold:

- the application needs special handling a generic chart cannot provide (CRD
  lifecycle management, vendored upstream manifests, and the like), **and**
- there is no official upstream chart.

Anything else should use its official chart or a generic solution such as
[app-template](https://github.com/bjw-s-labs/helm-charts).

## Charts

| Chart                                             | Description                                                                    |
| ------------------------------------------------- | ------------------------------------------------------------------------------ |
| [multus](charts/multus)                           | Multus CNI meta-plugin with the NetworkAttachmentDefinition CRD.               |
| [snapshot-controller](charts/snapshot-controller) | CSI snapshot-controller with the snapshot CRDs shipped verbatim from upstream. |

## Usage

```sh
helm install snapshot-controller oci://ghcr.io/home-operations/charts/snapshot-controller \
  --namespace kube-system
```

### Verifying signatures

Every published chart is signed with keyless
[Cosign](https://github.com/sigstore/cosign) using the release workflow's GitHub
Actions OIDC identity. Verify a chart before installing it:

```sh
cosign verify ghcr.io/home-operations/charts/snapshot-controller:<version> \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp 'https://github.com/home-operations/helm-charts/.github/workflows/release.yaml@.*'
```

## Development

Tooling is managed with [mise](https://mise.jdx.dev); `mise install` sets up
everything (including the git hooks via lefthook). Unit tests additionally need the
[helm-unittest](https://github.com/helm-unittest/helm-unittest) plugin.

| Task                       | Purpose                                                            |
| -------------------------- | ------------------------------------------------------------------ |
| `mise run crds`            | Pull the CRDs from upstream (`vendir sync` + per-chart post-steps) |
| `mise run crds-check`      | Fail if the committed vendir lock is stale (CI gate)               |
| `mise run helm-lint`       | Lint the charts                                                    |
| `mise run helm-test`       | Run the helm-unittest suites                                       |
| `mise run helm-docs`       | Regenerate each chart's `README.md` and `values.schema.json`       |
| `mise run helm-docs-check` | Fail if the generated docs are stale (CI gate)                     |
| `mise run e2e`             | Install the charts on a throwaway kind cluster and verify them     |

Pull-request workflows lint, unit-test, and e2e-test only the charts whose files
changed (via
[action-changed-files](https://github.com/bjw-s-labs/action-changed-files)); the
repo-wide gates (generated docs, vendir lock) always run. Releases are inherently
per chart through release-please tags.

Charts ship their CRDs through Helm's native `crds/` directory. The CRD files are
not committed: `mise run crds` pulls them with [vendir](https://carvel.dev/vendir/)
from the upstream ref pinned in each chart's `vendir.yml` (which must match that
chart's appVersion; the task enforces this), and CI re-pulls them for every test
run and at release packaging, so a published chart always carries the CRDs
matching its appVersion. Each chart's committed `vendir.lock.yml` pins the exact
upstream commit, and Renovate bumps a chart's appVersion and vendir ref together
in one grouped PR.

## Releases and versioning

Releases are cut by [release-please](https://github.com/googleapis/release-please)
from Conventional Commits, one release per chart (tagged `<chart>-<version>`). The
release workflow packages the chart, pushes it to GHCR, and signs it with Cosign.

- Chart versions are independent of the packaged application: a chart-only change
  releases a new chart version with the appVersion untouched, and an upstream bump
  is just another commit that produces a release.
- Chart versions follow [0ver](https://0ver.org) (they stay `0.x`; breaking
  changes bump minor, everything else bumps patch) and never carry a `v` prefix.
- Charts are published exclusively as OCI artifacts to
  `ghcr.io/home-operations/charts`; there is no classic index-based chart
  repository.

## License

[AGPL-3.0](LICENSE)

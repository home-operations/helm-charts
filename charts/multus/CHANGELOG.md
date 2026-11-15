# Changelog

## [0.1.2](https://github.com/home-operations/helm-charts/compare/multus-0.1.1...multus-0.1.2) (2026-11-12)


### Tests

* stop asserting release versions in image tests ([08bb957](https://github.com/home-operations/helm-charts/commit/08bb957b794f7a843e3de306dc44ce3af829263b))


### Miscellaneous Chores

* **container:** update image ghcr.io/home-operations/cni-plugins (1.9.1 → 1.10.0) ([#111](https://github.com/home-operations/helm-charts/issues/111)) ([861ade7](https://github.com/home-operations/helm-charts/commit/861ade7d4948d4f0da9898b4c76bbbcff392856b))
* **container:** update multus upstream (v4.3.1 → v4.3.2) ([#107](https://github.com/home-operations/helm-charts/issues/107)) ([7350715](https://github.com/home-operations/helm-charts/commit/735071532e38035e5afe5e562bb7aaf94e591aee))

## [0.1.1](https://github.com/home-operations/helm-charts/compare/multus-0.1.0...multus-0.1.1) (2026-10-10)


### Features

* **multus:** support DRA allocations via multus-cni v4.3.1 ([#72](https://github.com/home-operations/helm-charts/issues/72)) ([a80ef50](https://github.com/home-operations/helm-charts/commit/a80ef50090c9caadb3486acf2ca1c679613f69c8))

## 0.1.0 (2026-07-18)


### Features

* add snapshot-controller and multus charts ([ef14d91](https://github.com/home-operations/helm-charts/commit/ef14d9133664cd0f3bfc76f78681284c61764958))


### Bug Fixes

* prefix chart matrix paths and drop version badge from chart docs ([912bd17](https://github.com/home-operations/helm-charts/commit/912bd1750449d042bc638ed7d51a15d22d786259))


### Code Refactoring

* move vendir config into each chart directory ([d99f426](https://github.com/home-operations/helm-charts/commit/d99f426247baafea023d430a35d0388c59504691))

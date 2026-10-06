# Changelog

## Unreleased


### Features

* metrics for the cluster in the service's metrics view: CPU, connections, freeable memory, storage used and queries
* the requirements module grants the agent role `cloudwatch:GetMetricStatistics` so metrics show
* the registration example subscribes the cluster agent channel to `telemetry` notifications

## [0.2.0](https://github.com/nullplatform/services-document-db/compare/v0.1.5...v0.2.0) (2026-10-06)


### Features

* run the worker images as a non-root user ([27e13bb](https://github.com/nullplatform/services-document-db/commit/27e13bb6599498c47e247ee18cebea20da106ef3))
* run the worker images as a non-root user ([46a58dc](https://github.com/nullplatform/services-document-db/commit/46a58dcdfabab45d9ccb713f9b3d527ea2f631d5))


### Bug Fixes

* hand HOME to the runtime user ([00a561c](https://github.com/nullplatform/services-document-db/commit/00a561c6865abb24be9d7b19aece1a686d127863))

## [0.1.5](https://github.com/nullplatform/services-document-db/compare/v0.1.4...v0.1.5) (2026-10-02)


### Bug Fixes

* **deps:** bump aws-actions/configure-aws-credentials from 4 to 6 ([#3](https://github.com/nullplatform/services-document-db/issues/3)) ([f87148f](https://github.com/nullplatform/services-document-db/commit/f87148fab03c01d6e5c2268b30c2e3e126ab5bac))

## [0.1.4](https://github.com/nullplatform/services-document-db/compare/v0.1.3...v0.1.4) (2026-10-02)


### Bug Fixes

* **deps:** bump docker/setup-buildx-action from 3 to 4 ([#5](https://github.com/nullplatform/services-document-db/issues/5)) ([302c4ee](https://github.com/nullplatform/services-document-db/commit/302c4eed6077831be714357e511646d8c3634cc1))

## [0.1.3](https://github.com/nullplatform/services-document-db/compare/v0.1.2...v0.1.3) (2026-10-02)


### Bug Fixes

* **deps:** update dependency opentofu/opentofu to v1.13.1 ([#12](https://github.com/nullplatform/services-document-db/issues/12)) ([2071422](https://github.com/nullplatform/services-document-db/commit/2071422cac9d905b881cdf0fef05e7748ac29d45))

## [0.1.2](https://github.com/nullplatform/services-document-db/compare/v0.1.1...v0.1.2) (2026-10-01)


### Bug Fixes

* **deps:** bump nullplatform/scopes/worker-bridge from 1.1.1 to 2.0.1 ([8a9ef1f](https://github.com/nullplatform/services-document-db/commit/8a9ef1f6043f1708dc25482c120f1b775b6a4bb8))
* **deps:** bump nullplatform/scopes/worker-bridge from 1.1.1 to 2.0.1 ([d1baf7c](https://github.com/nullplatform/services-document-db/commit/d1baf7cf04bbb98a1d949b372f0bae958fe2aed4))

## [0.1.1](https://github.com/nullplatform/services-document-db/compare/v0.1.0...v0.1.1) (2026-09-24)


### Bug Fixes

* **deps:** bump actions/checkout from 4 to 7 ([92a3422](https://github.com/nullplatform/services-document-db/commit/92a342219b909dd4a44940c3e2a036bed6f22e40))
* **deps:** bump actions/checkout from 4 to 7 ([261a796](https://github.com/nullplatform/services-document-db/commit/261a7964d1e8610fe62338fb48105d6a468d5755))

## [0.1.0](https://github.com/nullplatform/services-document-db/compare/0.0.1...v0.1.0) (2026-09-22)


### Features

* add DocumentDB cluster and database services ([1d5fd21](https://github.com/nullplatform/services-document-db/commit/1d5fd218c1c9207c6b69c25129458b4564ad71d6))
* add DocumentDB cluster and database services ([9dfe298](https://github.com/nullplatform/services-document-db/commit/9dfe298452d5350c3c62e0d2a85807faa6914eb1))


### Bug Fixes

* address the PR [#1](https://github.com/nullplatform/services-document-db/issues/1) review ([24152b9](https://github.com/nullplatform/services-document-db/commit/24152b9cd95eee8ec1acbca200b04998fde0921b))
* move the worker images to worker-bridge 1.1.1 ([5fa15b0](https://github.com/nullplatform/services-document-db/commit/5fa15b02c57a30e4ad1cf5e788262015b97e9314))

# Blazar Deploy Configs

This folder contains all deploy configs used by Blazar itself. Blazar has three basic categories of deploy configs:

1. Executors
2. Fabric Deploys
3. Orion-mediated Deploys

Unfortunately, due to differing use cases, these three categories must be deployed separately and cannot be combined into one overarching meta.

## Executors

Deploy configs in this category are for the Blazar Executor, which is the agent that actually runs the builds. Primarily singularity tasks.

Use `BlazarExecutorBranchMeta` to deploy this category.

## Fabric Deploys

Deploys to bare AWS VMs for the Blazar Service. Orion can't mix these with non-fabric deploys, so they get their own meta.

Use `BlazarV2QaFabricMeta` to deploy this category.

## Orion-mediated deploys

Pretty much everything else. Kafka consumers, jobs, etc.

Use `BlazarV2QaOrionMediatedMeta` to deploy this category.
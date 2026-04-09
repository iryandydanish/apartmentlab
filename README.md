# ApartmentLab

ApartmentLab is my self-hosted homelab project built around Docker Compose, environment separation, and GitOps-style deployment. The repo is structured so the same application definitions can be run in **preprod** and **prod**, while infrastructure components are managed separately from application workloads.

The goal of the project is simple: keep deployments reproducible, keep environments isolated, and make it easy to promote changes from repository updates into a running homelab with minimal manual steps.

## What is hosted

### Applications

* **AIOStreams**

  * Main self-hosted application stack
  * Backed by a dedicated **PostgreSQL** container
  * Internal app port: `3000`
  * Preprod host port: `3002`
* **BentoPDF**

  * PDF-related utility service
  * Internal app port: `8080`
  * Preprod host port: `3001`
* **Send to eReader**

  * Lightweight app for sending content to e-readers
  * Internal app port: `3001`
  * Preprod host port: `3003`

### Infrastructure services

* **Cloudflared**

  * Used in prod to expose services through Cloudflare Tunnel
  * Connected to the shared `edge` Docker network
* **Portainer**

  * Container management UI for the homelab
  * Exposed on port `9443`

## High-level architecture

The repo is split into two logical layers:

### 1. Infrastructure layer

Infrastructure lives under `infrastructure/` and contains shared platform services such as:

* `cloudflared`
* `portainer`

These are brought up separately from apps so the platform layer can be managed independently.

### 2. Application layer

Applications live under `application/` and each app has its own Compose file:

* `application/aiostreams/compose.yml`
* `application/bentopdf/compose.yml`
* `application/send2ereader/compose.yml`

This keeps each stack modular while still allowing a single command to bring up the full application layer.

## How the infrastructure works

### Shared Docker network

All main services are attached to an external Docker network called `edge`.

This gives the stacks a shared service-to-service network while keeping Compose files modular. The infrastructure bootstrap script creates the network if it does not already exist.

### Environment separation

The project distinguishes environments by **where the repo is deployed on disk**:

* `/apartmentlab/prod-repo/apartmentlab` → `prod`
* `/apartmentlab/preprod-repo/apartmentlab` → `preprod`

The shell scripts detect the current base directory and automatically choose the matching environment name and Compose project name.

That means the same repo structure can be used in both environments without manually editing Compose files.

### Environment-specific config

Runtime secrets and app configuration are stored outside the repo under:

```text
/apartmentlab/gitops/env/${ENV}/...
```

Examples include:

* `aiostreams.env`
* `postgres-aiostreams.env`
* `cloudflared.env`

This keeps secrets out of source control while still making deployments deterministic.

### Persistent data

Persistent app data is mounted outside the repo under:

```text
/apartmentlab/data/${ENV}/...
```

Examples:

* PostgreSQL data
* AIOStreams app data
* Portainer data

This lets containers be recreated without losing state.

### Preprod access pattern

In **preprod**, the public-facing ports are exposed using small `alpine/socat` sidecar containers with the Compose profile `preprod`.

Examples:

* `3001` → BentoPDF
* `3002` → AIOStreams
* `3003` → Send to eReader

This allows preprod services to be reachable directly via host ports while keeping the app containers themselves defined in a consistent way.

### Prod access pattern

In **prod**, the application stacks are launched **without** the `preprod` profile, so those host-port publishing sidecars are not started.

Instead, prod relies on the infrastructure layer, specifically **Cloudflared**, to route traffic through a tunnel. This creates a cleaner production setup with fewer directly exposed host ports.

## Repository structure

```text
apartmentlab/
├── .github/
│   └── workflows/
│       └── deploy-prod.yml
├── application/
│   ├── aiostreams/
│   │   └── compose.yml
│   ├── bentopdf/
│   │   └── compose.yml
│   └── send2ereader/
│       └── compose.yml
├── infrastructure/
│   ├── cloudflared/
│   │   └── compose.yml
│   └── portainer/
│       └── compose.yml
├── apps-up.sh
├── apps-down.sh
├── apps-restart.sh
├── infra-up.sh
├── infra-down.sh
├── versions.env
└── README.md
```

## Operational flow

### Application lifecycle

The application layer is managed with three helper scripts:

#### `apps-up.sh`

* Detects whether the repo is running from `prod-repo` or `preprod-repo`
* Sets `ENV` accordingly
* Loads `versions.env`
* Starts the application Compose stack
* In preprod, includes the `preprod` Compose profile

#### `apps-down.sh`

* Stops the full application stack
* Removes orphaned containers

#### `apps-restart.sh`

* Runs `apps-down.sh`
* Then runs `apps-up.sh`

This makes restarts deterministic and keeps the deployment flow easy to reason about.

### Infrastructure lifecycle

The infrastructure layer is handled separately:

#### `infra-up.sh`

* Changes into the prod repo path
* Ensures the shared `edge` network exists
* Starts `cloudflared` and `portainer`

#### `infra-down.sh`

* Stops the infrastructure Compose stack
* Removes orphaned containers

## Version management

Image versions are centrally pinned in `versions.env`.

This file currently includes image references for:

* `cloudflare/cloudflared`
* `ghcr.io/viren070/aiostreams`
* `postgres`
* `ghcr.io/alam00000/bentopdf`
* `taylantatli/send2ereader`

This makes image updates explicit and keeps version changes easy to review in pull requests.

## How the CI/CD process works

The repo uses **GitHub Actions** to deploy to production.

### Trigger

The production deployment workflow runs on:

* **push to `main`**

It also uses a concurrency group so only one production deployment runs at a time.

### Deployment flow

The `deploy-prod.yml` workflow does the following:

1. **Comments on the related pull request** that deployment has started
2. **Connects to the homelab over Tailscale** using the GitHub Action
3. **Sets up SSH access** with an injected private key
4. **SSHes into the production host**
5. **Fetches the latest `main` branch** in the prod repo
6. **Hard resets the prod repo to `origin/main`**
7. **Restarts the application layer** using `./apps-restart.sh`
8. **Recreates the infrastructure layer** using `./infra-down.sh` and `./infra-up.sh`
9. **Comments back on the PR** with either success or failure

### Why this approach works

This deployment model is intentionally simple:

* **Git is the source of truth**
* **GitHub Actions is the deployment trigger**
* **The production host pulls and applies the desired state**
* **Environment-specific secrets stay outside the repo**

That gives the project a lightweight GitOps feel without introducing extra cluster tooling.

## Deployment philosophy

ApartmentLab is designed around a few principles:

* **Same repo, multiple environments**
* **Infra and apps are separated**
* **Secrets are not stored in Git**
* **Image versions are pinned explicitly**
* **Preprod is easier to reach directly**
* **Prod is cleaner and more controlled**

## Example commands

### Start applications

```bash
./apps-up.sh
```

### Restart applications

```bash
./apps-restart.sh
```

### Start infrastructure

```bash
./infra-up.sh
```

### Stop infrastructure

```bash
./infra-down.sh
```

## How the CI/CD process works

The repo uses **GitHub Actions** to deploy to production.

### Trigger

The production deployment workflow runs on:

* **push to `main`**

It also uses a concurrency group so only one production deployment runs at a time.

### Deployment flow

The `deploy-prod.yml` workflow does the following:

1. **Finds the related pull request** for the pushed commit
2. **Comments on the PR** that deployment has started
3. **Connects to the homelab over Tailscale**
4. **Sets up SSH access** with an injected private key
5. **SSHes into the production host**
6. **Fetches the latest `main` branch** in the prod repo
7. **Hard resets the prod repo to `origin/main`**
8. **Recreates the infrastructure layer** using:
   * `./infra-down.sh`
   * `./infra-up.sh`
9. **Restarts the application layer** using:
   * `./apps-restart.sh`
10. **Comments back on the PR** with either success or failure

On the production host, the workflow runs:

```bash
cd /apartmentlab/prod-repo/apartmentlab
git fetch origin main
git reset --hard origin/main
./infra-down.sh
./infra-up.sh
./apps-restart.sh

## CI/CD proof

The deployment pipeline is designed to report back directly into pull requests after a production deployment attempt. This gives visible proof that the workflow is actually running, whether the deployment succeeds or fails.

### Failed deployment example

* **PR #55** — `[preprod -> prod] Adjusted port & updated AIOstreams`
* Merged into `main`
* Deployment started automatically after merge
* PR comment reported: **`❌ Deployment FAILED`**

This shows the CI/CD pipeline does not just run silently. It detects and reports production deployment failures directly in the pull request.

### Successful deployment example

* **PR #56** — `Revert "[preprod -> prod] Adjusted port & updated AIOstreams"`
* Merged into `main`
* Deployment started automatically after merge
* PR comment reported: **`✅ Deployed to prod`**

This shows the same CI/CD pipeline can successfully deploy a rollback after a failed release.

### Additional successful deployment example

* **PR #57** — `[preprod -> prod] Updated AIOstreams and BentoPDF`
* Deployment started automatically after merge
* PR comment reported: **`✅ Deployed to prod`**

This confirms the pipeline is repeatable and not limited to a one-off success case.

## Current status

This repo is an active homelab and portfolio project. The setup is intentionally modular so more services can be added under `application/` or `infrastructure/` without changing the overall operating model.

## Notes

A few implementation details are worth knowing:

* Preprod exposes apps through `socat` sidecars and host ports.
* Prod application containers stay internal and rely on the infrastructure layer for external routing.
* The scripts use path-based environment detection, which keeps local operation simple but assumes a fixed filesystem layout.
* The deployment workflow is intentionally direct and favors clarity over heavy abstraction.

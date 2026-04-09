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
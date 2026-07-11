# devops-labs

Hands-on lab files for the **Cloud & DevOps Bootcamp**, organized by week. Copy a
folder to your Ubuntu box (or `git clone` this repo and `cd` in). Each folder is
self-contained with its own README.

## By week

| Week | Folder | What's inside |
|------|--------|----------------|
| **Week 1 — Linux** | `week-1-linux/` | Guided exercises (navigation, permissions, processes, services, SSH keys, cron, logs, monitoring) + a `setup-lab.sh` practice scaffold. |
| **Week 2 — NGINX** | `week-2-nginx/` | Static site, virtual hosts, reverse proxy, load balancing. Zero-dep Node apps + pm2/tmux launchers + a ready `demo.conf`. |
| **Week 3 — Networking & Git** | `week-3-networking-git/` | `networking-investigation.md` (dig/ping/traceroute/curl/ss) + `make-conflict.sh` and `branching-demo.sh`. |
| **Week 4 — Docker** | `week-4-docker/` | A simple Dockerfile, a multi-stage Dockerfile, and a Compose stack. |
| **Week 5 — Docker Compose** | `week-5-docker-compose/` | 6 progressive projects: hello → named volume → mongo-express → build-your-own → full-stack Notes app → **Next.js + MongoDB**. |
| **Week 8 — Kubernetes** | `week-8-kubernetes/` | K3s walkthrough: deploy → expose → scale → self-heal, imperative + declarative (`manifests/`). |

## Requirements
- **Docker** for the docker/compose labs: `curl -fsSL https://get.docker.com | sh`
- **Node** for the nginx demo apps
- Run shell scripts with `bash script.sh`

## A note on secrets
All credentials in these labs are **placeholder demo values** — safe to be public.
Real secrets belong in a `.env` file, which is **git-ignored**. Where a lab needs
one, copy the provided `.env.example` and fill in your own values:

```bash
cp .env.example .env
```

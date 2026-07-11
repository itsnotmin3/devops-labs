# devops-labs

Hands-on lab files for the **Cloud & DevOps Bootcamp**, organized by week. Copy a
folder to your Ubuntu box (or `git clone` this repo and `cd` in). Each folder is
self-contained with its own README.

## By week

| Week | Folder | What's inside |
|------|--------|----------------|
| **Week 2 — NGINX** | `week-2-nginx/` | Static site, virtual hosts, reverse proxy, load balancing. Zero-dep Node apps + pm2/tmux launchers + a ready `demo.conf`. |
| **Week 3 — Git** | `week-3-git/` | `make-conflict.sh` (live merge conflict) and `branching-demo.sh` (branch → merge → tag graph). |
| **Week 4 — Docker** | `week-4-docker/` | A simple Dockerfile, a multi-stage Dockerfile, and a Compose stack. |
| **Week 5 — Docker Compose** | `week-5-docker-compose/` | 6 progressive projects: hello → named volume → mongo-express → build-your-own → full-stack Notes app → **Next.js + MongoDB**. |

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

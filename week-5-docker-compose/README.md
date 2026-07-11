# Docker Compose labs

Six progressive Compose projects — start at 01 and build up to real full-stack
apps (including a Next.js + MongoDB app). Each folder is self-contained; `cd` in
and run it.

```
compose/
├── 01-hello-compose/     smallest possible file (nginx)
├── 02-named-volume/      persistence with a named volume (mongo)
├── 03-mongo-express/     multi-service + DNS by name (mongo + mongo-express)
├── 04-node-app/          build YOUR OWN app image with Compose (Node)
├── 05-fullstack-notes/   a real project: web -> api -> db (Notes app + .env)
└── 06-nextjs-mongo/      a tiny Next.js app (server built in) + MongoDB
```

Requires Docker (`curl -fsSL https://get.docker.com | sh`). Copy the folder up
with `scp -r labs/compose ubuntu@SERVER_IP:~/` or `git clone` the repo.

---

## 01 — Hello Compose
The smallest Compose file: one service.
```bash
cd 01-hello-compose
docker compose up -d
docker compose ps
curl -s localhost:8080 | head -4        # nginx welcome page
docker compose down
```

## 02 — Named volume (persistence)
Data survives `down`/`up` because it lives in a named volume.
```bash
cd 02-named-volume
docker compose up -d
docker compose exec db mongosh --eval 'db.demo.insertOne({hello:"world"})'
docker compose down                      # containers gone, VOLUME kept
docker compose up -d
docker compose exec db mongosh --eval 'db.demo.find()'   # still there!
docker compose down -v                   # -v wipes the volume (resets)
```

## 03 — Multi-service + DNS
Two services on one network; mongo-express reaches mongo by the name `db`.
```bash
cd 03-mongo-express
docker compose up -d
# open http://SERVER_IP:8081  (the Mongo web UI)
docker network inspect 03-mongo-express_default   # see both services on it
docker compose down -v
```
Note how mongo-express connects with `mongodb://admin:password@db:27017/` —
`db` is the service name, resolved by Compose DNS. No IPs, no manual network.

## 04 — Build your own app image
Compose builds a Node app from a Dockerfile via `build: ./app`.
```bash
cd 04-node-app
docker compose up -d --build
curl -s localhost:3000/api
# edit app/server.js, then:
docker compose up -d --build             # rebuilds the image
```

## 05 — Full-stack Notes project (with a .env)
A real app: an Nginx frontend that proxies to a Node API backed by MongoDB —
and the database credentials come from a git-ignored `.env` file.
```bash
cd 05-fullstack-notes
cp .env.example .env                     # Compose auto-reads .env (never commit it!)
docker compose up -d --build
# open http://SERVER_IP:8080 — add a few notes
docker compose logs -f api               # watch it hit mongo
docker compose restart api               # notes persist (they're in mongo)
docker compose down                      # stop (data KEPT)
docker compose up -d                     # ...notes are still there
docker compose down -v                   # wipe everything incl. the volume
```
Notes on this lab:
- The Mongo user/password live in `.env` and are referenced as `${MONGO_USER}` /
  `${MONGO_PASSWORD}` — no secrets are hard-coded in `compose.yaml`.
- `.env` is git-ignored; you commit `.env.example` with placeholder values instead.
- Only `web` publishes a port (8080). The api and db stay private on the Compose
  network — exactly how you keep a backend and database internal in production.

## 06 — Next.js + MongoDB (server built into the app)
A tiny modern app: Next.js (App Router) with its server integrated via a Server
Action — it reads and writes MongoDB directly, no separate backend service.
```bash
cd 06-nextjs-mongo
docker compose up -d --build             # first build takes ~a minute
# open http://SERVER_IP:3000 — post a message, it saves to Mongo
docker compose logs -f web
docker compose down                      # messages persist (in the volume)
docker compose up -d                     # ...still there
docker compose down -v                   # wipe it
```
Notes on this lab:
- The "server" is the Next.js app itself (a Server Action) — students usually
  build exactly this shape now.
- A multi-stage Dockerfile uses Next's `output: 'standalone'` for a small image.
- The app talks to MongoDB at `mongodb://db:27017` — `db` is the service name.

---

### Reset any lab
```bash
docker compose down -v      # from inside that lab's folder
```

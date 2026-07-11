# Docker Compose demo — web → api → mongo

A real three-service stack wired together by Compose:

```
Browser → web (nginx :8080) → api (Node/Express :3000) → db (MongoDB)
                                    proxies /api            persistent volume
```

- **web** (nginx) serves a page and proxies `/api` to the api service
- **api** (Node) increments a visit counter stored in MongoDB
- **db** (MongoDB) keeps the count in a **named volume** so it survives restarts

Every service finds the others by **service name** (Compose DNS): the api connects to
`mongodb://db:27017`, nginx proxies to `http://api:3000`. No IP addresses.

## Run it
```bash
cd compose-demo
docker compose up -d --build     # build the api image + start all 3 services
docker compose ps                # all three "running"
```
Open **http://SERVER_IP:8080** and click the button — the counter climbs.

```bash
docker compose logs -f api       # watch the api (and its mongo retry) logs
docker compose exec api ping db  # api reaches the db BY NAME
```

## Show off the key ideas

**Service DNS** — the api talks to `db`, nginx talks to `api`, all by name.

**Persistence (the volume)** — the counter lives in Mongo:
```bash
docker compose restart api       # counter is unaffected
docker compose down              # stop everything (volume KEPT)
docker compose up -d             # ...count continues where it left off
```

**Reset the data** — remove the volume:
```bash
docker compose down -v           # deletes dbdata → counter resets to 1
```

## Files
```
compose-demo/
├── docker-compose.yml   # the 3 services + network + volume
├── api/                 # Node + MongoDB (built from a Dockerfile)
│   ├── server.js
│   ├── package.json
│   └── Dockerfile
└── web/
    ├── index.html       # frontend that calls /api
    └── nginx.conf       # serves static + proxies /api → api:3000
```

> Note: only **web** publishes a port (8080). The api and db stay on the internal
> Compose network — exactly how you'd keep a backend and database private in prod.

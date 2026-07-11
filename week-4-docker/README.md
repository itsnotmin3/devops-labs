# Docker walkthrough labs

Two tiny apps for demoing Dockerfiles live. Copy this folder to your Ubuntu box:

```bash
scp -r labs/docker ubuntu@SERVER_IP:~/
ssh ubuntu@SERVER_IP
cd docker
```

Requires Docker installed (`curl -fsSL https://get.docker.com | sh`).

```
docker/
├── node-api/       # SIMPLE single-stage Dockerfile (Express API)
├── web-frontend/   # MULTI-STAGE Dockerfile (node build → nginx)
└── compose-demo/   # DOCKER COMPOSE: web → api → mongo (see its own README)
```

---

## 1) Simple Dockerfile — `node-api`

```bash
cd node-api

docker build -t node-api .            # watch each layer build
docker images node-api                # see the image + size
docker run -d -p 3000:3000 --name api node-api

curl localhost:3000/api               # {"message":"Hello from inside the container",...}
curl localhost:3000/health            # OK
docker logs api                       # the app's stdout
docker exec -it api sh                # step inside the container
```

**Show layer caching** — edit `server.js`, then rebuild:
```bash
docker build -t node-api .            # npm install layer is CACHED → build is instant
```
Point out the `CACHED` lines: because `package.json` was copied before the source,
the slow `npm install` layer is reused.

Clean up: `docker rm -f api`

---

## 2) Multi-stage Dockerfile — `web-frontend`

```bash
cd ../web-frontend

docker build -t web-frontend .        # stage 1 builds, stage 2 = nginx + dist only
docker run -d -p 8080:80 --name web web-frontend
curl -s localhost:8080 | head         # the built page (open http://SERVER_IP:8080)
```

**Show the size win** — build only the (fat) build stage and compare:
```bash
docker build --target build -t web-build .   # just stage 1 (node + deps + source)
docker images | grep -E "web-frontend|web-build"
# web-build   ~180MB   (node + everything)
# web-frontend ~25MB   (nginx + the built files ONLY)
```
That difference is the whole point of multi-stage builds.

Clean up: `docker rm -f web`

---

## 3) Docker Compose — `compose-demo`

A full three-service stack (nginx → Node API → MongoDB) wired by Compose, with
service-name DNS and a persistent volume. See `compose-demo/README.md` for the
full walkthrough. Quick start:

```bash
cd ../compose-demo
docker compose up -d --build
docker compose ps
# open http://SERVER_IP:8080 and click the button — the visit counter climbs

docker compose down -v    # tear down (and reset the DB volume)
```

---

## Handy cleanup
```bash
docker ps -a                 # everything
docker rm -f api web         # remove containers
docker image prune -f        # remove dangling images
```

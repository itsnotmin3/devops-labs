# NGINX demo apps & static sites

Tiny, **zero-dependency** apps for the live NGINX session — no `npm install`,
just Node. Use them to demo serving static files, reverse proxying, virtual
hosts, and load balancing.

```
labs/nginx/
├── app.js               # parameterized backend (PORT/NAME/COLOR) — reverse proxy + LB
├── api.js               # second service (JSON) — for "location /api/" routing
├── ecosystem.config.js  # pm2: starts backend + 3 LB instances + api
├── start-tmux.sh        # same, but in a tmux session
├── demo.conf            # ready-made NGINX config for ALL the demos below
├── static-site/index.html   # plain static site
├── site-a/index.html        # virtual host: sitea.local (green)
└── site-b/index.html        # virtual host: siteb.local (purple)
```
(Docker and Git walkthroughs live in the sibling `labs/docker/` and `labs/git/` folders.)

## One-shot NGINX config

`demo.conf` already contains every server block (static site, virtual hosts,
reverse proxy, load balancing, `/api/` routing) so you don't type them live:

```bash
pm2 start ecosystem.config.js                 # apps up first
sudo cp -r static-site site-a site-b /var/www/
sudo cp demo.conf /etc/nginx/sites-available/demo.conf
sudo ln -s /etc/nginx/sites-available/demo.conf /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default    # avoid default_server clash
sudo nginx -t && sudo systemctl reload nginx
```

Test without touching DNS, using a Host header:
```bash
curl http://SERVER_IP/                          # static site
curl -H "Host: sitea.local" http://SERVER_IP/   # Site A
curl -H "Host: app.local"   http://SERVER_IP/   # load-balanced (run it a few times!)
curl -H "Host: app.local"   http://SERVER_IP/api/users
```
Tip: comment out sections of `demo.conf` to reveal them one at a time as you teach.

## Get them onto the server
```bash
# either clone the repo…
git clone https://github.com/itsnotmin3/devops.git
cd devops/labs/nginx
# …or copy just this folder up:
#   scp -r labs/nginx ubuntu@SERVER_IP:~/
node -v                                 # make sure Node is installed
```
Install Node if needed: `sudo apt update && sudo apt install -y nodejs`.

---

## Run the apps

### Option A — pm2 (recommended)
```bash
sudo npm install -g pm2        # once
pm2 start ecosystem.config.js  # starts all 5 processes
pm2 list                       # see them
pm2 logs                       # watch output
pm2 delete all                 # stop & remove everything
```

### Option B — tmux
```bash
bash start-tmux.sh             # launches each app in its own tmux window
tmux attach -t nginx-demo      # Ctrl-b then 0/1/2/3/4 to switch windows
tmux kill-session -t nginx-demo
```

### Option C — manual (one terminal each)
```bash
PORT=3000 NAME=Backend  COLOR=#2563eb node app.js
PORT=3001 NAME="Server 1" COLOR=#16a34a node app.js
PORT=3002 NAME="Server 2" COLOR=#9333ea node app.js
PORT=3003 NAME="Server 3" COLOR=#ea580c node app.js
PORT=4000 node api.js
```

Quick check: `curl localhost:3001` and `curl localhost:3001/api/info`.

---

## How each maps to the NGINX session

**Serve a static site** — point NGINX `root` at the folder:
```nginx
server { listen 80; server_name _; root /home/ubuntu/labs/static-site; index index.html; }
```

**Virtual hosts** — two sites by hostname (add both to /etc/hosts for local testing):
```nginx
server { listen 80; server_name sitea.com; root /home/ubuntu/labs/site-a; index index.html; }
server { listen 80; server_name siteb.com; root /home/ubuntu/labs/site-b; index index.html; }
```

**Reverse proxy** — front the backend on 3000:
```nginx
server {
  listen 80; server_name app.example.com;
  location / { proxy_pass http://127.0.0.1:3000; proxy_set_header Host $host; }
}
```

**Load balancing** — refresh and watch the colour/port change each time:
```nginx
upstream demo { server 127.0.0.1:3001; server 127.0.0.1:3002; server 127.0.0.1:3003; }
server {
  listen 80; server_name app.example.com;
  location / { proxy_pass http://demo; proxy_set_header Host $host; }
}
```

**Path routing to the API** — send `/api/` to the api service on 4000:
```nginx
location /api/ { proxy_pass http://127.0.0.1:4000; }
```

> Each `app.js` page shows its own **port, name, colour, and a request counter**,
> so during the load-balancing demo students literally see NGINX rotate between
> Server 1 → 2 → 3 on every refresh.

### Endpoints
- `app.js`: `/` (HTML), `/health` (OK), `/api/info` (JSON)
- `api.js`: `/api/time`, `/api/users`, `/health`

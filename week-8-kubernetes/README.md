# Week 8 — Kubernetes lab (K3s)

The hands-on half of Session 25. Run a real one-node Kubernetes cluster with
**K3s**, then work through each object — Pod, Deployment, Service, Ingress —
the same YAML you saw in the session, applied with `kubectl`.

Do this on an Ubuntu VM or cloud VPS (needs ~1 GB RAM).

```
week-8-kubernetes/
├── manifests/
│   ├── pod.yaml          the smallest unit
│   ├── deployment.yaml   3 replicas — what you actually run
│   ├── service.yaml      a stable address (NodePort)
│   ├── ingress.yaml      hostname/path routing over HTTP (Traefik)
│   └── ingress-tls.yaml  the same Ingress + HTTPS (TLS)
└── README.md
```

---

## 1. Install K3s

```bash
curl -sfL https://get.k3s.io | sh -          # a 1-node cluster in ~30s
```

Make `kubectl` work without sudo:
```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
kubectl get nodes                            # STATUS should be Ready
```
(Or just prefix everything with `sudo k3s kubectl ...`.)

---

## Step 1 — a Pod (the smallest unit)

```bash
kubectl apply -f manifests/pod.yaml
kubectl get pods                             # web  1/1  Running
kubectl logs web                             # the container's logs
kubectl delete pod web                       # delete it — and it stays gone
```
A bare Pod does not come back. That is why you use a Deployment.

## Step 2 — a Deployment (what you actually run)

```bash
kubectl apply -f manifests/deployment.yaml   # 3 replicas
kubectl get pods                             # three web-xxxxx Pods

kubectl scale deployment web --replicas=5    # scaling is one number
kubectl get pods                             # now five
```

**Self-healing — the highlight:**
```bash
kubectl get pods                             # copy one Pod name
kubectl delete pod <pod-name>                # break it on purpose
kubectl get pods -w                          # WATCH: a replacement appears in seconds
```
You deleted a Pod, but the desired state is still 5, so a control loop
immediately creates a new one — no human action. That is self-healing.

> `kubectl apply` is idempotent: run it again with no change and nothing
> happens; edit `replicas` and re-apply and it reconciles the difference —
> exactly like Terraform.

## Step 3 — a Service (a stable address)

```bash
kubectl apply -f manifests/service.yaml
kubectl get svc web                          # note the 80:3xxxx NodePort
curl localhost:3xxxx                          # or http://SERVER_IP:3xxxx in a browser
```
Pods get new IPs every time they are replaced; the Service is the one address
that never changes, load-balancing across all the healthy Pods.

## Step 4 — an Ingress over HTTP (no SSL yet)

K3s ships the **Traefik** ingress controller, so Ingress works out of the box.
Get plain HTTP working first — TLS is a small add-on in Step 4b.
```bash
kubectl apply -f manifests/ingress.yaml
kubectl get ingress
curl -H "Host: app.example.com" http://localhost/    # Traefik routes it to the web Service
```

## Step 4b — the same Ingress, now with HTTPS (TLS)

Serving HTTPS does not rewrite the Ingress — you add one `tls:` block that
points at a Secret holding a certificate. `ingress-tls.yaml` is `ingress.yaml`
plus that block, reusing the name `web` so it upgrades the HTTP Ingress in place.

For a self-contained demo (no real domain needed), make a **self-signed**
certificate and store it in a Secret called `web-tls`:
```bash
# 1. generate a self-signed cert + key for app.example.com
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=app.example.com" \
  -addext "subjectAltName=DNS:app.example.com"

# 2. store them in a TLS Secret (type kubernetes.io/tls)
kubectl create secret tls web-tls --cert=tls.crt --key=tls.key

# 3. apply the TLS Ingress (same object name → upgrades the HTTP one)
kubectl apply -f manifests/ingress-tls.yaml
```

Test it. `--resolve` makes curl send the right TLS name (SNI) so Traefik serves
the app.example.com cert; `-k` accepts the self-signed one:
```bash
curl -k --resolve app.example.com:443:127.0.0.1 https://app.example.com/
```
You get the Nginx page over HTTPS. A browser will warn "not trusted" because the
cert is self-signed — that is expected for a local demo.

> **Real, auto-renewing certificates.** For a public domain you do not make certs
> by hand. Either install **cert-manager** (it requests Let's Encrypt certs and
> writes them into `web-tls` for you), or use **Traefik's built-in ACME resolver**
> on K3s. Both need the domain's DNS pointing at the node and ports 80/443 open;
> the Ingress YAML barely changes. The course site (Session 25) has the full code.

## Step 5 — roll out an update, and undo it

```bash
kubectl set image deployment/web web=nginx:1.27   # new version
kubectl rollout status deployment/web             # replaces Pods gradually, no downtime
kubectl rollout undo deployment/web               # bad release? one command back
```

---

## See everything you built

```bash
kubectl get all
```

## Cleanup

```bash
kubectl delete -f manifests/ --ignore-not-found   # remove everything you applied
kubectl delete secret web-tls --ignore-not-found  # the TLS cert Secret
/usr/local/bin/k3s-uninstall.sh                   # remove K3s entirely
```

> Every command here runs identically on managed Kubernetes (EKS, GKE, AKS) —
> only the cluster underneath changes.

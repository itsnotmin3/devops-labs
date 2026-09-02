# Week 8 — Kubernetes lab (K3s)

The hands-on half of Session 25. Run a real one-node Kubernetes cluster with
**K3s**, then work through each object — Pod, Deployment, Service, Ingress,
ConfigMap/Secret — the same YAML you saw in the session, applied with `kubectl`.

Do this on an Ubuntu VM or cloud VPS (needs ~1 GB RAM).

```
week-8-kubernetes/
├── manifests/
│   ├── pod.yaml          the smallest unit
│   ├── deployment.yaml   3 replicas — what you actually run
│   ├── service.yaml      a stable address (NodePort)
│   ├── ingress.yaml      hostname/path routing (Traefik, built into K3s)
│   └── config.yaml       a ConfigMap + a Secret
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

## Step 4 — an Ingress (hostname/path routing)

K3s ships the **Traefik** ingress controller, so Ingress works out of the box.
```bash
kubectl apply -f manifests/ingress.yaml
kubectl get ingress
curl -H "Host: app.example.com" http://localhost/    # Traefik routes it to the web Service
```

## Step 5 — config outside the image

```bash
kubectl apply -f manifests/config.yaml       # a ConfigMap + a Secret
```
Add them to the Deployment's container as environment variables — put this
under the container in `manifests/deployment.yaml`:
```yaml
          envFrom:
            - configMapRef: { name: web-config }
            - secretRef: { name: web-secret }
```
Re-apply and check they landed inside a Pod:
```bash
kubectl apply -f manifests/deployment.yaml
kubectl exec deploy/web -- printenv | grep -E "APP_ENV|API_KEY"
# APP_ENV=production
# API_KEY=super-secret-value
```

## Step 6 — roll out an update, and undo it

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
kubectl delete -f manifests/                 # remove everything you applied
/usr/local/bin/k3s-uninstall.sh              # remove K3s entirely
```

> Every command here runs identically on managed Kubernetes (EKS, GKE, AKS) —
> only the cluster underneath changes.

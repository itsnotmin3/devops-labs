# Week 8 — Kubernetes lab (K3s)

Run a real single-node Kubernetes cluster with **K3s**, then deploy, expose,
scale, and watch it self-heal. Do this on an Ubuntu VM or cloud VPS (needs ~1GB RAM).

## 1. Install K3s (a lightweight, certified Kubernetes)
```bash
curl -sfL https://get.k3s.io | sh -          # installs a 1-node cluster in ~30s
```

Make `kubectl` work without sudo:
```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
kubectl get nodes                            # STATUS should be Ready
```
(You can also just prefix everything with `sudo k3s kubectl ...`.)

---

## Lab A — the imperative way (quick)
```bash
kubectl create deployment nginx --image=nginx   # create a Deployment
kubectl get deployments
kubectl get pods                                 # one Pod running

kubectl expose deployment nginx --port=80 --type=NodePort   # a Service
kubectl get svc                                  # note the 80:3xxxx NodePort

kubectl scale deployment nginx --replicas=3      # scale out
kubectl get pods                                 # now three Pods
```

## Lab B — the declarative way (how you do it for real)
The same thing, but from YAML you can commit to git:
```bash
kubectl apply -f manifests/deployment.yaml       # 3 replicas
kubectl apply -f manifests/service.yaml          # NodePort service
kubectl get all
```
Edit `manifests/deployment.yaml` (change `replicas: 3` to `5`), then:
```bash
kubectl apply -f manifests/deployment.yaml       # Kubernetes reconciles to 5
kubectl get pods
```

## Access the app
```bash
kubectl get svc nginx                            # find the NodePort (e.g. 31544)
curl localhost:31544                             # or http://SERVER_IP:31544 in a browser
```

## Self-healing — the highlight
```bash
kubectl get pods                                 # copy one Pod name
kubectl delete pod <pod-name>                    # break it on purpose
kubectl get pods -w                              # WATCH: a replacement appears in seconds
```
You deleted a Pod, but the Deployment's desired state is still 3 (or 5), so a
control loop immediately creates a new one. That is self-healing — no human action.

---

## Cleanup
```bash
kubectl delete -f manifests/                     # remove what you applied
# or, if you used Lab A:
kubectl delete service nginx && kubectl delete deployment nginx

# uninstall K3s entirely:
/usr/local/bin/k3s-uninstall.sh
```

## Files
```
week-8-kubernetes/
├── README.md
└── manifests/
    ├── deployment.yaml   # nginx Deployment, 3 replicas
    └── service.yaml      # NodePort Service in front of it
```

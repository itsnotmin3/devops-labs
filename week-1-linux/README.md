# Week 1 — Linux labs

Practice the Linux **fundamentals** (Session 2) and **administration** (Session 3)
on a real Ubuntu box — a VM (VirtualBox/VMware), a cloud VPS, or WSL on Windows.

## Setup
```bash
bash setup-lab.sh          # creates ~/linux-lab with practice files
cd ~/linux-lab && ls -la
```

---

## Lab 1 — Navigation & files
```bash
pwd                        # where am I?
ls -la                     # list everything (incl. hidden)
mkdir -p projects/src && cd projects
touch src/index.js .env
cat ../logs/app.log
grep -rn "ERROR" ~/linux-lab/logs      # find errors
find ~/linux-lab -name "*.log"         # find all logs
```
**Challenge:** create `projects/{client,server}`, add a `README.md` in each, then
list the whole tree.

## Lab 2 — Permissions & ownership
```bash
cd ~/linux-lab
ls -l secret.env deploy.sh   # note they are 644 (world-readable) — not good
chmod 600 secret.env         # secrets: owner only
chmod +x deploy.sh           # make the script runnable
ls -l secret.env deploy.sh   # verify
sudo chown $USER:$USER deploy.sh
```
**Challenge:** map the numbers — what is `chmod 750`? Set `deploy.sh` to it and read
the `-rwxr-x---` output.

## Lab 3 — Processes & services
```bash
ps -ef | head                # running processes
top                          # live view (q to quit)  — or: htop
sudo apt update && sudo apt install -y nginx
sudo systemctl status nginx  # is it running?
sudo systemctl restart nginx # restart after a config change
sudo systemctl enable nginx  # start on boot
```
**Challenge:** find nginx's PID with `ps -ef | grep nginx`, then read what
`sudo systemctl status nginx` shows about memory and uptime.

## Lab 4 — SSH keys
```bash
ssh-keygen -t ed25519 -C "you@example.com"   # generate a key pair
ls -l ~/.ssh                                 # id_ed25519 (private) + .pub (public)
chmod 600 ~/.ssh/id_ed25519                  # lock the private key
# ssh-copy-id user@server   # then: ssh user@server  (no password)
```

## Lab 5 — Cron
```bash
crontab -e
# add this line, save, exit:
#   * * * * * date >> $HOME/cron.log
tail -f ~/cron.log           # watch it append every minute (Ctrl+C to stop)
crontab -l                   # list your jobs
```

## Lab 6 — Logs, disk & monitoring
```bash
tail -f /var/log/syslog                 # system log (Ctrl+C to stop)
sudo journalctl -u nginx -n 20          # nginx service log
sudo tail -f /var/log/nginx/access.log  # requests, live (curl localhost in another shell)
df -h                                   # disk usage
free -h                                 # memory
du -sh ~/linux-lab/*                    # size of each folder
```

---

## Troubleshooting challenge — "the website is down"
Work the checklist instead of guessing:
```bash
systemctl status nginx                       # 1. is the web server up?
ps -ef | grep node                           # 2. is the app process up?
df -h                                        # 3. is the disk full?
free -h                                      # 4. out of memory?
sudo tail -f /var/log/nginx/error.log        # 5. what do the logs say?
```

### Reset
```bash
rm -rf ~/linux-lab ~/cron.log && crontab -r   # (crontab -r removes ALL your cron jobs)
```

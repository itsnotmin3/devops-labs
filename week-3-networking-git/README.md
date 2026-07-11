# Git walkthrough lab

Two scripts + a command cheat-sheet for demoing git live. Copy to Ubuntu:

```bash
scp -r labs/git ubuntu@SERVER_IP:~/
ssh ubuntu@SERVER_IP && cd git
```

Run scripts with `bash script.sh` (avoids CRLF shebang issues).

---

## A) The basics (type these live)

```bash
mkdir demo && cd demo
git init
git config user.name "You" && git config user.email you@example.com

echo "# Demo" > README.md
git status                     # untracked
git add README.md
git commit -m "chore: init"

echo "line two" >> README.md
git diff                       # what changed
git add . && git commit -m "docs: add a line"
git log --oneline              # history
```

## B) Branching & merging  →  `branching-demo.sh`

```bash
bash branching-demo.sh
# it scaffolds a repo, branches, commits, merges (--no-ff), tags v1.0.0,
# then prints:  git log --oneline --graph --all --decorate
```
Or do it by hand:
```bash
git checkout -b feature/login
# ...edit files...
git commit -am "feat: add login"
git checkout main
git merge feature/login
```

## C) Merge conflicts  →  `make-conflict.sh`

```bash
bash make-conflict.sh          # builds a repo where main & feature edit the same line
cd /tmp/git-conflict-demo
git merge feature              # >>> CONFLICT <<<
cat config.js                  # see the <<<<<<< ======= >>>>>>> markers
nano config.js                 # keep the version you want, delete the 3 markers
git add config.js
git commit --no-edit           # conflict resolved
```

## D) Merge vs Rebase

```bash
# in a feature branch, bring in the latest main:
git merge main                 # keeps history + a merge commit
# ...or...
git rebase main                # replays your commits on top (linear history)
git rebase --continue          # after fixing any conflicts

# GOLDEN RULE: never rebase commits you've already pushed / shared.
```

## E) Tags & rollback (the DevOps bit)

```bash
git tag -a v1.2.0 -m "release 1.2.0"
git push origin v1.2.0         # a CI/CD pipeline builds & deploys this tag
git checkout v1.1.0            # roll back by redeploying a previous tag
```

## F) Connect to GitHub

```bash
git remote add origin git@github.com:you/repo.git
git branch -M main
git push -u origin main
```

---

### Reset a demo repo quickly
```bash
rm -rf /tmp/git-conflict-demo /tmp/git-branch-demo demo
```

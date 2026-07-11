#!/usr/bin/env bash
# Scaffolds a clean repo and walks through branch -> commit -> merge -> tag,
# then prints the history graph. Run with:  bash branching-demo.sh
set -e

DIR=${1:-/tmp/git-branch-demo}
rm -rf "$DIR"; mkdir -p "$DIR"; cd "$DIR"

git init -q
git config user.email demo@demo.com
git config user.name  "Demo"

printf '# My App\n' > README.md
git add . && git commit -qm "chore: init project"
git branch -M main

printf 'console.log("app started")\n' > app.js
git add . && git commit -qm "feat: add app entrypoint"

# feature branch
git checkout -qb feature/login
printf 'function login(){ /* ... */ }\n' >> app.js
git commit -qam "feat: add login function"

# merge it back
git checkout -q main
git merge -q --no-ff feature/login -m "merge: login feature"

# tag a release
git tag -a v1.0.0 -m "release 1.0.0"

echo
echo "Repo ready at: $DIR"
echo "History graph:"
echo "-------------------------------------------"
git log --oneline --graph --all --decorate
echo "-------------------------------------------"
echo "Tags:  $(git tag)"

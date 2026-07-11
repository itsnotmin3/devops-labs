#!/usr/bin/env bash
# Creates a fresh repo with a guaranteed MERGE CONFLICT, so you can demo
# resolving it live. Run with:  bash make-conflict.sh
set -e

DIR=${1:-/tmp/git-conflict-demo}
rm -rf "$DIR"; mkdir -p "$DIR"; cd "$DIR"

git init -q
git config user.email demo@demo.com
git config user.name  "Demo"

# base commit on main
printf 'const PORT = 3000;\n' > config.js
git add . && git commit -qm "initial: PORT 3000"
git branch -M main

# feature branch changes the SAME line
git checkout -qb feature
printf 'const PORT = 5000;\n' > config.js
git commit -qam "feature: PORT 5000"

# main changes the SAME line differently
git checkout -q main
printf 'const PORT = 8080;\n' > config.js
git commit -qam "main: PORT 8080"

echo
echo "Repo ready at: $DIR   (on branch main)"
echo "Now demo the conflict:"
echo "    cd $DIR"
echo "    git merge feature      # <-- this CONFLICTS"
echo "    cat config.js          # see the <<<<<<< ======= >>>>>>> markers"
echo "    # edit config.js to the version you want, remove the markers, then:"
echo "    git add config.js && git commit --no-edit"

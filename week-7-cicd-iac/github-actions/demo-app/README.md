# CI demo app — push it to a new repo and watch the pipeline run

A tiny, dependency-free app with a real test, a Dockerfile, and a complete
GitHub Actions pipeline already inside it at `.github/workflows/ci.yml`. Copy it
into a fresh repo, push, and the Actions tab runs the whole thing live.

```
demo-app/
├── .github/workflows/ci.yml   the pipeline (test -> build -> push image)
├── server.js                  the app + a pure function to test
├── test/app.test.js           the test
├── package.json               lint / test / build scripts
├── package-lock.json          so `npm ci` is exact
└── Dockerfile                 multi-stage image build
```

---

## Show it live

**1. Make a new, empty GitHub repo** — call it something lowercase like
`ci-demo` (GHCR image names must be lowercase). Do not add a README from the
GitHub UI, so the repo starts empty.

**2. Copy the CONTENTS of this folder into a new local folder and push:**

```bash
# from a fresh directory containing a copy of these files:
git init -b main
git add .
git commit -m "ci: demo app + pipeline"
git remote add origin https://github.com/<you>/ci-demo.git
git push -u origin main
```

**3. Open the repo on GitHub → the Actions tab.** The `CI` workflow is already
running: you will see the `test` job go green (lint, test, build), then the
`docker` job build and push an image.

**4. Look at the Packages section** of the repo — there is now a container
image tagged `latest` and with the commit SHA. That SHA tag is the artifact:
its name tells you exactly which commit produced it.

---

## The demo moments worth performing

**A pull request that fails.** Open `test/app.test.js`, change `1080` to `1081`
so the test is wrong, commit on a branch, and open a pull request:

```bash
git checkout -b break-the-test
# edit test/app.test.js …
git commit -am "break a test on purpose"
git push -u origin break-the-test
# open the PR on GitHub
```

The Actions run on the PR goes **red**, and GitHub blocks the merge with the
failing check right there on the pull request. Fix the number, push again, and
it goes green. That is the whole point of CI: the mistake is caught before it
reaches `main`.

**The gate.** Notice the `docker` job only runs on a push to `main`, never on a
PR (`if: github.ref == 'refs/heads/main'`). Pull requests get tested; only
merges get an image built. That is continuous delivery in one `if:`.

**Pull the image you just built** (after the docker job finishes):

```bash
docker run --rm -p 3000:3000 ghcr.io/<you>/ci-demo:latest
curl localhost:3000/health
# {"status":"ok","version":"dev"}
```

> If the image is private and the pull is denied, make the package public under
> the repo's Packages settings, or `docker login ghcr.io` with a token.

---

## Run the pipeline locally first (optional, with `act`)

You can run the workflow on your own machine before pushing, using
[`act`](https://github.com/nektos/act) (it executes the workflow in Docker):

```bash
# install once: https://nektosact.com
act pull_request            # runs the "test" job exactly as GitHub would
act -j test                 # or just that job by name
```

Great for a live demo with no network round-trip — the same YAML GitHub runs.

---

## How this maps to Session 19

| In the pipeline | Session 19 idea |
|-----------------|-----------------|
| `on: [push, pull_request]` | the **trigger** — the git event starts everything |
| `jobs: test / docker` | **jobs** run on fresh runners; `needs:` orders them |
| `steps:` with `run:` | **steps** — a shell command or a reusable action |
| `actions/checkout@v4` | an **action** someone already wrote |
| `secrets.GITHUB_TOKEN` | a **secret** injected at runtime, never in the repo |
| `if: … == 'refs/heads/main'` | the **gate** — PRs test, only main deploys |
| SHA image tag | the **artifact** with an identity you can roll back to |

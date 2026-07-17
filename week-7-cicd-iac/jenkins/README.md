# Jenkins — Session 20

The self-hosted half of the industry. GitHub Actions gave you the machines;
Jenkins is what you run yourself — your server, your plugins, your backups,
your outage at 3am.

Same concepts as Session 19. Different words, and a lot more responsibility.

```
jenkins/
├── docker-compose.yml   Jenkins in a container, with Docker access
├── Dockerfile           jenkins + docker CLI + node (the stock image has neither)
├── plugins.txt          pre-installed so nobody sits through the wizard
├── app/                 a tiny real app so the pipelines build something
└── pipelines/           7 Jenkinsfiles — start at 01, add one idea at a time
```

---

## Start Jenkins

```bash
cd week-7-cicd-iac/jenkins
docker compose up -d --build          # first build takes a few minutes
docker compose logs -f jenkins        # the setup password prints in here
```

Then open **http://localhost:8080** and paste the password. It also lives at:

```bash
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Choose **Install suggested plugins**, create the admin user, and you are in.

> **If `docker build` fails inside a pipeline** with `permission denied ...
> /var/run/docker.sock`, the jenkins user is not in your host's docker group.
> Find the real group id and rebuild:
> ```bash
> getent group docker | cut -d: -f3        # e.g. 999
> docker compose build --build-arg DOCKER_GID=999
> docker compose up -d
> ```

Stop it (your jobs survive — they are in a named volume):
```bash
docker compose down
```
Wipe it completely and start over:
```bash
docker compose down -v
```

---

## Run a pipeline

For **01** and **02**, the fastest path is to paste the script in:

1. **New Item** → name it → **Pipeline** → OK
2. Scroll to **Pipeline** → Definition: **Pipeline script**
3. Paste the contents of `pipelines/01-hello/Jenkinsfile`
4. **Save** → **Build Now**
5. Click the build number → **Console Output**

For **03 onward** the pipeline needs the `app/` folder in its workspace, so
point Jenkins at a repo instead:

1. **New Item** → **Pipeline**
2. Definition: **Pipeline script from SCM** → SCM: **Git**
3. Repository URL: your fork of this labs repo
4. Script Path: `week-7-cicd-iac/jenkins/pipelines/03-node-ci/Jenkinsfile`
5. **Save** → **Build Now**

> Jenkins clones the repo into the workspace, so `dir('app')` in the
> Jenkinsfile needs the path to match. If your Script Path is nested as above,
> change `dir('app')` to `dir('week-7-cicd-iac/jenkins/app')` — or just copy
> the `app/` folder to your own repo root, which is closer to real life.

---

## The labs

| # | Teaches | New idea |
|---|---------|----------|
| 01 | `pipeline / agent / stages / steps` | The smallest valid Jenkinsfile |
| 02 | Multiple stages, `environment`, `post` | What happens when a stage fails |
| 03 | A real CI: install → lint → test → build | `npm ci`, JUnit reports, `cleanWs()` |
| 04 | `parallel` and `when` | Buy back wall-clock; branch-conditional stages |
| 05 | `credentials()` and `withCredentials` | Secrets — and why masking is not security |
| 06 | Build + scan + push an image | Tag by commit SHA, never `latest` |
| 07 | The whole thing, with a human gate | `input` — the line between delivery and deployment |

Work through them **in order**. Each one is the previous one plus one idea.

---

## The mental model

```
Jenkinsfile (in your repo)
  └── pipeline
        ├── agent          WHERE it runs
        ├── environment    variables for every stage
        ├── stages
        │     └── stage    a named phase (a box in the UI)
        │           └── steps
        │                 └── sh / echo / git   one thing to do
        └── post           runs after — always / success / failure
```

## Jenkins ⇄ GitHub Actions

| Jenkins | GitHub Actions |
|---------|----------------|
| `pipeline { }` | the workflow file |
| `agent` | `runs-on` |
| `stage` | `job` |
| `steps` | `steps` |
| `environment` | `env:` |
| `credentials('id')` | `${{ secrets.NAME }}` |
| `when { branch 'main' }` | `if: github.ref == 'refs/heads/main'` |
| `parallel { }` | jobs are parallel by default |
| `post { always { } }` | `if: always()` |
| a plugin | an action from the marketplace |

The concepts transfer completely. **What does not transfer is who is
responsible.**

---

## What self-hosting actually costs you

These are not footnotes — they are the reason the choice matters, and every
one of them shows up in the labs:

- **The workspace is reused.** GitHub gives you a clean VM every run. Jenkins
  gives you the same directory until you call `cleanWs()`. A stale file from
  build 41 breaking build 42 is the classic self-hosted ghost.
- **Nothing is installed.** No node, no docker, no python — unless you put it
  there. That is what the `Dockerfile` here is.
- **The disk is yours.** Jenkins keeps every build forever by default and
  Docker leaves layers behind. Use `buildDiscarder` and prune, or the box dies
  of a full disk in about three months.
- **Plugins are the product and the risk.** Everything is a plugin; plugins
  need updating; an update can break your pipelines on a Tuesday.
- **Backups are your problem.** `/var/jenkins_home` is the whole world — jobs,
  config, credentials, history. If it is not backed up, it does not exist.

## So why does anyone use it?

Because sometimes owning the machine is the requirement, not the compromise:
code that may never leave the building, an air-gapped network, a compliance
regime, hardware nobody rents, or fifteen years of pipelines that work.

Jenkins is older than most of the tools in this course and still runs an
enormous amount of enterprise CI. Not out of nostalgia — out of constraints.

---

⚠️ **This setup is a lab, not a template.** It mounts the host Docker socket
into the container, which is a straightforward privilege escalation: anything
that can talk to that socket is effectively root on the host. Fine on your
laptop for an afternoon. Never on a server that matters.

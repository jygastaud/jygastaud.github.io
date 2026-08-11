+++
title = "Running GitLab CI on Cloudflare Workers & Containers: a custom GitLab Runner executor"
Description = """
Can Cloudflare's serverless platform replace the VMs/Kubernetes behind a GitLab Runner fleet?

This project explores the question with a GitLab Runner Custom Executor that hands CI job execution off to a Cloudflare Worker driving Cloudflare Containers, with image builds handled by Kaniko.

Why this approach, what works today, and what's still open.
"""

Tags = ["GitLab", "GitLab Runner", "CI/CD", "Cloudflare", "Cloudflare Workers", "Cloudflare Containers", "Go", "Kaniko", "Serverless"]
Categories = ["DevOps"]
image = ""
aliases = []
date = 2026-08-11T10:00:00+02:00
lastmod = 2026-08-11T10:00:00+02:00

+++

GitLab CI runners traditionally run on VMs or Kubernetes pods that you have to size, keep warm, and pay for even when idle.

What if job execution was pushed onto a serverless platform like Cloudflare instead, with a container provisioned on demand, by the second, for each job?

That's the question I wanted to dig into with `gitlab-runner-cloudflare`: a GitLab Runner executor that runs CI jobs on Cloudflare Workers + Containers.

<!--more-->

## Why this project

GitLab Runner exposes a [Custom Executor](https://docs.gitlab.com/runner/executors/custom.html): a very simple interface (`config` / `prepare` / `run` / `cleanup`), deliberately agnostic of transport and underlying infrastructure. There's no built-in notion of Docker or SSH — it's entirely up to the executor to decide how and where the job runs.

That genericity is what made me want to test a hypothesis: is this interface open enough to be wired onto a serverless platform like [Cloudflare Workers](https://developers.cloudflare.com/workers/) and [Cloudflare Containers](https://developers.cloudflare.com/containers/), instead of the usual VMs, Docker, or Kubernetes?

If it holds up, the interesting payoff is a very different cost model: no runner fleet to keep warm at all times, a container provisioned (and billed) on demand for each job, at Cloudflare's edge scale.

This is a POC/R&D-style project: the goal wasn't to ship a finished product, but to validate feasibility, document the decisions as [ADRs](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/tree/main/docs/adr), and push through the hard parts (building images without Docker-in-Docker, dynamic job images, arm64...) until there was a concrete answer rather than a gut feeling.

## How it fits together

```
GitLab Runner (on any host, anywhere)
  │  Custom Executor contract (config/prepare/run/cleanup)
  ▼
executor/   Go binary: gitlab-cf-executor
  │  HTTP
  ▼
worker/     Cloudflare Worker control plane
  │  one Durable Object + Container per job
  ▼
container/  Alpine + Kaniko agent (runs the job's script, builds images
            without a Docker daemon)
```

* **`executor/`** is the binary GitLab Runner invokes directly. It talks HTTP to a deployed `worker/`, with a fully local fallback mode (no Cloudflare account needed) to develop and test without any external dependency.
* **`worker/`** is the control plane: it provisions one Container (via a Durable Object) per job, and proxies `prepare`/`run`/`cleanup` to a small CGI agent baked into the container image.

## Objectives achieved

* **The feasibility question has an answer**: yes, a GitLab Runner Custom Executor can drive CI jobs on Cloudflare Workers + Containers, validated against a real Cloudflare deployment (not just locally with `wrangler dev`).
* **Image builds without Docker-in-Docker**: Cloudflare Containers doesn't grant privileged mode, which rules out Docker-in-Docker, Buildah, and BuildKit (all three need `unshare(CLONE_NEWUSER)`). The [`dind-validation`](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/spikes/dind-validation.md) spike confirmed that [Kaniko](https://github.com/GoogleContainerTools/kaniko) manages without any special privileges, and it's the one that got adopted.
* **Live-streamed logs**: a job's output streams live instead of being buffered and returned all at once, with a dedicated endpoint to fetch the exit code once the stream reaches EOF — a constraint forced by CGI headers needing to precede the response body.
* **Dynamic job images**: instead of one fixed, curated container image, `prepare.cgi` pulls and unpacks (via `skopeo`/`umoci`) whichever `image:` a job requests, and `run.cgi` runs the job's script `chroot`ed into it — see [ADR-0004](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0004-dynamic-job-images.md).
* **`git clone` that works even on an image without `git`**: `get_sources` runs outside the `chroot`, in the sandbox that does have `git`, symlinking `/builds`/`/cache` into the job image's rootfs — the same principle GitLab Runner's own Docker/Kubernetes executors use with a dedicated helper.
* **Tests and CI**: 29 Go unit tests on the `executor/` side, Vitest unit tests on the `worker/` side, and an E2E test that runs a real Kaniko build through a local `wrangler dev`. All of it automated in `.gitlab-ci.yml` (tests on every relevant change, manual deploy on `main`).
* **Documentation**: 4 ADRs tracking the architecture decisions (execution platform, multi-architecture support, `docker_autoscaler`/fleeting compatibility, dynamic job images), 2 spikes documenting the hands-on validations, and a README per component.

## Current limitations / what's left

This is a POC, not a finished product. What's still unresolved:

* **No arm64 lane**: Cloudflare Containers is amd64-only. The provider choice for the arm64 side (AWS Graviton, Oracle Ampere, Hetzner) hasn't been made, and the resulting `docker_autoscaler`/fleeting integration isn't built yet — see [ADR-0002](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0002-multi-architecture-support.md) and [ADR-0003](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0003-docker-autoscaler-fleeting-plugin-compatibility.md).
* **No private registry auth** for dynamic image pulls: `skopeo copy` supports `--src-creds`, but it isn't wired up yet.
* **No cross-job layer cache**: each job's container is destroyed at `cleanup`, so every job re-pulls its image from scratch. An R2-backed cache is a candidate if pull latency becomes a real problem in practice.
* **`restore_cache`/`download_artifacts`/`upload_artifacts` remain `chroot`ed** into the job's image, which assumes it has whatever those steps need — not fixed speculatively, since no concrete failure has been hit yet.
* **Build ≠ run within the same job**: Kaniko can build and push an image, but there's no mechanism yet to run that freshly built image as part of the same job.
* **No direct SSH/debug access** into a running Cloudflare Container instance for local troubleshooting.
* **`wrangler dev` is unreliable on long-running requests** (Kaniko builds, cold starts) — confirmed local-dev-only, with no impact on a real deployment, and tolerated rather than fixed in the E2E tests.

Each of these is tracked with its sources in [`docs/TODO.md`](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/TODO.md).

## Links

* Repository: [gitlab.com/jygastaud/gitlab-runner-cloudflare](https://gitlab.com/jygastaud/gitlab-runner-cloudflare)
* [ADR-0001 — Execution platform](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0001-execution-platform.md)
* [ADR-0002 — Multi-architecture support](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0002-multi-architecture-support.md)
* [ADR-0003 — `docker_autoscaler`/fleeting compatibility](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0003-docker-autoscaler-fleeting-plugin-compatibility.md)
* [ADR-0004 — Dynamic job images](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0004-dynamic-job-images.md)
* [Spike — Docker-in-Docker/Kaniko validation](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/spikes/dind-validation.md)

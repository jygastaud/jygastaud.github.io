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
lastmod = 2026-08-12T14:50:00+02:00

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
* **`services:`, `cache:`, and `artifacts:` support**: covered in detail just below.
* **Tests and CI**: 41 Go unit tests on the `executor/` side, Vitest unit tests on the `worker/` side, and an E2E test that runs a real Kaniko build through a local `wrangler dev`. All of it automated in `.gitlab-ci.yml` (tests on every relevant change, manual deploy on `main`).
* **Documentation**: 5 ADRs tracking the architecture decisions (execution platform, multi-architecture support, `docker_autoscaler`/fleeting compatibility, dynamic job images, services/cache/artifacts), 2 spikes documenting the hands-on validations, and a README per component.
* **Authenticated control plane**: the Worker's HTTP API used to be open to anyone who knew its `*.workers.dev` URL — every route now requires a shared-secret `Authorization: Bearer` token, see below.

## `services:`, `cache:`, `artifacts:`: how it actually works

GitLab exposes a job's `services:` to a Custom Executor through exactly one variable, `CUSTOM_ENV_CI_JOB_SERVICES` — a JSON array, and it's entirely up to the executor to start/stop them itself. Nothing else is provided: no Docker network, no API to implement, just that one piece of information.

```yaml
# .gitlab-ci.yml
cf-executor:demo-services:
  services:
    - name: redis:7-alpine
      alias: redis
  script:
    - for i in $(seq 1 10); do nc -z redis 6379 && break; sleep 1; done
    - nc -z redis 6379 && echo "OK" || exit 1
```

Because every job already runs inside **one** Cloudflare Container instance (one network namespace), a service doesn't need container-level isolation — it just needs to run as a background process, `chroot`ed into its own rootfs (unpacked with `skopeo`/`umoci`, same as the job's own image), and be reachable by its alias. `start-service.sh` uses `setsid` to detach the process from the CGI request that started it, and the OCI runtime-spec `config.json` that `umoci` produces to recover the image's `ENTRYPOINT`/`CMD` without having to redeclare them:

```sh
# simplified excerpt from start-service.sh
ROOTFS_DIR=$(pull-image.sh "$IMAGE" "$BUNDLE_DIR")
jq -r '.process.args[]' "$BUNDLE_DIR/config.json" > "$ARGV_FILE"   # ENTRYPOINT+CMD already resolved by umoci
setsid "$LAUNCH_SCRIPT" "$ENV_FILE" "$ARGV_FILE" "$ROOTFS_DIR" >"$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"
```

`cache:`/`artifacts:` turned out differently: `restore_cache`/`download_artifacts`/`archive_cache`/`upload_artifacts` are scripts GitLab Runner generates like any other stage, but its own docs are explicit that they shell out directly to the `gitlab-runner` binary itself — which has no reason to be inside a job's (dynamically pulled) image. The fix reuses the same pattern already in place for `get_sources`/`git`: widen the set of stages that run outside the `chroot`, in the sandbox that has that binary:

```sh
# run.cgi
case "$stage" in
  get_sources|restore_cache|download_artifacts|archive_cache|archive_cache_on_failure|upload_artifacts_on_success|upload_artifacts_on_failure)
    unchrooted_stage=1 ;;
  *)
    unchrooted_stage=0 ;;
esac
```

`docker:dind` as a service remains explicitly unsupported, for the same reason it is as a job image (needs privileged mode) — see [ADR-0005](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0005-service-containers-and-cache-artifacts.md) for the full writeup.

## What the real deployment revealed

This POC runs on one rule: nothing counts as working until it's run against a real Cloudflare deployment, not just locally or under `wrangler dev`. Adding `services:` support paid that rule back three times over — three bugs invisible locally, only surfacing once `worker:deploy` actually ran and the demo jobs went through the registered runner for real.

**1. `/etc/hosts` is mounted read-only on a real Cloudflare Container.** The first implementation appended `alias 127.0.0.1` straight into `/etc/hosts` — this works perfectly in a local Docker test (where `/etc/hosts` is an ordinary writable bind-mounted file), and fails in production:

```
$ echo "1.2.3.4 foo" >> /etc/hosts
/tmp/run-script.sh: line 1: can't create /etc/hosts: Read-only file system

$ cat /proc/mounts | grep -E "hosts|resolv"
overlay /etc/hosts       overlay ro,relatime,... 0 0
overlay /etc/resolv.conf overlay rw,relatime,... 0 0
```

Cloudflare mounts `/etc/hosts` as its own dedicated overlay, separate from the rest of `/etc` — but `/etc/resolv.conf` stays writable. Alias resolution now goes through a local `dnsmasq`, started the first time a service is declared, answering for known aliases and forwarding everything else to the real upstream resolvers captured before `resolv.conf` gets rewritten:

```sh
# setsid dnsmasq --no-daemon --addn-hosts=/tmp/service-hosts --server=<upstream1> --server=<upstream2>
echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

**2. A failed `prepare_exec` gets retried up to 3 times by GitLab Runner, against the same container instance.** A service already started by an earlier attempt (because a *different* service in the same job had failed) was still running and still holding its port:

```
185:M ... # Warning: Could not create server TCP listening socket *:6379: bind: Address in use
185:M ... # Failed listening on port 6379 (tcp), aborting.
```

A false negative that pointed at the wrong culprit entirely. Each service's PID is now tracked in its own file, and any leftover instance is killed before a new one starts:

```sh
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  kill "$(cat "$PID_FILE")" 2>/dev/null || true
  sleep 1
fi
```

**3. The bundled `gitlab-runner` binary's version has to track the registered runner's, not just any recent release.** `archive_cache` invokes `gitlab-runner cache-archiver` with flags that change between versions; a version mismatch (17.9 bundled vs. 19.2 registered, in this case) fails the call on an unrecognized flag:

```
Incorrect Usage: flag provided but not defined: -alternate-file
FATAL: flag provided but not defined: -alternate-file
```

Silently, too: GitLab Runner treats cache failures as non-fatal and still reports the job as succeeded. A green job can be hiding a cache that never actually got created — this only surfaced by reading `archive_cache`'s own stage log, not the job's overall status.

All three make the same point as the `wrangler dev` limitation further down: it looks like Cloudflare, but it isn't one.

## Securing the control-plane API

The Worker was deployed on the public `*.workers.dev` subdomain, no custom route or domain — and its HTTP API (`/jobs/:jobId/{prepare,run,cleanup}`) had no authentication whatsoever. Anyone who found the URL could provision and drive containers.

Two ways to fix that: Cloudflare Access (Zero Trust) service tokens, the more "native" Cloudflare-side option, or a plain shared-secret `Authorization: Bearer` token. Access would have needed a custom domain and zone — which this Worker doesn't have — plus an Access application configured outside `wrangler.toml`. The shared secret needs no extra Cloudflare infrastructure at all, just code.

```ts
// worker/src/handlers.ts
export function isAuthorized(request: Request, sharedSecret: string | undefined): boolean {
  if (!sharedSecret) return false; // fails closed if the secret isn't configured
  const header = request.headers.get("Authorization") ?? "";
  if (!header.startsWith("Bearer ")) return false;
  return timingSafeEqual(header.slice(7), sharedSecret);
}
```

Checked *before* the route is even parsed, so an unauthenticated caller can't tell an existing route from a 404. The constant-time comparison is hand-rolled rather than `crypto.subtle.timingSafeEqual` — that method is a Cloudflare-only Web Crypto extension, missing from Node's `SubtleCrypto`, and this file is deliberately kept testable under plain `vitest` (not `@cloudflare/vitest-pool-workers`).

On the `executor/` side, `GITLAB_CF_EXECUTOR_WORKER_TOKEN` (same value as the Worker's `SHARED_SECRET`, set via `wrangler secret put`, never committed) rides on every request. And like the three bugs in the previous section, the real proof came from a real deployment: the first demo job retried after wiring this up failed with `401 unauthorized` — not a false negative, but proof that the `gitlab-cf-executor` binary already running on the registered runner predated the fix and was sending no token at all. Rebuilt, the job went green again.

## Current limitations / what's left

This is a POC, not a finished product. What's still unresolved:

* **No arm64 lane**: Cloudflare Containers is amd64-only. The provider choice for the arm64 side (AWS Graviton, Oracle Ampere, Hetzner) hasn't been made, and the resulting `docker_autoscaler`/fleeting integration isn't built yet — see [ADR-0002](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0002-multi-architecture-support.md) and [ADR-0003](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0003-docker-autoscaler-fleeting-plugin-compatibility.md).
* **No private registry auth** for dynamic image pulls: `skopeo copy` supports `--src-creds`, but it isn't wired up yet.
* **No cross-job layer cache**: each job's container is destroyed at `cleanup`, so every job re-pulls its image from scratch. An R2-backed cache is a candidate if pull latency becomes a real problem in practice.
* **`cache:` persistence across jobs is still the runner operator's responsibility**: `restore_cache`/`archive_cache` now run correctly, but without `[runners.cache]` configured in `config.toml` (an S3-compatible backend, e.g. R2), there's nowhere for them to persist to — that's infrastructure configuration, not something this project can provide from inside the container.
* **Services get only a single default alias**, derived from the image name (`postgres:14` → `postgres`), not GitLab's full multi-alias scheme — an explicit `alias:` covers the more complex cases. They also start sequentially rather than in parallel, and with no readiness protocol: a job script has to poll the service itself (matching GitLab's own general guidance).
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
* [ADR-0005 — Services, cache, and artifacts](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0005-service-containers-and-cache-artifacts.md)
* [Spike — Docker-in-Docker/Kaniko validation](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/spikes/dind-validation.md)

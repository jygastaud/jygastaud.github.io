+++
title = "Faire tourner GitLab CI sur Cloudflare Workers & Containers : un exécuteur GitLab Runner maison"
Description = """
Peut-on remplacer les VMs/Kubernetes d'un GitLab Runner par la plateforme serverless de Cloudflare ?

Ce projet explore la question via un Custom Executor GitLab Runner qui délègue l'exécution des jobs CI à un Cloudflare Worker pilotant des Cloudflare Containers, avec build d'images via Kaniko.

Pourquoi ce choix, ce qui fonctionne aujourd'hui, et ce qu'il reste à faire.
"""

Tags = ["GitLab", "GitLab Runner", "CI/CD", "Cloudflare", "Cloudflare Workers", "Cloudflare Containers", "Go", "Kaniko", "Serverless"]
Categories = ["DevOps"]
image = ""
aliases = []
date = 2026-08-11T10:00:00+02:00
lastmod = 2026-08-12T14:50:00+02:00

+++

Les runners GitLab CI tournent traditionnellement sur des VMs ou des pods Kubernetes qu'il faut dimensionner, garder chauds, et payer même quand ils ne font rien.

Et si on déportait l'exécution des jobs sur une plateforme serverless comme Cloudflare, avec un container provisionné à la demande, à la seconde, pour chaque job ?

C'est la question que j'ai voulu creuser avec `gitlab-runner-cloudflare` : un exécuteur GitLab Runner qui exécute les jobs CI sur Cloudflare Workers + Containers.

<!--more-->

## Pourquoi ce projet

GitLab Runner expose un [Custom Executor](https://docs.gitlab.com/runner/executors/custom.html) : une interface très simple (`config` / `prepare` / `run` / `cleanup`), volontairement agnostique du transport et de l'infrastructure sous-jacente. Il n'y a ni notion de Docker, ni de SSH imposée : c'est à l'exécuteur de décider comment et où le job tourne.

Cette généricité m'a donné envie de tester une hypothèse : est-ce que cette interface est suffisamment ouverte pour qu'on puisse la brancher sur une plateforme serverless comme [Cloudflare Workers](https://developers.cloudflare.com/workers/) et [Cloudflare Containers](https://developers.cloudflare.com/containers/), plutôt que sur les habituels VMs, Docker ou Kubernetes ?

L'intérêt, s'il se confirme, serait un modèle de coût très différent : plus de fleet de runners à garder chaude en permanence, un container provisionné (et facturé) à la demande pour chaque job, à l'échelle de l'edge Cloudflare.

C'est un projet de type POC/R&D : l'objectif n'était pas de livrer un produit fini, mais de valider la faisabilité, documenter les choix via des [ADR](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/tree/main/docs/adr), et pousser les points durs (build d'images sans Docker-in-Docker, images de job dynamiques, arm64...) jusqu'à avoir une réponse concrète plutôt qu'une intuition.

## Comment ça s'articule

```
GitLab Runner (sur n'importe quel host)
  │  Custom Executor contract (config/prepare/run/cleanup)
  ▼
executor/   binaire Go : gitlab-cf-executor
  │  HTTP
  ▼
worker/     Worker Cloudflare (control plane)
  │  1 Durable Object + 1 Container par job
  ▼
container/  Alpine + agent Kaniko (exécute le script du job,
            build les images sans daemon Docker)
```

* **`executor/`** est le binaire que GitLab Runner invoque directement. Il parle en HTTP à un `worker/` déployé, avec un mode de repli 100% local (sans compte Cloudflare) pour développer et tester sans dépendance externe.
* **`worker/`** est le control plane : il provisionne un Container (via une Durable Object) par job, et relaie `prepare`/`run`/`cleanup` à un petit agent CGI packagé dans l'image du container.

## Objectifs atteints

* **La question de faisabilité a une réponse** : oui, un Custom Executor GitLab Runner peut piloter des jobs CI sur Cloudflare Workers + Containers, validé sur un déploiement Cloudflare réel (pas seulement en local avec `wrangler dev`).
* **Build d'images sans Docker-in-Docker** : Cloudflare Containers n'autorise pas le mode privilégié, ce qui élimine Docker-in-Docker, Buildah et BuildKit (les trois ont besoin de `unshare(CLONE_NEWUSER)`). Le spike [`dind-validation`](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/spikes/dind-validation.md) a confirmé que [Kaniko](https://github.com/GoogleContainerTools/kaniko) s'en sort sans privilèges particuliers, et c'est lui qui a été retenu.
* **Logs en streaming** : la sortie d'un job est diffusée en direct (et non plus bufferisée puis renvoyée d'un coup), avec un endpoint dédié pour récupérer le code de sortie une fois le flux terminé — contrainte imposée par le fait que les headers CGI doivent précéder le corps de la réponse.
* **Images de job dynamiques** : plutôt qu'une image container figée et unique, `prepare.cgi` télécharge et déballe (via `skopeo`/`umoci`) l'image `image:` demandée par n'importe quel job, et `run.cgi` exécute le script du job `chroot`é dans cette image — voir [ADR-0004](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0004-dynamic-job-images.md).
* **`git clone` qui fonctionne même sur une image sans `git`** : `get_sources` s'exécute hors du `chroot`, dans le sandbox qui, lui, embarque `git`, en symlinkant `/builds`/`/cache` vers le rootfs de l'image du job — le même principe que les helpers dédiés des exécuteurs Docker/Kubernetes de GitLab Runner.
* **Support de `services:`, `cache:` et `artifacts:`** : détaillé juste en dessous.
* **Tests et CI** : 41 tests unitaires Go côté `executor/`, tests unitaires Vitest côté `worker/`, et un test E2E qui exécute un vrai build Kaniko via un `wrangler dev` local. Le tout est automatisé dans `.gitlab-ci.yml` (tests sur chaque changement pertinent, déploiement manuel sur `main`).
* **Documentation** : 5 ADR qui tracent les décisions d'architecture (plateforme d'exécution, support multi-architecture, compatibilité fleeting/`docker_autoscaler`, images de job dynamiques, services/cache/artifacts), 2 spikes qui documentent les validations techniques, et des README par composant.
* **Control plane authentifié** : l'API HTTP du Worker était jusqu'ici ouverte à quiconque connaissait son URL `*.workers.dev` — un jeton partagé en `Authorization: Bearer` est désormais requis sur chaque route, voir plus bas.

## `services:`, `cache:`, `artifacts:` : comment ça marche concrètement

GitLab expose les `services:` d'un job au Custom Executor via une seule variable, `CUSTOM_ENV_CI_JOB_SERVICES` — un tableau JSON, à charge de l'exécuteur de démarrer/stopper les services lui-même. Rien de plus n'est fourni : pas de réseau Docker, pas d'API à implémenter, juste cette information.

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

Puisque chaque job tourne déjà dans **une seule** instance de Cloudflare Container (un seul namespace réseau), un service n'a pas besoin d'isolation container : il suffit de le démarrer comme un process en arrière-plan, `chroot`é dans son propre rootfs (dépaqueté avec `skopeo`/`umoci`, comme l'image du job), et de le rendre joignable par son alias. `start-service.sh` s'appuie sur `setsid` pour détacher le process de la requête CGI qui l'a lancé, et sur le `config.json` (runtime-spec OCI) qu'`umoci` produit pour retrouver l'`ENTRYPOINT`/`CMD` de l'image sans avoir à les redéclarer :

```sh
# extrait simplifié de start-service.sh
ROOTFS_DIR=$(pull-image.sh "$IMAGE" "$BUNDLE_DIR")
jq -r '.process.args[]' "$BUNDLE_DIR/config.json" > "$ARGV_FILE"   # ENTRYPOINT+CMD déjà résolus par umoci
setsid "$LAUNCH_SCRIPT" "$ENV_FILE" "$ARGV_FILE" "$ROOTFS_DIR" >"$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"
```

Pour `cache:`/`artifacts:`, le constat était différent : `restore_cache`/`download_artifacts`/`archive_cache`/`upload_artifacts` sont des scripts générés par GitLab Runner comme n'importe quelle autre étape, mais leur documentation officielle est explicite — ils appellent directement le binaire `gitlab-runner` lui-même, qui n'a aucune raison de se trouver dans l'image (dynamique) du job. La correction reprend le principe déjà en place pour `get_sources`/`git` : élargir la liste des étapes qui s'exécutent hors `chroot`, dans le sandbox qui embarque ce binaire :

```sh
# run.cgi
case "$stage" in
  get_sources|restore_cache|download_artifacts|archive_cache|archive_cache_on_failure|upload_artifacts_on_success|upload_artifacts_on_failure)
    unchrooted_stage=1 ;;
  *)
    unchrooted_stage=0 ;;
esac
```

`docker:dind` en tant que service reste explicitement non supporté, pour la même raison qu'en tant qu'image de job (mode privilégié requis) — voir [ADR-0005](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0005-service-containers-and-cache-artifacts.md) pour le détail complet.

## Ce que le déploiement réel a révélé

Le POC a une règle simple : rien n'est considéré acquis avant d'avoir tourné sur un vrai déploiement Cloudflare, pas seulement en local ou sous `wrangler dev`. En ajoutant le support des `services:`, cette règle a payé trois fois — trois bugs invisibles en local, qui ne se sont révélés qu'en poussant `worker:deploy` pour de vrai et en faisant tourner les jobs de démo à travers le runner enregistré.

**1. `/etc/hosts` est monté en lecture seule sur un vrai Cloudflare Container.** La première implémentation ajoutait `alias 127.0.0.1` directement dans `/etc/hosts` — ça fonctionne parfaitement dans un test Docker local (où `/etc/hosts` est un fichier bind-monté classique, inscriptible), et échoue en production :

```
$ echo "1.2.3.4 foo" >> /etc/hosts
/tmp/run-script.sh: line 1: can't create /etc/hosts: Read-only file system

$ cat /proc/mounts | grep -E "hosts|resolv"
overlay /etc/hosts       overlay ro,relatime,... 0 0
overlay /etc/resolv.conf overlay rw,relatime,... 0 0
```

Cloudflare y monte `/etc/hosts` comme un overlay dédié, distinct du reste de `/etc` — mais `/etc/resolv.conf`, lui, reste inscriptible. La résolution des alias passe donc maintenant par un `dnsmasq` local, démarré au premier service déclaré, qui répond pour les alias connus et relaie le reste vers les vrais résolveurs DNS capturés avant que `resolv.conf` ne soit réécrit :

```sh
# setsid dnsmasq --no-daemon --addn-hosts=/tmp/service-hosts --server=<upstream1> --server=<upstream2>
echo "nameserver 127.0.0.1" > /etc/resolv.conf
```

**2. Un `prepare_exec` qui échoue est rejoué jusqu'à 3 fois par GitLab Runner, sur la même instance de container.** Un service déjà démarré par une tentative précédente (parce qu'un *autre* service du même job avait échoué) restait actif et occupait déjà son port :

```
185:M ... # Warning: Could not create server TCP listening socket *:6379: bind: Address in use
185:M ... # Failed listening on port 6379 (tcp), aborting.
```

Un faux négatif qui accusait l'image du service plutôt que le vrai coupable. Chaque service voit maintenant son PID tracé dans un fichier dédié, et toute instance précédente est tuée avant d'en démarrer une nouvelle :

```sh
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  kill "$(cat "$PID_FILE")" 2>/dev/null || true
  sleep 1
fi
```

**3. La version du binaire `gitlab-runner` embarqué doit suivre celle du runner enregistré, pas une version au hasard.** `archive_cache` invoque `gitlab-runner cache-archiver` avec des flags qui varient d'une version à l'autre ; un décalage de version (17.9 embarqué vs 19.2 enregistré, dans mon cas) fait échouer l'appel sur un flag inconnu :

```
Incorrect Usage: flag provided but not defined: -alternate-file
FATAL: flag provided but not defined: -alternate-file
```

Silencieusement, en plus : GitLab Runner traite les échecs de cache comme non bloquants et affiche quand même le job en succès. Un job vert peut donc cacher un cache qui ne s'est jamais réellement créé — c'est en lisant le log de l'étape `archive_cache`, pas le statut global du job, que le problème est apparu.

Ces trois points illustrent bien la limite du `wrangler dev` local évoquée plus bas : il ressemble à Cloudflare, mais ce n'en est pas un.

## Sécuriser l'API du control plane

Le Worker était déployé sur le sous-domaine public `*.workers.dev`, sans route ni domaine personnalisé — et son API HTTP (`/jobs/:jobId/{prepare,run,cleanup}`) n'avait strictement aucune authentification. N'importe qui tombant sur l'URL pouvait provisionner et piloter des containers.

Deux options pour corriger ça : les service tokens de Cloudflare Access (Zero Trust), plus « natifs » côté Cloudflare, ou un simple jeton partagé en `Authorization: Bearer`. Access aurait demandé un domaine personnalisé et une zone — que ce Worker n'a pas — plus une application Access à configurer hors de `wrangler.toml`. Le jeton partagé, lui, ne demande aucune infrastructure Cloudflare supplémentaire : juste du code.

```ts
// worker/src/handlers.ts
export function isAuthorized(request: Request, sharedSecret: string | undefined): boolean {
  if (!sharedSecret) return false; // fail closed si le secret n'est pas configuré
  const header = request.headers.get("Authorization") ?? "";
  if (!header.startsWith("Bearer ")) return false;
  return timingSafeEqual(header.slice(7), sharedSecret);
}
```

Vérifié *avant même* de parser la route, pour qu'un appelant non authentifié ne puisse pas distinguer une route existante d'une 404. La comparaison en temps constant est écrite à la main plutôt qu'avec `crypto.subtle.timingSafeEqual` — cette méthode est une extension Cloudflare du Web Crypto API, absente du `SubtleCrypto` de Node, alors que ce fichier reste volontairement testable en `vitest` classique (pas `@cloudflare/vitest-pool-workers`).

Côté `executor/`, `GITLAB_CF_EXECUTOR_WORKER_TOKEN` (même valeur que le `SHARED_SECRET` posé côté Worker via `wrangler secret put`, jamais commité) est envoyé sur chaque requête. Et comme pour les trois bugs de la section précédente, la vraie validation est venue du déploiement réel : le premier job de démo rejoué après la mise en place a échoué avec un `401 unauthorized` — pas un faux négatif, mais la preuve que le binaire `gitlab-cf-executor` déjà en place sur le runner datait d'avant ce correctif et n'envoyait donc aucun jeton du tout. Une fois rebuild, le job est repassé au vert.

## Limites actuelles / reste à faire

Ce projet est un POC, pas un produit fini. Ce qui n'est pas (encore) résolu :

* **Pas de lane arm64** : Cloudflare Containers ne fait que de l'amd64. Le choix du provider pour la partie arm64 (AWS Graviton, Oracle Ampere, Hetzner) n'est pas tranché, et l'intégration `docker_autoscaler`/fleeting qui en découle n'est pas encore implémentée — voir [ADR-0002](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0002-multi-architecture-support.md) et [ADR-0003](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0003-docker-autoscaler-fleeting-plugin-compatibility.md).
* **Pas d'authentification registre privé** pour les images de job dynamiques : `skopeo copy` sait faire du `--src-creds`, mais ce n'est pas encore câblé.
* **Pas de cache de layers entre jobs** : chaque container est détruit au `cleanup`, donc chaque job re-télécharge son image depuis zéro. Un cache R2 est envisagé si la latence devient un vrai problème en pratique.
* **La persistance de `cache:` entre jobs reste à la charge de l'opérateur du runner** : `restore_cache`/`archive_cache` fonctionnent désormais correctement, mais sans `[runners.cache]` configuré côté `config.toml` (backend S3-compatible, R2 par exemple), il n'y a nulle part où persister le cache — une configuration d'infrastructure, pas quelque chose que ce projet peut fournir depuis le container.
* **Les services n'ont qu'un seul alias par défaut**, dérivé du nom d'image (`postgres:14` → `postgres`), pas le schéma complet multi-alias de GitLab — un `alias:` explicite couvre les cas plus complexes. Ils démarrent aussi séquentiellement, pas en parallèle, et sans protocole de disponibilité : un script de job doit sonder lui-même le service (comme le recommande GitLab de façon générale).
* **Build ≠ run dans le même job** : Kaniko sait builder et pousser une image, mais rien n'est prévu pour l'exécuter dans la foulée, dans le même job.
* **Pas d'accès SSH/debug direct** à une instance de Container Cloudflare pour le troubleshooting local.
* **`wrangler dev` peu fiable sur les requêtes longues** (build Kaniko, cold start) — un problème confirmé local-only, sans impact sur un déploiement réel, contourné plutôt que corrigé dans les tests E2E.

Le détail de chacun de ces points, avec ses sources, est maintenu dans [`docs/TODO.md`](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/TODO.md).

## Liens vers le projet

* Dépôt : [gitlab.com/jygastaud/gitlab-runner-cloudflare](https://gitlab.com/jygastaud/gitlab-runner-cloudflare)
* [ADR-0001 — Plateforme d'exécution](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0001-execution-platform.md)
* [ADR-0002 — Support multi-architecture](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0002-multi-architecture-support.md)
* [ADR-0003 — Compatibilité `docker_autoscaler`/fleeting](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0003-docker-autoscaler-fleeting-plugin-compatibility.md)
* [ADR-0004 — Images de job dynamiques](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0004-dynamic-job-images.md)
* [ADR-0005 — Services, cache et artifacts](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0005-service-containers-and-cache-artifacts.md)
* [Spike — Validation Docker-in-Docker/Kaniko](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/spikes/dind-validation.md)

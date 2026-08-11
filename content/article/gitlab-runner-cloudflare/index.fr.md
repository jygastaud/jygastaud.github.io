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
lastmod = 2026-08-11T10:00:00+02:00

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
* **Tests et CI** : 29 tests unitaires Go côté `executor/`, tests unitaires Vitest côté `worker/`, et un test E2E qui exécute un vrai build Kaniko via un `wrangler dev` local. Le tout est automatisé dans `.gitlab-ci.yml` (tests sur chaque changement pertinent, déploiement manuel sur `main`).
* **Documentation** : 4 ADR qui tracent les décisions d'architecture (plateforme d'exécution, support multi-architecture, compatibilité fleeting/`docker_autoscaler`, images de job dynamiques), 2 spikes qui documentent les validations techniques, et des README par composant.

## Limites actuelles / reste à faire

Ce projet est un POC, pas un produit fini. Ce qui n'est pas (encore) résolu :

* **Pas de lane arm64** : Cloudflare Containers ne fait que de l'amd64. Le choix du provider pour la partie arm64 (AWS Graviton, Oracle Ampere, Hetzner) n'est pas tranché, et l'intégration `docker_autoscaler`/fleeting qui en découle n'est pas encore implémentée — voir [ADR-0002](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0002-multi-architecture-support.md) et [ADR-0003](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/adr/0003-docker-autoscaler-fleeting-plugin-compatibility.md).
* **Pas d'authentification registre privé** pour les images de job dynamiques : `skopeo copy` sait faire du `--src-creds`, mais ce n'est pas encore câblé.
* **Pas de cache de layers entre jobs** : chaque container est détruit au `cleanup`, donc chaque job re-télécharge son image depuis zéro. Un cache R2 est envisagé si la latence devient un vrai problème en pratique.
* **`restore_cache`/`download_artifacts`/`upload_artifacts` restent `chroot`és** dans l'image du job, ce qui suppose qu'elle contient tout ce dont ces étapes ont besoin — non corrigé de façon spéculative, faute d'un cas d'échec concret observé.
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
* [Spike — Validation Docker-in-Docker/Kaniko](https://gitlab.com/jygastaud/gitlab-runner-cloudflare/-/blob/main/docs/spikes/dind-validation.md)

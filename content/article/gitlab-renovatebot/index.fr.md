+++
title = "Installer et configurer Renovate Bot sur GitLab CE"
Description = """
La documentation pour installer et configurer RenovateBot sur un GitLab Self Hosted peut paraitre un peu complexe.
Ce n'est finalement pas si compliqué une fois les bonnes mécaniques comprises.
"""

Tags = ["Git", "GitLab", "DevOps", "CI/CD", "Automation","Quality check"]
Categories = ["DevOps"]
image = ""
aliases = []
date = 2021-11-27T16:14:35+01:00
lastmod = 2021-11-27T16:14:35+01:00

+++

[Renovate Bot](https://renovatebots.com) est un outil permettant de contrôler les versions des dépendances de ses projets.

On peut le comparer au projet [Dependabot](https://github.com/dependabot) qui est disponible sur GitHub.

Dans cette article, nous allons explorer comment installer et configurer Renovate pour fonctionner sur une instance de Gitlab CE.

<!--more-->

## Prérequis

Afin de pouvoir suivre le process d'initialisation vous devez pouvoir :

* Créer des groupes et projets
* Avoir accès ou installer, au moins, 1 GitLab Runner avec un executeur `docker`
* Avoir un compte GitHub (même si nous allons utiliser GitLab, il servira notamment à récupérer les releases notes des projets)



## Initialisation

### Structure de projets

* Créer un groupe projet `Renovate`
* Créer 2 projets dans le groupe
  * un projet `renovate-config` qui contiendra les fichiers de configurations partageables à tous les projets du GitLab;
  * un projet `renovate-runner` qui contiendra les configurations pour dédier au conteneur Renovate.



### Utilisateur Gitab

Comme le nom du projet l'indique (Renovate**Bot**) nous allons avoir de créer un compte utilisateur représentant notre Bot.

Pour notre exemple, nous l'appelerons `Renovate Bot <renovatebot@example.com>` et le nom d'utilisateur `renovatebot`.

Cet utilisateur servira à 2 choses : 

1. les Merge Requests, commits... seront crées par le Bot ;
2. restreindre les droits de renovate à ne parcourir que les projets sur lequels il est explicitement invités.



## Configuration du projet renovate-runner

Nous allons commencer par travailler sur la partie Runner. Rendons nous donc dans le projet `renovate-runner` précédemment créé.



### Création des tokens utilisateurs (PAT : Personal Access Token)

#### GitLab

Sur votre instance GitLab, connectez-vous avec le compte `renovatebot` créé précédemment.

Nous allons créé un Access Token via votre profil utilisateur (/-/profile/personal_access_tokens).

Nommez le token comme bon vous semble (`renovatebot` par exemple) et choisissez les scopes suivants comme [indiqué dans la documentation](https://docs.renovatebot.com/getting-started/running/#gitlab) :

* `read_user`,
* `api`,
* `write_repository`.



Copiez le token et retourner sur le projet `renovate-runner`, dans les CI/CD Settings (menu `Settings` > `CI/CD` > `Variables`)

et créer une nouvelle variable nommée `RENOVATE_TOKEN` avec la valeur du token récupérée.



#### GitHub

Afin de pouvoir récupérer les releases notes des projets et ne pas être soumis aux limitations de l'API GitHub, il va nous falloir créer un GitHub et y créer un [Personal Acces Token](https://docs.renovatebot.com/getting-started/running/#githubcom-token-for-release-notes). 



Copiez le token et retourner sur le projet `renovate-runner`, dans les CI/CD Settings (menu `Settings` > `CI/CD` > `Variables`)

et créer une nouvelle variable nommée `GITHUB_COM_TOKEN` avec la valeur du token récupérée.



### Notre fichier `.gitlab-ci.yml`



```
image: renovate/renovate:29	

variables:
  RENOVATE_BASE_DIR: $CI_PROJECT_DIR/renovate
  RENOVATE_GIT_AUTHOR: Renovate Bot <renovatebot@exemple.com>
  RENOVATE_OPTIMIZE_FOR_DISABLED: 'true'
  RENOVATE_REPOSITORY_CACHE: 'true'
  LOG_LEVEL: debug


cache:
  key: ${CI_COMMIT_REF_SLUG}-renovate
  paths:
    - $CI_PROJECT_DIR/renovate

renovate:
  stage: deploy
  resource_group: production
  only:
    - schedules
  script:
    - renovate $RENOVATE_EXTRA_FLAGS
```



Renovate propose la plupart de ces configurations en variable d'environnements.
Néanmoins, pour pouvoir utiliser le bot dans d'autres contextes que GitLab (un lancement manuel par exemple), je n'ai gardé que les paramètres spécifiques à GitLab dans le fichier `.gitlab-ci.yml`.



Le reste des configurations se trouvent donc dans le fichier `config.js` que nous allons regarder tout de suite. :arrow_down:



### Fichier de configuration Renovate

Renovate s'appuie donc sur un fichier de configuration `config.js`

On y défini notamment la plateforme Git à utiliser, [les options du configurations propres](https://docs.renovatebot.com/self-hosted-configuration/) au runner et les [profils de configurations (Config Presets)](https://docs.renovatebot.com/config-presets/) qui seront appliqués pour tous les projets `onboardingConfig`.

```
module.exports = {
        endpoint: 'https://[url du gitlab]/api/v4/',
        platform: 'gitlab',
        persistRepoData: true,
        logLevel: 'debug',
        onboardingConfig: {
                "extends": [
                        "local>groupes/sous-groupes/renovate/renovate-config"
                ],
        },
        autodiscover: true,
};
```



### Tâche récurrente

* Menu CI/CD > Schedules
* Créer une nouvelle tâche planifiée avec la fréquence de passage que vous souhaitez (j'ai fait le choix, totalement arbitraire, de faire tourner l'analyse 2 fois par jour) et à déclencher.
* Sauvegardez



## Configuration des configurations par défaut

Dans le projet `renovate-config` nous allons créer un simple fichier `renovate.json` qui sera celui recherchait par défaut par le fichier `config.json` et notamment la ligne `"local>groupes/sous-groupes/renovate/renovate-config"`.



Voici les choix que j'ai fait : 

```
 {
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "packageRules": [
    {
      "depTypeList": ["devDependencies", "require-dev"],
      "updateTypes": ["patch", "minor", "digest"],
      "groupName": "devDependencies (non-major)"
    }
  ],
  "extends": [
    "config:base",
    ":preserveSemverRanges",
    ":dependencyDashboard",
    ":rebaseStalePrs",
    ":enableVulnerabilityAlertsWithLabel('security')",
    "group:recommended"
  ]
}
```



* `packageRules` permet de créer des nouveaux regroupements. Dans notre cas, cela nous permet d'avoir une seule Merge Request contenant toutes les dépendances de développements du projet lorsqu'elles sont non-majeures.

* `extends` nous permet de définir les règles/configs presets que l'on souhaite activer. On active notamment le [Dependency Dashboard](https://docs.renovatebot.com/key-concepts/dashboard/) qui permet de suivre dans un ticket l'état de toutes les mises à jour disponibles et/ou des MR en cours et différents  [Group Presets](https://docs.renovatebot.com/presets-group/).



## Activer le bot pour les projets

Avec ces configurations, chaque projet souhaite activer le bot n'a que 4 étapes à suivre : 

1. Ajouter l'utilisateur `renovatebot` sur le projet, avec au moins un droit de `contributeur`
2. Activer les `issues` pour le `dependency Dashboard`
3. Activer les `merge requests` pour tout d'abord avec une 1ère Merge Request de création de la configuration renovate, puis les MR associées aux mises à jours à appliquer.
4. Affiner les configurations de Renovate selon les spécificités de son projet



Et voilà :champagne:

Nous avons maintenant un bot Renovate qui tourne de façon régulière et va updater l'ensemble des repositories auxquels il a accès.


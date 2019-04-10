+++
title = "Drupal, Gitlab CI et Clever Cloud sont dans un bâteau"
Description = "Déployer un site Drupal 8 sur Clever Cloud avec Gitlab CI"
Tags = ["Développement", "Drupal", "Cloud", "PaaS", "Clever Cloud", "Gitlab", "Gitlab CI"]
Categories = ["Développement", "Drupal", "Cloud"]
image = ""
aliases = []
date = 2019-04-10T15:15:36+02:00
lastmod = 2019-04-10T15:15:36+02:00
+++

Déployer un site Drupal 8 sur Clever Cloud avec Gitlab CI

<!--more-->

## Qu'est-ce que Clever Cloud

[Clever Cloud](https://www.clever-cloud.com/) est un hébergement PAAS (Platform As A Service).

### Grands principes

A chaque déploiement de l'application, une nouvelle machine va être créée.  
Le code disponible dans un repository Git fournit par Clever Cloud va être déployer sur la machine et si aucune erreur n'est détectée, l'ancienne machine et la nouvelle sont switchées.  
Le stockage de données et le stockage permanent de fichiers sont assurés respectivement par l'add-on `mysql` et `bucketFS`.

Toutes les machines et services possèdent un identifiant unique et un alias.

## Serveurs et services

2 environnements sont provisionnées.

### PREPROD

**VM**

* type XS : 1GB de RAM, 1 CPU
* Pas d'autoscalling
* 1 seule instance

**Services**

* MySQL (la base de données)
  * 10GB d'espace
* 2 FS Buckets
  * 1 pour le répertoire public de Drupal
  * 1 pour le repertoire privé de Drupal
  * Assure la persistance des données / fichiers uploadés
  * Pas de taille min / max

### PROD

Identique à la PREPROD avec une machine un peu plus puissante : type S, 2GB de RAM, 2 CPUs

## Configurations et variables d'environnement

### Variables d'environnements

Afin d'accéder aux différents services associés depuis la VM, Clever Cloud fournit des variables d'environnement.

Les variables standards sur Clever Cloud et disponibles par environnement sont documentées au lien suivant :

* [Général](https://www.clever-cloud.com/doc/admin-console/environment-variables/)
* [PHP](https://www.clever-cloud.com/doc/php/php-apps/#environment-injection)

### Variables par instances

Les variables ci-dessous sont définies et modifiées pour chacune des instances.

##### Variables custom / customisables

```
CC_FS_BUCKET=/web/sites/default/files:bucket-xxxx-xxxx-xxxx-xxxx-xxxx-fsbucket.services.clever-cloud.com
CC_FS_BUCKET=/private/files:bucket-xxxx-xxxx-xxxx-xxxx-xxxx-fsbucket.services.clever-cloud.com
```

permet de définir quels répertoires doivent être stockés de façon permanente dans le `FS BUCKETS`.

```
CC_PRE_RUN_HOOK=composer.phar run-script drupal-update-all
```

Permet d'exécuter à la fin d'un déploiement les actions de migration de base de données / vidage de cache...
Pour simplifier le process, on joue un script disponible dans le `composer.json`

```
CC_WEBROOT=/web
```

Permet de définir l'emplacement du fichier index.php/index.html pour l'affichage du site.

```
DRUPAL_SALT=xxxxxxx
```

**Le SALT Drupal est obligatoire**. Il sera nécessaire de le configurer également sur les instances de DEV/LOCAL en cas de redescente de base.

```
PHP_VERSION=7.2
```

Définie la version de PHP à utiliser

```
PORT=8080
```

**Ne pas changer le port. Il est configuré par défaut sur 8080 pour le bon fonctionnement Clever Cloud.**

```
GIT_TAG=CURRENT_VERSION
```

Cette variable est définie automatiquement par Gitlab CI.

Elle sert uniquement de repaire pour savoir quel est le dernier tag déployé

#### Variables liées aux services

```
BUCKET_HOST
MYSQL_ADDON_DB
MYSQL_ADDON_HOST
MYSQL_ADDON_PASSWORD
MYSQL_ADDON_PORT
MYSQL_ADDON_URI
MYSQL_ADDON_USER
```

## Faire communiquer Drupal et les services Clever Cloud

Afin de pouvoir utiliser pleinement les services de Clever Cloud, les adaptations suivantes ont été faites sur Drupal.

* Ajout au fichier `default.settings.php` d'une condition pour inclure un fichier de settings propre à Clever Cloud

```php
if (getenv('APP_ID')) {
  include $app_root . '/' . $site_path . '/settings.clevercloud.php';
}
```

* Commit du fichier settings.php (iso default.settings.php)
* Création et commit du fichier `settings.clevercloud.php` qui ne s'inclue que si la variable `APP_ID` est disponible.

Sur Clever Cloud : `APP_ID`: the ID of the application. Each application has a unique identifier used to identify it in our system. This ID is the same than the one you can find in the information section of your application.

* Modification de la partie `scripts` du fichier `composer.json` pour y ajouter des scripts d'installation et de mise à jour.

Extract du fichier composer.json

```json
...
    "scripts": {
        ...
        "drupal-config-update": [
            "cd web && ../vendor/bin/drush cr",
            "cd web && ../vendor/bin/drush cim -y",
            "cd web && ../vendor/bin/drush csim -y",
            "cd web && ../vendor/bin/drush csim -y",
            "cd web && ../vendor/bin/drush locale:check",
            "cd web && ../vendor/bin/drush locale:update",
            "cd web && ../vendor/bin/drush cr"
        ],
        "drupal-db-update": [
            "cd web && ../vendor/bin/drush updb -y",
            "cd web && ../vendor/bin/drush entup -y"
        ],
        "drupal-monsite-default-install": [
            "cd web && ../vendor/bin/drush si monsite_profile --locale=en --account-name=admin --account-pass=admin -y",
            "cd web && ../vendor/bin/drush cset system.site uuid 28ece100-1664-4072-9a92-55a5a53192f3 -y",
            "@drupal-update-all"
        ],
        "drupal-theme-build": [
            "cd web/themes/custom/monsite && npm install && ./node_modules/.bin/gulp build -r"
        ],
        "drupal-update-all": [
            "@drupal-theme-build",
            "@drupal-db-update",
            "@drupal-config-update"
        ]
    },
...
```

## Utiliser les outils PHP et Drupal avec Clever Cloud

Si besoin de lancer des commandes directement sur le serveur, il vous faudra passer par l'outil `Clever Tools` en ligne de commande.

[La documentation d'installation](https://www.clever-cloud.com/doc/clever-tools/getting_started/)

### Connexion SSH

Clever Tools dispose d'une commande `ssh`.

Comme nous avons 2 VMs définies dans le `.clever.json`, il est nécessaire de préciser à cette commande l'environnement cible.

* Connexion PREPROD : `clever ssh mon-site-preprod`
* Connexion PROD : `clever ssh mon-site-prod`

### Composer

Composer est disponible directement et globalement sur les machines via `composer.phar`.

Si vous avez besoin de lancer un `composer install` directement sur la machine, il vous faudra donc exécuter `composer.phar install`.

### Drush, Drupal Console et autres binaires du projet

Drush et Drupal Console sont à déclarer en dépendance composer du projet.

Une fois le `composer install` exécuté, il est possible d'aller utiliser les binaires dans le dossier `vendor/bin`.

Exemple pour Drush depuis la racine de l'application : `./vendor/bin/drush MA_COMMANDE`



## Gitlab / Gitlab CI

Afin de simplifier la gestion et le déploiement de l'application, les actions suivantes ont été menées sur l'Intégration Continue (via Gitlab-ci).

* Activation d'un runner Gitlab CI sur l'instance de QA
* Activation de Gitlab CI dans le projet Drupal
* Création d'une tâche de déploiement pour la PREPROD
    * cette tâche se déclenche automatiquement que si des changements se produisent sur la branche `release`
    * On force la mise à jour du code dans le dépôt Git de Clever Cloud à chaque déploiement.
* Création d'une tâche de déploiement sur la PROD
    * Cette tâche doit être déclenché manuellement et n'est proposée que lorsque d'un tag est poussé
* Création de 2 jobs planifiés dans Gitlab
    * Mise en sommeil de la VM de PREPROD à 19h
    * Reveil de la VM de PREPROD à 8h
* Commit du fichier `.clever.json` qui contient les infos pour accéder aux 2 machines.

L'ensemble des jobs/tâches sont définies dans le fichier `.gitlab-ci.yml` à la racine du repository Git.

Des variables d'environnement ont été définies dans le projet Gitlab pour être accessible par Gitlab CI : 

* APP_ID_PREPROD
* APP_ID_PROD
* APP_ALIAS_PREPROD
* APP_ALIAS_PROD
* APP_NAME_PREPROD
* APP_NAME_PROD
* CLEVER_SECRET
* CLEVER_TOKEN

### (Ré)Installation des environnements

2 jobs, à lancer manuellement sont disponibles dans Gitlab-ci.

* `install_preprod`
* `install_prod`

Ces 2 jobs réinstallent complètement le site (réinstallation du profil d'install)

```yaml
install_preprod:
  stage: oneshot
  environment:
    name: preproduction
    url:  https://$APP_NAME_PREPROD.cleverapps.io
  when: manual
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - /release/
  except:
    - schedules
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-monsite-default-install" --alias $APP_ALIAS_PREPROD
    - ./clever deploy --alias $APP_ALIAS_PREPROD -f

install_prod:
  stage: oneshot
  environment:
    name: production
    url:  https://$APP_NAME_PROD.cleverapps.io
  when: manual
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - tags
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-monsite-default-install" --alias $APP_ALIAS_PROD
    - ./clever deploy --alias $APP_ALIAS_PROD -f
```

Le déploiement est géré par 3 nouveaux stages.  
Le déploiement en prod, s'il est réussi, va déclencher le job `update_info_prod` et modifier la variable d'environnement GIT_TAG qui peut nous permettre de tracker simplement la dernière version déployée.


```yaml
deploy_preprod:
  stage: deploy_preprod
  environment:
    name: preproduction
    url:  https://$APP_NAME_PREPROD.cleverapps.io
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - /release/
    - /clevercloud/
  except:
    - schedules
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/1.0.0/clever-tools-1.0.0_linux.tar.gz
    - tar -xvf clever-tools-1.0.0_linux.tar.gz --strip-components=1
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-update-all" --alias $APP_ALIAS_PREPROD -v
    - ./clever deploy --alias $APP_ALIAS_PREPROD -f -v

deploy_prod:
  stage: deploy_prod
  environment:
    name: production
    url:  https://$APP_NAME_PROD.cleverapps.io
  when: manual
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - tags
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-update-all" --alias $APP_ALIAS_PROD
    - ./clever deploy --alias $APP_ALIAS_PROD -f
  allow_failure: false

update_variable_prod:
  stage: update_info_prod
  environment:
    name: production
    url:  https://$APP_NAME_PROD.cleverapps.io
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - tags
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set GIT_TAG $CI_COMMIT_TAG --alias $APP_ALIAS_PROD
  when: on_success
```

Pour la PREPROD, nous avons également planifiés des jobs automatiques qui vont arrêter et démarrer la machine.  
Ces 2 jobs sont définis via l'interface Gitlab et contiennent des variables dédiées (`SLEEPING` et `WAKEUP`)

```yaml
good_night_preprod:
  stage: money
  only:
    variables:
      - $SLEEPING == "PREPROD"
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever stop --alias $APP_ALIAS_PREPROD

wakeup_preprod:
  stage: money
  only:
    variables:
      - $WAKEUP == "PREPROD"
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-update-all" --alias $APP_ALIAS_PREPROD
    - ./clever restart --alias $APP_ALIAS_PREPROD
```

**Le fichier gitlab-ci.yml complet**

```yaml
image: debian:9-slim

variables:
  GIT_STRATEGY: clone

stages:
  - oneshot
  - deploy_preprod
  - deploy_prod
  - update_info_prod
  - money

deploy_preprod:
  stage: deploy_preprod
  environment:
    name: preproduction
    url:  https://$APP_NAME_PREPROD.cleverapps.io
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - /release/
    - /clevercloud/
  except:
    - schedules
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/1.0.0/clever-tools-1.0.0_linux.tar.gz
    - tar -xvf clever-tools-1.0.0_linux.tar.gz --strip-components=1
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-update-all" --alias $APP_ALIAS_PREPROD -v
    - ./clever deploy --alias $APP_ALIAS_PREPROD -f -v

deploy_prod:
  stage: deploy_prod
  environment:
    name: production
    url:  https://$APP_NAME_PROD.cleverapps.io
  when: manual
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - tags
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-update-all" --alias $APP_ALIAS_PROD
    - ./clever deploy --alias $APP_ALIAS_PROD -f
  allow_failure: false

update_variable_prod:
  stage: update_info_prod
  environment:
    name: production
    url:  https://$APP_NAME_PROD.cleverapps.io
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - tags
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set GIT_TAG $CI_COMMIT_TAG --alias $APP_ALIAS_PROD
  when: on_success

good_night_preprod:
  stage: money
  only:
    variables:
      - $SLEEPING == "PREPROD"
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever stop --alias $APP_ALIAS_PREPROD

wakeup_preprod:
  stage: money
  only:
    variables:
      - $WAKEUP == "PREPROD"
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-update-all" --alias $APP_ALIAS_PREPROD
    - ./clever restart --alias $APP_ALIAS_PREPROD

install_preprod:
  stage: oneshot
  environment:
    name: preproduction
    url:  https://$APP_NAME_PREPROD.cleverapps.io
  when: manual
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - /release/
  except:
    - schedules
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-monsite-default-install" --alias $APP_ALIAS_PREPROD
    - ./clever deploy --alias $APP_ALIAS_PREPROD -f

install_prod:
  stage: oneshot
  environment:
    name: production
    url:  https://$APP_NAME_PROD.cleverapps.io
  when: manual
  before_script:
    - apt-get update -yqq
    - apt-get install git curl -y
  only:
    - tags
  script:
    - curl -O https://clever-tools.cellar.services.clever-cloud.com/releases/latest/clever-tools-latest_linux.tar.gz
    - tar -xvf clever-tools-latest_linux.tar.gz --strip-components=1
    - ./clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET
    - ./clever env set CC_PRE_RUN_HOOK "composer.phar run-script drupal-monsite-default-install" --alias $APP_ALIAS_PROD
    - ./clever deploy --alias $APP_ALIAS_PROD -f
```

+++
date = "2013-06-21T15:00:28+01:00"
title = "DrupalCamp Paris2013 - Livraison continue avec Drupal 7"
category = ["Développement", "DevOps"]
tag = ["Drupal", "CI/CD"]
description = "Prise de notes réalisées lors de la conférence Livraison continue avec Drupal 7 lors du DrupalCamp Paris2013."
aliases = [
  "/blog/articles/DrupalCampParis2013-livraison-continue/"
]
+++

Prise de note lors de la conférence du DrupalCamp Paris 2013.

## Comment faire un site en 1,5 mois sans le faire à l'arrache?
Faut le faire en agile!

* On s'engage sur une date ou sur un périmètre mais pas les 2
* Définition du "Minimum Viable Product"

Comment livrer le plus souvent possible:
 * Tout automatisé

### Construction d'un build pipeline
Flux automatisé jusqu'à la mise en production

commit -> Inté continue -> recette développeur -> déploiement en intégration -> recette métier -> déploiement en pré prod -> validation finale -> déploiement en production

Tout a été orchestré avec Jenkinks

#### Quelle base de données fait foi?
La base de données de developpement doit être la base de référence

#### Comment transposer la configuration d'un environnement à l'autre?
 * Features
 * hook_update

1 feature par grand domaine, pas par réelles fonctionnalités

Toujours valider le déploiement (smoke tests)

Lancement des tests d'intégration automatisés -> Dans le cadre du projet, seul le front a été testé automatiquement

#### Et la qualité du code?
* Coder
* Lint
* phpmd
* phpcd

#### Tests de performances
 * JMeter
 * Gatling? en Scala

### Outils utilisés
* Déploiement en environnement de dév -> Capistrano
* Validation -> PHPUnit + cURL

## Capistrano
Permet de faire de déploiement parallélisé via un domaine spécifique
Il permet de déployer les fichiers spécifiques aux devs et ne pas se préoccuper des fichiers spécifiques à l'environnement.

Permet de sauvegarder l'ancienne version du code, partage des fichiers de config

Quasi plus besoin d'actions manuelles sur le serveur au final.

## Smoke Tests
Permet de détecter les "fuites" coté Front

* Succession de curl
    * home en HTTP 200
    * Pas de blocs d'erreurs
    * Pas de 404 sur les assets
    * Blocs importants bien présents

## Comment on monitore?
 * Buildwall Jenkins


## Et les tests unitaires dans tout ça?
* Uniquement sur le front dans le cadre de ce projet
* SimpleTest trop lent


Découpage pour la mise en production avec 2 taches
* 1 pour le merge de DEV vers PROD only
* 1 pour la mise en prod de la branch "mergée"

## Coordonnées contact
twitter: @arnaudhuon
mail: ahuon@octo.com

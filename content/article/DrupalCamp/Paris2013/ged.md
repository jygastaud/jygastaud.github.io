+++
date = "2013-06-21T15:00:28+01:00"
title = "DrupalCamp Paris2013 - GED"
category = ["Développement"]
tag = ["Drupal", "GED"]
description = "Prise de notes réalisées lors de la conférence GED du DrupalCamp Paris2013."
+++

# GED

## Acquisition

* Imports: Feed, custom
* Services, CMIS API
* Solr

## Stockage
Versionning + diff
Archivage: Taxonomie
Workflow: Maestro

## Classement
* Gestion des permissions
* FacetAPI

### Principales
Alfresco
Knowledge Tree

### Annexes
* ExoPatform
* Quotero


## Comparaison
Faiblesses de Drupal:

 * Intégration avec MS et Google Docs
 * WebDav

Avantages de Drupal :

 * Garantie de support et d'évolutivité
 * Confiance
 * 431 modules uniquement pour la gestion de fichiers
 * Couverture fonctionnelle "sans limite"

## Cas clients

### Intranet collaboratif : Médecin Sans Frontière
Problèmes:

 * Documents non structurés
 * Pas toujours à jour

Solutions:

 * FacetApi
 * LDAP


### Constructeur automobile
Problèmes:

 * Médiathèque déjà en place
 * Pas de partages
 * Pas de visualisation

Solutions:

 * Feed + Feeds Xpath Parser pour les imports


### Prêt à porter
Problèmes:

 * Gestion manuelle des PDF
 * Synchronisation journalière de l'ensemble des docs
 * Uniquement accessible sur le réseau d'entreprise

Solutions:

 * Classement par taxo
 * Module custom pour import automatique 1 fois / jour
 * Versionning Drupal
 * Apache Solr
    * 6000 pdf / jour à importer en 2 heures
 * Permissions gérées de façon hierarchique
    * Modules custom d'import du LDAP avec la hierachie associé
 * Délégations des permissions
    * Le salarié C peut déléguer au salarié B
    * Module Custom

## Drupal est-il toujours pertinant?
Toujours faire le pendant entre le niveau de custom à faire vs autres solutions du marché

Dans ce cas, penser à faire collaborer Alfresco et Drupal via module CMIS

On peut donc toujours utiliser Drupal en pensant bien les besoins à l'avance.

## Q&A
Niveau indexation: Les optimisations sont plus simples à mettre en place coté Drupal que Alfresco

Pas de modules contribués

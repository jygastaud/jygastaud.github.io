+++
date = "2013-06-21T01:14:28+01:00"
title = "DrupalCamp Paris2013 - Magnifiez votre backend"
Categories = ["Drupal"]
Tags = ["Drupal", "Backoffice"]
description = "Prise de notes réalisées lors de la conférence Magnifiez vos backend lors du DrupalCamp Paris2013."
aliases = [
  "/blog/articles/DrupalCampParis2013-magnifiez-backend"
]
+++

## Les formulaires peuvent être très long

Création d'un concept => FormMode basé sur le concept des ViewsMode : https://drupal.org/sandbox/Artusamak/1796634

Field Extra Widget : https://drupal.org/project/field_extrawidgets

Views Megarow => Edition en ligne dans le backend : https://drupal.org/project/views_megarow

Démo du Back Cartier

Bundle Switcher : https://drupal.org/project/bundleswitcher


## Créer vos propres plugins pour l'api de views
Views Matrix

## Gérer les transitions de workflow
Une 12ene de type d'entité
Problématique avec les modules contrib qui ne gèrent que les nodes

Statefield: https://drupal.org/sandbox/damz/1550106

(hors session: https://drupal.org/sandbox/andypost/1114392)

## Créer des variantes de certaines parties du contenus
avec propriétés et champs surchargeables

Objectif: Pas de duplication de nodes pour ce besoin

Entity override : https://drupal.org/project/entity_override

Utiliser aussi pour la traduction!!
Exportable dans des features
Est capable de créer l'entité cible.

Module Tree + TreeField

Device Management

EntityBundlePlugin : https://drupal.org/project/entity_bundle_plugin ?

Synchronisation des contenus via Migration et XMLRPC



Le backend a été implémenté comme un sous-projet à part en tiers
18 mois du 1er jour à la mise en ligne 1 => Par contre les nouveaux sites sont simples à mettre en ligne

1 master pour piloter tous les sites, choisir si le site est Ecommerce ou non.
Les frontaux sont totalement passifs.

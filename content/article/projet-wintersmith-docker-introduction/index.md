+++
date = "2014-08-08"
title = "Wintersmith Docker - Introduction"
Description = "Projet Wintersmith Docker. Génération d'un site statique Wintersmith à l'intérieur d'un conteneur Docker."
Tags = ["Nodejs", "Docker"]
Categories = ["Développement", "DevOps"]
aliases = [
  "/blog/articles/projet-wintersmith-docker-introduction",
  "/blog/articles/projet-wintersmith-docker"
]
+++


Après plusieurs lectures et essais rapides de Docker, j'ai décidé d'y consacrer une peu plus de temps de manière concrête.

Etant en pleine réflexions sur l'outil que j'allais utilisé pour la réalisation de ce blog, j'ai donc décidé de lancer le projet [Wintersmith Docker](https://github.com/jygastaud/wintersmith_docker) afin de pouvoir tester [Wintersmith](http://wintersmith.io), un générateur de site statique basé sur [Nodejs](http://nodejs.org), dans un conteneur [Docker](http://docker.com).

## Ca sert à quoi ce projet?

Le projet donne accès à 2 types d'utilisation:

* **Pour les utilisateurs de Vagrant**, un Vagrantfile est disponible en plus du Dockerfile afin d'avoir l'installation de Docker, la création de l'image et le lancement du conteneur Docker réalisé de manière automatisé.
* **Pour les utilisateurs de Docker**, le Dockerfile permet de créer une image contenant Nodejs et Wintersmith pré-installés qui peut être ensuite appeler pour la création d'un ou plusieurs containers.

La mise en place de ce projet a été extremement formatrice sur Docker.
Je vous invite à lire les [quelques notes en vracs](http://jygastaud.github.io/blog/articles/notes-docker/) que j'ai posté dans mon billet précédent.

## Un peu d'historique

L'idée initiale du projet était simple et se décomposait comme ceci:

1. Créer une image via Docker contenant Wintersmith et Nodejs pour pouvoir à volonté:
  * Créer un nouveau site Wintersmith: ```wintersmith new <site name>```
  * Partager un site existant

2. Créer un conteneur Docker qui
  * Lancerait Wintermith en mode preview: ```wintersmith preview```
  * Permettrait de voir en live les modifications / ajouts faits dans le dossier de contenus.

**Le tout sans avoir besoin d'installer Wintersmith et Nodejs en local** (comme avec une VM Vagrant en fait mais en plus léger).

## Un peu d'honnêteté

Soyons franc,tout n'a pas été tout beau et tout rose.

Docker n'offre pas la même souplesse qu'un machine virtuelle complète et est notamment restreint par:

* le fait de ne devoir gérer qu'un seul processus par conteneur (tout du moins si l'on ne passe pas par des solutions de contournement telles que Supervisor)
* le fait de ne pas pouvoir exécuter plusieurs commandes lors du ```run``` d'un conteneur
* le fait de ne pas avoir d'accès direct (via ssh par exemple) au conteneur lancé
* *etc*

Ces quelques exemples montrent bien les différences, potentiellement mal perçues/comprises, entre un Docker et une VM.

Les usages que l'on peut trouver aux 2
systèmes ne sont pas forcement concurrents. Pour preuves, Vagrant propose de faire son provisioning avec Docker.

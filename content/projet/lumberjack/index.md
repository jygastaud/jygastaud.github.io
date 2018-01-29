+++
Categories = ["Développement", "Projet"]
Description = "Lumberjack propose une UI permettant de générer une box Vagrant provisionnée avec Ansible."
Tags = ["Ansible", "Vagrant", "Générateur"]
aliases = []
date = "2015-05-04T22:19:34+02:00"
project_url = "https://github.com/FlorianLB/lumberjack-ansible"
title = "Lumberjack Ansible"
Weight = 1
is_github = 0
is_drupal = 0
project_repo_name = "jygastaud/lumberjack-ansible"
image = "image-min.jpg"

+++

Lumberjack propose une UI permettant de générer une box Vagrant provisionnée avec Ansible et permettant de lancer rapidement le développement d'un projet PHP.

## Etat actuel

Lumberjack vous génèrera une box contenant par défaut un serveur web (Nginx) et PHP-FPM.
Cette box est basée sur la distribution Debian 7 (Wheezy).

Contrairement à d'autres projets ayant la même vocation ([PhAnsible](https://github.com/Phansible/phansible) ou [Protobox](https://github.com/protobox/protobox)), Lumberjack offre moins de finesse dans ses configurations diponibles via son interface utilisateur. En effet, l'objectif est de pouvoir fournir des configurations pré-définies pour fonctionner sur certains projets types. C'est pour cela que des options Symfony2 et Drupal ont d'ores et déjà commencé à être implémentées.

## Le futur

2 chantiers importants sont en cours.

1. Refactorer l'organisation du dossier de provisionning pour suivre [les bonnes pratique recommandées par Ansible](https://github.com/FlorianLB/lumberjack-ansible/issues/17)
2. Ajouter la possibilité d'utiliser Apache en tant que [serveur web principal](https://github.com/FlorianLB/lumberjack-ansible/issues/7).



## Et si on testait ça?

Pour générer une box rendez-vous sur [la page Heroku du projet](http://lumberjack-ansible.herokuapp.com/) ou [télécharger le projet sur Github](https://github.com/FlorianLB/lumberjack-ansible) et suivez [les instructions du README](https://github.com/FlorianLB/lumberjack-ansible/blob/master/README.md).

+++
Categories = ["Développement", "Article"]
Description = "Proposition de structure globale à mettre en place sur nos projets web."
Tags = ["Développement", "Article"]
aliases = []
date = "2015-12-16T07:52:43+01:00"
image = ""
title = "Structure globale sur nos projets"
draft = true
+++

```
.
├── docker-compose
├── docroot -> source
├── provision
├── scripts
├── source
└── Vagrantfile

4 directories, 2 files
```

* docker-compose
  * fichier de provisionning pour Docker
* docroot
  * les sources du projet telles qu'elles doivent aller en production
  * pour les projets non compilés (PHP par exemple), proposition de faire un simple lien symbolique vers `source`
* provision
  * l'ensemble des fichiers/scripts utiles au provisionning des machines virtuelles ou Docker
* scripts
  * les scripts utilitaires du projet (cf: eggplant)
* source
  * les sources non compilées du projet
* Vagrantfile
  * fichier de provisionning pour Vagrant

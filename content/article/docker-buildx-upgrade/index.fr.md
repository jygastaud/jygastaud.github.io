+++
title = "Mettre à jour Buildx dans Docker CLI"
Description = """
Procédure de mise à jour de Buildx dans Docker.

Docker CLI inclut le plugin buildx permettant d'étendre les fonctions de build de Docker.

Problème, la version disponible et pré-paquagée n'est pas à jour des dernières évolutions.

Si vous souhaitez profiter des toutes dernières évolutions, il vous sera nécessaire de procéder à une mise à jour.
"""
Categories = ["DevOps"]
Tags = ["Docker", "Buildx"]
image = "docker-logo.png"
aliases = []
date = 2020-05-02T14:29:42+02:00
lastmod = 2020-05-02T14:29:42+02:00
+++

Docker CLI, depuis la version 19.03 inclut le plugin [buildx](https://github.com/docker/buildx) permettant d'étendre les fonctions de build de Docker en s'appuyant sur [Buildkit](https://github.com/moby/buildkit).

Parmis les principaux points qu'apportent Buildkit on notera les suivants :

* résolution en parallèle des dépendences
* meilleure gestion du cache (import/export, résolution)
* possibité de distribuer les charges de travail
* exécution sans droits root

Et donc, comme indiqué plus haut, buildkit est maintenant inclut dans docker CLI.
Problème, la version disponible et pré-paquagée n'est pas à jour des dernières évolutions.

Si vous souhaitez profiter des toutes dernières évolutions,
il vous sera nécessaire de procéder à une mise à jour.

{{% notice info "version de buildx" %}}
Ce tutoriel utilise la version **0.4.1** de buildx.  
Pensez à vérifier le numéro de la dernière version avant de copier/coller les instructions.
{{% /notice %}}

## Les étapes

Vérifier l'existance du dossier `~/.docker/cli-plugins`.
S'il n'existe pas, créez le

```bash
mkdir ~/.docker/cli-plugins
```

Télécharger la dernière version de buildx depuis la [page de release Buildx sur Github](https://github.com/docker/buildx/releases) ou directement via votre terminal

```bash
wget -O ~/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.4.1/buildx-v0.4.1.linux-amd64
```

Définir les droits d'éxécution sur le binaire : `chmod +x ~/.docker/cli-plugins/docker-buildx`

et voilà !

Il ne nous reste plus qu'à vérifier si la version de buildx est maintenant celle attendue

```bash
docker buildx version`
```

Si vous voulez que buildx deviennent le builder par défaut de Docker CLI

```bash
docker builx install
```

## Démo

[![asciicast](https://asciinema.org/a/aWtsg3uCTb2wbEeZHh79c2ntS.svg)](https://asciinema.org/a/aWtsg3uCTb2wbEeZHh79c2ntS)

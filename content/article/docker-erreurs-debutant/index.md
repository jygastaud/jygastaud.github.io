+++
title = "Docker - Erreurs de débutant"
date = "2014-08-12"
image = "http://js.blog.kaliop.com/wp-content/uploads/2014/08/homepage-docker-logo.png"
description = "Dans l'article précédent, je parlais du projet Wintersmith Docker et mentionnais le fait que j'avais fait des erreurs dans la conception initiale, dûes à un manque de connaissance de Docker. Cet article vient apporter quelques éclairages sur ces erreurs."
aliases = [
  "/blog/articles/docker-erreurs-debutant/",
  "/blog/articles/projet-wintersmith-docker-erreurs-debutant-partie-1/"
]
Categories = ["DevOps"]
Tags = ["Docker"]
+++

Dans l'article précédent, je parlais du projet [Wintersmith Docker]((https://github.com/jygastaud/wintersmith_docker) et mentionnais le fait que j'avais fait des erreurs dans la conception initiale, dûes à un manque de connaissance de Docker.

## Le Dockerfile

L'une des premières erreurs que j'ai fait a été de vouloir tout mettre dans le Dockerfile en pensant que tout doit passer par là pour automatiser les choses.

C'est en partie vrai mais il est parfois préférable de séparer la partie stack logiciel, data et build.

Mon 1er Dockerfile ressemblait à cela

```
# DOCKER-VERSION 0.9.1
FROM  ubuntu

RUN     sudo apt-get update -qq
RUN     sudo apt-get install python-software-properties -y -qq
RUN     sudo apt-get install nodejs npm -y -qq
RUN     sudo apt-get install nodejs-legacy -y -qq

# Bundle app source
ADD ./www /www

# Install app dependencies
RUN sudo npm install wintersmith -g

# Create new site
WORKDIR /www
RUN wintersmith new site

# Launch Wintersmith preview
WORKDIR /www/site
CMD ["wintersmith", "preview"]

EXPOSE  8080
```


Rentrons un peu dans le détail du fichier pour voir les différentes problématiques:

* ```FROM  ubuntu```
nous ne spécifions aucune version ce qui a pour conséquence de provoquer le téléchargement de tous les layers Ubuntu et non pas ceux seulement dédiés à la version souhaitée.

Il est donc préférable d'écrire l'instruction sous la forme suivante:
```FROM ubuntu:<VERSION>```

* ```RUN wintersmith new site```
était censé créé l'arborescence du site par défaut tel que présentée ci-dessous

```
www
└── site
    ├── contents
    │   ├── articles
    │   │   ├── XXXXXXXXXXX
    │   │   ├── YYYYYYYYYYY
    │   │   ├── ZZZZZZZZZZZ
    │   ├── authors
    │   └── css
    ├── plugins
    └── templates
```

La commande s'exécutait bien mais le dossier créé n'est pas récupérable.

Avec quelques recherches, il s'avère que la commande ```docker cp``` semblait être faite pour cela mais l'export de fonctionne pas car cp n'est, à ce jour, capable de ne copier qu'un fichier à la fois (nous y reviendrons dans un prochain article).


* ```CMD ["wintersmith", "preview"]```
bien que cette commande ne soit pas fausse en soit, il est recommandé par par Docker l'utilisation de ENTRYPOINT[] et de garder au niveau du CMD[] uniquement les paramètres de la commande.

J'apprenais d'ailleurs par la suite, en discutant sur le channel IRC de Docker, que ENTRYPOINT ne servait pas que au niveau des commandes du Dockerfile mais aussi du run d'un conteneur en définissant la commande par défaut exécutée.

En effet, lors du run, il est possible de spécifier des paramètres d'exécution à l'image d'origine. Il est ainsi possible d'éxécuter différents types de conteneur:

* ```docker run -d jygastaud/wintersmith preview``` permettra de lancer le mode preview
* ```docker run -d jygastaud/wintersmith new nouveau_site``` lancera la commande de génération de site de Wintersmith.


Finalement, après qelques ajustements et changements de méthodes, mon Dockerfile ressemble à cela maintetenant:

```
FROM ubuntu:14.04
MAINTAINER jygastaud

# Some stuff
# Here

ENTRYPOINT ["wintersmith"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
```

Cette configuration nous donne un panel d'utilisation globale de Wintersmith en ne stockant qu'un minimum d'information.

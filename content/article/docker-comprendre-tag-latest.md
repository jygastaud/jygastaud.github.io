+++
Categories = ["DevOps"]
Tags = ["Docker"]
date = "2015-04-09"
title = "Docker - Comprendre le fonctionnement du tag latest"
Description = "Cet article est une synthèse d'une publication parue sur Medium qui explique de manière précise le fonctionnement du tag:latest disponible sur les images Docker."

+++

Cet article est une synthèse d'une [publication parue sur Medium](https://medium.com/@mccode/the-misunderstood-docker-tag-latest-af3babfd6375) qui explique de manière précise le fonctionnement du tag **latest** disponible sur les images Docker.

Comme vous le savez surement, il est possible de tagger ces images Docker pour les déposer sur un registry.

Cependant si vous avez essayé d'utiliser le tag **lastest** disponible pour certaines images, notamment sur le [Hub Docker](https://hub.docker.com/), vous avez pu vous rendre compte que ce tag n'a pas toujours le comportement espéré.

## Un secret enfin révélé

Ce que l'on apprend dans l'article, c'est que ce tag "latest" n'est pas vraiment un tag.

Il n'est en réalité présent que pour désigner la dernière version commitée **sans tag** et non pas la dernière version taggée/commitée.

Il est ainsi probable que beaucoup de versions "latest" sur le Hub Docker ne soit en réalité pas les versions les plus à jour.
Cela implique en effet une forte rigeur (et connaissance du fonctionnement que l'on vient de décrire) de la part des auteurs des images disponibles car pour maintenir le tag "latest" à jour, il est obligatoire de toujours prévoir un double taggage de son image.

1. une première fois sans numéro de tag
2. une seconde fois avec une numéro de tag


## Le conseil de l'auteur

* **Oublier que ce tag latest existe** et ne jamais l'utiliser.
* **Toujours** penser à tagger vos images

Je vous invite à [lire l'intégralité de la démonstration](https://medium.com/@mccode/the-misunderstood-docker-tag-latest-af3babfd6375) pour plus de détails.

+++
Categories = ["DevOps"]
Description = "Le support de HTTP/2 est maintenant suffisamment stable et implémenté dans les serveurs les plus couramment utilisés alors qu'elles sont les raisons qui pourraient nous pousser à choisir une version ou l'autre dans nos projets ?"
Tags = ["Développement", "Infrastructre", "HTTP"]
date = "2016-02-02T13:45:17+02:00"
title = "HTTP 1.x ou HTTP/2  - Lequel choisir ?"

+++

Le support de HTTP/2 est maintenant suffisamment stable et implémenté dans les serveurs les plus couramment utilisés alors qu'elles sont les raisons qui pourraient nous pousser à choisir une version ou l'autre dans nos projets ?

## HTTP 1.x

Vous serez obliger de continuer à utiliser HTTP 1.x dans les cas suivants :

* site en HTTP non sécurisé

Bien qu'HTTP/2 supporte officiellement le protocole HTTP non sécurisé, l'ensemble des navigateurs ont pour le moment fait le choix de ne pas l'implémenter.
Du coup, si vous n'avez pas de certificat pour votre nom de domaine, il vous faudra rester sur HTTP 1.x

* Restrictions techniques par rapport au serveur web utilisé

Les cas sont rares maintenant.
Vous pouvez vérifier si le votre le supporte sur le [Github HTTP2](https://github.com/http2/http2-spec/wiki/Implementations)

* mon hébergeur ne veut pas le faire

Changer d'hébergeur ! :)


## HTTP/2

Si vous avez la main sur l'architecture serveur de votre application ou êtes à même d'être prescripteur sur les solutions à implémenter alors il est préconisé d'envisager de passer à HTTP/2 dès maintenant.

## Les contraintes

* un serveur supportant HTTP/2
* un certificat SSL


Et vous alors êtes-vous déjà passer à HTTP/2 ?

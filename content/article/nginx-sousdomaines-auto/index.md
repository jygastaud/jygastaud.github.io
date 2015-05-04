+++
title = "Configurer Nginx pour gérer automatiquement vos sous-domaines locaux"
date = "2014-01-07"
description = "Dans cette article j'aborde une idée permettant de demander à Nginx de générer automatiquement des sous-domaines locaux pour simplifier la mise en place et le démarrage de nouveaux développements."
aliases = [
	"/blog/articles/nginx-sousdomaines-auto/"
]
+++

Lors des développements locaux, nous avons pris l'habitude de toujours définir un nom de domaine local (mon_site.local dans notre exemple) afin de coller au plus proche de la réalité du site final.

## Le processus classique était le suivant
* Ajout d'un nouveau dossier allant contenir notre site dans notre répertoire de développement (/var/www dans notre exemple). On obtient ainsi l'arborescence suivante:

```
/var/www/
├── mon_site1
│   └── index.html
├── mon_site2
│   └── index.html
```

* Ajout d'un nouvel host local dans le fichier ```/etc/hosts```

```
127.0.0.1 mon_site.local
```

* * *

## Fonctionnement désiré

Le but principal de notre implémentation est de pouvoir traiter un ensemble de sous-sites de manière générique pour ne pas avoir à recréer de nouveaux vhosts et aller modifier le fichier hosts local à chaque nouvelle implémentation.

Ainsi avec l'arborescence ci-dessous,

```
/var/www/
├── local.dev
│   └── www
│       ├── test1
│       │   └── index.html
│       └── test2
│           └── index.html
```

il nous sera immédiatement possible d'accéder aux sous-domaines suivants et de charger le bon fichier d'index:

```
test1.local.dev
test2.local.dev
```

* * *

## Configuration de Nginx

Nous partons du prérequis que vous avez déjà Nginx installé sur votre machine.
Si ce n'est pas le cas, une bref recherche vous permettra de trouver de nombreux tutoriaux traitant de ce sujet.

Dans notre exemple, la version de nginx utilisée est la suivante:
	nginx version: nginx/1.4.1 (Ubuntu)

### Création d'un nouveau site nginx

Configuration de notre site dans le dossier ```/etc/nginx/sites-available```

```
server {
    # On écoute le port 80.
    listen 80;

    # On va utiliser une expression régulière
    # pour récupérer le sous-domaine dans une variable nommée "sub".
    server_name  ~^(?P<sub>.+)\.local\.dev$;

    location / {
         # On définie le chemin local
         # en utilisant la variable "sub" récupérée précédemment.
         root /var/www/local.dev/www/$sub;
    }
}
```


On active notre site via un lien symbolique dans le dossier ```/etc/nginx/sites-enable```

```
ln -s /etc/nginx/sites-available/local.dev /etc/nginx/sites-enable/local.dev
```
et on redémarre le serveur via la commande:

```
service nginx restart
```


* * *

## Configuration d'un hote générique

### 1ères tentatives

Notre 1ère logique a donc était d'essayer de définir un domaine générique au sein de notre fichier ```/etc/hosts``` comme nous pouvions le faire avec notre domaine classique.

Nous avons donc tenter l'ajout de plusieurs lignes avec ou sans wildcard (*) telles que:
```
127.0.0.1 local.dev
127.0.0.1 .local.dev
127.0.0.1 *.local.dev
```

mais rien n'y fait, ces solutions ne marchent pas et il nous fallait toujours ajouter nos sous-domaines "à la main" dans le fichier hosts.

### Le problème

Le fichier hosts ne permet pas de définir de wildcards pour un domaine.

Il est donc normal que nos tentitves précédentes ne fonctionnent pas.

### La solution

Nos diverses recherches nous ont emmené à découvrir que la seule solution possible pour obtenir le résultat escompté était de passer par un serveur de DNS installé en local et qui se chargerait de faire l'interprétation et la traduction du nom de domaine.

Plusieurs solutions existes pour cela et dont la plus connue est **Bind**.
Toutefois, Bind nous paraissait trop lourd à implémenter pour notre besoin et nous nous sommes finalement rabattus sur l'utilisation de **DNSMasq** qui permet une implémentation rapide et une configuration très simple.

###DNSmasq

Dans le fichier /etc/dnsmasq.conf (le créer s'il n'existe pas), il vous suffit d'ajouter la ligne suivante:

```
address=/mon_nom_de_domaine.extension/127.0.0.1
```

et c'est tout!

Dans notre exemple, nous avons donc ajouter:

```
address=/local.dev/127.0.0.1
```

On redémarre dnsmasq (```service dnsmasq restart``` sur Ubuntu) et on peut constater que nos domaines sont accessibles.

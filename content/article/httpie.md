+++
Categories = ["Développement", "Shell"]
Tags = ["Développement", "Shell"]
date = "2016-04-14T11:49:35+02:00"
title = "Oubliez cURL et Wget grâce à HTTPie"
Description = "HTTPie remplace élégamment les traditionnels cURL et Wget pour notre plus grand bonneur."

+++

[HTTPie](https://github.com/jkbrzt/httpie) est un utilitaire en ligne de commande qui a vocation à remplacer simplement l'utilisation des commandes cURL et wget tout en ajoutant une petite touche bien agréable.

## Installation

Plusieurs modes d'installation sont possibles. En effet HTTPie est disponible via les packages officiels (pas forcement la dernière version) ou via `pip`.

Vous trouverez toutes les informations nécessaires dans le [Readme du projet](https://github.com/jkbrzt/httpie#installation).

## Formatage et couleur

### Formatage

Si vous avez déjà lancé des requêtes à une API via cURL, vous avez déjà du voir des résultats comme ci-dessous.

```
$ curl "https://www.drupal.org/api-d7/user.json?name=jygastaud"

{"self":"https:\/\/www.drupal.org\/api-d7\/user?name=jygastaud","first":"https:\/\/www.drupal.org\/api-d7\/user?name=jygastaud\u0026page=0","last":"https:\/\/www.drupal.org\/api-d7\/user?name=jygastaud\u0026page=0","list":[{"field_industries_worked_in":[],"field_organizations":[{"uri":"https:\/\/www.drupal.org\/api-d7\/field_collection_item\/468341","id":"468341","resource":"field_collection_item"},{"uri":"https:\/\/www.drupal.org\/api-d7\/field_collection_item\/724935","id":"724935","resource":"field_collection_item"}],"field_bio":[],"field_irc_nick":"jygastaud","field_websites":[{"url":"http:\/\/www.clever-age.com","attributes":[]}],"field_country":"France","field_gender":"male","field_languages":["English","French"],"field_terms_of_service":true,"field_areas_of_expertise":[],"field_contributed":["patches","modules","issues","applications","forums","services","irc","mentor"],"field_events_attended":[],"field_mentors":[],"field_drupal_contributions":[],"field_first_name":null,"field_last_name":null,"og_user_node":[],"og_membership":[],"og_membership__1":[],"og_membership__2":[],"og_membership__3":[],"og_user_node__og_membership":[],"og_user_node__og_membership__1":[],"og_user_node__og_membership__2":[],"og_user_node__og_membership__3":[],"uid":"660334","name":"jygastaud","url":"https:\/\/www.drupal.org\/u\/jygastaud","edit_url":"https:\/\/www.drupal.org\/user\/660334\/edit","created":"1259343731","language":"en","flag_sid":0,"flag_drupalorg_user_spam_user":[]}]}

```

Pas très lisible, vous en conviendrez ?

Avec HTTPie, fini les requêtes CURL à une API qui renvoi un gros bloc illisible. Vous pouvez maintenant avoir un retour lisible dans votre terminal.

```
$ http "https://www.drupal.org/api-d7/user.json?name=jygastaud"

HTTP/1.1 200 OK
Accept-Ranges: bytes
Access-Control-Allow-Credentials: false
Access-Control-Allow-Headers: Content-Type
Access-Control-Allow-Methods: GET, OPTIONS
Access-Control-Allow-Origin: *
Age: 0
Cache-Control: no-cache
Connection: keep-alive
Content-Encoding: gzip
Content-Length: 546
Content-Security-Policy: frame-ancestors 'self'
Content-Type: application/json
Date: Thu, 14 Apr 2016 10:16:55 GMT
Etag: "1460629015-1"
Expires: Sun, 19 Nov 1978 05:00:00 GMT
Fastly-Debug-Digest: 760fd3aa9c342b8e1bbdc30d5ebbb895ba37763ccd3ce2e0bdab520ac08df17e
Last-Modified: Thu, 14 Apr 2016 10:16:55 GMT
Server: Apache
Strict-Transport-Security: max-age=10886400; includeSubDomains; preload
Vary: Cookie,Accept-Encoding
Via: 1.1 varnish
Via: 1.1 varnish
X-Cache: MISS, MISS
X-Cache-Hits: 0, 0
X-Content-Type-Options: nosniff
X-Drupal-Cache: MISS
X-Frame-Options: SAMEORIGIN
X-Served-By: cache-sea1924-SEA, cache-fra1227-FRA
x-host: www.drupal.org
x-url: /api-d7/user.json?name=jygastaud

{
    "first": "https://www.drupal.org/api-d7/user?name=jygastaud&page=0",
    "last": "https://www.drupal.org/api-d7/user?name=jygastaud&page=0",
    "list": [
        {
            "created": "1259343731",
            "edit_url": "https://www.drupal.org/user/660334/edit",
            "field_areas_of_expertise": [],
            "field_bio": [],
            "field_contributed": [
                "patches",
                "modules",
                "issues",
                "applications",
                "forums",
                "services",
                "irc",
                "mentor"
            ],
            "field_country": "France",
            "field_drupal_contributions": [],
            "field_events_attended": [],
            "field_first_name": null,
            "field_gender": "male",
            "field_industries_worked_in": [],
            "field_irc_nick": "jygastaud",
            "field_languages": [
                "English",
                "French"
            ],
            "field_last_name": null,
            "field_mentors": [],
            "field_organizations": [
                {
                    "id": "468341",
                    "resource": "field_collection_item",
                    "uri": "https://www.drupal.org/api-d7/field_collection_item/468341"
                },
                {
                    "id": "724935",
                    "resource": "field_collection_item",
                    "uri": "https://www.drupal.org/api-d7/field_collection_item/724935"
                }
            ],
            "field_terms_of_service": true,
            "field_websites": [
                {
                    "attributes": [],
                    "url": "http://www.clever-age.com"
                }
            ],
            "flag_drupalorg_user_spam_user": [],
            "flag_sid": 0,
            "language": "en",
            "name": "jygastaud",
            "og_membership": [],
            "og_membership__1": [],
            "og_membership__2": [],
            "og_membership__3": [],
            "og_user_node": [],
            "og_user_node__og_membership": [],
            "og_user_node__og_membership__1": [],
            "og_user_node__og_membership__2": [],
            "og_user_node__og_membership__3": [],
            "uid": "660334",
            "url": "https://www.drupal.org/u/jygastaud"
        }
    ],
    "self": "https://www.drupal.org/api-d7/user?name=jygastaud"
}

```

### couleur

Regarder l'image en exemple sur le dépôt github

![curl vs httpie](https://raw.githubusercontent.com/jkbrzt/httpie/master/httpie.png)

Comme vous pouvez le voir, HTTPie en plus d'apporter un formatage de la sortie vous apportera aussi une colorisation.

## Uniformation

Donc avant, vous aviez cURL pour requêter vos URLs et Wget pour télécharger des fichiers.

Grâce à HTTPie, vous pouvez maintenant ne retenir qu'une seule syntaxe !

Ainsi

```
$ wget https://ftp.drupal.org/files/projects/devel-8.x-1.x-dev.tar.gz
```

devient

```
$ http --download https://ftp.drupal.org/files/projects/devel-8.x-1.x-dev.tar.gz
```

Le fait d'être capable d'utiliser une même commande pour les requêtes et pour le téléchargement va vite vous simplifier la vie. Une seule syntaxe à retenir.

Le fait de n'avoir plus qu'une commande à retenir va nous simplifier la vie et cela est encore plus vrai si on doit utiliser des certificats SSL.

Par exemple, nous avons une API que l'on doit requêter et une route de récupération de fichier zip, le tout accessible uniquement via une clé et un certificat SSL.

On passera donc des commandes suivantes

```
$ curl -i -v --key ./certs/mon-certicat.key --cert ./certs/mon-certicat.pem "https://mon-api.com/infos"

$ wget --private-key="./certs/mon-certicat.key" --certificate="./certs/mon-certicat.pem" "https://mon-api.com/infos/images.zip"

```

à

```
$ http --cert=./certs/mon-certicat.pem --cert-key=./certs/mon-certicat.key https://mon-api.com/infos

$ http --download --cert=./certs/mon-certicat.pem --cert-key=./certs/mon-certicat.key https://mon-api.com/infos/images.zip
```

C'est quand même plus simple à retenir quand on a qu'une seule syntaxe non ?


## Pour aller plus loin

Lisez la documentation disponible sur le [dépôt Github HTTPie](https://github.com/jkbrzt/httpie) elle est vraiment très complète.

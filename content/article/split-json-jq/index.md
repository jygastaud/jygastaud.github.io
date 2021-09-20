+++
title = "Split JSON avec jq"
Description = "Comment découper un JSON en plusieurs fichiers"
Tags = ["Développement", "Tips", "Shell"]
Categories = ["DevOps"]
image = ""
aliases = []
date = 2019-01-16T16:36:46+01:00
lastmod = 2019-01-16T16:36:46+01:00
+++

Vous êtes vous déjà demandé comment découper un JSON en plusieurs "sous-"fichiers" ?

Si oui, cette ligne de commande est faite pour vous !

La seule dépendance ici est l'utilisation de l'outils [jq](https://stedolan.github.io/jq/).

Je vous encourage d'ailleurs à regarder cet outil très puissant sur la manipulation de JSON.

## TL;DR

```
jq -c -M '.[]' myfile.json | \
while read line; do echo $line > $(echo $line | jq -r -c ".id").json; done
```

La commande va parser le fichier `myfile.json` et créer 1 fichier pour chaque `id` trouvé.

Cela fonctionne également en récupérant directement la sortie d'un service / API...

### Exemple

```
echo '[{ "id": "16", "name": "produit 1" }, { "id": "17", "name": "produit 2" }, { "id": "18", "name": "produit 3" }, { "id": "19", "name": "produit 4" }]' | \
jq -c -M '.[]' | \
while read line; do \
echo $line > $(echo $line | jq -r -c ".id").json; \
done
```

## Détails

### Parsing du fichier JSON initial

```
jq -c -M '.[]' myfile.json
```

On va parser le fichier `myfile.json` et récupérér 1 ligne pour chaque entrée de 1er niveau.

### Lire chaque ligne et créer le json associé

Tant qu'il y a des lignes, on boucle dessus.

```
while read line; do 
    ...
done
```

On renvoi ensuite la ligne et on utilise de nouveau jq pour récupérer l'id afin de nommer le fichier

```
echo $line > $(echo $line | jq -r -c ".id").json;
```

### Fichier myfile.json

```
[
    {
        "id": "16",
        "name": "produit 1"
    },
    {
        "id": "17",
        "name": "produit 2"
    },
    {
        "id": "18",
        "name": "produit 3"
    },
    {
        "id": "19",
        "name": "produit 4"
    }
]
```

### Options de la commande

* `-c             compact instead of pretty-printed output;` : nous permet d'avoir 1 ligne affiché par résultat
* `-M             monochrome (don't colorize JSON);` : purement esthétique pour ne pas risquer de polluer l'extraction
* `-r             output raw strings, not JSON texts;` : permet de supprimer le guillemet de sortir de notre ID.


## Bonus : Ajouter des informations à un fichier JSON

```
$ jq '. += { "category": "ma categoie", "subcategory": "ma sous categorie" }' 19.json
```

jq va ajouter les entrées `category` et `subcategory` au fichier `19.json` lors de l'affichage.

Il vous ai bien entendu ensuite possible de passer ce nouveau JSON à un nouveau fichier et l'enregistrer.

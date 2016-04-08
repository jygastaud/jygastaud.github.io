+++
Categories = ["Développement"]
Description = "Supprimer toutes les branches mergées sur votre dépot distant en 1 ligne de commande."
Tags = ["Développement", "Git"]
date = "2015-12-03T13:51:38+02:00"
title = "Git : Supprimer toutes les branches mergées sur le dépot distant"

+++

Supprimer toutes les branches mergées sur votre dépot distant en 1 ligne de commande c'est possible !

## TL;DR

```
git branch -r --merged master | grep -v master | sed 's/origin\///' | xargs -n 1 git push --delete origin
```

{{% tips color="negative" %}}
<strong>Attention :</strong> cette commande permet de véritablement supprimer des branches dans le dépôt distant. Par exemple, si <code>develop</code> est mergé avec <code>master</code>, cela supprimera <code>develop</code>. Mais peut-être que les développeurs n'ont pas le droit de pousser du code sur <code>master</code> directement&#8230; et se retrouveront, du coup, bloqués. Pensez-y !
{{% /tips %}}

### Exemple excluant une branche nommée `develop`

```
git branch -r --merged master | grep -v master | grep -v develop | sed 's/origin\///' | xargs -n 1 git push --delete origin
```


## Explications

* `git branch -r --merged master` va récupérer la liste des branches distantes mergées (par rapport à master)
* `grep -v master` va exclure la branche master des résultats (vous pouvez ajouter d'autres branches à exclure si nécessaire)

Ces 2 premières commandes combinées vont renvoyés un résultat dans ce style :

```
  origin/t-619
  origin/t-63
  origin/t-675
  origin/t-707
  origin/t-808
  origin/t-809
  origin/t-819
```

* `sed 's/origin\///'` permet de supprimer le `origin/`
* `xargs -n 1 git push --delete origin` va prendre chaque ligne renvoyée et lancer la commande `git push --delete origin BRANCHE`

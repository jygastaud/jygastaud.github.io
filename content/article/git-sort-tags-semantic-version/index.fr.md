+++
title = "Git - Trier les tags d'un repo utilisant du semantic versioning"
Description = "Comment trier correctement ses tags basés sur du semantic versioning dans un repository Git ?"
Tags = ["Git", "Tips"]
Categories = ["DevOps"]

date = 2021-09-20T23:10:00+02:00

lastmod = 2021-09-20T23:10:00+02:00

+++

Un rapide article aujourd'hui pour vous parler d'une découverte récente dans les fonctions de tri de Git et les tags basés sur le [semantic versioning](https://semver.org/lang/fr/).

<!--more-->

Par défaut, si vous lancez la commande `git tag -l`, Git va faire un tri alphabétique.

Cependant, ce tri donne des résultats déconcertant lorsque les tags utilisent une notation basée sur le semantic versioning.

```bash
git tag -l
v2.6.1
v2.6.10
v2.6.11
v2.6.12
v2.6.2
v2.6.3
v2.6.4
v2.6.5
v2.6.6
v2.6.7
v2.6.8
v2.6.9
v2.7.0
```

Noté ici la séquence `v2.6.10`, `v2.6.11` et `v2.6.12`  qui s'intercale entre la version `v2.6.1` et `v2.6.2`.



Afin de résoudre ce souci, il est possible d'utiliser la fonction de tri `--sort` avec l'attribut `version` dans Git.

```bash
git tag --sort=version:refname
```



Cela affichera les résultats triés de façon cohérente :



```bash
git tag --sort=version:refname
v2.6.1
v2.6.2
v2.6.3
v2.6.4
v2.6.5
v2.6.6
v2.6.7
v2.6.8
v2.6.9
v2.6.10
v2.6.11
v2.6.12
v2.7.0
```


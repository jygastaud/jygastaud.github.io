+++
title = "Git - Comparer les commits de 2 branches Git"
Description = "Listing des différentes manières de comparer des branches dans Git :"
Tags = ["Développement", "Git", "Tips"]
Categories = ["DevOps"]
image = ""
aliases = []
date = 2019-01-18T09:50:14+01:00
lastmod = 2019-01-18T09:50:14+01:00
+++

Listing des différentes manières de comparer des branches dans Git.

## TLDR;

Toute la magie réside dans l'utilisation des plages de révision et la syntaxe `BRANCH_1..BRANCH_2`

## Connaitre les différences entre 2 branches

```
git diff [BRANCH_1]..[BRANCH_2]
```

retourne les différences de code entre 2 branches.

```
diff --git a/readme.txt b/readme.txt
index ac28f91..ae362e4 100644
--- a/readme.txt
+++ b/readme.txt
@@ -1 +1 @@
-Coucou
+Coucou2
```

On constate ici que dans le fichier readme.txt de a branche `b`, le mot `Coucou` a été remplacé par `Coucou2`.


## Comparer les commits de 2 branches

Avec l'utilisation de `diff`, nous n'avons cependant pas la vision sur les commits qui ont créé le delta.

Pour ce type de comparaison, il est possible d'utiliser `git log`.

```
git log [BRANCH_1]..[BRANCH_2]
```

retourne uniquement les commits de `branch_2` non présents dans `branch_1`

```
commit fc372ddecf5d98a8ba0d000a3c1ccf77a4f1237b (b)
Author: Jean-Yves Gastaud <jeanyves@gastaud.io>
Date:   Thu Jan 10 16:53:07 2019 +0100

    third commit
```

Pour avoir plus de détails sur le contenu du changement, il est possible d'utiliser toutes la panoplie d'options de la commande `log`.

L'utilisation des options `--graph` et `--stat` est particulièrement utile dans ce cas.

```
$ git log --oneline --decorate --graph --stat [BRANCH_1]..[BRANCH_2]
```

retourne

```
* fc372dd (b) 3eme commit
   readme.txt | 2 +-
   1 file changed, 1 insertion(+), 1 deletion(-)
```

Admettons maintenant que `branch_1` est été rebase par rapport à `master` mais pas la `branch_2`, est-ce que mon delta de commit sera toujours cohérent ?

Prenons l'exemple suivant :

`master` contient

```
* 81faeea 2019-01-18 | a commit in master (master) [Jean-Yves Gastaud]
* 3be0b31 2019-01-10 | 1er commit [Jean-Yves Gastaud]
```

`branch_1` a été rebase avec les données de `master` et contient 2 commits de plus.

```
* 5b3a95a 2019-01-18 | a commit (BRANCH_1) [Jean-Yves Gastaud]
* 19b7763 2019-01-10 | 2nd commit [Jean-Yves Gastaud]
* 81faeea 2019-01-18 | a commit in master (master) [Jean-Yves Gastaud]
* 3be0b31 2019-01-10 | 1er commit [Jean-Yves Gastaud]
```

`branch_2` quant à elle n'est pas rebase et par toujours du 1er commit sur `master`.

```
* fc372dd 2019-01-10 | 3eme commit (BRANCH_2) [Jean-Yves Gastaud]
* 3be0b31 2019-01-10 | 1er commit [Jean-Yves Gastaud]
```

Retestons notre  
`git log --oneline --decorate --graph --stat [BRANCH_1]..[BRANCH_2]`

```
* fc372dd (BRANCH_2) 3eme commit
   readme.txt | 2 +-
   1 file changed, 1 insertion(+), 1 deletion(-)
```

Super, nous voyons toujours notre commit non présent dans la `branch_1` !

Si besoin de savoir quelles sont les commits de la `branch_1` non présents dans `branch_2`, il est bien entendu possible d'inverser les arguments.

Ainsi `git log --oneline --decorate --graph --stat [BRANCH_2]..[BRANCH_1]` nous renverra

```
* 5b3a95a (BRANCH_1) a commit
|  readme.txt | 3 +--
|  1 file changed, 1 insertion(+), 2 deletions(-)
* 19b7763 2nd commit
|  readme.txt | 3 ++-
|  1 file changed, 2 insertions(+), 1 deletion(-)
* 81faeea (master) a commit in master
   readme.txt | 2 +-
   1 file changed, 1 insertion(+), 1 deletion(-)
```

Enfin, si notre `branch_1` a été mergée dans `master`, nous pouvons toujours avoir les mêmes résultats.

Un `git log --oneline --decorate --graph --stat [BRANCH_2]..master` renverra bien l'ensemble de l'arbre de commits absents.

```
*   9eb6957 (HEAD -> master) Merge branch 'a'
|\
| * 5b3a95a (a) a commit
| |  readme.txt | 3 +--
| |  1 file changed, 1 insertion(+), 2 deletions(-)
| * 19b7763 2nd commit
|/
|    readme.txt | 3 ++-
|    1 file changed, 2 insertions(+), 1 deletion(-)
* 81faeea a commit in master
   readme.txt | 2 +-
   1 file changed, 1 insertion(+), 1 deletion(-)
```


+++
title = "Git - Tips & Tricks"
Description = ""
Tags = ["Développement", "Git", "Tips"]
Categories = ["DevOps"]
image = ""
aliases = []
date = 2019-04-23T14:44:54+02:00
lastmod = 2019-04-23T14:44:54+02:00

+++

Git est un outil très puissant et il propose de nombreuses fonctionnalités qui ne sont pas toujours connues ou simple à appréhender.

Vous trouverez ci-dessous quelques astuces pour vous aider au quotidien et ne plus avoir peur de faire une bêtise !

<!--more-->

## Visualiser son historique

### Visualiser l'historique des logs de la branche courante

```
git log
```

### Améliorer l'affichage de ses logs

```bash
git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short
```

que vous pouvez alias-er par exemple en  `git hist` avec la commande suivante

```
git config --global alias.hist 'log --pretty=format:"%h %ad | %s%d [%an]" --graph --date'
```

ou en modifiant votre fichier de configuration `~/.gitconfig`, section `[alias]`

```
[alias]
  hist = log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short
```



### Comparer 2 branches

```
git log <branch>..<branch>
```

pour plus de détails : [Git - Comparer les commits de 2 branches Git]({{< relref "git-compare-branches/index.md" >}})



## Vérifier / modifier ce que l'on commit

### Découper ses modifications en plusieurs commits

```
git add -p
```

Vous pourrez avec cette commande ne sélectionner que les parties qui vous intéressent.

### Faire un diff sur un nouveau fichier

```
git diff new_file.txt # Ne renvoi rien
git add --intent-to-add new_file.txt # ou git add -N
git diff new_file.txt # Renvoi le contenu du fichier
```

Voir le détail sur [Stackoverflow](https://stackoverflow.com/a/24347875)


### Commiter tous les fichiers modifiés

Si vous avez effectué un diff et que vous êtes certains que toutes les modifications sont à commiter, vous pouvez utiliser 

```
git add --update
```

ou 

```
git add -u
```

### Ajout interactif

La commande `git add -i` peut également être bien pratique, pour combiner plusieurs actions. Par exemple l'update complet d'un fichier, récupérer en mode patch certains éléments d'un autre fichier ou encore ajouter des fichiers jamais commités.


#### Ajout interactif de fichiers jamais commités

Lorsque vous avez des fichiers non trackés et que vous voulez les ajouter au repository, vous ne voulez pas forcément ajouter tout le répertoire.

Exemple : 

```
$ git status
Sur la branche preview
Modifications qui seront validées :
Fichiers non suivis:
  (utilisez "git add <fichier>..." pour inclure dans ce qui sera validé)

	content/article/openshift/
```

On voit ici que le dossier `content/article/openshift/` n'est pas présent dans le repository et doit donc être ajouté via `git add`.

Si nous faisons uniquement `git add content/article/openshift/` alors tous les fichiers seront mis dans l'index.

Si le nombre de fichiers est limité, il sera rapide d'ajouter simplement le nom du fichier à la suite de la commande `git add content/article/openshift/<my-file>`.

Par contre, si vous avez plusieurs fichiers, alors la commande `--interactive` va grandement vous aider.

Etapes :

* Lancer `git add -i`
* Presser 4 pour afficher les fichiers non trackés
* La liste affichée est numéroté.

Vous avez maintenant les options suivantes : 

1. Soit saisir un numéro et presser entrée. Puis un autre numéro etc...
2. Si vous avez des plages de numéros, vous pouvez les déclarer via la syntaxe : `<num1>-<num2>`
3. Vous pouvez également utiliser le `;` pour séparer 2 numéros : `1;2;3;4;12`

Toutes ces options sont bien entendus combinables : `1-4;12`


### Corriger son dernier commit

* Ajouter les modifications au commit précédent et vous proposer de modifier le message

```
git commit --amend
```

* Ajouter les modifications au commit précédent sans modification du message de commit

```
git commit --amend --no-edit
```



### Corriger un précédent commit

#### Version 1

```
git commit
git rebase -i <head>
```

Puis déplacer le dernier commit au niveau du commit dans lequel l'intégrer et définir le mot clé à `fixup` ou juste la lettre `f`.


#### Version 2

```
git commit --fixup <hash>
```

va automatiquement reprendre le nom du commit ciblé, préfixé par fixup!



Exemple : 

```
* 61739a7 2019-04-25 | fixup! new commit (HEAD -> master) [Jean-Yves Gastaud]
* ccb6360 2019-04-23 | rename file [Jean-Yves Gastaud]
* 0dfc522 2019-04-23 | new commit [Jean-Yves Gastaud]
* 229fe83 2019-04-23 | new commit [Jean-Yves Gastaud]
* c1420d3 2019-04-23 | new commit [Jean-Yves Gastaud]
* cb893a3 2019-04-23 | new commit [Jean-Yves Gastaud]
* b95163d 2019-04-23 | Good commit [Jean-Yves Gastaud]
```



Il est ainsi possible de demander à Git de rebase l'historique dans le bon ordre automatiquement

```
git rebase -i --autosquash <hash>
```

Va proposer automatiquement la fusion des commits marqués en `fixup` avec son commit de référence.

```
pick b95163d Good commit
pick cb893a3 new commit
fixup 61739a7 fixup! new commit
pick c1420d3 new commit
pick 229fe83 new commit
pick 0dfc522 new commit
pick ccb6360 rename file
```



!! Attention aux conflits quand même !!



### Faire un rebase en incluant le tout 1er commit

```
git rebase -i --root
```

## Squash VS Fixup

### Fixup

Comme vu ci-dessus, fixup va inclure un commit dans le commit précédent.

Le message du commit et la description du commit parent seront conservés.

### Squash

Un squash est le regroupement d'un ou plusieurs commits dans un parent, de la même manière que fixup.

C'est une pratique couramment utilisé dans les projets Open Source afin de simplifier le tracking entre une Merge Request et un commit.

A la différence de fixup, squash va afficher l'éditeur de texte avec les messages et descriptions des n commits mergés et vous proposer de modifier la description pour correspondre au regroupement de vos commis.

Tout comme pour fixup, il est possible de définir directement un commit comme état "à squasher" :

```
git commit --squash <hash>
```

puis, comme pour fixup,

```
git rebase -i --autosquash <hash>
```

### Modifier l'historique d'une branche

```
git rebase -i <hash>
```



### Annuler un rebase en cours

Oula, qu'est ce qu'il se passe ici ?

Je vais plutôt annuler ça !

```
git rebase --abort
```

### Valider une résolution de conflit dans un rebase

```
git add <file>
git rebase --continue
```

J'ajoute mon correctif de conflit et je continue le rebase !

Mon correctif sera inclu dans le commit qui vient d'être appliqué. C'est pour cela que je n'ai pas besoin de commité à nouveau.


### Pas de changement lors du rebase ?

Parfois, un message indique que l'application du commit n'apporte pas de changement.

Le commit est donc déjà inclus dans une modification déjà appliqué au dépôt. Il peut être supprimé sans craintes.

```
git rebase --skip
```


### Retrouver les changements effectuées sur une fonction

Avec `git grep` tu peux déjà avoir un certain niveau d’information (commit de la fonction, fichier dans laquelle elle est).

Si tu as un changement de nom par contre…

Exemple :

`git grep -p csv_import_get_ftp_params_provider_2 $(git rev-list --all)` renvoi

```
a79ed97f14eede3cdd98ae53ce3b990b58bbd351:sites/all/modules/custom/csv_import/csv_import_query.inc:function csv_import_get_ftp_params_provider_2() {
8b7ca76ca554accd397fcec1073776d60280521e:sites/all/modules/custom/csv_import/csv_import_query.inc:function csv_import_get_ftp_params_provider_2() {
118ffd0839985555dbaadd9edd9846ce9c18eb05:sites/all/modules/custom/csv_import/csv_import.module:function csv_import_get_ftp_params_provider_2() {
2b5196af0dddd28744acbf0ec015b6d59bddedee:sites/all/modules/custom/csv_import/csv_import.module:function csv_import_get_ftp_params_provider_2() {
d58b7662c6a8d47793fd79ec25030ee5c7cee4a6:sites/all/modules/custom/csv_import/csv_import.module:function csv_import_get_ftp_params_provider_2() {
```





## Créer, partager et appliquer un patch



### Créer un patch



#### `format-patch`

```
git format-patch <hash>..HEAD
```

va générer n fichiers (où n est égale au nombre de commits entre le hash et HEAD)



Si vous voulez regrouper les commits en 1 seul fichier

```
git format-patch -k --stdout <hash>..<hash> > my.patch
```



L'option `-k` permet de garder sujet/message du commit intact et ne pas avoir la mention `[PATCH]` insérer automatiquement.



Exemple : `wk-patch` n'a pas l'option `-k`

```
$ diff wk-patch.patch nok-patch.patch                
4c4
< Subject: fixup! new commit
---
> Subject: [PATCH 1/2] fixup! new commit
27c27
< Subject: change
---
> Subject: [PATCH 2/2] change
```



#### `diff`

Avec l'utilisation de la commande `git diff` vous pouvez également géréner un patch.

```
git diff <hash>..<hash> > my.patch
```



La différence avec `format-patch` est que l'on n'a pas de notions d'historique des commits et donc que :

* toutes les modifications se retrouveront unfiées dans un seul fichier
* on perd l'information sur l'auteur des commits



### Partager un patch

!! peu de chance que vous ayez à l'utiliser mais toujours marrant de savoir que cela existe !!

```
git send-email --to="jygastaud <jygastaud@clever-age.com>" 0001-fixup-new-commit.patch
```



Sur Ubuntu/Debian, peut nécessiter l'installation d'un paquet spécifique : `apt-get install git-email`

Il faut aussi un serveur smtp dispo, soit en passer un en ligne de commande



### Appliquer un patch

* Si le patch a été créé avec `format-patch`

```
git am <my-patch-files>
```



* Vous pouvez utiliser la commande `apply`

```
git apply <my-patch>
```



### Supprimer un patch

```
git apply -R <my-patch>
```





### Description d'une branche



#### Ajouter une description



```
git branch --edit-description
```



#### Voir la description



``` 
git config branch.master.description
```





```
$ git request-pull v1.0 origin master:v1.x -p
The following changes since commit 61739a74f55f6f08bfebbccfc00e5e2cbb9bda52:

  fixup! new commit (2019-04-25 17:51:22 +0200)

are available in the Git repository at:

  git@github.com:jygastaud/git-conferences.git v1.x

for you to fetch changes up to 967fbc53e959804b17acc90cec89bdafad2e63ce:

  change (2019-04-25 18:29:25 +0200)

----------------------------------------------------------------
(from the branch description for master local branch)

La branche de prod

----------------------------------------------------------------
Jean-Yves Gastaud (1):
      change

 README2.md | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/README2.md b/README2.md
index 504bc75..3a59441 100644
--- a/README2.md
+++ b/README2.md
@@ -12,3 +12,5 @@ Encore 1 ligne
 
 Derniere ligne ?
 
+A change
+

```



## Gérer ses repositories distants

### fetch + rebase VS pull (--rebase)



### Gérer plusieurs remotes



## Les hooks

### Gérer et partager ses hooks simplement

```
$ tree gitconfig 
gitconfig
|-- .gitconfig
|-- hooks
|   |-- pre-commit
|   `-- prepare-commit-msg
`-- templates
    `-- .gitmessage
```

puis `git config --local include.path ../gitconfig/.gitconfig`

## Debuger



### git grep

[Voir la section précédente]({{< ref "#retrouver-les-changements-effectuées-sur-une-fonction" >}})

### Savoir ce qui est déjà commité / pushé sur une autre branche

### git bisect

```
git bisect start
git bisect good <hash>
git bisect bad
git bisect bad
git bisect reset
```

Si vous avez des tests automatisés et que vous avez une erreur sur ces tests, il est possible de lancer un git bisect pour exécuter automatiquement les tests

```
git bisect start
git bisect good <hash>
git bisect bad
git bisect run ./test.sh
git bisect reset
```

### git reflog

L'historique de toutes les actions que vous avez pu effectuer sur votre repository **local**.

```
cc7ccc0 (HEAD -> squash, master) HEAD@{0}: rebase -i (finish): returning to refs/heads/squash
cc7ccc0 (HEAD -> squash, master) HEAD@{1}: rebase -i (start): checkout HEAD~5
cc7ccc0 (HEAD -> squash, master) HEAD@{2}: rebase -i (finish): returning to refs/heads/squash
cc7ccc0 (HEAD -> squash, master) HEAD@{3}: rebase -i (start): checkout HEAD~5
72f188e HEAD@{4}: commit: squash! vide2
74e13d7 HEAD@{5}: commit: vide3
7eb0740 HEAD@{6}: commit: vide2
2396775 HEAD@{7}: commit: vide
cc7ccc0 (HEAD -> squash, master) HEAD@{8}: checkout: moving from master to squash
cc7ccc0 (HEAD -> squash, master) HEAD@{9}: am: [PATCH 5/5] change
```

Comme vous pouvez le constater, chaque action contient un hash spécifique.

Avec ce hash, il vous ai possible de revenir revert simplement une action si nécessaire.

### git worktree

`git worktree` permet de gérer plusieurs espaces de travail pour un même dépôt.

Un cas typique d'utilisation : 

* Je travaille sur une nouvelle fonctionnalité et j'ai des modifications en cours
* Un ticket URGENT arrive et j'ai besoin de changer de branche pour faire une correction
* Je commite mon travail en cours (au risque d'ajouter des choses non voulues) et je change de branche

STOP ! Utilisez maintenant `worktree` !

```
git worktree add <path> [<branch>]
```

avec cette commande, je vais créer un nouvel espace de travail dans un dossier différent et travailler dessus comme sur ma branche courante.

Une fois fini, le travail commité et poussé, il ne nous reste plus qu'à supprimer l'espace de travail :

```
git worktree prune
```

## Configurer votre profil

### Gérer plusieurs profils

Voir article [Git - Gérer des profils distincts dans Git]({{< relref "git-gerer-profils/index.md" >}})




## Partager un repository

### git bundle

Git bundle permet de partager une branche d'un dépôt avec tout son historique de commit, de commiter dessus et de réintégrer les modifications dans le dépôt d'origine.

Pratique lorsque vous devez bosser avec des équipes distantes qui ne peuvent pas avoir un vrai accès au dépôt initial.

```
git bundle create <repo.bundle> <branch or hash or tag>
```

puis partager le fichier `repo.bundle`.

Sur le poste de l'autre développeur, il est maintenant possible de cloner le dépôt

```
git clone -b <branch_name> <path/to/repo.bundle> <folder>
```

Le dev peut générer un nouveau bundle de diff à partager

```
git bundle create gitconf.bundle origin/master..master
```

puis vous pouvez réintégrer le fichier dans le repo d'origine avec les mêmes commandes que pour la mise à jour via un dépôt distant

* Avec un commit merge

```
git pull ../testconf/gitconf.bundle master
```

* Avec pull --rebase 

```
git pull --rebase ../testconf/gitconf.bundle master
```

Si des modifications ont été faites sur le dépôt d'origine et qu'elles doivent être repartagée au développeur, il suffira de générer un diff avec le bundle précédent. Le développeur n'aura plus qu'à remplacer son fichier initial et faire un pull dessus.



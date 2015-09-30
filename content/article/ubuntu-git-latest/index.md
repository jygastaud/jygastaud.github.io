+++
Categories = ["Système"]
Description = "Vous souhaitez avoir accès à la dernière version de Git sur votre Ubuntu. Découvrez comment le faire en 3 commandes."
Tags = ["Système", "Git"]
date = "2015-09-30T10:44:14+02:00"
title = "Installer la dernière version de Git sur Ubuntu"

+++

Si vous utilisez régulièrement les systèmes de paquets fournis avec vos distributions, vous avez surement remarqué que les versions fournies sont généralement anciennes.  

Sur Ubuntu, Git ne déroge pas à la règle.  

En effet, Ubuntu 14.04 LTS donne accès à Git 1.9 et Ubuntu 15.05, Git 2.1. Au mieux une version sortie en fin 2014.

Faites le test par vous même en ouvrant votre terminal et en lançant la commande suivante :

```
$> git --version
```

## Pourquoi mettre à jour ?

Dans un 1er temps pour profiter des corrections et optimisations apportées régulièrement au produit (amélioration des capacités de merge par exemple qui permet d'avoir une meilleure gestion des conflits), sans oublier les évolutions qui sont ajoutées régulièrement.

On peux par exemple noté que la version 2.5 de Git apporte la possibilité d'avoir plusieurs `worktree` - nos espaces de travail - simultanés via la commande [`git worktree`](https://git-scm.com/docs/git-worktree) et depuis le 28 septembre 2015, la version 2.6.0 de Git est sortie.

Alors comment mettre à jour simplement notre machine pour avoir accès aux dernières versions de Git.

## Comment on fait ?

La solution en 3 commandes (à lancer dans votre terminal)

```
$> sudo add-apt-repository ppa:git-core/ppa
$> sudo apt-get update
$> sudo apt-get install git
```

Et voilà ! Vous devriez maintenant avoir accès à la dernière version de Git.

Pour vérifier lancer à nouveau, dans votre terminal :

```
$> git --version
```

Si la commande vous renvoie `git version 2.6.0` (ou un nombre supérieure), c'est que tout c'est bien déroulé.

Maintenant, votre version de Git continuera à se mettre à jour.

Je vous invite donc à suivre régulièrement les [Releases Notes  de Git](https://github.com/git/git/tree/master/Documentation/RelNotes), toujours pleines de bonnes informations à découvrir.

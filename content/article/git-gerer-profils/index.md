+++
title = "Gérer des profils distincts dans Git"
Description = "Comment simplifier la gestion des identités associés à nos commits Git et éviter les erreurs de configuration ? "
Tags = ["Développement", "Git", "Tips", "Profil", "Configuration", "IncludeIf", "Includes Conditionnels"]
Categories = ["Développement", "Git"]
image = ""
aliases = []
date = 2019-01-24T00:02:55+01:00
lastmod = 2019-01-24T00:02:55+01:00
+++

Vous utilisez votre ordinateur pour travailler et, plus que jamais, il vous arrive sûrement d'utiliser Git (que feriez-vous sur cet article sinon ?).  
Peut-être vous arrive-t-il aussi de travailler sur un projet personnel sur ce même ordinateur ?  
Ou de contribuer à un projet Open-Source, toujours sur la même machine.

Vous avez probablement défini une identité (nom + mail) globale à votre machine et vous la surchargée pour chaque projet en fonction du contexte.

Parfait !

Et pourtant malgré ces précautions d'usage, qui n'a jamais commité dans un projet avec une mauvaise identité ?
Parfois peut être vous en vous rendu compte tardivement et votre email personnel se retrouve maintenant *ad vitam æternam* dans les logs d'un projet.

Alors comment essayer de limiter le risque d'erreurs ?

Pourrait-on automatiser la sélection de la bonne identité pour nos projets ?

Et bien, la bonne nouvelle est que **la réponse est OUI**  et que nous allons voir comment juste après.

## .gitconfig et includes conditionnels grâce à IncludeIf

Prenons le fichier `.gitconfig`, généralement présent dans votre `$HOME`.

```
[user]
	name = Jean-Yves Gastaud
	email = mon.super@mail.com

[alias]
  amend = commit --amend
  st = status
  co = checkout
```

Ce fichier défini notre identité par défaut et nos aliases globaux.

Grâce à utilisation de la directive `includeIf`[^1] dans notre fichier `.gitconfig`, nous pouvons maintenant ajouter des includes conditionnels liés, notamment à des répertoires.

```
[includeIf "gitdir:/workspace/work/"]
  path = ~/.gitconfig-work

[includeIf "gitdir:/workspace/opensource/"]
  path = ~/.gitconfig-opensource

[includeIf "gitdir:/workspace/perso/"]
  path = ~/.gitconfig-perso
```

Pour chaque `includeIf` défini, il ne nous reste plus qu'à créer le fichier correspondant au chemin que nous avons défini dans `path`.

Dans le fichier `~/.gitconfig-work`, nous n'avons donc plus qu'à ajouter ou surcharger les configurations qui nous intéresse.

Exemple :

```
user]
        email = my.work@mail.com

[core]
        editor = "code -w"
```

Dans ce fichier, on surcharge donc notre email et on ajoute un éditeur de code par défaut.

Maintenant, tout dossier sous le répertoire `/workspace/work` bénéficiera automatiquement du chargement des configuration fichier `.gitconfig`, surcharger ou compléter par celles du fichier `.gitconfig-work`.

Pour vérifier votre configuration, allez dans n'importe quel répertoire sous le répertoire ciblé, `/workspace/work` dans notre exemple et lancer la commande `git config -l`

Vous devriez voir la fusion de vos fichiers de configs.

```
user.name=Jean-Yves Gastaud
email = mon.super@mail.com
alias.amend=commit --amend
alias.st=status
alias.co=checkout
includeif.gitdir:/workspace/work/.path=~/.gitconfig-work
user.email=my.work@mail.com
core.editor=code -w
includeif.gitdir:/workspace/opensource/.path=~/.gitconfig-opensource
includeif.gitdir:/workspace/perso/.path=~/.gitconfig-perso
core.repositoryformatversion=0
core.filemode=true
…
```

Comme vous pouvez le constater, les 2 mails définis sont présents dans le listing.  
Le dernier "parlant" ayant raison, c'est donc bien la valeur du fichier `.gitconfig-work` qui sera considéré lors du commit.

Vous remarquerez aussi que les 2 autres includes sont listés mais n'ajoutent pas de nouvelles variables / surcharges car leur condition d'application n'est pas remplie.

Cela nous laisse toujours la possibilité de surcharger, localement au repository, toutes configurations souhaitées, comme avant.

**En quelques lignes et une gestion simple de vos répertoires de travail, il vous est donc possible de ne plus risquer de vous tromper dans le changement de vos identités.**

[^1]: Depuis la version 2.13 de Git (mai 2017). [Documentation sur les Includes dans Git](https://git-scm.com/docs/git-config#_includes)

+++
title = "Git - travailler son historique"
Description = ""
Tags = ["Développement", "Git"]
Categories = ["Git", "Tips"]
image = ""
aliases = []
draft = true
date = 2019-04-23T14:44:54+02:00
lastmod = 2019-04-23T14:44:54+02:00

+++



<!--more-->



## Visualiser et rechercher dans son historique



```bash
git hist
```

Alias for 

```bash
git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short
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

```
git format-patch -k -m --stdout v2.6.14..private2.6.14
```



### Partager un patch

```
git send-mail
```



### Appliquer un patch

```
git am -3 -k
```







A explorer 



```
git request-pull
```



signer ces commits avec GPG




Plan : 

- Rappel des notions de base 

  - clone, add, commit, checkout et push

- Visualiser et rechercher dans son historique

- Vérifier / modifier ce que l'on commit

  - add -p
  - amend / fixup
  - rebase -i

- Gérer ses repositories distants

  - fetch + rebase VS pull (--rebase)
  - gérer plusieurs remotes

- Les hooks

  - Gérer ces hooks simplements
  - partager ces hooks Git

- Debuger

  - git blame
  - git grep
  - savoir ce qui est déjà commité / pushé sur une autre branche
  - git bisect
  - git reflog

- Configurer votre profil

  - gérer plusieurs profils
  - pourquoi et comment signer ces commits avec GPG ?

- Partager un repository

  - git bundle

  


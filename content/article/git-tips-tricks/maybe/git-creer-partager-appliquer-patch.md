+++
title = "Git - Créer, partager et appliquer un patch"
Description = ""
Tags = ["Développement", "Git"]
Categories = ["Git", "Tips"]
image = ""
aliases = []
draft = true
date = 2019-04-23T14:44:54+02:00
lastmod = 2019-04-23T14:44:54+02:00

+++



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



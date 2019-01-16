+++
title = "Makefile et parallélisation des jobs"
Description = "Tests sur l'utilisation des jobs parallèles via Make"
Tags = ["Développement", "Tips"]
Categories = ["Développement", "Shell"]
image = ""
aliases = []
date = 2019-01-16T15:18:58+01:00
lastmod = 2019-01-16T15:18:58+01:00
+++

PoC / Tests sur l'utilisation des jobs parallèles via Make et résultats constatés

https://www.gnu.org/software/make/manual/html_node/Parallel.html


## Tests basiques

### Makefile

```
all: test test2 test3 test4 test5 test6 test7

test:
	@sleep 2 && \
	echo "---> 1"

test2:
	@sleep 2 && \
	echo "---> 2"

test3: test test2 .FORCE
	@sleep 2 && \
	echo "---> 3"

test4:
	@sleep 2 && \
	echo "---> 4"

test5:
	@sleep 2 && \
	echo "---> 5"

test6:
	@sleep 2 && \
	echo "---> 6"

test7:
	@sleep 2 && \
	echo "---> 7"

.FORCE:
```

## Tests sans parallélisation

On exécute 7 jobs à la suite.

Pour tester plus facilement nos résultats, chaque job dure environ 2 secondes.

```
$ date +'%Y%m%d%H%M%S' && make &&  date +'%Y%m%d%H%M%S'
20181213172307
---> 1
---> 2
---> 3
---> 4
---> 5
---> 6
---> 7
20181213172321
```

Comme prévu, nos jobs mettent 14 secondes à s'éxécuter.

### Tests avec parallélisation

On lance maintenant la même commande en parallélisant les 7 jobs.

```
$ date  +'%Y%m%d%H%M%S' && make -j7 && date  +'%Y%m%d%H%M%S'
20181213172242
---> 1
---> 5
---> 7
---> 2
---> 6
---> 4
---> 3
20181213172246
```

On a ici un temps d'éxécution de 4 secondes correspondant au temps d'éxécution du `test3` qui est obligé d'attendre l'éxéution de `test1` et `test2`.

> Soucis : Les jobs s'exécutent dans un ordre aléatoire.

## Job Parallèles indépendants

Maintenant que nous avons vu comment fonctionne les jobs parallèle avec Make, comment gérer l'éxécution de plusieurs étapes ayant des dépendances de façon optimisée ?

Dans notre exemple, nous allons simuler 2 étapes :

1. Le clone de 2 repositories Git
2. Le lancement d'une commande `composer`

### Makefile

```
steps: ## les 2 étapes, sans parallélisation
	$(MAKE) step1
	$(MAKE) step2

steps_j: ## les 2 étapes, avec parallélisation
	$(MAKE) step1 -j2
	$(MAKE) step2 -j2

step1: clone_toto clone_tata

clone_toto:
	@sleep 2 && \
	echo "git clone toto"

clone_tata:
	@sleep 2 && \
	echo "git clone tata"

step2: composer_toto composer_tata

composer_toto:
	@sleep 2 && \
	echo "composer toto"

composer_tata:
	@sleep 2 && \
	echo "composer tata"
```


### Tests sans parallélisation

On lance notre test de référence

```
$ date +'%Y%m%d%H%M%S' && make steps &&  date +'%Y%m%d%H%M%S'
20181213173756
make step1
make[1] : on entre dans le répertoire « /var/www/make-parallel »
git clone toto
git clone tata
make[1] : on quitte le répertoire « /var/www/make-parallel »
make step2
make[1] : on entre dans le répertoire « /var/www/make-parallel »
composer toto
composer tata
make[1] : on quitte le répertoire « /var/www/make-parallel »
20181213173804
```

Ce test met 48 secondes à s'éxécuter.

> Make semble particulièrement lent dans les appels récursifs à lui même.  
Je n'ai pas creusé pourquoi.

Le même test en adaptant `steps` comme suit nous fait revenir au timing initialement prévu (8 secondes)

```
steps2: step1 step2
```


### Tests avec parallélisation

En appliquant les capacités de paralélisation de Make, on peut donc maintenant assurer un ordre d'éxécution sur les jobs et lancer en même ceux indépendants.

```
$ date +'%Y%m%d%H%M%S' && make steps_j &&  date +'%Y%m%d%H%M%S'
20181213173803
make step1 -j2
make[1] : on entre dans le répertoire « /var/www/make-parallel »
git clone toto
git clone tata
make[1] : on quitte le répertoire « /var/www/make-parallel »
make step2 -j2
make[1] : on entre dans le répertoire « /var/www/make-parallel »
composer tata
composer toto
make[1] : on quitte le répertoire « /var/www/make-parallel »
20181213173807
```

On obtient une exécution de seulement 4 secondes !

## Notre Makefile de tests complet

```
all: test test2 test3 test4 test5 test6 test7

test:
	@sleep 2 && \
	echo "---> 1"

test2:
	@sleep 2 && \
	echo "---> 2"

test3: test test2 .FORCE
	@sleep 2 && \
	echo "---> 3"

test4:
	@sleep 2 && \
	echo "---> 4"

test5:
	@sleep 2 && \
	echo "---> 5"

test6:
	@sleep 2 && \
	echo "---> 6"

test7:
	@sleep 2 && \
	echo "---> 7"

.FORCE:

steps:
	$(MAKE) step1
	$(MAKE) step2

steps_j:
	$(MAKE) step1 -j2
	$(MAKE) step2 -j2

step1: clone_toto clone_tata

clone_toto:
	@sleep 2 && \
	echo "git clone toto"

clone_tata:
	@sleep 2 && \
	echo "git clone tata"

step2: composer_toto composer_tata

composer_toto:
	@sleep 2 && \
	echo "composer toto"

composer_tata:
	@sleep 2 && \
	echo "composer tata"
```

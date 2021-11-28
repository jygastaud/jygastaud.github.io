+++
title = "Test de Gomplate"
type = "article"
date = "2021-11-20"
description = """

[Gomplate](https://docs.gomplate.ca/) est un utilitaire en Go qui permet de faire un rendu dynamique.

La possiblité d'utiliser du templating Go, d'utiliser les fonctions built-in de gotemplate et le support de datasources par Gomplate me paraissait intéressant.

Découvrons commencer utiliser Gomplate pour de la transformation de fichiers.

"""
Categories = ["DevOps"]
Tags = ["Gomplate", "CLI", "templating"]

+++

[Gomplate](https://docs.gomplate.ca/) est un utilitaire en Go qui permet de faire un rendu dynamique.

La possiblité d'utiliser du templating Go, d'utiliser les fonctions built-in de gotemplate et le support de datasources par Gomplate me paraissait intéressant.



## Objectifs

Ce test va probablement détourner un peu l'objectif initial du produit mais je vais tenter de voir si Gomplate peut être un candidat pour aider à la génération de documentation dynamique.



## Le projet

_Point de départ&nbsp;: [Documentation de Gomplate](https://docs.gomplate.ca/)



### Préparation

* Installation de Gomplate

Il existe de nombreuses méthodes pour [installer Gomplate](https://docs.gomplate.ca/installing/). 

De mon côté, j'essaie en ce moment de privilégier l'utilisaton de [asdf]() pour gérer mes utilitaires locaux et leurs versions.

La procédure n'étant pas détaillée dans la documentation officielle Gomplate, la voici ci-dessous : 

* Ajout du plugin

``` shell
asdf plugin add gomplate
```

* Installation de la version de gomplate souhaitée

```bash
asdf install gomplate v3.10.0
```

* Activation pour tout le système

```bash
asdf global gomplate v3.10.0
```

* Vérification de bon fonctionnement

```bash
gomplate --version
gomplate version 3.10.0
```

Ca fonctionne ! :thumbsup:



## Découverte du fonctionnement de l'outil



### Comment déclarer un template ?

Pour notre besoin, nous allons avoir besoin de pouvoir créer un (1) ou plusieurs fichiers d'entrée qui contiendront des variables que l'on souhaitera remplacer lors de la génération.



La documentation de la CLI parle de l'option `-t` pour un template mais cela ne semble pas être réellement notre besoin.

Par contre, la page de documentation sur la configuration mentionne des entrées qui semblent prométeuses [inputFiles](https://docs.gomplate.ca/config/#inputfiles) et [inputDir](https://docs.gomplate.ca/config/#inputdir). :champagne:



Testons cela. :rocket:



### Test avec 1 seul template en entrée

Nous allons créer 2 fichiers pour ce test

`test.tpl` qui va simplement reprendre l'exemple de base de gomplate

```
Hello {{ .Env.USER }}
```

et le fichier `.gomplate.yaml`

```yaml
inputFiles:
  - basic.tpl
```

Vérifions notre arborescence

```bash
tree -a
.
├── basic.tpl
└── .gomplate.yaml

0 directories, 2 files
```

Testons l'exécution de gomplate

```
gomplate
Hello jyg
```



### Test avec plusieurs fichiers de template

Pour ce test, nous allons avoir une arborescence légèrement plus complexe avec l'ajout d'un dossier `in` dans lequel on va avoir 2 fois notre fichier précédent `basic.tpl` qui sera déposé (et légèrement édité).

```
tree -a -L 2
.
├── .gomplate.yaml
├── in
│   ├── basic2.tpl
│   └── basic.tpl
```



Nous faisons évoluer le fichier `.gomplate` comme ceci :

```yaml
inputDir: in/
```



En exécutant `gomplate` on se rend compte qu'il n'y a pas d'output dans le terminal.

Par contre 2 fichiers on était créé à la racine de notre dossier :

```bash
tree -a -L 2
.
├── basic2.tpl
├── basic.tpl
├── .gomplate.yaml
├── in
│   ├── basic2.tpl
│   └── basic.tpl
```

et  ces 2 fichiers contiennent bien la variable interprétée.

Il faut donc définir la valeur `outputDir` pour un mapping 1:1 ou `outputMap` si l'on souhaite pouvoir agir sur le nom des fichiers de sorti.

Exemple d'utilisation d'`outputMap` pour modifier l'extension du fichier de `tpl` à `md` (markdown).

```
inputDir: in/
outputMap: |
    out/{{ .in | strings.ReplaceAll ".tpl" ".md" }}
```



OK à priori, avec ces 2 directives nous devrions être en mesure de pouvoir avancer sur notre projet.



### Implémentation du projet

Pour notre test, nous allons reprendre la structure simplifier d'un projet existant.

Quelques élements de contexte :

* le projet sert de documentation,
* chaque page de la documentation est un fichier markdown,
* à la génération de la documentation, on souhaite être capable de récupérer ou injecter des variables, par exemple, la branche Git utilisée pour la génération,
* on veut que les fichiers générés respectent l'arborescence initiale.



 ### Préparation des dossiers et fichiers

```bash
tree -a -L 4
.
├── .gomplate.yaml
├── in
│   ├── en
│   │   ├── docker-compose.md
│   │   └── security
│   │       ├── cohesion.md
│   │       └── gitleaks.md
│   └── home.md
```



Les détails intéressants : 

* `.gomplate.yaml`

```yaml
inputDir: in/
outputDir: out/
```

* dans le fichier `docker-compose.md` on va définir la récupération d'une variable d'environnement représentant la branche Git.

````
# Docker-compose

## Docker-compose helper

...

```yaml
include:
  - project: '<group>/<project>/templates'
    ref: {{ env.Getenv "GITBRANCH" }}
    file: '/docker-compose.gitlab-ci.yml'
```

...
````



#### Exécution et vérification

On peut maintenant lancer la commande `GITBRANCH=test gomplate` et vérifiier les résultats.

*  :white_check_mark: le dossier `out` contient bien la même arborescence de fichiers ;

```
tree -a -L 4
.
├── .gomplate.yaml
├── in
│   ├── en
│   │   ├── docker-compose.md
│   │   └── security
│   │       ├── cohesion.md
│   │       └── gitleaks.md
│   └── home.md
└── out
    ├── en
    │   ├── docker-compose.md
    │   └── security
    │       ├── cohesion.md
    │       └── gitleaks.md
    └── home.md
```

* :white_check_mark: la variable `{{ env.Getenv "GITBRANCH" }}`est bien remplacée par la valeur attendue ;

* :white_check_mark: il est possible de définir une valeur par défaut `{{ env.Getenv "GITBRANCH" "defaultbranch" }}`



````
# Docker-compose

## Docker-compose helper

...

```yaml
include:
  - project: '<group>/<project>/templates'
    ref: test
    file: '/docker-compose.gitlab-ci.yml'
```

...
````



## Conclusion

Gomplate répond plutôt bien à un besoin simple de génération / transformation de fichiers. En moins d'1 heure, en ne connaissant par l'outil, nous avons réussi à répondre à notre besoin, sans partir dans des outils plus complexes à installer et utiliser.

Le fait que Gomplate soit disponible comme un simple binaire facilite son installation et est donc très intéressant à utiliser aussi dans le cadre d'une CI.



## Prochaines étapes

* Creuser les fonctionnalités/fonctions natives de Gomplate, notamment l'utilisation des datasources ;
* Voir l'utilisation de Gomplate en remplacement de `envsubst` ;


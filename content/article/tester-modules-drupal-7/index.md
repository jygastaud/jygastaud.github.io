+++
Categories = ["Drupal"]
Tags = ["Drupal", "Drupal 7", "Tests", "Simpletest"]
Description = "Une introduction aux différents types de tests disponibles sous Drupal 7 et Simpletest."
date = "2015-10-22T22:17:21+02:00"
title = "Tester ses modules Drupal"

+++

{{% tips color="grey" icon="warning" %}}
Les tests fonctionnels et encore plus unitaires sous Drupal c'est la galère.
{{% /tips %}}

Voilà une phrase qu'il est fréquent d'entendre.

Nous allons donc essayer via une série d'articles de voir quels types de tests s'offrent à nous, que ce soit via les outils fournis directement par Drupal ou via l'utilisation d'outils externes.

Démarrons donc par une présentation du framework de tests embarqué dans Drupal 7 : **Simpletest**.

## Types de tests disponibles

Simpletest met à disposition 2 types de tests :

* des tests fonctionnels
* des tests unitaires

### Tests fonctionnels

Ces tests sont gérés par la class `DrupalWebTestCase` qu'il faut ensuite étendre dans son module.

Pour chaque fonction commençant par `test` définie dans la class, Simpletest va reconstruire entièrement une instance de Drupal, activer les modules désirés et exécuter les tests.

L'avantage de ce type de tests réside dans le fait que Drupal a accès aux informations de la base de données et est donc en capacité d’exécuter la totalité des fonctions disponibles.

Il est donc possible d'utiliser dans ces tests des fonctions comme node_save(), variable_get() ...

{{% tips color="negative" %}}
  Si le nombre de tests lancé est conséquent, il est possible que ces tests prennent beaucoup de temps.
{{% /tips %}}

{{% tips color="blue" title="A lire aussi"%}}
&nbsp;

* [Tests fonctionnels avec Simpletest sous Drupal 7]({{< ref "/article/tests-fonctionnels-simpletest-drupal-7/index.md" >}})

{{% /tips %}}

### Tests unitaires

Ces tests sont gérés par la class `DrupalUnitTestCase` qu'il faut ensuite étendre dans son module.

Comme pour les tests fonctionnels, Drupal va exécuter chaque fonction commençant par `test` définie dans la class.

Contrairement aux tests fonctionnels, Drupal ne va pas reconstruire d'environnement pour lancer ce type de tests. Il va se contenter de charger les modules spécifiés dans l'initialisation et lancer les fonctions donner avec les bons paramètres.

Les fonctions testées ne doivent donc pas dépendre de données récupérées en base. C'est le retour de la fonction qui sera ensuite vérifié.

{{% tips color="blue" title="A lire aussi"%}}
&nbsp;

* [Tests unitaires dans Drupal 7 avec Simpletest]({{< ref "/article/tests-unitaires-simpletest-drupal-7/index.md" >}})
{{% /tips %}}

## Commandes de base

Pour pouvoir lancer vos tests sur Drupal, il faut activer le module Simpletest.  
`drush en simpletest -y`

* Lancer les tests via le coeur de Drupal
  * pour un groupe de tests  
`php scripts/run-tests.sh --url http://site.dev "Editor List"`
  * pour une class à tester  
`php scripts/run-tests.sh --url http://site.dev --class EditorListTests`
* Lancer les tests via Drush
  * pour un groupe de tests  
`drush test-run --uri=http://site.dev "Editor List"`
  * pour une class à tester  
`drush test-run --uri=http://site.dev EditorListTests`


### Stocker les résultats des tests

Que ce soit via Drush ou le sh, vous pouvez spécifier l'option --xml=chemin/dossier/resultats/de/tests qui recevra les récapitulatifs des tester effectués.

`drush test-run --uri=http://site.dev --xml=$PWD/tests MonModuleTests`


{{% tips title="Pour en savoir plus" color="positive" icon="warning" %}}
&nbsp;

* [Tests fonctionnels avec Drupal 7]({{< ref "/article/tests-fonctionnels-simpletest-drupal-7/index.md" >}})
* [Tests unitaires avec Drupal 7]({{< ref "/article/tests-unitaires-simpletest-drupal-7/index.md" >}})
* [Liste des assertions Simpletest disponibles](https://www.drupal.org/node/265828)
{{% /tips %}}

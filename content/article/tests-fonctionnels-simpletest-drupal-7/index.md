+++
title = "Tests fonctionnels avec Simpletest dans Drupal 7"
Description = "Introduction aux tests fonctionnels avec Simpletest."
Categories = ["Drupal"]
Tags = ["Développement", "drupal", "drupal 7", "Tests", "Simpletest"]
date = "2015-10-22T22:17:56+02:00"

+++

{{% tips color="positive" %}}
Si vous ne l'avez pas encore lu, allez lire l'article [Tester ses modules Drupal 7]({{< ref "/article/tester-modules-drupal-7/index.md" >}}).
{{% /tips %}}

Les tests fonctionnels via Simpletest sont gérés par la class `DrupalWebTestCase` qu'il faut ensuite étendre dans son module.

Pour chaque fonction commençant par `test` définie dans la class, Simpletest va reconstruire entièrement une instance de Drupal, activer les modules désirés et exécuter les tests.

L'avantage de ce type de tests réside dans le fait que Drupal a accès aux informations de la base de données et est donc en capacité d’exécuter la totalité des fonctions disponibles.

Il est donc possible d'utiliser dans ces tests des fonctions comme node_save(), variable_get() ...

## Mise en place des tests

### Déclarer ces fichier de tests

Drupal décrit l'ensemble de ces tests dans des fichiers portant l'extension **.test**.  
Chaque fichier de test doit ensuite être déclaré dans le **.info** de votre module via la déclaration `files[]` qui est notamment utilisé par Drupal pour charger ces class.

Ainsi si vous nommez le fichier contenant vos tests *mon_module.test*, il vous faudra ajouter la ligne suivante dans le .info : `files[] = mon_module.test`

### Contenu minimal d'un fichier de tests

#### Etendre la class de base de Drupal

Dans le cadre de tests fonctionnels, c'est donc la class `DrupalWebTestCase` que l'on veut étendre.

{{< highlight php  >}}
<?php

class EditorListTests extends DrupalWebTestCase {}
{{< /highlight >}}

### Déclaration des infos de notre test

C'est la fonction static getInfo() qui se charge de recevoir ces informations.
Elle retourne un tableau contenant un nom, une description et un groupe.

Le nom doit être unique pour votre class.
Le groupe peut être commun à plusieurs modules, ce qui est pratique pour pouvoir lancer par exemple l'ensemble des tests de vos modules custom en 1 fois.

{{< highlight php  >}}
<?php

public static function getInfo() {
  // Note: getInfo() strings should not be translated.
  return array(
    'name' => 'Editor List tests',
    'description' => 'Test that editor_list module work fine.',
    'group' => 'Editor List',
  );

}
{{< /highlight >}}

#### Déclaration des modules à activer

2nd fonction obligatoire à déclarer dans vos fichiers de tests, il s'agit de `setUp()`.
Cette fonction vous permet de définir, notamment, les modules à charger lors de l'initialisation des environnements de test.

Dans l'exemple ci-dessous, on déclare ainsi que les environnements doivent avoir le module *editor_list* de charger.
A l'initialisation Drupal se charge de regarder les dépendances des modules à activer et les activer automatiquement.
Il n'est donc pas nécessaire de tous les déclarer explicitement.

{{< highlight php  >}}
<?php

/**
 * {@inheritdoc}
 */
public function setUp() {
  parent::setUp('editor_list');
}
{{< /highlight >}}

Il est également possible d'utiliser cette méthode *setUp()* pour définir des éléments nécessaires à l'ensemble de vos tests.
Par exemple, création d'un compte admin, création de contenus de tests ...
Ces éléments pourront ainsi être exploiter directement dans vos tests sans avoir besoin de répéter la phase de création à chaque fois.

#### Déclarer une fonction de test

Un fonction de test doit obligatoirement commencer par le mot clé `test`.

{{< highlight php  >}}
<?php

/**
 * Test Administration page access and edition.
 */
public function testAdministrationPage() {
  // Your tests
}
{{< /highlight >}}

L'obligation d'avoir le mot clé *test* au début du nom de votre fonction vous permet de créer des fonctions utilitaires dans la même class en étant certains qu'elles ne seront pas exécuter par Simpletest si vous ne les appelez pas explicitement.

# Exemple complet

[Module editor_list](https://git.clever-age.net/clever-age-expertise/drupal-editor-list/blob/master/editor_list.test)

{{% tips title="Pour en savoir plus" color="positive" icon="warning" %}}
&nbsp;

* [Tester ses modules Drupal 7]({{< ref "/article/tester-modules-drupal-7/index.md" >}})
* [Tests unitaires avec Drupal 7]({{< ref "/article/tests-unitaires-simpletest-drupal-7/index.md" >}})
{{% /tips %}}

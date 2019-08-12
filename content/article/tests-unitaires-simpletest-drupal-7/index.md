+++
Categories = ["Drupal"]
Tags = ["Développement", "drupal", "drupal 7", "Tests", "Simpletest"]
date = "2015-10-22T22:18:35+02:00"
title = "Tests unitaires avec Simpletest dans Drupal 7"
Description = "Introduction aux tests unitaires avec Simpletest."

+++

{{% tips color="positive" %}}
Si vous ne l'avez pas encore lu, allez lire l'article [Tester ses modules Drupal 7]({{< ref "/article/tester-modules-drupal-7/index.md" >}}).
{{% /tips %}}

Les tests fonctionnels via Simpletest sont gérés par la class `DrupalUnitTestCase` qu'il faut ensuite étendre dans son module.

Drupal va exécuter chaque fonction commençant par `test` définie dans la class.

Contrairement aux tests fonctionnels, Drupal ne va pas reconstruire d'environnement pour lancer ce type de tests. Il va se contenter de charger les modules spécifiés dans l'initialisation et lancer les fonctions donner avec les bons paramètres.

Les fonctions testées ne doivent donc pas dépendre de données récupérées en base. C'est le retour de la fonction qui sera ensuite vérifié.

# Mise en place des tests

Comme pour les [tests fonctionnels]({{< ref "/article/tests-fonctionnels-simpletest-drupal-7/index.md" >}}) il faut étendre une class de base de Drupal : `DrupalUnitTestCase`

{{< highlight php  >}}
<?php

class MyModuleUnitTestCase extends DrupalUnitTestCase {}
{{< /highlight >}}


On va également déclarer la méthode getInfo().

{{< highlight php  >}}
<?php

public static function getInfo() {
  // Note: getInfo() strings should not be translated.
  return array(
    'name' => 'My module unit tests',
    'description' => 'Test that utilities functions used in my_module modules work fine.',
    'group' => 'My module group',
  );

}
{{< /highlight >}}

Déclaration les modules dont on va charger le code via la méthode `setUp()`

{{< highlight php  >}}
<?php

/**
 * Set up the test environment.
 *
 * Note that we use drupal_load() instead of passing our module dependency
 * to parent::setUp(). That's because we're using DrupalUnitTestCase, and
 * thus we don't want to install the module, only load it's code.
 *
 * Also, DrupalUnitTestCase can't actually install modules. This is by
 * design.
 */
public function setUp() {
  drupal_load('module', 'my_module');
  parent::setUp();
}
{{< /highlight >}}

et enfin déclarer nos fonction de test qui doivent commencer par le mot clé `test`.

{{< highlight php  >}}
<?php

/**
 * Test my_module_check_login().
 *
 * Note that no environment is provided; we're just testing the correct
 * behavior of a function when passed specific arguments.
 */
public function testMyModuleCheckLoginFunction() {
  // Your tests
}
{{< /highlight >}}

## Exemple

On souhaite pouvoir tester le retour de la fonction suivante :

{{< highlight php  >}}
<?php

/**
 * Check the user login match the regex.
 *
 * @return
 */
function my_module_check_login($login) {
  // Extract all regex defined.
  $regex_list = explode(';', '/^[0-9]{7}[A-Z]$/i;/^(P|A|Z|F|E|S)[A-Z]{3}[0-9]{5}$/i;/^.*domain\.fr$/i');

  // Check if the login verify at least one regex.
  foreach ($regex_list as $regex) {

    // If there is one result.
    if (preg_match($regex, $login)) {
      return TRUE;
    }
  }
  return FALSE;
}
{{< /highlight >}}

ce qui pourrait donner un test comme ceci :

{{< highlight php  >}}
<?php

/**
 * Test my_module_check_login().
 *
 * Note that no environment is provided; we're just testing the correct
 * behavior of a function when passed specific arguments.
 */
public function testMyModuleCheckLoginFunction() {
  $result = my_module_check_login(NULL);
  // Note that test assertion messages should never be translated, so
  // this string is not wrapped in t().
  $message = 'A NULL value should return FALSE.';
  $this->assertFalse($result, $message);

  $result = my_module_check_login('');
  $message = 'An empty string should return FALSE.';
  $this->assertFalse($result, $message);

  $result = my_module_check_login('something@domain.fr');
  $message = 'An string with @domain.fr should return TRUE.';
  $this->assertTrue($result, $message);

  $result = store_user_check_login('@domain.fr');
  $message = 'An string with @domain.fr should return TRUE.';
  $this->assertTrue($result, $message);

  $result = my_module_check_login('AZER01234');
  $message = 'A string that looks like a CP code should return TRUE.';
  $this->assertTrue($result, $message);

}
{{< /highlight >}}

{{% tips title="Pour en savoir plus" color="positive" icon="warning" %}}
&nbsp;

* [Tester ses modules Drupal 7]({{< ref "/article/tester-modules-drupal-7/index.md" >}})
* [Tests fonctionnels avec Drupal 7]({{< ref "/article/tests-fonctionnels-simpletest-drupal-7/index.md" >}})
{{% /tips %}}

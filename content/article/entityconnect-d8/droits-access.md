+++
Categories = ["Drupal"]
Tags = ["Developpement", "drupal", "drupal 8", "Entity Connect"]
date = "2015-09-01T22:47:16+02:00"
title = "Gestion des droits d'accès sous Drupal 8"
Description = "Retour sur le portage des droits d'accès du module Entity Connect sous Drupal 8."
draft = true
+++

Retour sur le portage des droits d'accès du module [Entity Connect](https://drupal.org/project/entityconnect) sous Drupal 8.

{{% tips color="blue" title="Dans la même série"%}}
* [Création d'un formulaire d'administration sous Drupal 8]({{< relref "formulaire-administration.md" >}})
* [Gestion des droits d'accès sous Drupal 8]({{< relref "droits-access.md" >}})
{{% /tips %}}


## Création de permissions

La création de permissions custom était gérée par le hook_permission().
Sur Drupal 8, c'est maintenant le fichier `*.permission.yml` qui est responsable de cela.

### Drupal 7

{{< highlight php   >}}
<?php

/**
 * Implements hook_permission().
 *
 * @return Assoc
 *   permission items
 */
function entityconnect_permission() {
  return array(
    'entityconnect add button' => array(
      'title' => t('Allows users to see add button'),
      'description' => t('Display the add button for user'),
    ),
    'entityconnect edit button' => array(
      'title' => t('Allows users to see edit button'),
      'description' => t('Display the edit button for user'),
    ),
  );
}
{{< /highlight >}}

### Drupal 8

{{< highlight yaml  >}}
entityconnect add button:
  title: 'Allows users to see add button'
  description: 'Display the add button for user'
entityconnect edit button:
  title: 'Allows users to see edit button'
  description: 'Display the edit button for user'
{{< /highlight >}}

{{% tips color="positive" %}}
Assez peu de changements entre la version 7 et 8.  
Les informations nécessaires restent identiques.  
Seule la manière de les déclarer (implémentation d'un hook vs fichier yml) diffère.
{{% /tips %}}


## Route et droits d'accès sur une permission

Comme nous l'avons vu lors de la [création du formulaire d'administration](/article/entityconnect-d8/formulaire-administration/) les routes (équivalentes aux MENU_CALLBACK sous Drupal 7) sont déclarées dans le fichier `*.routing.yml`.


### Drupal 7

{{< highlight php  >}}
<?php

/**
 * Implements hook_menu().
 */
function entityconnect_menu() {
  $items = array();
  $items['admin/entityconnect/return/%'] = array(
    'description' => 'Return item for original entity.',
    'page callback' => 'entityconnect_return',
    'page arguments' => array(3),
    'access callback' => 'entityconnect_check_access',
    'file' => 'includes/entityconnect.menu.inc',
  );

  $items['admin/entityconnect/edit/%'] = array(
    'description' => 'Edit item for entity referenced.',
    'page callback' => 'entityconnect_edit',
    'page arguments' => array(3),
    'access callback' => 'user_access',
    'access arguments' => array('entityconnect edit button'),
    'file' => 'includes/entityconnect.menu.inc',
  );

  $items['admin/entityconnect/add/%'] = array(
    'title' => "Choose type to create and add",
    'description' => 'Add item for entity referenced.',
    'page callback' => 'entityconnect_add',
    'page arguments' => array(3),
    'access callback' => 'user_access',
    'access arguments' => array('entityconnect add button'),
    'file' => 'includes/entityconnect.menu.inc',
  );

  return $items;
}
{{< /highlight >}}

## Convertion des "access callback"

### Drupal 7

{{< highlight php  >}}
<?php

/**
 * Access callback: Used in return menu.
 */
function entityconnect_check_access() {
  if (user_access('entityconnect add button') || user_access('entityconnect edit button')) {
    return TRUE;
  }
  else {
    return FALSE;
  }
}

{{< /highlight >}}

### Drupal 8

{{< highlight php  >}}
.
├── src
│   ├── Access
│   │   └── CustomAccessCheck.php

{{< /highlight >}}

{{< highlight php  >}}
.
├── src
│   ├── Controller
│   │   └── EntityconnectController.php

{{< /highlight >}}

{{< highlight php  >}}
{{< /highlight >}}

{{< highlight php  >}}
{{< /highlight >}}

{{< highlight php  >}}
{{< /highlight >}}

{{< highlight php  >}}
{{< /highlight >}}


{{% tips title="Pour en savoir plus" color="positive" icon="warning" %}}
&nbsp;

* [Access checking on routes](https://www.drupal.org/node/2122195)
* [D7 to D8 upgrade tutorial: Convert hook_menu() and hook_menu_alter() to Drupal 8 APIs](https://www.drupal.org/node/2118147)
{{% /tips %}}

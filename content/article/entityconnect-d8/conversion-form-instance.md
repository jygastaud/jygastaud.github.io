+++
Categories = ["Drupal"]
Tags = ["Développement", "drupal", "drupal 8", "Entity Connect"]
date = "2015-08-31T23:54:38+02:00"
title = "Gestion et surcharge d'un field instance sous Drupal 8"
Description = "Retour sur le portage des options de configuration des instance de champs pour le module Entity Connect sous Drupal 8."

+++

<center>![entity connect](entityconnect.png)</center>

Retour sur le portage des options de configuration de champs pour le module [Entity Connect](https://drupal.org/project/entityconnect) sous Drupal 8.

Entity Connect vient ajouter de nouvelles fonctionnalités aux champs de type Entity Reference. Le module propose de définir, pour chaque instance de champ, si les fonctionnalités proposées doivent être activées ou non.

## Surcharge de l'instance du champ Entity Reference

Dans notre cas, nous avons besoin de surcharger la class `ConfigurableEntityReferenceItem`.

{{< highlight php >}}
<?php

namespace Drupal\entityconnect;

use Drupal\entity_reference\ConfigurableEntityReferenceItem;
use Drupal\Core\Form\FormStateInterface;

class ConfigurableEntityconnectItem extends ConfigurableEntityReferenceItem {
  // Do something.
}
{{< /highlight >}}

## Création du formulaire

### Ajout des paramètres au field instance.

#### Drupal 7

Sur Drupal 7, nous implémentions le `hook_field_instance_settings_form` que nous invoquions ensuite via un `hook_form_alter`.  
C'est l'utilisation du hook_form_alter qui permettait de passer de nouvelles valeurs de configuration au champ.

{{< highlight php >}}
<?php

/**
 * Add settings to an instance field settings form.
 *
 * Invoked from field_ui_field_edit_form() to allow the module defining the
 * field to add settings for a field instance.
 *
 * @return array
 *   The form definition for the field instance settings.
 */
function entityconnect_field_instance_settings_form($field, $instance) {
  $settings = $instance;

  // Add choice for user to not load entity connect "add" button
  // on the field.
  $form['entityconnect_unload_add'] = array(
    '#type' => 'radios',
    '#title' => t('Display Entity Connect "add" button.'),
    '#default_value' => !isset($settings['entityconnect_unload_add']) ? variable_get('entityconnect_unload_add_default', 1) : $settings['entityconnect_unload_add'],
    '#description' => t('Choose "No" if you want to unload "add" button for the field'),
    '#options' => array(
      '0' => t('Yes'),
      '1' => t('No'),
    ),
    '#weight' => 1,
  );

  // ...
}

{{< /highlight >}}

{{< highlight php  >}}
<?php

/**
 * Implements hook_FORM_ID_form_alter().
 *
 * @param $form
 * @param $form_state
 * @param $form_id
 */
function entityconnect_form_field_ui_field_edit_form_alter(&$form, &$form_state, $form_id) {

  $field_types = _entityconnect_get_references_field_type_list();

  // Use to add choice field.
  if (in_array($form['#field']['type'], $field_types)) {
    $instance = $form['#instance'];
    $field = $form['#field'];
    $additions = module_invoke('entityconnect', 'field_instance_settings_form', $field, $instance);
    if (is_array($additions) && isset($form['instance'])) {
      $form['instance'] += $additions;
    }
  }
}

{{< /highlight >}}

### Drupal 8

Sur Drupal 8, la déclaration du formulaire va passer par la fonction `fieldSettingsForm()`.

* La récupération de la configuration va se faire via `$this->getSettings()`. Cette fonction renvoi un tableau.
* On va charger le formulaire parent (la configuration de notre champ Entity Reference) et ensuite ajouter nos champs. Sans cela, seuls nos nouveaux champs vont apparaitre.

{{< highlight php >}}
<?php

  /**
   * {@inheritdoc}
   */
  public function fieldSettingsForm(array $form, FormStateInterface $form_state) {
    $settings = $this->getSettings();

    $form = parent::fieldSettingsForm($form, $form_state);

    // ...

    $form['entityconnect']['buttons']['button_add'] = array(
      '#required' => '1',
      '#default_value' => $settings['entityconnect']['buttons']['button_add'],
      '#description' => $this->t('Default: "off"<br />
                            Choose "on" if you want the "add" buttons displayed by default.<br />
                            Each field can override this value.'),
      '#weight' => '0',
      '#type' => 'radios',
      '#options' => array(
        '0' => $this->t('on'),
        '1' => $this->t('off'),
      ),
      '#title' => $this->t('Default Entity Connect "add" button display'),
    );


    // ...
  }

{{< /highlight >}}  

{{% tips color="positive" %}}
Comme dans le formulaire d'administration, nous n'avons pas besoin de tester l'existance ou non d'une configuration.  
On se contente de récupérer la valeur configurée.
{{% /tips %}}

## Définir les valeurs par défaut de notre instance de champ

### Utiliser des valeurs définies en dures

{{< highlight php >}}
<?php

  /**
   * {@inheritdoc}
   */
  public static function defaultFieldSettings() {
    return array(
      'entityconnect' => array(
        'buttons' => array(
          'button_add' => 1,
          'button_edit' => 1,
        ),
        'icons' => array(
          'icon_add' => 0,
          'icon_edit' => 0,
        ),
      ),
    ) + parent::defaultFieldSettings();
  }
{{< /highlight >}}

{{% tips color="red" icon="warning" %}}
Attention à ne pas oublier l'appel à `+ parent::defaultFieldSettings();` sous peine de ne pas avoir l'ensemble des settings disponibles.
{{% /tips %}}


### Utiliser les valeurs par défaut disponible dans la configuration

{{< highlight php >}}
<?php

  /**
   * {@inheritdoc}
   */
  public static function defaultFieldSettings() {

    $config = \Drupal::config('entityconnect.administration_config');
    $data = $config->getRawData();

    return array(
      'entityconnect' => $data
    ) + parent::defaultFieldSettings();
  }
{{< /highlight >}}

* `\Drupal::config('entityconnect.administration_config')` nous permet de charger les informations de configurations disponibles
* `$config->getRawData()` nous permet de récupérer un tableau des valeurs (ci-dessous) par défaut (celles définies à l'installation ou configurées via le Back-Office).

{{< highlight perl >}}
# Le retour de l'appel à $config->getRawData();
# Dans cet exemple, on voit que les valeurs par défaut
#   ont été changées dans l'interface d'administration.
array (size=2)
  'buttons' =>
    array (size=2)
      'button_add' => string '1' (length=1)
      'button_edit' => string '0' (length=1)
  'icons' =>
    array (size=2)
      'icon_add' => string '2' (length=1)
      'icon_edit' => string '1' (length=1)
{{< /highlight >}}

Il ne nous reste plus qu'à remplacer nos valeurs en dures par nos valeurs dynamiques.


## Prise en compte de notre nouvelle class

Le module Entity Reference définie sa class dans son fichier .module et utilise le `hook_field_info_alter`

{{< highlight php "linenos=inline,hl_lines=9" >}}
<?php

/**
 * Implements hook_field_info_alter().
 */
function entity_reference_field_info_alter(&$info) {
  // Make the entity reference field configurable.
  $info['entity_reference']['no_ui'] = FALSE;
  $info['entity_reference']['class'] = '\Drupal\entity_reference\ConfigurableEntityReferenceItem';
  $info['entity_reference']['list_class'] = '\Drupal\Core\Field\EntityReferenceFieldItemList';
  $info['entity_reference']['default_widget'] = 'entity_reference_autocomplete';
  $info['entity_reference']['default_formatter'] = 'entity_reference_label';
  $info['entity_reference']['provider'] = 'entity_reference';
}
{{< /highlight >}}

Afin que notre class soit prise en compte, nous allons nous aussi utiliser ce hook et remplacer la class ConfigurableEntityReferenceItem par la notre.

{{< highlight php "linenos=inline,hl_lines=7">}}
<?php

/**
 * Implements hook_field_info_alter().
 */
function entityconnect_field_info_alter(&$info) {
  $info['entity_reference']['class'] = '\Drupal\entityconnect\ConfigurableEntityconnectItem';
}
{{< /highlight >}}

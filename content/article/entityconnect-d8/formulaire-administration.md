+++
Categories = ["Developpement", "Drupal"]
Tags = ["Developpement", "drupal", "drupal 8", "Entity Connect"]
date = "2015-08-27T15:47:06+02:00"
title = "Création d'un formulaire d'administration sous Drupal 8"
Description = "Retour sur le portage de la partie d'administration du module Entity Connect sous Drupal 8."
+++

Retour sur le portage de la partie d'administration du module [Entity Connect](https://drupal.org/project/entityconnect) sous Drupal 8.

## Conversion du fichier .info

 * Le nom du fichier change légèrement. Il passe ainsi de `*.info` à `*.info.yml`
 * Comme vous pouvez vous en douter en lisant le nom du nouveau fichier, le format utilisé dans ce fichier est le `YAML`.

### Drupal 7

`.info`

{{< highlight yaml  >}}
name = "Entity Connect"
description = "Allows for referenced entity to be created and edited from the entity reference field"
core = "7.x"
package = Entity Connect
configure = admin/config/content/entityconnect
{{< /highlight >}}

### Drupal 8

`.info.yml`

{{< highlight yaml  >}}
name: Entity Connect
type: module
description: Allows for referenced entity to be created and edited from the entity reference field
core: 8.x
package: Entity Connect
configure: entityconnect.administration_form
dependencies:
  - entity_reference

{{< /highlight >}}

* La notation YAML fait que les ` = ` deviennet des ` : `
* Les guillemets sont toujours optionnels
* Il faut maintenant définir un type : `type: module`
* Le lien `configure` permettant d'afficher un lien direct vers l'interface d'administration ne contient plus directement un lien mais une référence à une route définie dans le fichier `entityconnect.routing.yml` (voir ci-dessous).
* Le module `entityreference` (sous D7) fait maintenant partie intégrante du coeur et s'appelle `entity_reference`.


## Définition des routes

### Drupal 7

la définition d'un nouveau chemin d'accès (route) passait par l'utilisation du hook_menu.

{{< highlight php  >}}
<?php
/**
 * Implements hook_menu().
 */
function entityconnect_menu() {
  $items = array();

  $items['admin/config/content/entityconnect'] = array(
    'title' => 'Entity Connect',
    'description' => 'Configure default values for Entity Reference fields using Entity Connect',
    'page callback' => 'drupal_get_form',
    'page arguments' => array('_entityconnect_admin_form'),
    'access arguments' => array('administer site configuration'),
    'file' => 'includes/entityconnect.admin.inc',
  );

  return $items;
}

{{< /highlight >}}


### Drupal 8

nous définissons maintenant ces éléments dans un fichier en `*.routing.yml`

{{< highlight yaml  >}}
entityconnect.administration_form:
  path: '/admin/config/content/entityconnect'
  defaults:
    _form: '\Drupal\entityconnect\Form\AdministrationForm'
    _title: 'Entity Connect Administration'
  requirements:
    _permission: 'access administration pages'
{{< /highlight >}}


## Conversion du formulaire

### Drupal 7

{{< highlight php  >}}
<?php
/**
 * Defines the settings form.
 */
function _entityconnect_admin_form($form, &$form_state) {
  $form = array();
  $form['entityconnect'] = array(
    '#type' => 'fieldset',
    '#title' => t('EntityConnect default Parameters'),
  );
  $form['entityconnect']['button'] = array(
    '#type' => 'fieldset',
    '#title' => t('Buttons display Parameters'),
  );
  $form['entityconnect']['button']['button_add'] = array(
    '#required' => '1',
    '#key_type_toggled' => '1',
    '#default_value' => variable_get('entityconnect_unload_add_default', 1),
    '#description' => t('Default: "off"<br />
                          Choose "on" if you want the "add" buttons displayed by default.<br />
                          Each field can override this value.'),
    '#weight' => '0',
    '#type' => 'radios',
    '#options' => array(
      '0' => t('on'),
      '1' => t('off'),
    ),
    '#title' => t('Default Entity Connect "add" button display'),
  );
  $form['entityconnect']['button']['button_edit'] = array(
    '#required' => '1',
    '#key_type_toggled' => '1',
    '#default_value' => variable_get('entityconnect_unload_edit_default', 1),
    '#description' => t('Default: "off"<br />
                          Choose "on" if you want the "edit" buttons displayed by default.<br />
                          Each field can override this value.'),
    '#weight' => '1',
    '#type' => 'radios',
    '#options' => array(
      '0' => t('on'),
      '1' => t('off'),
    ),
    '#title' => t('Default Entity Connect "edit" button display'),
  );
 ...

  $form['submit'] = array(
    '#type' => 'submit',
    '#value' => 'Save',
    '#weight' => '2',
  );

  return $form;
}
{{< /highlight >}}

{{< highlight php  >}}
<?php

/**
 * The settings form submit.
 */
function _entityconnect_admin_form_submit($form, &$form_state) {
    variable_set('entityconnect_unload_add_default', $form_state['values']['button_add']);
    variable_set('entityconnect_unload_edit_default', $form_state['values']['button_edit']);
    drupal_set_message(t('The settings were saved.'));
}

{{< /highlight >}}

### Drupal 8

Nous allons devoir définir une class qui va étendre la class `ConfigFormBase` de Drupal.  
Pour assurer l'autoload des classes, Drupal suit les conventions PSR-4.  
Nous allons donc créer notre nouvelle class au sein de l'arborescence suivante :

```
.
├── src
│   └── Form
│       └── AdministrationForm.php
```

On défini une namespace à notre class qui sera de la forme `Drupal\nom_du_module\Form\MyForm`  

{{% tips color="positive" %}}Les modules avec un nom composé utilisent le caractère underscore ( _ ) comme séparateur.{{% /tips %}}


{{< highlight php  >}}
<?php

/**
 * @file
 * Contains Drupal\entityconnect\Form\AdministrationForm.
 */

namespace Drupal\entityconnect\Form;

{{</highlight>}}

On va définir les classes utilisées dans notre Formulaire.

{{< highlight php  >}}
<?php

use Drupal\Core\Form\ConfigFormBase;
use Drupal\Core\Form\FormStateInterface;

{{</highlight>}}

On instancie notre class qui étend `ConfigFormBase`.  

{{< highlight php  >}}
<?php

/**
 * Class DefaultForm.
 *
 * @package Drupal\entityconnect\Form
 */
class AdministrationForm extends ConfigFormBase {

{{</highlight>}}

{{% tips color="positive" %}}ConfigFormBase nous permet ne pas avoir à redéfinir l'action de sauvegarde, l'instanciation du thème et du message de confirmation d'enregistrement.{{% /tips %}}

Nous commençons par initialiser la fonction getEditableConfigNames() qui va nous permettre de définir un tableau contenant les noms des objets de configuration que notre formulaire va pouvoir éditer.

{{< highlight php  >}}
<?php
  /**
   * {@inheritdoc}
   */
  protected function getEditableConfigNames() {
    return [
      'entityconnect.administration_config'
    ];
  }
{{</highlight>}}

La documentation Drupal fait généralement référence à un nom de la forme  `mon_module.settings`. Cependant settings n'est pas un nom obligatoire. Le format attendu étant le suivant `<module_name>.<config_object_name>.<optional_sub_key>.yml`.

{{% tips color="positive" %}}Ce nom sera utilisé à chaque fois qu'il est nécessaire de récupérer ou modifier cet élément de configuration. Il sera également utilisé pour instancier les valeurs par défaut.{{% /tips %}}


On donne ensuite un Id à notre formulaire.

{{< highlight php  >}}
<?php

  /**
   * {@inheritdoc}
   */
  public function getFormId() {
    return 'entityconnect_administration_form';
  }
{{< /highlight >}}

{{% tips color="positive"%}}Il est recommandé de faire commencer le formId par le nom du module.{{% /tips %}}

Et on construit notre formulaire via la fonction `buildFrom`.  
Comme nous avons besoin de récupérer des éléments de configuration, nous allons charger la configuration via `$this->config('entityconnect.administration_config')` que l'on stocke dans une variable nommée `$config`.  
Ainsi nous utiliserons la variable $config pour récupérer la valeur souhaitée via l'appel `$config->get('ma_variable'),`

{{< highlight php  >}}
<?php

  /**
   * {@inheritdoc}
   */
  public function buildForm(array $form, FormStateInterface $form_state) {
    $config = $this->config('entityconnect.administration_config');

    $form['entityconnect'] = array(
      '#type' => 'fieldset',
      '#title' => $this->t('EntityConnect default Parameters'),
    );

    // ...

    $form['entityconnect']['button']['button_add'] = array(
      '#required' => '1',
      '#default_value' => $config->get('button_add'),
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

{{</highlight>}}

Et on fini par retourner un appel à la class parent avec les éléments de formulaire ajoutés.

{{< highlight php  >}}
<?php
    return parent::buildForm($form, $form_state);
  }
{{</highlight>}}

Enfin il est nécessaire de pouvoir enregistrer les valeurs après validation du formulaire.
Nous allons donc encore une fois utiliser l'objet `$this->config('entityconnect.administration_config')` et définir la variable avec la valeur du formulaire.

{{< highlight php  >}}
<?php

  /**
   * {@inheritdoc}
   */
  public function submitForm(array &$form, FormStateInterface $form_state) {
    parent::submitForm($form, $form_state);

    $this->config('entityconnect.administration_config')
      ->set('icon_add', $form_state->getValue('icon_add'))
      ->set('icon_edit', $form_state->getValue('icon_edit'))
      ->save();
  }

}

{{</highlight>}}

On a maintenant un formulaire prêt à fonctionner et enregistrer des éléments de configuration.

## Définition des valeurs par défaut

Vous aurez peut être remarqué qu'à la différence de la fonction variable_get() dans Drupal 7, nous n'avons pas défini de valeurs par défaut à nos <s>variables</s> configuration.

Il n'est donc plus possible (et nécessaire) de redéfinir à chaque appel la valeur par défaut associée à une variable comme dans cet exemple `variable_get('entityconnect_unload_add_default', 1)` où 1 était la valeur par défaut.

Dans Drupal 8, les configurations sont maintenant stockées dans des fichiers.  
Pour définir une valeur par défaut à nos éléments de configuration, il est donc nécessaire de définir cela à l'installation du module.  

2 voies sont possibles :  

* soit via le hook_install, si les valeurs a renseignée sont dynamiques
{{< highlight php  >}}
<?php
/**
 * Implements hook_install() in Drupal 8.
 */
function modulename_install() {
  // Set default values for config which require dynamic values.
  \Drupal::configFactory()->getEditable('modulename.settings')
    ->set('default_from_address', \Drupal::config('system.site')->get('mail'))
    ->save();
}
{{< /highlight >}}

* soit via l'utilisation d'un fichier YAML qui contiendra les configurations par défaut (si les valeurs sont statiques).
{{< highlight yaml  >}}
# Contenu du fichier entityconnect.administration_config.yml
button_add: 1
button_edit: 1
icon_add: 0
icon_edit: 0

{{< /highlight >}}

{{% tips color="positive" %}}Ce fichier doit se nommer avec le même nom que l'objet de configuration que nous appelons dans notre formulaire.{{% /tips %}}

Le fichier YAML créé doit être placé dans l'arborescence suivante :  
```
.
├── config
│   └── install
│       └── entityconnect.administration_config.yml
```


{{% tips title="Pour en savoir plus" color="positive" icon="warning" %}}
&nbsp;

* [Upgrading Drupal 7 Variables to Drupal 8 Configuration](https://www.drupal.org/node/1667896)
* [Configuration Storage in Drupal 8](https://www.drupal.org/node/2120571)

{{% /tips %}}


## Organisation des fichiers (récapitulatif)

Drupal 7

```
.
├── entityconnect.info
├── entityconnect.module
├── includes
│   ├── entityconnect.admin.inc
```

Drupal 8

```
.
├── config
│   └── install
│       └── entityconnect.administration_config.yml
├── entityconnect.info.yml
├── entityconnect.module
├── entityconnect.routing.yml
├── src
│   └── Form
│       └── AdministrationForm.php
```

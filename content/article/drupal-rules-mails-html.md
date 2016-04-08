+++
Categories = ["Développement", "Drupal"]
Description = "Créer, gérer et envoyer des mails en HTML avec Rules dans Drupal."
Tags = ["Développement", "Drupal", "email", "html", "rules"]
date = "2015-11-03T13:54:56+02:00"
title = "Envoyer des mails HTML via Drupal et Rules"

+++

## Modules de la contribution

* [HTML Mail](https://www.drupal.org/project/htmlmail) pour la gestion pure du mail au format HTML
* [Mail System](https://www.drupal.org/project/mailsystem) pour définir quel type de mail on envoi en fonction des actions    
* [Variable Email](https://www.drupal.org/project/variable_email) vous permettra de stocker le mail dans une variable et l'envoyer via Rules.

## Configuration du module HTML Mail

Définissez dans le module HTMLMail le thème de votre site. Cela permettra de centraliser vos templates au sein de votre thème.

## Configuration du module Mail System

Configuré le module pour envoyer des mails passant par HTMLMail dans les cas qui vous intéressent, par exemple les mails système (création de compte, demande de renouvellement de mots de passe) en paramétrant la class `HTMLMailSystem`

Si vous voulez que les mails envoyés via Rules passent également par HTML Mail, il est possible de créer un "New settings" en sélectionnant le module Rules dans la liste.
Une fois le nouveau paramétrage créé, il est possible de lui associer la class `HTMLMailSystem`


## Créer une nouvelle variable de type mail

Dans le .info du module, ajouter une dépendance à

```
dependencies[] = variable
```

Créer un fichier my_module.variable.inc

{{< highlight php >}}

<?php

/**
 * @file
 * my_module.variable.inc
 */

/**
 * Implements hook_variable_info().
 */
function my_module_variable_info($options) {

  $variable['mail_do_something_[mail_part]'] = array(
    'title' => t('Send mail when something happend'),
    'type' => 'mail_text',
    'default' => array(
      'subject' => 'My default subject',
      'body' => 'My default body',
    ),
    'required' => TRUE,
    'group' => 'store_mails',
    'token' => TRUE,
  );

  return $variable;
}
{{< /highlight >}}

## Permettre la modification et traduction de la variable

* Allez sur la page /admin/config/regional/i18n/variable et cocher la nouvelle variable créée.
* Enregistrer
* La variable devrait être disponible en édition pour les différentes langues de votre site sur la page /admin/store/mails
* Modifier les valeurs des différentes langues pour y inclure le markup HTML du mail
* Enregistrer

## Packaging du mail

Ajouter à votre feature la variable à packager
Ajouter à votre feature la variable `variable_realm_list_language`

{{< highlight php >}}
<?php

$strongarm = new stdClass();
$strongarm->disabled = FALSE; /* Edit this to true to make a default strongarm disabled initially */
$strongarm->api_version = 1;
$strongarm->name = 'variable_realm_list_language';
$strongarm->value = array(
  0 => 'mail_do_something_[mail_part]',
);
$export['variable_realm_list_language'] = $strongarm;
{{< /highlight >}}


## Utiliser la variable dans Rules

* Ajouter une Action : Send mail with Variable
* Sélectionner la variable créée
* Ajouter `node:author:language` dans la partie Langue, ce qui permettra d'envoyer automatiquement la variable localisée à l'utilisateur

Lors du packaging de votre rules, une dépendance à variable_email devrait se créer.

```
dependencies[] = variable_email
```

Dans l'exemple, ci-dessous nous allons envoyer un mail à l'auteur du contenu à sa création et on obtient l'export suivant :

{{< highlight php >}}

<?php

/**
 * Implements hook_default_rules_configuration().
 */
function my_module_default_rules_configuration() {
  $items = array();
  $items['rules_mail_to_author'] = entity_import('rules_config', '{ "rules_mail_to_author" : {
      "LABEL" : "Send mail to author",
      "PLUGIN" : "reaction rule",
      "OWNER" : "rules",
      "REQUIRES" : [ "variable_email", "rules" ],
      "ON" : { "node_insert--page" : { "bundle" : "page" } },
      "DO" : [
        { "variable_email_mail" : {
            "to" : [ "node:author:mail" ],
            "variable" : "mail_do_something_[mail_part]",
            "language" : [ "node:author:language" ]
          }
        },
      ]
    }
  }');

  return $items;
}

{{< /highlight >}}

Et vous comment gérez-vous les envois de mails HTML dans Drupal ?

+++
Categories = ["Développement", "Article", "Drupal", "Tuto"]
Tags = ["Développement", "Drupal", "Drupal 8"]
date = "2016-05-02T10:13:54+02:00"
title = "Import de fichier XML sous Drupal 8 - Traitements spécifiques sur la source"
Description = "Surcharger la class source lors de l'import de fichier XML sous Drupal 8 pour traiter les cas particuliers sur les champs"
+++

Dans l'article précédent, [Réaliser un import de fichier XML sous Drupal 8]({{< relref "drupal-8-migration-xml.md" >}}), nous avons vu comment importer un fichier XML via Migrate.
La configuration était simple et nous avons pu faire l'ensemble du mapping sans manipuler les données du fichier XML.

Nous allons étendre notre exemple précédent pour importer une date.  
Cependant cette date n'a pas un format de date *standard* et n'est pas valide pour être importée dans Drupal directement.

## Mise à jour du contexte

### Fichier XML à importer

```
<?xml version="1.0" encoding="utf-8"?>
<flux-communiques>
    <communique>
        <id-communique>1</id-communique>
        <titre>Titre de l'article 1</titre>
        <date-diffusion>2016-02-05 16:07:00</date-diffusion>
        <corps><![CDATA[<div style="color: red">Un texte bleu</div>]]></corps>
        <pj1>http://example.com/monfichier.pdf</pj1>
    </communique>
    <communique>
        <id-communique>2</id-communique>
        <titre>Titre de l'article 2</titre>
        <date-diffusion>2016-01-14 16:24:00</date-diffusion>
        <corps><![CDATA[<div style="color: red">Un texte rouge</div>]]>
        </corps>
        <pj1>http://example.com/monfichier2.pdf</pj1>
    </communique>
</flux-communiques>
```

La champ `date-diffusion` n'est pas valide et nous allons avoir besoin d'ajouter un **T** entre la date et l'heure pour obtenir le format suivant : `2016-02-05T16:07:00`

### Type de contenus

Nous possédons un type de contenus, nommé `Communique` avec les champs suivants :

|Label|Nom machine|
|---|---|
|Titre|title|
|Corps|body|
|Date de diffusion|field_communique_date|
|Pièce jointe|field_communique_attachment|
|Id du communiqué|field_communique_id|

## Modifications du module d'import

### Nouveau mapping des champs source

Dans la partie `source`, nous allons ajouter une entrée pour mapper la date de diffusion.

```
source:
  #...
  fields:
    #...
    -
      name: date_diffusion
      label: Date Diffusion
      selector: date-diffusion
  #...
```

### Nouveau mapping des champs Drupal

```
process:
  #...
  field_press_release_date: date_diffusion
  #...
```

Si vous lancez un `drush migrate-fields-source` vous devriez voir le nouveau champ apparaitre

```
$ drush mfs communique
ID              id_communique  
Titre           titre          
Corps           corps          
Date Diffusion  date_diffusion
Lien            pj1
```

## Modification de la class Source

Comme indiqué précédemment, il va maintenant nous falloir altérer la valeur de la date de diffusion pour qu'elle est un format interprétable par Drupal et ainsi que l'import de ce champ se réalise correctement.

Pour cela nous allons devoir modifier le comportement du plugin de la source (Url.php dans notre) et utiliser, comme sur Drupal 7, la méthode prepareRow().

Nous allons donc créer une nouvelle class nommée Communique.php dans `./src/Plugin/migrate/source/Communique.php`  
On obtient l'arborescence de module suivante :

```
.
├── config
│   └── install
│       └── migrate_plus.migration.communique.yml
├── migrate_press_release.info.yml
└── src
    └── Plugin
        ├── migrate
        │   └── source
        │       └── Communique.php
```

Notre nouvelle class `Communique.php` :

```
<?php

namespace Drupal\migrate_communique\Plugin\migrate\source;

use Drupal\migrate\Row;
use Drupal\migrate_plus\Plugin\migrate\source\Url;

/**
 * Source plugin for communique content.
 *
 * @MigrateSource(
 *   id = "communique"
 * )
 */

class Communique extends Url {

    /**
     * {@inheritdoc}
     */
    public function prepareRow(Row $row) {
        // Alter XML provided date.
        $row->setSourceProperty('date_diffusion', $this->processDateDiffusion($row->getSource()['date_diffusion']));
        return parent::prepareRow($row);
    }

    /**
     * Format Date from XML to be compliant with DateTime format.
     *
     * @param $element
     * @return string
     */
    protected function processDateDiffusion($element) {

        $exploded = explode(' ', (string) $element);
        $data = implode('T', $exploded);

        return $data;
    }
}
```

Nous avons donc ici une class qui étant la class `Url` et prépare le format de la date obtenue dans le champ *date_diffusion* pour correspondre à ce qu'attend Drupal.  
L'utilisation de `$row->setSourceProperty()` permet de (re)définir  la valeur de la date de diffusion.

Il ne nous reste plus qu'à préciser à notre migration de prendre en compte cette source en remplacement de la source `url` initialement définie.

Pour cela, nous allons modifier notre fichier `migrate_plus.migration.communique.yml` pour lui renseigner l'id de notre source : *communique*

```
source:
  # L'identifiant de notre source custom.
  plugin: communique
  #...
```

{{% tips color="red" icon="warning" %}}
Afin que les changements de configuration soient pris en compte, il vous faudra désinstaller le module, supprimer la config déjà enregistrée et réinstaller le module.
Voir l'article [Drupal 8 - Suppression de configurations à la désinstallation du module]({{< relref "drupal-8-suppression-config-desinstallation.md" >}})
{{% /tips %}}

Une fois les modifications effectuées, il ne vous reste plus qu'à relancer votre migration.


{{% tips color="blue" title="A lire aussi"%}}
&nbsp;

* [Réaliser un import de fichier XML sous Drupal 8]({{< relref "drupal-8-migration-xml.md" >}})
* [Drupal 8 - Suppression de configurations à la désinstallation du module]({{< relref "drupal-8-suppression-config-desinstallation.md" >}})

{{% /tips %}}

+++
Categories = ["Développement", "Article", "Drupal", "Tuto"]
Tags = ["Développement", "Drupal", "Drupal 8"]
date = "2016-05-02T10:13:54+02:00"
title = "Réaliser un import de fichier XML sous Drupal 8"
Description = "Comment réaliser un import de contenu XML dans Drupal 8 à l'aide des modules migrate, migrate_plus et migrate_source_xml"
+++

Dans cette article nous allons voir comment réaliser un import de contenu XML dans Drupal 8 à l'aide des modules migrate, [migrate_plus](https://drupal.org/project/migrate_plus) et [migrate_source_xml](https://drupal.org/project/migrate_source_xml).

## Récupération des modules et installation

* `migrate` est disponible dans le coeur de Drupal 8. Cependant il ne contient à ce jour que la possibilité de migrer des contenus en provenance d'une base SQL.
* `migrate_plus` est un module contribué qui permet notamment d'obtenir la possibilité de migrer des contenus à partir d'une URL.

```
$ drush dl migrate_plus --dev
```

* `migrate_source_xml` permet d'avoir une class de migration gérant des fichiers XML.

```
# depuis le dossier ./modules/[contrib]
$ git clone --branch refactor https://git.drupal.org/project/migrate_source_xml.git
```

## Contexte

## Fichier XML à importer

```
<?xml version="1.0" encoding="utf-8"?>
<flux-communiques>
    <communique>
        <id-communique>1</id-communique>
        <titre>Titre de l'article 1</titre>
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

### Type de contenus

Nous possédons un type de contenus, nommé `Communique` avec les champs suivants :

|Label|Nom machine|
|---|---|
|Titre|title|
|Corps|body|
|Pièce jointe|field_communique_attachment|
|Id du communiqué|field_communique_id|

## Création du module d'import

### Création du module migrate_communique

Nous allons nommer notre module `migrate_communique` et commencer par créer le dossier du même nom dans le répertoire `modules` à la racine de Drupal.

```
./modules
├── migrate_communique
└── README.txt
```

et définir le fichier migrate_communique.info.yml

```
type: module
name: Migrate Communiqué
description: 'Migration des communiqués.'
package: Migration
core: 8.x
dependencies:
  - migrate_plus
  - migrate_source_xml
```

On notera ici les dépendances aux modules `migrate_plus` et `migrate_source_xml`.

### Définition du mapping entre le XML et le type de contenus

Nous allons créer un fichier de configuration nommé `migrate_plus.migration.communique.yml` dans le dossier `config/install` à partir de la racine du module.

```
.
├── config
│   └── install
│       └── migrate_plus.migration.pressrelease.yml
├── migrate_communique.info.yml
```

La configuration contenue dans ce fichier sera initialisée à l'installation du module.

#### Contenu du fichier migrate_plus.migration.communique.yml

#### Contenu intégral du fichier

Nous détaillerons juste après le contenu de ce fichier

```
# Configuration de la migration des communiqués.
id: communique
label: Communique
migration_group: Communique
migration_dependencies: {}

source:
  plugin: url
  data_fetcher_plugin: http
  data_parser_plugin: xml
  urls: http://exemple/monfichier.xml
  item_selector: /flux-communiques/communique
  fields:
    -
      # Nom machine utilisé pour le mapping lors du processing.
      name: id_communique
      # Label qui sera affiché dans l'UI.
      label: ID
      # Nom du champ dans le XML.
      selector: id-communique
    -
      name: titre
      label: Titre
      selector: titre
    -
      name: corps
      label: Corps
      selector: corps
    -
      name: pj1
      label: Lien
      selector: pj1

  ids:
    id_communique:
      type: string

destination:
  plugin: entity:node

process:
  type:
    plugin: default_value
    default_value: communique

  title: titre
  field_communique_id: id_communique
  'field_communique_body/value': corps
  'field_communique_body/format':
      plugin: default_value
      default_value: full_html
  field_communique_attachment: pj1

  sticky:
    plugin: default_value
    default_value: 0

  uid:
    plugin: default_value
    default_value: 1
```

#### Configuration générale

```
id: communique
label: Communique
migration_group: Communique
migration_dependencies: {}
```

#### Mapping de la source

```
source:
  plugin: url
  data_fetcher_plugin: http
  data_parser_plugin: xml
```

* **plugin** permet de définir le nom du plugin qui va servir de base pour la parsing de la source.  
Ici le plugin `url` est fourni par le module `migrate_plus` dans la class `Url.php` (./modules/contrib/migrate_plus/src/Plugin/migrate/source/Url.php)

Dans cette class, on retrouve notamment l'annotation suivante qui nous permet d'obtenir l'id du plugin :

```
/**
 * Source plugin for retrieving data via URLs.
 *
 * @MigrateSource(
 *   id = "url"
 * )
 */
```

* **data_fetcher_plugin** : plugin implémenté dans `migrate_plus` pour permettre de récupérer un fichier depuis une URL (./modules/contrib/migrate_plus/src/Plugin/migrate_plus/data_fetcher/Http.php)

```
/**
 * Retrieve data over an HTTP connection for migration.
 *
 * @DataFetcher(
 *   id = "http",
 *   title = @Translation("HTTP")
 * )
 */
```

* **data_parser_plugin** : plugin implémenté par `migrate_source_xml` (./modules/contrib/migrate_source_xml/src/Plugin/migrate_plus/data_parser/Xml.php)

```
/**
 * Obtain XML data for migration.
 *
 * @DataParser(
 *   id = "xml",
 *   title = @Translation("XML")
 * )
 */
```

* **urls** : une liste d'urls auxquelles récupérer le fichier XML.

```
  urls: http://exemple/monfichier.xml
```

* **item_selector** : permet de définir l'emplacement des items qui seront mappés et parsés (au format XPath)

```
  item_selector: /flux-communiques/communique
```

* **fields** : permet de définir le mapping entre les champs XML et la class de migration

On va ici définir pour chaque champs :

* un nom machine - qui sera réutiliser plus tard lors du processing du champ
* un label (optionnel)
* un sélecteur - le nom du champ dans le XML

```
  fields:
    -
      # Nom machine utilisé pour le mapping lors du processing.
      name: id_communique
      # Label qui sera affiché dans l'UI.
      label: ID
      # Nom du champ dans le XML.
      selector: id-communique
    -
      name: titre
      label: Titre
      selector: titre
    -
      name: corps
      label: Corps
      selector: corps
    -
      name: pj1
      label: Lien
      selector: pj1
```

* **ids** : permet de définir l'identifiant unique dans le flux pour gérer les nouveaux imports et mises à jour

```
  ids:
    id_communique:
      type: string
```

#### Destination de la migration

```
destination:
  plugin: entity:node
```

On définie ici une migration vers une entitité de type `node`.
On peut tout à fait envisager également de migrer vers d'autres entités comme les utilisateurs ou .

```
# Exemple pour l'entité User.
destination:
  plugin: entity:user
```


#### Mapping avec les champs Drupal

La partie `process` du yaml permet de définir le type de contenus dans lequel importer les données.

```
process:
  type:
    plugin: default_value
    default_value: communique
```

Le `type` est ici forcé à `Communique`. Tous les contenus créés auront seront donc des communiqués.  
Le plugin `default_value` permet de définir la valeur par défaut que prendra un champ.  
On réutilise ce plugin plus bas pour définir la valeur du champ Sticky et l'identifiant de l'utilisateur (uid)

```
sticky:
  plugin: default_value
  default_value: 0

uid:
  plugin: default_value
  default_value: 1
```

Nous retrouvons ensuite le mapping des champs à proprement parler.

```
  title: titre
  field_communique_id: id_communique
```

Il s'écrit sous la forme :

```
  nom_machine_champ_drupal: nom_machine_source_yaml
```

Enfin on retrouvera une notation un peu particulière pour les champs *composés* tels que le champ `body` qui attend une valeur complète, un format et potentiellement un résumé.

```
  'field_communique_body/value': corps
  'field_communique_body/format':
      plugin: default_value
      default_value: full_html
```

Comme vous l'avez sûrement remarqué, ces champs s'écrivent sous la forme `'nom_champ/propriété'`.   
Il est important de ne pas omettre les guillemets simples autour du nom du champ.

## Lancer la migration avec Drush

Il est possible, comme sur Drupal 7 de lancer les migrations via Drush.
Pour cela, il va cependant nous falloir installer un module complémentaire : [migrate_tools](https://drupal.org/project/migrate_tools).

Un simple `drush dl migrate_tools --dev` et `drush en migrate_tools` devrait suffire.

Ce module permet de faire le pont entre drush et migrate, qui rappelons-le est maintenant inclus directement dans le coeur de Drupal.

Une fois le module installé, on va avoir aux habituelles commandes drush migrate

```
$ drush --filter=migrate_tools
All commands in migrate_tools: (migrate_tools)
 migrate-fields-sourc  List the fields available for mapping in a source.
 e (mfs)                                                                  
 migrate-import (mi)   Perform one or more migration processes.           
 migrate-messages      View any messages associated with a migration.     
 (mmsg)                                                                   
 migrate-reset-status  Reset a active migration's status to idle.         
 (mrs)                                                                    
 migrate-rollback      Rollback one or more migrations.                   
 (mr)                                                                     
 migrate-status (ms)   List all migrations with current status.           
 migrate-stop (mst)    Stop an active migration operation.
```

### Vérification du mapping des champs

```
$ drush mfs communique
ID              id_communique  
Titre           titre          
Corps           corps          
Lien            pj1
```

On retrouve bien ici les champs mappés dans la partie `source`.

### Status des imports

```
$ drush ms communique
 Group: Communique  Status  Total  Imported  Unprocessed  Last imported       
 communique         Idle    2      0         0            
```

### Lancer la migration

```
$ drush mi communique --update
Processed 2 items (2 created, 0 updated, 0 failed, 0 ignored) - done with 'communique'          

$ drush mi communique --update
Processed 2 items (0 created, 2 updated, 0 failed, 0 ignored) - done with 'communique'          
```

Voilà ! Vos noeuds ont été créés et sont maintenant visibles dans le back-office Drupal.

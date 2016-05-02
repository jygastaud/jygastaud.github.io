+++
Categories = ["Développement", "Article", "Drupal", "Tuto"]
Tags = ["Développement", "Drupal", "Drupal 8"]
date = "2016-05-02T15:21:25+02:00"
title = "Drupal 8 - Suppression de configurations à la désinstallation du module"
Description = "Un méthode simple et rapide pour supprimer vos configurations à la désinstallation d'un module."

+++

Lors de l'implémentation d'un module, il va vous arriver de créer des configurations lors de l'installation.

Il est nécessaire de penser à les supprimer à la désinstallation.

Pour cela, il vous suffit d'utiliser le `hook_uninstall` dans le fichier `.install` de votre module, comme cela pouvait être fait sur Drupal 7.

Exemple avec une configuration du type *migration* nommée *communique*:

```
/**
 * Implements hook_uninstall().
 */
function migrate_communique_uninstall() {
    \Drupal::entityTypeManager()->getStorage('migration')->load('communique')->delete();
}
```

+++
Categories = ["Drupal"]
Description = "Nettoyer les informations des contacts de votre base de données en une ligne de commande avec Drush."
Tags = ["Drupal", "Drush"]
date = "2015-10-05T13:51:52+02:00"
title = "Réinitiliser tous les emails et mots de passe utilisateur avec Drush"

+++

Si vous récupérez une base de données Drupal en local, il peut être utile d'assigner des valeurs par défaut aux comptes utilisateurs.

Cela permet entre autre :  

* de se connecter simplement à l'ensemble des comptes
* d'éviter que des mails de tests soient envoyés aux contacts réels

Avec Drush, cela est possible en une ligne de commande :

```
drush sql-sanitize --sanitize-email="user+%uid@localhost" --sanitize-password="password"
```

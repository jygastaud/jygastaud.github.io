+++
Categories = ["Drupal"]
Description = "Technique pour récupérer l'url définie dans une page gérée via le module page_manager"
Tags = ["Développement", "Drupal", "Drupal 7", "Page Manager", "tips"]
date = "2016-08-09T14:48:18+02:00"
title = "Obtenir l'url d'une page gérée via page_manager"

+++

Ci-dessous une technique pour récupérer l'url définie dans une page gérée via le module page_manager (inclus dans Ctools).

```php
// Load ctools plugins.
ctools_include('page', 'page_manager', 'plugins/tasks');

// Load path "my-page" page.
$path = page_manager_page_load('my-page')->path;
```

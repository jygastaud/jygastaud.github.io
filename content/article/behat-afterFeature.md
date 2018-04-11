+++
Categories = ["Développement", "Article"]
Description = "Snippet permettant d'éxécuter des actions à la fin de l'éxécution d'une feature Behat."
Tags = ["Développement", "Behat", "Drupal"]
aliases = []
date = "2016-09-02T17:12:10+02:00"
image = ""
title = "Drupal Behat afterFeature"
+++

Snippet permettant d'éxécuter des actions à la fin de l'éxécution d'une feature Behat.

```
/**
 * Defines application features from the specific context.
 */
class FeatureContext extends RawDrupalContext implements SnippetAcceptingContext {

  /**
   * That function will be executed after the end of the feature.
   *
   * @AfterFeature
   */
  public static function cleanupSomethingAfterFeatureExcution() {
    // Do something.
  }
}
```

# Ressources

* http://docs.behat.org/en/v2.5/guides/3.hooks.html
* https://www.webomelette.com/content-fixtures-behat-testing-drupal-7
* http://www.metaltoad.com/blog/what-i-learned-today-drupal-behat-scenario-cleanup

+++
date = "2013-06-22T15:00:28+01:00"
title = "DrupalCamp Paris2013 - Behat et Drupal"
category = ["Développement"]
tag = ["Drupal", "Behat"]
description = "Prise de notes réalisées lors de la conférence Behat et Drupal du DrupalCamp Paris2013."

+++

# Behat et Drupal

### Selenium API et IDE
* Comment automatiser les tests?
    * Selenium Server
    * PHPUnit
    * Selenium IDE
    * ...
* Comment tester l'ajax?
    * Selenium à installer
* Comment tester le multi-domaine


### Behaviour Driven Development (BDD)
CF: Ryan Weaver
portland 2013

## Gherkin
Langage qui permet de définir des tests
 * Feature
    * Scenario
        * Steps
            * Context: Given
                * And
            * When
                * And
            * Result: Then

### Cucumber
* Gherkin + Ruby

## Behat + Mink

### Behat
 * Gherkin + PHP => Behat

### Mink
 * Drivers
    * ZombieDriver
    * Sahi
    * Goutte (si pas besoin de js)
    * Selenium (avec js)

* MinkExtension sert à lier Behat et Mink
* Behat est indépendant de l'application web
* Behat s'installe via Composer
* Exécutable dans dossier bin/

FeatureContext.php doit être modifié pour étendre MinkContext
Il est possible de créer des subcontexts

Attention le mouseover ne fonctionne que sur les éléments javascript, pas css

## Projet Drupal
DrupalExtension => project/drupalextension

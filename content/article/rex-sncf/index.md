+++
Categories = ["Développement", "REX"]
Description = "Retour d'expérience sur la mise en place du projet Store.SNCF sur Drupal."
Tags = ["Agile", "Scrum", "Drupal", "REX"]
aliases = []
date = "2015-12-09T11:37:05+01:00"
title = "REX - Mise en place du Store.SNCF"
draft = "true"

+++

# Store SNCF

## Le projet

### Objectifs

* Lister l'ensemble des applications SNCF ***officielles*** ET ***officieuses***
* Mettre en lumière les développeurs ***Shadow***
* Aider à la mise en place de bonnes pratiques

### Un peu d'historique

On est le 22 avril : on démarre le projet
  * sans specs (on a un bout de backlog)
  * sans UX
  * sans graphisme (ni graphiste !)
  * sans hébergement

1ère deadline annoncée

**Conférence de presse le 11 juin !**

1,5 mois ? On est LARGE !

### Scrum à la rescousse  

<img height="500px" src="rex-sncf/IMG_20150427_115457.jpg" />

Sprints de 2 semaines  

### Equipe

#### Clever Age (et assimilé)
* 2 Devs à temps plein : CorentinB.; JonathanV.
* 1 inté : AnthonyL.
* 1 ScrumMaster : JYG.
* Des renforts ponctuels : JulienK.; DavidO.
* BryanF. et MaximeJ. depuis peu

#### Hors Clever Age
* 1 PO SNCF (Florence) + 1 Proxy PO (Sonia)
* Razorfish : 1 UX; 1 DA; 1 WebDesigner


## Besoins et Solutions

### Côté Front

* Responsive - intégration proportionnelle -
* IE8+ (mode degradé)
* Non compatible Android browser
* Utilisation massive de SVG
* Limitation de font-face
* Lazyload des images
* Bye-Bye divites Drupal
* Bye-Bye les CSS du coeur Drupal

### Drupal

| Besoins | Solutions |
|---|---|
| Contribution simple | Paragraphs + Markdown |
| Positionnement de blocs | Panels + Beans |
| Recherche d'applications | Search_api + FacetAPI |
| Import One-shot | [Fixtures](https://github.com/jygastaud/drupal-fixtures) |
| Multi-auteurs | [Editor List](https://git.clever-age.net/clever-age-expertise/drupal-editor-list) |
| Connexion des internes SNCF | OpenAM et SimpleSAMLPHP |
| Synchro MDM / MAM <br /> MobileIron / Appaloosa | Migrate + Certificats SSL |

Utilisation des `View Mode`


### Hébergement

AMAZON !

Ah bah finalement **non**

Acquia + Acquia Search : SolR as a Service


## Et si c'était à refaire

### Certains choix initiaux

* Non utilisation de la `"Render API"` au démarrage
  * 3 semaines de refacto <br />incluant la refonte des widgets de formulaires
* clientside_validation
  * Fait le job mais le code laisse à désirer


###  Travailler l'automatisation

* Drush make (abandonné)
* Utiliser les [hooks Acquia](https://github.com/acquia/cloud-hooks) : On y travaille !
  * post-code-deploy
  * post-code-update
  * post-db-copy
  * post-files-copy
  * pre-web-activate
* Utiliser les hooks GIT en local


###  + de Tests automatisés

* Des tests fonctionnels
* Des tests unitaires

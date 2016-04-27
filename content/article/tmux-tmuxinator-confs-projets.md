+++
Categories = ["Développement", "Shell", "Tuto"]
Description = "Exemple de fichier de configuration Tmuxinator pour vos projets Drupal"
Tags = ["Développement", "Tmux", "Tmuxinator", "Shell"]
date = "2016-04-27T19:00:00+02:00"
title = "Utiliser Tmux et Tmuxinator pour gérer vos confs projets"
+++


## Pré-requis

Avoir installé sur vos machines

* [Tmux](https://tmux.github.io/)
* [Tmuxinator](https://github.com/tmuxinator/tmuxinator)

## Votre nouveau projet en 3 étapes

1. `tmuxinator new [project_name]` : Cette commande va générer un fichier YAML avec la configuration par défaut
1. Editer le fichier généré : `~/.tmuxinator/[project_name].yml` (voir exemple ci-dessous)
1. Lancer `mux [project_name]` dans votre terminal

## Exemple de configuration Tmuxinator pour le projet Store sous Drupal

<pre>
<code class="yml">
# ~/.tmuxinator/store.yml

name: store
root: ~/www/store

windows:
  - drupal:
      layout: main-vertical
      panes:
        # Aller dans le réperoire docroot/ et utiliser l'alias drush projet.local
        - cd www/store/docroot && drush use @projet.local
        # crée simplement un panneau dans le répertoire root défini
        -
        # Lancer vagrant et se connecter dedans
        - vagrant up && vagrant ssh
  - dev: drush use @projet.dev
  - staging: drush use @projet.test
  - prod:  drush use @projet.prod
  # Lancer PHPStorm
  - editor: pstorm .
</code>
</pre>

Dans le terminal, lancer `mux store` permettra ainsi de lancer 5 fenêtres tmux + phpstorm.

## Références

* [Tame the command line: How to get started with tmux](http://nils-blum-oeste.net/getting-started-with-tmux/)
* [Drupal: Efficient Drupal Development with Tmux and Tmuxinator - See more at: http://www.mediacurrent.com/blog/efficient-drupal-development-tmux-and-tmuxinator#sthash.QBmP4vJZ.dpuf](http://www.mediacurrent.com/blog/efficient-drupal-development-tmux-and-tmuxinator)
* [Manage different tmux configurations with tmuxinator](http://zdk.github.io/manage-different-tmux-configurations-with-tmuxinator/)

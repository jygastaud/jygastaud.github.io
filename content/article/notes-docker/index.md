+++
title = "Mes notes sur Docker"
date = "2014-08-04"
description = "Vous trouverez ici mes notes sur Docker réalisée lors de mes 1ers essais et la réalisation du projet Wintersmith Docker."

+++

* Le fichier ```Dockerfile``` produit une Image
* Dans le Dockerfile il n'est possible de mettre qu'une seule instruction CMD.
	* Si 2 intructions (ou plus) sont dans le même fichier, seule la dernière sera exécutée.
* Il est possible de commiter, pusher ou récupérer une image (à la façon de GIT)
* ```docker run ...``` produit une instance de l'image

* Les fichiers ajoutés via l'image (et le Dockerfile) sont fixes à chaque lancement de run
* Si la commande run contient l'option ```-v``` il est possible de partager un dossier local (alors dynamique dans le conteneur)
	* Si un ```ADD``` dans le dockerfile contient le même chemin que celui que l'on veut rendre dynamique, cela ne marche pas.
* Il est possible de partager des volumes entre les conteneurs lors du run via l'option --volumes-from
* On peut nommer un conteneur (--name) ce qui permet d'effectuer les opérations via son nom et non son ID (ne marche pas pour toutes les commandes)

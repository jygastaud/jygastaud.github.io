+++
title = "Azure-cli, activer l'auto-complétion sur Zsh"
Description = "Azure-cli, activer l'auto-complétion dans bash et Zsh sur Ubuntu."
Tags = ["Tips", "Azure", "Shell", "zsh", "ubuntu"]
Categories = ["DevOps", "Azure"]
image = ""
aliases = []
date = 2019-11-26T23:35:18+01:00
lastmod = 2019-11-26T23:35:18+01:00
+++


Azure-cli n'a pas d'auto-complétion activée sur Zsh et le framework Oh-My-Zsh n'a pas de plugin disponible en natif.

Cependant, Azure-cli est installé avec un script d'auto-complétion pour bash qui devrait se trouver dans le répertoire `bash_completion.d`.

Dans ma configuration, en utilisant Ubuntu 18.04, j'ai trouvé le script `azure-cli` dans un répertoire `/etc/bash_completion.d/`.

Maintenant nous avons juste besoin de charger le script autocomplete dans notre `~/.zshrc` avec la ligne suivante :

```
source /etc/bash_completion.d/azure-cli
```

Sauvegardez et rechargez votre terminal. Fin.

#### Notes complémentaires

* Si vous rencontrez une erreur au redémarrage, vous devrez peut-être ajouter cette ligne avant le chargement du script pour assurer la compatibilité croisée entre les scripts bash et zsh. 

```
autoload -U +X bashcompinit && bashcompinit
```

* En regardant les différents billets du blog, vous constaterez peut-être que le script s'appelle `az`, et non `azure-cli`.

* D'après le répertoire que je l'ai trouvé, le script était chargé nativement si j'utilise le shell bash. Si vous utilisez bash et n'avez pas l'auto-complétion activée, vous devez probablement chercher le script `azure-cli` ou `az` puis le charger dans votre fichier `~/.bashrc`.

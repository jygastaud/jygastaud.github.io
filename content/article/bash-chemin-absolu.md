+++
Categories = ["DevOps"]
Description = "Récupérer le chemin absolu d'exécution de son script en bash."
Tags = ["Développement", "Bash", "Shell"]
date = "2015-12-10T13:50:52+02:00"
title = "Bash - Récupérer le chemin absolu d'exécution du script"

+++

Lors de l'exécution d'un fichier *bash*, il est parfois nécessaire de récupérer le chemin d'exécution du script.

## TL;DR

```
$(dirname $(readlink -f $0))
```

{{% tips color="negative" %}}
<strong>Attention :</strong> Sur Mac OS X, readlink ne fonctionne pas de la même façon que sur Linux.
Il vous faudra chercher une alternative. 3 pistes :

<br/>

* la plus universelle <code>$( cd "$( dirname "${0}" )" &amp;&amp; pwd )</code></li>
* utiliser <code>realpath -s $0</code></li>
* installer <code>greadlink</code></li>

{{% /tips %}}

## La commande dirname
L'un des moyens les plus courant est d'utiliser la commande

```
`dirname "$0"`
```

* $0 renvoi le nom du script

Le soucis ici c'est que le retour de `dirname` ne sera pas identique en fonction de son lieu d'exécution.

Par exemple, les appels suivants auront tous un retour différent :

```
vagrant@store-dev:~$ sh www/store/updates/update_sample.sh
dirname: www/store/updates

vagrant@store-dev:~/www/store/updates$ sh update_sample.sh
dirname: .

vagrant@store-dev:~/www/store$ sh ./updates/update_sample.sh
dirname: ./updates

vagrant@store-dev:~/www/store/docroot$ sh ../updates/update_sample.sh
dirname: ../updates
```

## Readlink pour nous sauver

Pour s'assurer que `dirname` nous renvoi toujours un chemin consistant, il est possible de le combiner avec la commande `readlink`

La combinaison des 2 nous renverra ainsi un chemin absolu vers le script.
On aura donc maintenant un retour identique pour tous nos appels au script.

```
vagrant@store-dev:~$ sh www/store/updates/update_sample.sh
dirname: www/store/updates
dirname/readlink: /home/vagrant/www/store/updates

vagrant@store-dev:~/www/store/updates$ sh update_sample.sh
dirname: .
dirname/readlink: /home/vagrant/www/store/updates

vagrant@store-dev:~/www/store$ sh ./updates/update_sample.sh
dirname: ./updates
dirname/readlink: /home/vagrant/www/store/updates

vagrant@store-dev:~/www/store/docroot$ sh ../updates/update_sample.sh
dirname: ../updates
dirname/readlink: /home/vagrant/www/store/updates
```

## Vérifier ce qui marche chez vous

A mettre dans un fichier test.sh

{{< highlight bash >}}
#!/usr/bin/env bash

echo "pwd: `pwd`"
echo "\$0: $0"
echo "basename: `basename $0`"
echo "dirname: `dirname $0`"
echo "dirname/readlink: $(dirname $(readlink -f $0))"
echo "realpath: $(dirname $(realpath -s $0))"
echo "cd/pwd: $( cd "$( dirname "${0}" )" &amp;&amp; pwd )"

{{< /highlight >}}

## Mise en application

L'exemple ci-dessous nous permet de définir, en fonction des paramètres d'appel du script, l'alias drush à utiliser.
Cependant si le script est appelé sans paramètre, nous souhaitons passer définir `--root` en tant qu'alias.

{{< highlight bash >}}
#!/usr/bin/env bash

# Si pas de paramètres.
if [ -z "${1}" ]
then
    DIR=$(dirname $(readlink -f $0))

    # On vérifie que docroot existe.
    if [ -d ${DIR}"/../docroot" ]
    then
        drush_alias="--root=${DIR}/../docroot"
    else
        echo "Script was not run."
        exit 1
    fi
else
    drush_alias="@${1}"
fi

# La suite du script.

{{< /highlight >}}

+++
title = "Mon workflow Git"
Description = "Résumé du workflow Git qui me semble fonctionner le mieux"
Tags = ["Développement", "Git", "Workflow"]
Categories = ["Développement", "Git"]
image = ""
aliases = []
date = 2019-01-22T08:51:19+01:00
lastmod = 2019-01-22T08:51:19+01:00
+++

Résumé du workflow Git, en ligne de commande, que j'applique de façon quasi-systématique à mes projets.

Dans cet article, je n'entrerai pas le détail de la gestion des Pull Request / Merge Request, des process de validation...

Ces éléments peuvent, bien entendu, modifier légèrement le process en fonction des contraintes que peuvent avoir les outils utilisés.

## Branches principales

Au démarrage du projet, 3 branches principales et permanentes (qui seront toujours présentes) sont créées.

* `master` : La branche de production
* `stage` :  La branche de préproduction. Contient toutes les branches de story / ticket validées, prêtes à passer en production.
* `dev` : La branche de développement. Contient les branches à tester. Les branches sont mergées dessus au fil de l'eau.

A l'initialisation, toutes les branches auront donc le même point de départ.

{{< figure src="images/01-init.svg" width="400px" class="center" >}}

Au fil des développements, ces 3 branches, en plus des branches de tickets, vont vivres à des rythmes différents.

Pour chaque ticket ou story, une nouvelle branche sera créée. Nous verrons plus loin l'origine de cette branche.

## Cycle de vie des branches principales

### dev

La branche de `dev` reçoit les *merges* des branches de ticket au fil de l'eau.

Les branches de ticket peuvent ne pas être rebase au moment du merge dans `dev`.

Il est possible de merger plusieurs fois une même branche de ticket dans `dev`.

{{< figure src="images/02-dev-branch.svg" width="400px" class="center" >}}

### stage

Tous les développements ou les créations de nouvelles branches partent de la branche `stage`.

{{< figure src="images/03.1-stage-branch.svg" width="500px" class="center" title="merge de la branche t2 dans stage" >}}


Les merges sur `stage` doivent être **obligatoirement** fait en `fast-forward`.

Cela implique que chaque branche est `rebase` avant d'être mergée dans `stage`.

On garde ainsi un historique propre et linéaire.

{{< figure src="images/03.1-stage-ff.svg" width="400px" class="center" title="merge avec fast-forward" >}}


> En cas de merge de multiples branches, le travail peut être un peu fastidieux car il implique de passer sur chaque branche 1 par 1 pour la rebase avant de la merger.

### master

On ne merge sur `master` que dans 2 cas :

1. lors d'un passage en production de fin de sprint ou de cycle de release. Le merge se fait uniquement via la branche `stage`.
2. en cas de hotfix. Via une branche de ticket.


{{< figure src="images/04-master-branch.svg" width="400px" class="center" title="merge de stage dans master" >}}

La branche `master` ne doit **jamais être rebase ou "push forcée"**.

> Idéalement la branche `master` est protégée pour éviter les erreurs.


### Réinitialisation des branches

#### Cas 1 : Merge dans master

A la suite d'un merge dans `master`, il conviendra,

* de rebase `stage`

{{< figure src="images/05-reinit-branches.svg" width="500px" class="center" title="merge de stage dans master" >}}

* de réinitialiser `dev`

{{< figure src="images/05.1-reinit-branches.svg" width="500px" class="center" title="réinitialisation de dev" >}}


#### Cas 2 : Divergences des branches

Avec le fait d'accepter n'importe quel merge sur `dev`, cette branche peut devenir rapidement très différentes, diverger, de la branche de production, `master`, voir de `stage` comme illustré ci-dessous :

{{< figure src="images/06-divergences-branches.svg" width="300px" class="center" title="Divergences importantes entre stage et dev" >}}

La branche `dev` sera donc régulièrement réinitialisée à partir de la branche `stage`, qui rappelons-le contient la dernière version des tickets validés et prêts à passer en production.

> Concrètement, nous allons donc faire un `git reset --hard origin/stage`

Une fois la réinitialisation faite, il conviendra, si cela est nécessaire, de :

1. `rebase` les branches de développements à partir de `stage`
2. (Re)merger dans `dev` les branches qui auraient pu être en attente de tests.

> Dans notre exemple, les branches `t1-new-feat`, `t2-new-feat`, `t3-new-feat` n'ont pas encore été mergées dans `stage` et seront donc `rebase` puis `merge` dans `dev`.

{{< figure src="images/06.1-divergences-branches.svg" width="300px" class="center" title="Historique git propre" >}}

<p>&nbsp;</p>
<p>&nbsp;</p>

**Détaillons maintenant le workflow de gestion des tickets via Git.**

## Workflow ticket / story

Pour traiter un nouveau ticket, nous commençons d'abord par se mettre sur la branche `stage` et s'assurer qu'elle soit à jour de notre `remote`.

```bash  
$ git checkout stage
$ git fetch
$ git reset --hard origin/stage
```

Nous avons ainsi une branche locale `stage` à jour de notre `remote`.

> Si vous avez plusieurs remote, un `git fetch --all` est recommandé et il conviendra d'adapter le `reset --hard`.

Créons maintenant notre branche de ticket/story.

Pour cela, nous partons **toujours** de la branche `stage`.

```bash
$ git checkout -b [NUM-TICKET]-[short-description]
``` 

> Si vous utilisez Gitlab pour vos tickets, il existe une fonction permettant de générer directement des branches à partir d'un ticket et ainsi d'avoir un nommage de vos branches cohérent.  
Gitlab se base sur le titre du ticket pour nommer la branche.  
Il conviendra d'avoir définie la branche `stage` comme branche par défaut dans Gitlab pour que le process expliqué ci-dessus s'applique automatiquement.


Une fois le ticket terminé, ou dans un état suffisamment stable pour être testé, nous pouvons merger la branche dans `dev`.

```bash
$ git checkout dev
$ git merge [NUM-TICKET]-[short-description]
```

Si le ticket n'est pas validé, vous pouvez merger à nouveau la branche de ticket dans `dev`.

Si le ticket est validé (tests automatisés validés, recette OK...), il est donc considéré comme pouvant potentiellement passer en production.

Dans le cadre d'un projet Agile avec des sprints ou d'une TMA avec lotissement de correctifs / évolutions, le ticket ne passera potentiellement pas en production.

Notre branche de ticket va donc être mergé dans la branche `stage` (notre préproduction).

Avant le merge, assurons nous de nouveau que `stage` est (toujours) à jour localement.

```bash
$ git checkout stage
# Mise à jour de stage si nécessaire; Voir plus haut
$ git merge --ff-only [NUM-TICKET]-[short-description]
$ git push origin stage
```

> Si vous avez un message d'erreur, c'est probablement que la branche de ticket n'est pas à jour de `stage`.  
Pensez à la `rebase`.

Si une autre branche de ticket (également validée) doit être mergée sur `stage`, nous devons donc rebase cette branche avant de pouvoir la merger.

```bash
$ git checkout [NUM-TICKET]-[short-description]
$ git rebase origin/stage
```

Et nous recommençons ensuite l'étape précédente.

Le code de `stage` peut ainsi être déployé en préproduction pour validation finale et globale.

Une fois le sprint fini ou la release complétée, nous allons finalement merger l'ensemble de la branche `stage` sur `master`.

```bash
$ git checkout master
# Mise à jour de la branche master locale si nécessaire
$ git merge origin/stage
* git push origin master
```

> Ici, nous ne mergons pas la branche stage en `fast-forward` afin d'avoir une lecture simplifiée / rapide, grâce au commit de merge, de la dernière livraison.  
Je vous laisse choisir si vous préférez cela ou non.

Enfin il est possible de tagger la branche `master` et publier notre release.

Une fois notre branche `stage` mergée dans `master`, nous pouvons réinitialiser nos branches `stage` et `dev`.

```bash
$ git checkout stage && git reset --hard origin/master
```

## FAQ

Quelques questions / objections récurrentes reviennent régulièrement quand je présente ce workflow.

### Pourquoi avoir une branche de preproduction / stage ?

C'est certainement le point qui fait le plus débat.

Il serait possible de se passer de la branche `stage` et merger directement nos tickets dans `master`.  
`master` serait ainsi toujours la branche par défaut, le point d'origine de tous les nouveaux développements.

J'apprécie d'avoir une branche `stage` pour les raisons suivantes : 

1. **En cas de bug sur ma branche `stage`** : parceque 2 développements ne sont finalement pas totalement compatibles entre eux ou qu'ils entrainent une régression, il est possible simplement d'ajouter un `hotfix` sur `stage` en s'assurant qu'il ira en prod,
 
1. **En cas de non validation d'un ticket au sein d'une release** :  il est autorisé de ré-écrire l'historique de `stage` (même si cela doit être exceptionnel) sans grosses contraintes de communication avec l'ensembe de l'équipe.  
Alors que la ré-écriture de l'historique de `master` n'est pas autorisée.

Avoir une branche `stage` offre donc une plus grande souplesse dans le workflow.

### Rebase chaque branche de travail avant le merge sur `stage` peut être long et conflictuel

Cela n'est vrai que si vos branches de travail sont longues et trainent dans le temps.  
Éventuellement si vous êtes un très grand nombre de développeurs à travailler sur de nouvelles branches simultanéement.

Il est donc nécessaire que l'équipe applique un minimum de rigeur sur la gestion des points suivants :

1. Rebase régulier des branches de travail depuis `stage` : les principaux conflits sont ainsi résolus directement par le développeur. Il peut s'assurer que son travail n'a pas été impacté.

2. Les branches de travail doivent avoir une durée de vie courte, quelques heures ou jours maximum.  
Au plus les process de tests / non régressions sont automatisés, au plus vous serez en mesure de réduire ce délai.

### Comment faire si une branche de travail dépend d'un autre développement en cours et non disponible sur `stage` ?

C'est une question sans réelle solution que l'on retrouvera dans tous workflows.

En fonction du niveau de dépendance, 2 cas peuvent s'appliquer :

1. **Je ne dépend que d'un commit présent dans une autre branche** : dans ce cas, je préconise de `cherry-pick` le commit dans la branche. On garde ainsi nos branches indépendantes.

2. **Ma nouvelle feature vient compléter une autre branche** : dans ce cas, ma suggestion est d'avoir une branche commune qui regroupera les 2 développements au moment du merge dans `stage`.

Notre nouvelle branche pourra donc, selon un choix à discuter avec les équipes,
  * soit partir de la branche du ticket dont je dépend et être rebase régulièrement avec les nouveaux développements de cette branche,
  * soit travailler directement sur la même branche.

**Alors qu'en pensez-vous ? A vous maintenant de réagir et partager vos propres workflows**.

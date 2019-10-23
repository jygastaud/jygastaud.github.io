+++
title = "Gitlab CI, After Script et Merge Request"
date = 2019-10-23T09:52:49+02:00
Description = "Poster un commentaire dans une Merge Request branchée à Gitlab CI pour visualiser le retour de vos scripts"
Tags = ["Git", "Gitlab", "Gitlab CI", "Merge Request", "after_script"]
Categories = ["DevOps"]
+++

Gitlab CI propose de nombreuses intégrations lorsque vous lancez vos tests (junit par exemple).

En complément, ou parfois à défaut d'avoir accès à la version entreprise de Gitlab, il peut être utile de voir le résultat d'une commande ou d'un export en commentaire de votre Merge Request.

Pour réaliser cela nous allons utiliser les options suivantes : 

* les variables d'environnement prédéfinies dans Gitlab CI
* l'option `only:merge_requests` de Gitlab CI
* la fonction `after_script` de Gitlab CI
* l'API Gitlab pour les Merge Request
* un jeton (token) Gitlab à générer en amont
* curl
* [JQ](https://stedolan.github.io/jq/manual/)


Avec ce process, nous pourrons ainsi avoir un retour dans notre Merge Request

{{< imgproc "images/gitlab-post-comment-on-merge-request.png" Fit "1200x1200" "" />}}


## Le script final


```
post:comment:on:merge-request:
  variables:
    FILE_EXPORT_PATH: "text-export.txt"
  before_script:
    - apk --no-cache add curl jq
  script:
    - echo "An awesome text to report" > text-export.txt
  after_script:
    - |
      if [ -f "text-export.txt" ]
      then
        printf "${CI_JOB_NAME} \n<pre>$(cat text-export.txt)\n</pre>\n" | \
        jq -R -c -s '{"body":.}' - | \
        curl -X POST "${CI_API_V4_URL}/projects/${CI_MERGE_REQUEST_PROJECT_ID}/merge_requests/${CI_MERGE_REQUEST_IID}/notes" \
          --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" \
          --header "Content-Type: application/json" \
          --data @-;
      fi
  only:
    refs:
      - merge_requests
```

## Details

### Préparation

Tout d'abord, nous devons nous assurer que notre image de base, une Alpine dans notre exemple, contient les outils `curl` et `jq`.

```yaml
before_script:
    - apk --no-cache add curl jq
```

### Le script

Au niveau de notre script, nous allons exporter la sortie dans un fichier qui sera ensuite exploité dans l'`after_script`

```yaml
script:
    - echo "An awesome text to report" > ${FILE_EXPORT_PATH}
```

Nous allons nous assurer que le job n'est exécuté que lors d'une Merge Request, ce qui nous garantira d'avoir accès aux bonnes variables d'environnement.

```yaml
only:
  refs:
    - merge_requests
```

### After script

Enfin, notre `after_script`.

`printf` est utilisé ici pour aider à la mise en forme de notre texte, supprimer d'éventuelles contraintes de formatage...

On utilise la variable `CI_JOB_NAME` pour pouvoir directement voir dans le commentaire quel job à renvoyer l'information.

```
printf "${CI_JOB_NAME} \n<pre>$(cat text-export.txt)\n</pre>\n" | \
```

`jq` arrive ensuite pour formater le contenu avant sa transmission à l'API Gitlab.

```
jq -R -c -s '{"body":.}' - | \
```

Enfin, l'envoi à l'API Gitlab en utilisant les variables suivantes `CI_API_V4_URL`, `CI_MERGE_REQUEST_PROJECT_ID`, `CI_MERGE_REQUEST_IID`, `GITLAB_PRIVATE_TOKEN`.

La variable `GITLAB_PRIVATE_TOKEN` est la seule qui n'est pas "nativement" disponible. Il vous faudra la générer avec l'utilisateur qui postera le commentaire et la renseigner dans les variables CI/CD de votre projet.

```
curl -X POST "${CI_API_V4_URL}/projects/${CI_MERGE_REQUEST_PROJECT_ID}/merge_requests/${CI_MERGE_REQUEST_IID}/notes" \
    --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" \
    --header "Content-Type: application/json" \
    --data @-;
```

## Quelques cas d'usage possibles

* Terraform plan
* Fuite de mots de passe / clés 
* Retours tests d'intrusions
* Retours de tests de performance
* ...

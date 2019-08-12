+++
title = "Test de Ansible Molecule"
type = "article"
date = "2019-08-10"
description = "Découverte et implémentation de Molecule sur un rôle Ansible"
Categories = ["DevOps"]
Tags = ["Ansible", "Molecule", "testinfra"]
+++

Pour l'un de nos clients chez [Clever Age](https://www.clever-age.com), nous avons appuyer une grosse partie de notre provisioning de l'ensemble de nos environnements avec Ansible et nous utilisons un grand nombre de rôles créés par l'excellant [Geerlingguy](https://github.com/geerlingguy).

L'un de ces rôles est le [rôle Ansible PHP](https://github.com/geerlingguy/ansible-role-php).

Le rôle permet de confier à Ansible la gestion du fichier du pool php-fpm.

Malheureusement, il n'est pas possible de modifier certaines variables du fichier d'origine ou d'ajouter de nouvelles lignes simplement.



## Objectifs

Nous voulons donc créer un nouveau rôle qui dépendra du rôle `geerlingguy.php` et viendra gérer de nouvelles variables, notamment&nbsp;:

* `pm` pour pouvoir passer de `dynamic` à `static`
* `pm.max_requests`



## Le projet

_Point de départ&nbsp;: [Documentation de Molecule](https://molecule.readthedocs.io/en/stable/)_



### Préparation

* Installation de molecule

``` bash
pip install --user molecule
```



### Implémentation

Molecule permet de générer directement un nouveau rôle Ansible avec une préconfiguration des tests.
Nous allons utiliser cette fonctionnalité pour créer notre rôle.



#### Générer un nouveau rôle Ansible avec Molecule

```bash
molecule init role --role-name newrole.php --verifier-name testinfra --driver-name docker
```

On définit ici le nom du rôle, l'outil de tests qui nous servira à vérifier le résultat du provisioning, `verifier`, et le pilote, `driver`, qui va exécuter recevoir l'éxécution des tests.

_A noter : on définit ici testinfra et docker pour l'exemple, néanmoins ce sont les valeurs par défaut._

Une fois le rôle généré, vous obtenez la structure d'un rôle classique et un ensemble de dossiers et fichiers spécifique à Molecule&nbsp;: 

```
.
├── defaults
│   └── main.yml
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── molecule
│   └── default
│       ├── Dockerfile.j2
│       ├── INSTALL.rst
│       ├── molecule.yml
│       ├── playbook.yml
│       └── tests
│           └── test_default.py
├── README.md
├── tasks
│   └── main.yml
└── vars
    └── main.yml
```

En regardant le fichier `Install.rst`, on se rend compte que pour faire fonctionner molecule avec Docker il faut ajouter un sous-module à notre système&nbsp;:

```bash
pip install 'molecule[docker]'
```

Si vous suivez une approche TDD, il est maintenant temps d'aller modifier les fichiers `molecule.yaml` et `playbook.yaml` pour y ajouter les éléments à provisionner.



#### Définir son playbook de tests



L'objectif du playbook est de tester le rôle courant et ses éventuels dépendances.



On va donc définir un playbook, dans le fichier `playbook.yaml`, avec nos variables et les rôles à appliquer

```yaml
---
- name: Converge
  hosts: all
  become: yes

  vars:
    php_enable_webserver: false
    php_enable_php_fpm: true
    php_install_recommends: false
    php_fpm_pm_max_requests: 1000
    php_fpm_pm_type: "static"

  pre_tasks:
    - name: Update apt cache.
      apt: update_cache=true cache_valid_time=3600
      when: ansible_os_family == 'Debian'
      changed_when: false

  roles:
    - role: geerlingguy.php
    - role: newrole.php

```



Dans notre cas, on va tester l'installation du rôle `geerlingguy.php` suivi de notre nouveau role `newrole.php` et passer les 2 variables que l'on souhaite vérifier par la suite : 

* `php_fpm_pm_max_requests: 1000`
* `php_fpm_pm_type: "static"`



#### Écrire des tests avec testinfra



Avant de lancer les tests, on va écrire un petit test avec `testinfra`, un module Pyhton pour tester ses configurations.



Dans le fichier `newrole.php/molecule/default/tests/test_default.py`, nous allons ajouter une nouvelle fonction

```python
import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

def test_php_pool_file(host):
    f = host.file('/etc/php/7.0/fpm/pool.d/www.conf')

    # Check if www.conf file exists
    assert f.exists

    c = f.content

    # Check if our 2 variables exists with the right values
    assert b'pm = static' in c
    assert b'pm.max_requests = 1000' in c

```



#### Lancer les tests

La commande `molecule test` va lancer l'ensemble des étapes de tests (création, lint, provision, tests...).

Si l'on veut uniquement le provisioning, il est possible de lancer uniquement la commande `molecule converge`.

Si l'on veut tester manuellement le résultat du provisioning, `molecule verify` sera à lancer.



### Les comandes essentielles

* `molecule test` permet de lancer toutes les étapes
* `molecule converge` permet de lancer le provisioning
* `molecule verify` permet de lancer uniquement les tests
* `molecule login` permet de se connecter dans le conteneur
* `molecule destroy` pour supprimer le conteneur



## Résumé

Les objectifs atteints :

* [x] Un nouveau rôle Ansible qui permet de surcharger les variables du fichier pool de fpm
* [x] Apprentissage des commandes principales de `molecule`
* [x] Découverte de `testinfra`
* [x] Un test, minimalistes, pour vérifier si les valeurs sont bien disponibles dans le fichier avec `testinfra`



## Conclusion



Molecule permet de tester simplement dans divers contextes ses rôles Ansible.
Sans garantir à 100% l'intégrité du résultat lors de l'application sur un autre environnement, il permet d'avoir un niveau de confiance bien plus élevé et de simplifier les tests de non régressions.





## Prochaines étapes



* Généraliser l'utilisation de molecule sur tous les nouveaux développements de rôle
* Ajouter des tests sur les rôles existants
* Creuser les options disponibles pour lancer des tests en mode matrice
* Tester le provisioning d'un ensemble plus conséquent de rôles avec Molecule
* Tester le framework de test `goss` en complément / remplacement de `testinfra`







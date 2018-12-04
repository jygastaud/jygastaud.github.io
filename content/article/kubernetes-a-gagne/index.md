+++
title = "Kubernetes a gagné la bataille des orchestrateurs"
date = "2018-07-05"
Description = "Vous vous posez encore la question sur quel orchestrateur choisir pour votre projet ? Ne cherchez plus, Kubernetes a gagné cette bataille."
Tags = ["Cloud", "Container", "Orchestrateurs", "Kubernetes", "Docker"]
Categories = ["Cloud"]
aliases = []
head_js = []
head_css = []
canonical = "https://blog.clever-age.com/fr/2018/07/10/kubernetes-a-gagne-la-bataille-des-orchestrateurs/"
+++

L'arrivée il y a quelques années de solutions permettant de simplifier la création et gestion de conteneurs, telles que [Docker](https://www.docker.com/) ou [rkt](https://coreos.com/rkt/), combinées aux approches micro-services et leurs popularités croissantes ont entraîné rapidement le besoin de solutions dites d'`orchestration de conteneurs`.

De nombreuses solutions d'orchestration ont vu le jour et se sont retrouvées disponibles en Open-Source.  
[Apache Mesos Marathon](https://mesosphere.github.io/marathon/), [Docker Swarm](https://docs.docker.com/swarm/overview/), [Kubernetes](https://kubernetes.io/) ou encore [OpenStack Magnum](https://docs.openstack.org/magnum/latest/) permettent toutes de traiter ces problématiques.

Il y a encore 2 ou 3 ans, les communautés Mesos et Docker avait fait de gros efforts pour rendre Mesos capable d'orchestrer des Docker.

Pourtant, cela n'empêcha pas Docker inc. de lancer sa propre solution, Docker Swarm, pour traiter ces aspects. Avec une volonté affichée d'être une solution d'orchestration plus intégrée à Docker, plus simple à mettre en place tout en  assumant une gestion moines "fines" des ressources que Mesos.

Chacun a sa place, pour son besoin. Pas de vraie compétition entre les 2.

Mesos (via Marathon) semblait avoir pris de l'avance sur ces concurrents. En milieu d'année 2017, une bascule a commencé à se produire vers Kubernetes, utilisé chez Google depuis plus de 10 ans.

Alors pourquoi peut-on penser aujourd'hui que Kubernetes a gagné cette bataille et devient, un peu au même titre que Docker pour les conteneurs, le standard de l'industrie ?


## Des signes qui ne trompent pas

### Une croissance très rapide

* Kubernetes est actuellement le projet le plus actif sur Github.
* Les plateformes comme OpenShift ou CoreOS intègrent Kubernetes.
* Le [CNCF (Cloud Native Computing Foundation)](https://www.cncf.io/) en a fait le 1er projet `Graduated`, son rang le plus haut.
* L’écosystème autours de Kubernetes s'étoffe très vite pour plus d'intégrations autours des systèmes, du monitoring, la sécurité, le déploiement continue...

{{< imgproc "images/CloudNativeLandscape_latest.png" Fit "1200x1200" "https://raw.githubusercontent.com/cncf/landscape/master/landscape/CloudNativeLandscape_latest.png" />}}

### Le Cloud public l'a adopté

Toutes les principales plateformes Cloud proposent Kubernetes en tant services :

* Google Cloud Platform avec GKE (Google Kubernetes Engine)
* Amazon Web Services avec EKS (Amazon Elastic Container Service for Kubernetes)
* Azure avec AKS (Azure Kubernetes Service)
* Digital Ocean propose une beta privée

### Docker (for mac) intègre nativement Kubernetes

Docker a annoncé l'année dernière intégrée directement Kubernetes dans son application Docker for mac et propose maintenant le choix entre Swarm et Kubernetes.


## Conclusion

Faut-il donc oublier vraiment toutes les autres solutions et ne faire plus que Kubernetes ?

Pour des problématiques d'orchestration combinant des applications non conteneurisées et/ou des conteneurs, alors une solution comme Mesos pourra vous être d'une grande aide.

Pour des problématiques d'orchestration dédiés uniquement aux conteneurs, **sur une petite volumétrie de serveurs et conteneurs**, une solution comme Docker Swarm sera certainement un bon tremplin, plus abordable.

Enfin, si vous avez besoin d'une solution **fiable, robuste, scalable et pérenne**, alors la balance tend clairement vers Kubernetes.

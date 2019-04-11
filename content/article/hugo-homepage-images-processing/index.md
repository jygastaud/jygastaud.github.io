+++
title = "GoHugo - Générer des déclinaisons d'images utilisables en page d'accueil"
Description = "Générer automatiquement des déclinaisons d'images responsives et utilisables en page d'accueil"
Tags = ["Développement", "gohugo", "responsive images"]
Categories = ["Développement"]
image = ""
aliases = []
date = 2019-04-11T16:51:22+02:00
lastmod = 2019-04-11T16:51:22+02:00
+++

GoHugo, depuis la version 0.32, est capable de gérer des [ressources dédiées à une page](https://gohugo.io/about/new-in-032/#page-resources)
ainsi que de générer des [déclinaisons d'images](https://gohugo.io/about/new-in-032/#image-processing).

Cette fonctionnalité est notamment très pratique pour gérer automatiquement des déclinaisons responsives de ces images et les utiliser dans un template ou shortcode.

Cela fonctionne parfaitement lorsque l'on est dans un contenu.

## Alors c'est quoi le soucis ?

Admettons que nous voulions utiliser des images responsives sur la page d'accueil de notre site.

* La page d'accueil ne fait pas parti d'une section ou d'un bundle et n'a donc pas accès à des ressources
* Les fichiers mis dans le répertoire `static` ne sont pas traités comme des ressources par Hugo

Il sera donc nécessaire de gérer "à la main", la déclinaison de ces images et les inclure manuellement dans notre template.

Pour simplifier, nous avons donc l'aborescence suivante : 

```
.
| content
| | _index.md
| layouts
| | index.html
```


## Quoi ? Mais j'ai trop d'images à décliner et le contenu change souvent ?! 

Pour arriver à automatiser le processus de génération, nous allons utiliser introduit en version 0.35 : les [Headless Bundles](https://gohugo.io/news/0.35-relnotes/).

Ce nouveau type de bundle permet de gérer du contenu qui ne produira pas une page à part entière lors du rendu fait par Hugo.

Il est donc pratique de s'en servir pour gérer des blocs, messages... qui sont ensuite injecter dans les pages.

En s'appuyant donc sur ce type de bundle et en le combinant avec la fonctionnalité de génération d'images, nous allons pouvoir obtenir automatiquement nos diverses déclinaisons d'images.

Nous allons suivre les quesques étapes suivantes.

### Création d'un nouveau bundle `headless-img`

On aura donc maintenant l'arborescence de contenus suivante : 

```
.
| content
| | _index.md
| | headless-img
| | | images
| | | | mon_image.png
| | | index.md
```

Le fichier `headless-img/index.md` contiendra 

```markdown
+++
headless = true
title = "homepage images"
+++

{{</* imghp src="images/mon_image.png" alt="A nice image for our homepage" */>}}
```

Nous avons donc créer ici une ressource `headless` qui va appeler un shortcode hugo nommé `imghp` et qui prend en paramètres un chemin et un texte alternatif.

### Création du shortcode

Dans l'aborescence `layouts/shortcodes` nous allons créer un nouveau fichier nommé `imghp.html` qui contiendra la logique de génération de nos images et leur rendu.

```golang
{{ /* Le shortcode pour les images responsives de la HP */ }}

{{/* get file that matches the filename as specified as src="" in shortcode */}}
{{ $src := (.Site.GetPage "/headless-img").Resources.GetMatch (printf "*%s*" (.Get "src")) }}

{{/* set image sizes, these are hardcoded for now, x dictates that images are resized to this width */}}

{{ $tinyw := default "500x" }}
{{ $smallw := default "800x" }}
{{ $mediumw := default "1200x" }}
{{ $largew := default "1500x" }}

{{/* resize the src image to the given sizes */}}

{{ .Scratch.Set "tiny" ($src.Resize $tinyw) }}
{{ .Scratch.Set "small" ($src.Resize $smallw) }}
{{ .Scratch.Set "medium" ($src.Resize $mediumw) }}
{{ .Scratch.Set "large" ($src.Resize $largew) }}

{{/* add the processed images to the scratch */}}

{{ $tiny := .Scratch.Get "tiny" }}
{{ $small := .Scratch.Get "small" }}
{{ $medium := .Scratch.Get "medium" }}
{{ $large := .Scratch.Get "large" }}

{{/* only use images smaller than or equal to the src (original) image size, as Hugo will upscale small images */}}
{{/* set the sizes attribute to (min-width: 35em) 1200px, 100vw unless overridden in shortcode */}}

<img 
{{ with .Get "sizes" }}sizes='{{.}}'{{ else }}sizes="(min-width: 35em) 1200px, 100vw"{{ end }}
srcset='
{{ if ge $src.Width "500" }}
    {{ with $tiny.RelPermalink }}{{.}} 500w{{ end }}
{{ end }}
{{ if ge $src.Width "800" }}
    {{ with $small.RelPermalink }}, {{.}} 800w{{ end }}
{{ end }}
{{ if ge $src.Width "1200" }}
    {{ with $medium.RelPermalink }}, {{.}} 1200w{{ end }}
{{ end }}
{{ if ge $src.Width "1500" }}
    {{ with $large.RelPermalink }}, {{.}} 1500w {{ end }}
{{ end }}'
{{ if .Get $medium }}
    src="{{ $medium.RelPermalink }}" 
{{ else }}
    src="{{ $src.RelPermalink }}" 
{{ end }}
{{ with .Get "alt" }}alt='{{.}}'{{ end }}>
```

Ce template peut être retrouvé sur de nombreux sites comme exemple.

La principale différence avec les autres se situe dans cette ligne :  
`{{ $src := (.Site.GetPage "/headless-img").Resources.GetMatch (printf "*%s*" (.Get "src")) }}`  
qui nous permet de récupérer les ressources du bundle `headless-img`.

Lorsque ce shortcode est exécuté, il va donc chercher l'image définie dans le fichier `headless-img/index.md` et génère automatiquement les déclinaisons.

### Et maintenant, j'affiche ça comment sur ma page d'accueil ?

Il ne nous reste plus qu'à appeler notre bundle dans notre template `index.html`.


#### Si vous n'avez qu'un uniquement 1 seul contenu index.md

```
{{ define "content" }}
  {{ /* Le rendu de la section headless. Assume */ }}
  {{ $headless := .Site.GetPage "/headless-img" }}
  {{ $headless.Content }}
{{ end }}
```

#### Si vous devez rendre plusieurs fichiers .md en se basant sur un nom. `img1`, `img2`... par l'exemple

```
{{ define "content" }}
  {{ $headless := .Site.GetPage "/headless-img" }}
  {{ $reusablePages := $headless.Resources.Match "img*" }}
  {{ range $reusablePages }}
    {{ .Content }}
  {{ end }}
{{ end }}
```

Et voilà, maintenant vos images sont bien rendues sur votre page d'accueil et leurs versions responsives sont également disponibles.

+++
title = "GoHugo - Generate alternative images that can be used in the homepage"
Description = "Automatically generate responsive and usable alternative images on the homepage"
Tags = ["gohugo", "responsive images", "hugo"]
Categories = ["Jamstack"]
canonical = "https://dev.to/jygastaud/gohugo-generate-image-declinations-that-can-be-used-as-a-home-page-530j"
date = 2019-04-11T16:51:22+02:00
lastmod = 2019-04-11T16:51:22+02:00
+++

Translate from French on [dev.to](https://dev.to/jygastaud/gohugo-generate-image-declinations-that-can-be-used-as-a-home-page-530j) and backport here.


GoHugo, since version 0.32, is able to manage [dedicated one-page resources](https://gohugo.io/about/new-in-032/#page-resources)
as well as to generate [image declinations](https://gohugo.io/about/new-in-032/#image-processing).

This feature is particularly useful for automatically managing responsible declinations of these images and using them in a template or shortcode.

It works perfectly when you are in a content.

## So what's the problem?

Let's assume that we want to use responsible images on the homepage of our site.

* The home page is not part of a section or bundle and therefore does not have access to resources
* Files placed in the `static` directory are not treated as resources by Hugo

It will therefore be necessary to manage "by hand", the declination of these images and include them manually in our template.

To simplify, we have the following aborescence: 

```
.
| content
| | | _index.md
| layouts
| | | index.html
```


## What? But I have too many images to decline and the content changes often?! 

To automate the generation process, we will use the [Headless Bundles](https://gohugo.io/news/0.35-relnotes/) introduced in version 0.35.

This new type of bundle allows you to manage content that will not produce a full page when rendered by Hugo.

It is therefore convenient to use it to manage blocks, messages... which are then injected into the pages.

By using this type of bundle and combining it with the image generation functionality, we will be able to automatically obtain our various image declinations.

We will follow the following steps.

#### Creating a new bundle `headless-img`

We will now have the following content tree structure: 

```
.
| content
| | | _index.md
| | | headless-img
| | | | | images
| | | | | | my_image.png
| | | | index.md
```

The file `headless-img/index.md` will contain 

```markdown
+++
headless = true
title = "homepage images"
+++

{{</* imghp src="images/mon_image.png" alt="A nice image for our homepage" */>}}
```

So we have created here a `headless` resource that will call a hugo shortcode named `imghp` and that takes a path and an alternative text as parameters.

#### Creating the shortcode

In the `layouts/shortcodes` aborescence we will create a new file named `imghp.html` which will contain the logic of generating our images and their rendering.

```golang
{{ /* The shortcode for HP's responsive images */ }}

{{/* get file that matches the filename as specified as src=""" in shortcode */}}
{{ $src := (.Site.GetPage "/headless-img").Resources.GetMatch (printf "*%s**" (.Get "src") }}}

{{/* set image sizes, these are hardcoded for now, x dictates that images are resized to this width */}}

{{ $tinyw := default "500x" }}}
{{ $smallw := default "800x" }}}
{{ $mediumw := default "1200x" }}}
{{ $largew := default "1500x" }}}

{{/* resize the src image to the given sizes */}}

{{{.Scratch.Set "tiny" ($src.Resize $tinyw) }}
{{{.Scratch.Set "small" ($src.Resize $smallw) }}
{{{.Scratch.Set "medium" ($src.Resize $mediumw) }}
{{{.Scratch.Set "large" ($src.Resize $largew) }}

{{/* add the processed images to the scratch */}}

{{$tiny :=.Scratch.Get "tiny" }}
{{ $small :=.Scratch.Get "small" }}
{{ $medium :=.Scratch.Get "medium" }}
{{$large :=.Scratch.Get "wide" }}

{{/* only use images smaller than or equal to the src (original) image size, as Hugo will upscale small images */}}
{{/* set the sizes attribute to (min-width: 35em) 1200px, 100vw unless overridden in shortcode */}}

<img 
{{{with .Get "sizes" }}sizes='{{.}}'{{ else }}sizes="(min-width: 35em) 1200px, 100vw"{{end }}
srcset=''
{{if ge $src.Width "500" }}}
    {{ with $tiny.RelPermalink }}{{{.}} 500w{{{end }}
{{end }}
{{if ge $src.Width "800" }}}
    {{ with $small.RelPermalink }}, {{.}} 800w{{{{end }}
{{end }}
{{if ge $src.Width "1200" }}}
    {{ with $medium.RelPermalink }}, {{.}} 1200w{{{end }}
{{end }}
{{if ge $src.Width "1500" }}}
    {{with $large.RelPermalink }}, {{.}} 1500w {{{end }}
{{end }}''.
{{if.Get $medium }}}
    src="{{$medium.RelPermalink }}" 
{{ else }}}
    src="{{$src.RelPermalink }}}" 
{{end }}
{{{with.Get "alt" }}alt='{{.}}'{{{end }}>>
```

This template can be found on many sites as an example.

The main difference with the others is in this line:  
`{{{$src := (.Site.GetPage "/headless-img").Resources.GetMatch (printf "*%s*") (.Get "src") }}}`  
which allows us to retrieve the resources of the `headless-img` bundle.

When this shortcode is executed, it will look for the image defined in the `headless-img/index.md` file and automatically generate the declinations.

#### And now, how do I display this on my homepage?

All we have to do now is call our bundle in our template `index.html`.


##### If you have only one single index.md index content

```golang
{{define "content" }}
  {{ /* The rendering of the headless section. Assume */ }}
  {{$headless :=.Site.GetPage "/headless-img" }}
  {{{$headless.Content }}
{{end }}
```

##### If you need to render multiple.md files based on a name. `img1`, `img2`... by example

```golang
{{define "content" }}
  {{$headless :=.Site.GetPage "/headless-img" }}
  {{ $reusablePages:= $headless.Resources.Match "img*" }}
  {{range $reusablePages }}
    {{{.Content }}}
  {{end }}
{{end }}
```

And that's it, now your images are well rendered on your homepage and their responsive versions are also available.

Translated with www.DeepL.com/Translator
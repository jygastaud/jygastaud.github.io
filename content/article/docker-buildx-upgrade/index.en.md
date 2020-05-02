+++
title = "Upgrade Buildx in Docker CLI"
Description = "How to get the last version of buildx in Docker"
Categories = ["DevOps", "Docker"]
Tags = ["Docker", "Buildx", "Tips", "ubuntu"]
image = "docker-logo.png"
aliases = []
date = 2020-05-02T14:29:42+02:00
lastmod = 2020-05-02T14:29:42+02:00
+++


Docker CLI, since version 19.03 includes the [buildx](https://github.com/docker/buildx) plugin to extend the build functions of Docker based on [Buildkit](https://github.com/moby/buildkit).

Among the main points that Buildkit brings are the following:

* parallel resolution of dependencies
* better cache management (import/export, resolution)
* ability to distribute workloads
* run without root privileges

And so, as mentioned above, buildkit is now included in docker CLI.
Problem, the available and pre-packaged version is not up to date with the latest developments.

If you want to take advantage of the latest evolutions,
you will need to update.

{{% notice info "buildx version" %}}
This tutorial uses buildx version **0.4.1**.  
Remember to check the latest version number before copying and pasting the instructions.
{{% /notice %}}

## The steps

Check the existence of the `~/.docker/cli-plugins` directory.
If it doesn't exist, create the

```bash
mkdir ~/.docker/cli-plugins
```

Download the latest buildx version from the [Buildx release page on Github](https://github.com/docker/buildx/releases) or directly from your terminal.

```bash
wget -O ~/.docker/cli-plugins/docker-buildx https://github.com/docker/buildx/releases/download/v0.4.1/buildx-v0.4.1.linux-amd64
```

Set execution rights on the binary: `chmod +x ~/.docker/cli-plugins/docker-buildx`.

and voila!

We just have to check if the buildx version is now the expected one.

```bash
docker buildx version
```

If you want buildx to become the default builder of Docker CLI

```bash
docker builx install
```

## Demo

[![asciicast](https://asciinema.org/a/aWtsg3uCTb2wbEeZHh79c2ntS.svg)](https://asciinema.org/a/aWtsg3uCTb2wbEeZHh79c2ntS)

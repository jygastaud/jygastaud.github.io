+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "2019-12-17 06:40:28"
title = "Docker Tips: All About the Build Context"
link = "https://medium.com/better-programming/docker-tips-about-the-build-context-dbc76505e178"
+++
The build context is the set of files located at the specified PATH or URL. Those files are sent to the Docker daemon during the build so it can use them in the filesystem of the image. Let’s illustrate this.
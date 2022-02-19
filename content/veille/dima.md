+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "2022-02-19 06:56:01"
title = "dima"
link = "https://dev.doroshev.com/"
+++
TL;DR The contents of directories mounted with --mount=type=cache are not stored in the docker image, so it makes sense to cache intermediate directories, rather than target ones. In dockerfile:1.
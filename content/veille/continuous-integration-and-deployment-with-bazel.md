+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "2019-12-13 21:34:11"
title = "Continuous integration and deployment with Bazel"
link = "https://blogs.dropbox.com/tech/2019/12/continuous-integration-and-deployment-with-bazel/"
+++
Dropbox server-side software lives in a large monorepo. One lesson we’ve learned scaling the monorepo is to minimize the number of global operations that operate on the repository as a whole. Years ago, it was reasonable to run our entire test corpus on every commit to the repository.
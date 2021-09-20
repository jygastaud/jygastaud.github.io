+++
title = "Sorting tags from a Git repo using semantic versioning"
Description = "How to correctly sort the tags of a repository based on semantic versioning?"
Tags = ["Git", "Tips"]
Categories = ["DevOps"]

date = 2021-09-20T23:10:00+02:00

lastmod = 2021-09-20T23:10:00+02:00

+++

A quick post today to tell you about a recent discovery in Git's sorting functions and tags based on [semantic versioning](https://semver.org/).

<!--more-->

By default, if you run the `git tag -l` command, Git will do an alphabetical sort.

However, this sorting gives confusing results when the tags use semantic versioning notation.

```bash
git tag -l
v2.6.1
v2.6.10
v2.6.11
v2.6.12
v2.6.2
v2.6.3
v2.6.4
v2.6.5
v2.6.6
v2.6.7
v2.6.8
v2.6.9
v2.7.0
```

Notice here the sequence `v2.6.10`, `v2.6.11` and `v2.6.12` which is interposed between version `v2.6.1` and `v2.6.2`.



To solve this problem, it is possible to use the `--sort` function with the `version` attribute in Git.

```bash
git tag --sort=version:refname
```



This will display the sorted results consistently:

```bash
git tag --sort=version:refname
v2.6.1
v2.6.2
v2.6.3
v2.6.4
v2.6.5
v2.6.6
v2.6.7
v2.6.8
v2.6.9
v2.6.10
v2.6.11
v2.6.12
v2.7.0
```


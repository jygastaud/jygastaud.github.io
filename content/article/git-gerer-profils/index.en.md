+++
title  = "Manage distinct profiles in Git"
Description = "How to simplify the management of identities associated with our Git commits and avoid configuration mistakes?"
Tags = ["Git", "Tips", "Profile", "Configuration", "IncludeIf", "Includes Conditionnels"]
Categories = ["DevOps"]
canonical = "https://dev.to/jygastaud/manage-distinct-profiles-in-git-1b56"
date = 2019-04-02T00:02:55+01:00
lastmod = 2019-04-02T00:02:55+01:00
+++

Translate from French on [dev.to](https://dev.to/jygastaud/manage-distinct-profiles-in-git-1b56) and backport here.

You use your computer to work and, more than ever, you probably use Git (what would you do on this article if not?).  
Perhaps you also work on a personal project on the same computer?  
Or to contribute to an Open-Source project, always on the same machine.

You have probably defined a global identity (name + email) for your machine and overloaded it for each project according to the context.

Perfect! Perfect!

And yet despite these usual precautions, who has never commited in a project with a wrong identity?
Sometimes you may find this out late and your personal email is now *ad vitam æternam* in the project logs.

So how can we try to limit the risk of errors?

Could we automate the selection of the right identity for our projects?

Well, the good news is that **the answer is YES** and we'll see how right after that.

## .gitconfig and conditional includes thanks to IncludeIf

Let's take the file `.gitconfig`, usually present in your `$HOME`.

```
[user]
	name = Jean-Yves Gastaud
	email = mon.super@mail.com

[alias]
  amend = commit --amend
  st = status
  co = checkout
```

This file defines our default identity and global aliases.

Thanks to the use of the `includeIf`[^1] directive in our `.gitconfig` file, we can now add conditional includes linked, especially to directories.

```
[includeIf "gitdir:/workspace/work/"]
  path = ~/.gitconfig-work

[includeIf "gitdir:/workspace/opensource/"]
  path = ~/.gitconfig-opensource

[includeIf "gitdir:/workspace/perso/"]
  path = ~/.gitconfig-perso
```

For each defined `includeIf`, all we have to do is create the file corresponding to the path we defined in `path`.

In the `~/.gitconfig-work` file, we only have to add or override the configurations we are interested in.

Example :

```
[user]
        email = my.work@mail.com

[core]
        editor = "code -w"
```

In this file, we overload our email and add a default code editor.

Now, any folder under the `/workspace/work` directory will automatically benefit from loading the configuration of the `.gitconfig` file, overloading or supplementing with those of the `.gitconfig-work` file.

To check your configuration, go to any directory under the target directory, `/workspace/work` in our example and run the command `git config -l`

You should see the merging of your config files.

```
user.name=Jean-Yves Gastaud
email = my.super@mail.com
alias.amend=commit --amend
alias.st=status
alias.co=checkout
includeif.gitdir:/workspace/work/work/.path=~/.gitconfig-work
user.email=my.work@mail.com
core.editor=code -w
includeif.gitdir:/workspace/opensource/.path=~/.gitconfig-opensource
includeif.gitdir:/workspace/perso/.path=~/.gitconfig-perso
core.repositoryformatversion=0
core.filemode=true
…
```

As you can see, the 2 defined emails are present in the listing.  
The last "speaking" being right, it is therefore the value of the file `.gitconfig-work` which will be considered during the commit.

You will also notice that the other 2 include are listed but do not add new variables / overloads because their application condition is not met.

This always gives us the possibility to overload, locally at the repository, all desired configurations, as before.

**In a few lines and a simple management of your working directories, it is therefore possible for you to no longer risk making mistakes in changing your identities.**

[^1]: Since Git, version 2.13 (2017, May). [Documentation on Includes in Git] (https://git-scm.com/docs/git-config#_includes)


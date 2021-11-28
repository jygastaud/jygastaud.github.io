+++
title = "Install and configure Renovate Bot on GitLab CE"
Description = """
The documentation for installing and configuring RenovateBot on a GitLab Self Hosted may seem a bit complex.
It's actually not that complicated once you understand the right mechanics.
"""

Tags = ["Git", "GitLab", "DevOps", "CI/CD", "Automation", "Quality check"]
Categories = ["DevOps"]
image = ""
aliases = []
date = 2021-11-27T16:14:35+01:00
lastmod = 2021-11-27T16:14:35+01:00

+++

[Renovate Bot](https://renovatebots.com) is a tool to control the versions of dependencies of your projects.

It can be compared to the [Dependabot](https://github.com/dependabot) project which is available on GitHub.

In this article, we will explore how to install and configure Renovate to run on a Gitlab CE instance.

<!--more-->

## Prerequisites

In order to follow the initialization process you must be able to:

* Create groups and projects
* Have access or install at least 1 GitLab Runner with a docker executor
* Have a GitHub account (even if we are going to use GitLab, it will be used to get the release notes of the projects)



## Initialization

### Project structure

* Create a `Renovate` project group
* Create 2 projects in the group
  * a `renovate-config` project which will contain configuration files that can be shared with all GitLab projects;
  * a `renovate-runner` project which will contain the configurations to dedicate to the Renovate container.



### Gitab user

As the name of the project indicates (Renovate**Bot**) we will have to create a user account representing our Bot.

For our example, we will call it `Renovate Bot <renovatebot@example.com>` and the username `renovatebot`.

This user will be used for 2 things: 

1. merge requests, commits... will be created by the Bot ;
2. restrict renovate's rights to browse only those projects on which it is explicitly invited.



## Renovate-runner project configuration

We will start by working on the runner part. Let's go to the `renovate-runner` project we created earlier.



### Creation of user tokens (PAT : Personal Access Token)

#### GitLab

On your GitLab instance, log in with the `renovatebot` account created earlier.

We'll create an Access Token via your user profile (/-/profile/personal_access_tokens).

Name the token whatever you like (`renovatebot` for example) and choose the following scopes as [indicated in the documentation](https://docs.renovatebot.com/getting-started/running/#gitlab):

* `read_user`,
* `api`,
* `write_repository`.



Copy the token and go back to the `renovate-runner` project, in the CI/CD Settings (menu `Settings` > `CI/CD` > `Variables`)

and create a new variable named `RENOVATE_TOKEN` with the retrieved token value.



#### GitHub

In order to be able to retrieve release notes from projects and not be subject to the limitations of the GitHub API, we will need to create a GitHub and create a [Personal Access Token](https://docs.renovatebot.com/getting-started/running/#githubcom-token-for-release-notes) there. 



Copy the token and go back to the `renovate-runner` project, in the CI/CD Settings (menu `Settings` > `CI/CD` > `Variables`)

and create a new variable named `GITHUB_COM_TOKEN` with the value of the recovered token.



### Our `.gitlab-ci.yml` file



```
image: renovate/renovate:29	

variables:
  RENOVATE_BASE_DIR: $CI_PROJECT_DIR/renovate
  RENOVATE_GIT_AUTHOR: Renovate Bot <renovatebot@exemple.com>
  RENOVATE_OPTIMIZE_FOR_DISABLED: 'true'
  RENOVATE_REPOSITORY_CACHE: 'true'
  LOG_LEVEL: debug


cache:
  key: ${CI_COMMIT_REF_SLUG}-renovate
  paths:
    - $CI_PROJECT_DIR/renovate

renovate:
  stage: deploy
  resource_group: production
  only:
    - schedules
  script:
    - renovate $RENOVATE_EXTRA_FLAGS
```

Renovate offers most of these configurations as environment variables.
However, to be able to use the bot in other contexts than GitLab (a manual launch for example), I only kept the GitLab specific parameters in the `.gitlab-ci.yml` file.



The rest of the configurations are in the `config.js` file that we'll look at right now. :arrow_down:



### Renovate configuration file

Renovate is based on a configuration file `config.js`.

It defines the Git platform to use, the [configuration options](https://docs.renovatebot.com/self-hosted-configuration/) of the runner and the [configuration profiles (Config Presets)](https://docs.renovatebot.com/config-presets/) which will be applied for all the projects `onboardingConfig`.



```
module.exports = {
        endpoint: 'https://[url of gitlab]/api/v4/',
        platform: 'gitlab',
        persistRepoData: true,
        logLevel: 'debug',
        onboardingConfig: {
                'extends': [
                        "local>groups/subgroups/renovate/renovate-config"
                ],
        },
        autodiscover: true,
};
```



### Recurring task

* CI/CD menu > Schedules
* Create a new scheduled task with the frequency you want (I made the choice, totally arbitrary, to run the analysis twice a day) and to trigger.
* Save



## Configuration of default configurations

In the `renovate-config` project we will create a simple `renovate.json` file which will be the one searched by default by the `config.json` file and in particular the line `"local>groups/subgroups/renovate/renovate-config"`.



Here are the choices I made: 

```
 {
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "packageRules": [
    {
      "depTypeList": [ "devDependencies", "require-dev" ],
      "updateTypes": [ "patch", "minor", "digest"],
      "groupName": "devDependencies (non-major)"
    }
  ],
  "extends": [
    "config:base",
    ":preserveSemverRanges",
    ":dependencyDashboard",
    ":rebaseStalePrs",
    ":enableVulnerabilityAlertsWithLabel('security')",
    ":group:recommended"
  ]
}
```



* `packageRules` allows to create new groupings. In our case, this allows us to have a single Merge Request containing all the development dependencies of the project when they are not major.

* `Extends` allows us to define the rules/configs presets that we want to activate. In particular, we activate the [Dependency Dashboard](https://docs.renovatebot.com/key-concepts/dashboard/) which allows us to follow in a ticket the status of all available updates and/or current MRs and various [Group Presets](https://docs.renovatebot.com/presets-group/).



## Activate the bot for projects

With these configurations, each project that wants to activate the bot has only 4 steps to follow: 

1. Add the user `renovatebot` on the project, with at least a `contributor` right
2. Enable the `issues` for the `dependency Dashboard`.
3. Enable `merge requests` for first with a 1st Merge Request to create the renovate configuration, then the MRs associated with the updates to apply.
4. Refine the Renovate configurations according to the specificities of your project



And that's it :champagne:

We now have a Renovate bot that runs regularly and will update all the repositories it has access to.

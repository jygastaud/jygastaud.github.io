+++
title = "Azure-cli, activate autocomplete on Zsh"
Description = "Azure-cli, active autocomplete in Zsh on Ubuntu."
Tags = ["Tips", "Azure", "Shell", "zsh", "ubuntu"]
Categories = ["DevOps", "Azure"]
image = ""
aliases = []
date = 2019-11-26T23:35:18+01:00
lastmod = 2019-11-26T23:35:18+01:00
+++

Out of the box, Azure-cli doesn't have autocomplete activated in Zsh and Oh-My-Zsh framework doesn't have plugin available natively.

However, Azure-cli comes with an autocomplete script that should be located in `bash_completion.d` directory.

In my setup, using Ubuntu 18.04, I found the `azure-cli` script in `/etc/bash_completion.d/` directory.

Now we just need to load the autocomplete script inside our `~/.zshrc` with the following line:

```
source /etc/bash_completion.d/azure-cli
```

Save and reload your terminal. Done.

### Additional notes

* If you encounter an error when restarting, you may have to add that line before the script loading to ensure cross compatibility between bash and zsh script 

```
autoload -U +X bashcompinit && bashcompinit
```

* Looking at different blog post, you may find that the script is called `az`, not `azure-cli`.

* According to the directory I found it, the script was natively loaded if I use bash shell. If you use bash and doesn't have autocomplete activate, you probably have to search for `azure-cli` or `az` script and load it to your `~/.bashrc` file.

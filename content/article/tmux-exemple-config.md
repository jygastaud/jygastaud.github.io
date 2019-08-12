+++
Categories = ["DevOps"]
Description = "Fichier de configuration tmux."
Tags = ["Développement", "Projet"]
aliases = []
date = "2016-04-07T13:49:38+02:00"
image = ""
title = "Tmux - Exemple de fichier de configuration"
+++

Exemple de fichier .tmux.conf

```
# Update default binding of `Enter` to also use copy-pipe
unbind -t vi-copy Enter
bind-key -t vi-copy Enter copy-pipe "reattach-to-user-namespace pbcopy"

# Mouse scrolling and selection
set -g mode-mouse on
set -g default-terminal "screen-256color"

# Allows for faster key repetition
set -s escape-time 0

# C-b is not acceptable -- Vim uses it; Set ctrl+a as a prefix
set -g prefix C-a
unbind-key C-b
bind-key a send-prefix

bind-key C-a last-window

# Kill windows and panes faster, by rebinding the confirmation key
bind-key &amp; kill-window
bind-key x kill-pane
bind-key q kill-server

# Renumber windows sequentially after closing any of them
set -g renumber-windows on

# set window and pane index to 1 (0 by default)
set-option -g base-index 1
setw -g pane-base-index 1

# increase scrollback lines
set -g history-limit 10000

# get notification when something happend on a tmux window
setw -g monitor-activity on

# disable auto-rename from tmux
set-window-option -g allow-rename off
```

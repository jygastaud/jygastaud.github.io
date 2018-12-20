+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "2018-12-20 22:25:01"
title = "Advanced command execution in Go with os/exec"
link = "https://blog.kowalczyk.info/article/wOYk/advanced-command-execution-in-go-with-osexec.html"
+++
Go has excellent support for executing external programs. Let’s start at the beginning.  Here’s the simplest way to run ls -lah and capture its combined stdout/stderr.
+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "2018-05-03 06:45:51"
title = "Open-sourcing gVisor, a sandboxed container runtime"
link = "https://cloudplatform.googleblog.com/2018/05/Open-sourcing-gVisor-a-sandboxed-container-runtime.html"
+++
With traditional containers, the kernel imposes some limits on the resources the application can access. These limits are implemented through the use of Linux cgroups and namespaces, but not all resources can be controlled via these mechanisms.
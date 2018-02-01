+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "2018-02-01 10:56:03"
title = "Kestrel vs Gin vs Iris on EC2 nano"
link = "https://dizzy.zone/2018/01/23/Kestrel-vs-Gin-vs-Iris-on-EC2/"
+++
I came across this blog post on ayende.com. Here Oren Eini tries to see how far he could push a simple ipify style of api on an EC2 by running a synthetic benchmark. He hosts the http server on a T2.nano instance and then uses wrk to benchmark it from a T2.small instance.
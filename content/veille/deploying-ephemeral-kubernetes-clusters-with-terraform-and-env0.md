+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "1595967551"
title = "Deploying ephemeral Kubernetes clusters with Terraform and env0"
link = "Deploying ephemeral Kubernetes clusters with Terraform and env0"
+++

env0 is a SaaS that can deploy Terraform plans, track their cost, and automatically shut them down after a given time. I’m going to show how to use it to deploy short-lived Kubernetes clusters and make sure that they get shut down when we don’t use them anymore.
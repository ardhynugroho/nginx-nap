Docker Installation
====

Docker will be used to install NGINX Ingress Controller in the next step.

.. note::
  This already installed for lab. hands-on session. You can skip this step.

Login in *APP* node, change directory to ``setup``::
  
  $ cd /home/ubuntu/setup

Install Script
----

Examine `docker.sh` file below::

  #!/bin/bash
  set -x
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release

  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  
  sudo addgroup ubuntu docker
  sudo su ubuntu

Apply the script to install:: 
  
  $ bash docker.sh

Verify The Installation
----

Run a *NGINX* container::

  $ docker run --name nginx nginx
  Unable to find image 'nginx:latest' locally
  latest: Pulling from library/nginx
  ...
  ...
  [ctl-c]

Show terminated *nginx* container::

  $ docker ps -a
  CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS                      PORTS     NAMES
  f0d3a264afdb   nginx     "/docker-entrypoint.…"   About a minute ago   Exited (0) 59 seconds ago             nginx

In this point, docker is ready.
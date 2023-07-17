Installing Docker
====

Docker will be used to pull docker image from *NGINX Plus* private registry and then push it to a local registry.

.. note::
  This already installed in your lab deployment.

Make sure you're login to *APP* node then change directory to ``setup``::
  
  $ cd /home/ubuntu/setup

.. code-block:: bash
  :linenos:
  
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

Let's execute the script:: 
  
  $ bash docker.sh

At this point, *Docker* should be successfully installed & ready to use.
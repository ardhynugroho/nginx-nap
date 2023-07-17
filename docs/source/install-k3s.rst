Installing Kubernetes Platform
====

This lab uses k3s as kubernetes platform. It come with *traefik* as ingress controller.
In this guide, *traefik* will be replaced with *NGINX Plus Ingress Controller with App. Protect*.

.. note::
  This already available in your lab deployment.

Make sure you're login to *APP* node then change install target hostname to `app`::

  $ sudo bash
  # hostname app

Make it persistent across restart::

  # echo "app" > /etc/hostname

The *K3s* Install Script
----

This script will install *k3s* and remove *traefik ingress controller*::

.. note::
  You can change ``app`` inside the ``while`` *loop* to reflect the actual hostname where k3s installed

::

  #!/bin/bash
  
  curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -s -
  
  # wait until ready
  while true;
  do
      if [ "$(kubectl get nodes app -o=jsonpath='{.status.conditions[3].status}')" == "True" ]; then
        break;
      fi
      sleep 5;
  done
  
  # Based on https://github.com/k3s-io/k3s/issues/1160#issuecomment-1133559423
  # remove k3s default ingress controller
  set -x
  sudo touch /var/lib/rancher/k3s/server/manifests/traefik.yaml.skip
  kubectl -n kube-system delete helmchart traefik traefik-crd
  sleep 10

  sudo systemctl restart k3s
  
  echo "Done"

Execute the install script::

  $ bash k3s.sh

Verify *K3s* Installation
----

After script execution finished, verify the cluster::

  $ kubectl get nodes

Make sure node status is *Ready*::

  NAME   STATUS   ROLES                  AGE   VERSION
  app    Ready    control-plane,master   36h   v1.27.3+k3s1

You also can check if *traefik* service no longer listed::

  $ kubectl get svc -n kube-system
  NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE
  kube-dns         ClusterIP   10.43.0.10      <none>        53/UDP,53/TCP,9153/TCP   41h
  metrics-server   ClusterIP   10.43.141.175   <none>        443/TCP                  41h

At this point, *k3s* is ready.
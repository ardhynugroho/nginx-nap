Kubernetes Cluster Installation
====

K3s will be used in this lab. to run Arcadia app micro-services.
K3s come with *traefik* ingress controller. 
But it will be replaced with *NGINX Plus Ingress Controller* in the next step.

.. note::
  This already installed for lab. hands-on session. You can skip this step.

.. warning::
  Make sure you're login to *APP* node.

Change install target hostname to `app`::

  $ sudo bash
  # hostname app

Make it persistent across restart::

  # echo "app" > /etc/hostname

The K3s Install Script
----

This script will install *k3s* and then remove default *ingress controller*.

The `k3s.sh` script file::

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

Verify *k3s* Installation
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

In this point, *k3s* is ready.
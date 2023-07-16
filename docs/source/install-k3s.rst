K3s Kubernetes Cluster Installation
====

K3s will be used in this lab, to host the test application.
K3s coming with *traefik* ingress controller. 
But it will be replaced with *NGINX Ingress Controller* in the next step.

.. note::
  This already installed for lab. hands-on session. You can skip this step.

In the *APP* node, change install target hostname to `app` & make it persistent across restart::

  $ sudo bash
  # hostname app
  # echo "app" > /etc/hostname

Install Script
----

Examine install script `k3s.sh` below::

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

Verify the cluster::

  $ kubectl get nodes

Make sure node status is *Ready*::

  NAME   STATUS   ROLES                  AGE   VERSION
  app    Ready    control-plane,master   36h   v1.27.3+k3s1

In this point, k3s is ready.
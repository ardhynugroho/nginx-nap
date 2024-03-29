Deploying Local Image Registry
====

A local registry is needed to pull *NGINX Plus Ingress Controller* image from *k3s*.

Make sure Docker already installed.

.. note::
  This already deployed in your lab deployment.

Deployment Manifest
----

Resource defined in the manifest:

Persistent volume & claim
  Required to store downloaded *Docker* images, it needs to be persistent.

The *local-registry* pod
  The pod itself.

Service
  To publish the *local-registry* service.

``/home/ubuntu/setup/local-registry.yaml`` manifest file

.. code-block:: yaml
  :linenos:

  apiVersion: v1
  kind: PersistentVolume
  metadata:
    name: local-registry-pv
  spec:
    capacity:
      storage: 10Gi
    accessModes:
      - ReadWriteOnce
    hostPath:
      path: /tmp/repository
      
  ---
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    name: local-registry-pvc
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: 10Gi
  
  ---
  apiVersion: v1
  kind: Pod
  metadata:
    name: local-registry
    labels:
      app: local-registry
  spec:
    containers:
      - name: local-registry
        image: registry:2.6.2
        volumeMounts:
          - name: repo-vol
            mountPath: "/var/lib/registry"
          - name: certs-vol
            mountPath: "/certs"
            readOnly: true
          - name: auth-vol
            mountPath: "/auth"
            readOnly: true
        env:
          - name: REGISTRY_AUTH
            value: "htpasswd"
          - name: REGISTRY_AUTH_HTPASSWD_REALM
            value: "Registry Realm"
          - name: REGISTRY_AUTH_HTPASSWD_PATH
            value: "/auth/htpasswd"
          - name: REGISTRY_HTTP_TLS_CERTIFICATE
            value: "/certs/tls.crt"
          - name: REGISTRY_HTTP_TLS_KEY
            value: "/certs/tls.key"
    volumes:
      - name: repo-vol
        persistentVolumeClaim:
          claimName: local-registry-pvc
      - name: certs-vol
        secret:
          secretName: local-registry-tls
      - name: auth-vol
        secret:
          secretName: local-registry-auth
  
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: local-registry
  spec:
    selector:
      app: local-registry
    ports:
      - port: 5000
        targetPort: 5000

Deployment Script
----

Steps executed by this script:

#. Generate TLS certificate and *htpasswd* file

#. Create secrets for *tls, generic* and *docker-registry*

#. Deploy *local-registry* pods

#. Setup docker to use the *local-registry*

#. Setup K3s to use the *local-registry*

``/home/ubuntu/setup/local-registry.sh`` script file

.. code-block:: bash
  :linenos:

  #!/bin/bash
  #
  # Local Docker registry install script
  #
  
  # Generate certificate & htpasswd
  openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout local-registry.key -out local-registry.crt -subj "/CN=local-registry" -addext "subjectAltName = DNS:local-registry"
  docker run --rm --entrypoint htpasswd registry:2.6.2 -Bbn myuser mypasswd > htpasswd
  
  # Create secrets
  kubectl create secret tls local-registry-tls --cert=local-registry.crt --key=local-registry.key
  kubectl create secret generic local-registry-auth --from-file=htpasswd
  kubectl create secret docker-registry local-registry-cred --docker-server=local-registry:5000 --docker-username=myuser --docker-password=mypasswd
  
  # Create local-registry pod
  kubectl create -f local-registry.yaml
  echo -n "Waiting for pod to up and running"
  
  # wait for the pod to up and running before continue
  while true;
  do
    if [ "$(kubectl get pod local-registry -o=jsonpath='{.status.phase}')" == "Running" ]; then
      break;
    fi
    echo -n ".";
    sleep 3;
  done
  
  set -x
  
  # Setup docker to use local-registry
  export REGISTRY_IP="$(kubectl get svc local-registry -o=jsonpath={.spec.clusterIP})"
  sudo sh -c "echo '$REGISTRY_IP local-registry' >> /etc/hosts"
  sudo mkdir -p /etc/docker/certs.d/local-registry:5000
  sudo cp local-registry.crt /etc/docker/certs.d/local-registry:5000/ca.crt
  
  # Setup K3s to use local-registry
  cat <<EOF > /tmp/registries.yaml
  configs:
      "local-registry:5000":
          auth:
              username: myuser
              password: mypasswd
          tls:
              ca_file: /etc/docker/certs.d/local-registry:5000/ca.crt
              insecure_skip_verify: true
  EOF
  sudo mv /tmp/registries.yaml /etc/rancher/k3s/
  sudo systemctl restart k3s

  # Test
  docker login local-registry:5000 -u myuser -p mypasswd
  echo "Local-registry setup, done!"

Make sure you're in *APP* node then change working directory to ``/home/ubuntu/setup``,
then run the deployment script::

  $ bash local-registry.sh

Verify Deployment
----

After install script finished, you can verify the result using below command::

  $ kubectl get pods,svc,ep local-registry -o wide
  NAME                 READY   STATUS    RESTARTS        AGE   IP           NODE   NOMINATED NODE   READINESS GATES
  pod/local-registry   1/1     Running   3 (3h13m ago)   38h   10.42.0.40   app    <none>           <none>

  NAME                     TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE   SELECTOR
  service/local-registry   ClusterIP   10.43.3.5    <none>        5000/TCP   38h   app=local-registry

  NAME                       ENDPOINTS         AGE
  endpoints/local-registry   10.42.0.40:5000   38h

You can see the pod is running, the service & endpoint are defined.

Check if you can login to *local-registry* via *Docker CLI*::

  $ docker login local-registry:5000 -u myuser -p mypasswd

At this point, the local registry is deployed inside *k3s*.
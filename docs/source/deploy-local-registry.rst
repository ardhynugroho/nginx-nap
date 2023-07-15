Setup local-registry
====

Create local-registry manifest named ``local-registry.yaml``::

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


Examine install script ``local-registry.sh``::

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
  docker login local-registry:5000 -u myuser -p mypasswd
  echo "Local-registry setup, done!"

Apply above script::

  bash local-registry.sh
Install docker
====

1. Change to setup::
   cd ~/setup

#. Examine `docker.sh` file::

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

#. Apply:: 
  
   bash docker.sh


```
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
```

Install NGINX Ingress Controller (NIC)
====

required certificate:
- nginx-repo.crt
- nginx-repo.key

bash nic.sh

```
#!/bin/bash
#
# NGINX Plus Ingress Controller install script
#

if [[ -f "nginx-repo.crt" && -f "nginx-repo.key" ]]; then
  sudo mkdir /etc/docker/certs.d/private-registry.nginx.com
  sudo cp nginx-repo.crt /etc/docker/certs.d/private-registry.nginx.com/client.cert
  sudo cp nginx-repo.key /etc/docker/certs.d/private-registry.nginx.com/client.key

  # pulling nginx ingress image to local registry
  docker pull private-registry.nginx.com/nginx-ic-nap/nginx-plus-ingress:3.2.0
  docker tag private-registry.nginx.com/nginx-ic-nap/nginx-plus-ingress:3.2.0 local-registry:5000/nginx-ic-nap/nginx-plus-ingress:3.2.0
  docker push local-registry:5000/nginx-ic-nap/nginx-plus-ingress:3.2.0

  git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v3.2.0
  
  cd kubernetes-ingress/deployments

  kubectl apply -f common/ns-and-sa.yaml

  # create RBAC
  kubectl apply -f rbac/rbac.yaml
  kubectl apply -f rbac/ap-rbac.yaml
  kubectl apply -f ../examples/shared-examples/default-server-secret/default-server-secret.yaml
  kubectl apply -f common/nginx-config.yaml
  kubectl apply -f common/ingress-class.yaml

  # create CRDs
  kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
  kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
  kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
  kubectl apply -f common/crds/k8s.nginx.org_policies.yaml
  kubectl apply -f common/crds/k8s.nginx.org_globalconfigurations.yaml
  kubectl apply -f common/crds/appprotect.f5.com_aplogconfs.yaml
  kubectl apply -f common/crds/appprotect.f5.com_appolicies.yaml
  kubectl apply -f common/crds/appprotect.f5.com_apusersigs.yaml

  # patching service account
  kubectl patch serviceaccount nginx-ingress -n nginx-ingress -p '{"imagePullSecrets": [{"name": "local-registry-cred"}]}'

  # update image
  sed -i 's/image: nginx-plus-ingress:3.2.0/image: local-registry:5000\/nginx-ic-nap\/nginx-plus-ingress:3.2.0/g' daemon-set/nginx-plus-ingress.yaml

  # enable app protect
  sed -i 's/#- -enable-app-protect$/\ - -enable-app-protect/g' daemon-set/nginx-plus-ingress.yaml

  # deploy ingress
  kubectl apply -f daemon-set/nginx-plus-ingress.yaml

  # KIC service
  kubectl apply -f service/nodeport.yaml
else
  echo "Required nginx-repo.crt and/or nginx-repo.key files not found"
fi
```

clean up the setup

```
rm /etc/docker/certs.d/private-registry.nginx.com/client.cert
rm /etc/docker/certs.d/private-registry.nginx.com/client.key
rm ~/setup/nginx-repo.*
```

Deploy arcadia app
====

from: https://gitlab.com/arcadia-application

cd ~/arcadia
kubectl apply -f app.yaml

```
##################################################################################################
# FILES - BACKEND
##################################################################################################
apiVersion: v1
kind: Service
metadata:
  name: backend
  labels:
    app: backend
    service: backend
spec:
  type: NodePort
  ports:
  - port: 80
    nodePort: 31584
    name: backend-80
  selector:
    app: backend
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: default
  labels:
    app: backend
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
      version: v1
  template:
    metadata:
      labels:
        app: backend
        version: v1
    spec:
      containers:
      - env:
        - name: service_name
          value: backend
        image: registry.gitlab.com/arcadia-application/back-end/backend:latest
        imagePullPolicy: IfNotPresent
        name: backend
        ports:
        - containerPort: 80
          protocol: TCP
---
##################################################################################################
# MAIN
##################################################################################################
apiVersion: v1
kind: Service
metadata:
  name: main
  namespace: default
  labels:
    app: main
    service: main
spec:
  type: NodePort
  ports:
  - name: main-80
    nodePort: 30511
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: main
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: main
  namespace: default
  labels:
    app: main
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: main
      version: v1
  template:
    metadata:
      labels:
        app: main
        version: v1
    spec:
      containers:
      - env:
        - name: service_name
          value: main
        image: registry.gitlab.com/arcadia-application/main-app/mainapp:latest
        imagePullPolicy: IfNotPresent
        name: main
        ports:
        - containerPort: 80
          protocol: TCP
---
##################################################################################################
# APP2
##################################################################################################
apiVersion: v1
kind: Service
metadata:
  name: app2
  namespace: default
  labels:
    app: app2
    service: app2
spec:
  type: NodePort
  ports:
  - port: 80
    name: app2-80
    nodePort: 30362
  selector:
    app: app2
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app2
  namespace: default
  labels:
    app: app2
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app2
      version: v1
  template:
    metadata:
      labels:
        app: app2
        version: v1
    spec:
      containers:
      - env:
        - name: service_name
          value: app2
        image: registry.gitlab.com/arcadia-application/app2/app2:latest
        imagePullPolicy: IfNotPresent
        name: app2
        ports:
        - containerPort: 80
          protocol: TCP
---
##################################################################################################
# APP3
##################################################################################################
apiVersion: v1
kind: Service
metadata:
  name: app3
  namespace: default
  labels:
    app: app3
    service: app3
spec:
  type: NodePort
  ports:
  - port: 80
    name: app3-80
    nodePort: 31662
  selector:
    app: app3
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app3
  namespace: default
  labels:
    app: app3
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app3
      version: v1
  template:
    metadata:
      labels:
        app: app3
        version: v1
    spec:
      containers:
      - env:
        - name: service_name
          value: app3
        image: registry.gitlab.com/arcadia-application/app3/app3:latest
        imagePullPolicy: IfNotPresent
        name: app3
        ports:
        - containerPort: 80
          protocol: TCP
---

```

WAF Policy
====

from: https://github.com/nginxinc/kubernetes-ingress/tree/v3.2.0/examples/custom-resources/app-protect-waf

apply in order

kubectl apply -f syslog.yaml
kubectl apply -f ap-jeruk-uds.yaml
kubectl apply -f ap-dataguard-alarm-policy.yaml
kubectl apply -f ap-logconf.yaml
kubectl apply -f waf.yaml

then enable WAF policy in VS-Arcadia

kubectl apply -f vs-2.yaml


Test
====

goto arcadia login page
user "jeruk" as user name --> blocked
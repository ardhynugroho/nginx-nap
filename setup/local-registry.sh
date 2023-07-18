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
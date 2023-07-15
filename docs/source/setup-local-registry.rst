Setup local-registry
====

create local-registry manifest named local-registry.yaml::

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

bash local-registry.sh

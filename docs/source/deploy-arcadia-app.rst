Deploying The Arcadia App
====

In this lab. Arcadia App will be used as test application that will be protected by *NGINX App Protect*.

About Arcadia App. Architecture
----

.. note:: 
  This application is available in `Arcadia App GitLab repository <https://gitlab.com/arcadia-application>`_

This is the architecture of Arcadia apps. It has 4 micro-services:

#. Main App

#. Backend

#. Money transfer

#. Refer friend

.. image:: img/arcadia-arch.png

This is what displayed when only *main* and *backend* services are deployed.

.. image:: img/arcadia-main-be.png

This is what displayed when *main*, *backend* and *money transfer* services deployed.

.. image:: img/arcadia-main-be-money.png

This is what displayed when *main*, *backend*, *money transfer* and *referral* services deployed.

.. image:: img/arcadia-main-be-money-friend.png

Deploy Arcadia Apps In Kubernetes
----

.. note::
  This already installed in your lab. deployment.
  
  You can moving forward to :ref:`verifyArcadia` step.
  
  Or else you can start over by execute below command under ``/home/ubuntu/arcadia``::

    $ kubectl delete -f app.yaml
    $ kubectl delete -f vs-1.yaml

Login in *APP* node then change dir to ``/home/ubuntu/arcadia`` directory::

  $ cd /home/ubuntu/arcadia

This ``app.yaml`` file define all the required resource to deploy Arcadia App in k3s

.. code-block:: yaml
  :linenos:

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

Let's apply the ``app.yaml`` manifest above::

  $ kubectl apply -f app.yaml

Verify Arcadia Apps Deployment
----

::

  $ kubectl get pods,svc
  NAME                           READY   STATUS    RESTARTS        AGE
  pod/app2-6999bc5c98-lfbzj      1/1     Running   2 (4h26m ago)   39h
  pod/syslog-56d66bfffc-ftql6    1/1     Running   2 (4h26m ago)   38h
  pod/local-registry             1/1     Running   3 (4h26m ago)   39h
  pod/main-66767686d9-xw9br      1/1     Running   2 (4h26m ago)   39h
  pod/backend-78c5979444-9k7rf   1/1     Running   2 (4h26m ago)   39h
  pod/app3-554b8c45d5-8mlsv      1/1     Running   2 (4h26m ago)   39h
  
  NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
  service/kubernetes       ClusterIP   10.43.0.1       <none>        443/TCP        39h
  service/local-registry   ClusterIP   10.43.3.5       <none>        5000/TCP       39h
  service/backend          NodePort    10.43.248.112   <none>        80:31584/TCP   39h
  service/main             NodePort    10.43.136.176   <none>        80:30511/TCP   39h
  service/app2             NodePort    10.43.66.125    <none>        80:30362/TCP   39h
  service/app3             NodePort    10.43.61.157    <none>        80:31662/TCP   39h
  service/syslog-svc       ClusterIP   10.43.206.48    <none>        514/TCP        38h

As you can see there are *main-*, *backend-*, *app2-* 
and *app-3* pods are running and their respective service are defined.

.. _verifyArcadia:
Verify the Arcadia apps
----

At this point, you should can access the app using exposed NodePort.

From *Client* node, open Firefox web browser and navigate to http://app.arcadia.com:30511/

Please notice the port 30511 in the URL, this is Main service NodePort.

.. image:: img/arcadia-nodeport.png

Publish the Arcadia App Using *NGINX Plus Ingress Controller*
----

Now we will create a *VirtualServer* resource for Arcadia Apps.

Make sure you're in *APP* node.

Look inside ``/home/ubuntu/arcadia`` directory, there is ``vs-1.yaml`` manifest file with below content

.. code-block:: yaml
  :linenos:

  apiVersion: k8s.nginx.org/v1
  kind: VirtualServer
  metadata:
    name: vs-arcadia
  spec:
    host: app.arcadia.com
    upstreams:
    - name: main
      service: main
      port: 80
    - name: backend
      service: backend
      port: 80
    routes:
    - path: /
      action:
        pass: main
    - path: /files
      action:
        pass: backend

#. Now apply ``vs-1.yaml`` manifest::

    $ kubectl apply -f vs-1.yaml

#. Now back to *Client* node.

    Verify the Arcadia App by open ``http://app.arcadia.com/`` in the Firefox web browser. 
    Notice we ommited port 30511 in the URL, so the request served over NGINX Ingress Controller.

At this point. The Arcadia app is up and running served by *NGINX Plus Ingress Controller*
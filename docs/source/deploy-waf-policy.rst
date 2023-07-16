Configure App Protect Policy
====

.. warning:: Back to *APP* node
  
Policy CRD
----

The Policy resource allows you to configure features like access control and rate-limiting, 
which you can add to your *VirtualServer* and *VirtualServerRoute* resources.

Policies work together with *VirtualServer* and *VirtualServerRoute* resources, which you need to create separately.

The WAF policy configures *NGINX Plus* to secure client requests using *App Protect* WAF policies.

For example, the following policy will enable the referenced APPolicy. 
You can configure multiple *APLogConfs* with log destinations:

::

  apiVersion: k8s.nginx.org/v1
  kind: Policy
  metadata:
    name: waf-policy
  spec:
    waf:
      enable: true
      apPolicy: "default/dataguard-alarm"
      securityLogs:
      - enable: true
        apLogConf: "default/logconf"
        logDest: "syslog:server=syslog-svc.default:514"

App Protect Policy CRD
----

You can define NGINX App Protect WAF policies for your *VirtualServer*, *VirtualServerRoute*
by creating an *APPolicy* Custom Resource.

The ``ap-dataguard-alarm-policy.yaml`` example file::

  apiVersion: appprotect.f5.com/v1beta1
  kind: APPolicy
  metadata:
    name: dataguard-alarm
  spec:
    policy:
      signature-requirements:
      - tag: Fruits
      signature-sets:
      - name: jeruk_sigs
        block: true
        signatureSet:
          filter:
            tagValue: Fruits
            tagFilter: eq
      applicationLanguage: utf-8
      blocking-settings:
        violations:
        - alarm: true
          block: false
          name: VIOL_DATA_GUARD
      data-guard:
        creditCardNumbers: true
        enabled: true
        enforcementMode: ignore-urls-in-list
        enforcementUrls: []
        lastCcnDigitsToExpose: 4
        lastSsnDigitsToExpose: 4
        maskData: true
        usSocialSecurityNumbers: true
      enforcementMode: blocking
      name: dataguard-alarm
      template:
        name: POLICY_TEMPLATE_NGINX_BASE

User Defined Signature
----

You can define NGINX App Protect WAF User-Defined Signatures 
for your *VirtualServer* by creating an *APUserSig* Custom Resource.

In example below, we add user-signature that if there is "jeruk" string detected in the request 
then the request must be blocked.

This definition referenced in *APPolicy* CRD.

::
  
  apiVersion: appprotect.f5.com/v1beta1
  kind: APUserSig
  metadata:
    name: jeruk
  spec:
    signatures:
    - accuracy: medium
      attackType:
        name: Brute Force Attack
      description: Medium accuracy user defined signature with tag (Fruits)
      name: Jeruk_medium_acc
      risk: medium
      rule: content:"jeruk"; nocase;
      signatureType: request
      systems:
      - name: Microsoft Windows
      - name: Unix/Linux
    tag: Fruits

Logging Resource Definition
----

*syslog* deployment example::

  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: syslog
  spec:
    replicas: 1
    selector:
      matchLabels:
        app: syslog
    template:
      metadata:
        labels:
          app: syslog
      spec:
        containers:
          - name: syslog
            image: balabit/syslog-ng:3.38.1
            ports:
              - containerPort: 514
              - containerPort: 601
  ---
  apiVersion: v1
  kind: Service
  metadata:
    name: syslog-svc
  spec:
    ports:
      - port: 514
        targetPort: 514
        protocol: TCP
    selector:
      app: syslog

You can set the NGINX App Protect WAF log configurations by creating an *APLogConf* Custom Resource 
like ``ap-logconf.yaml`` file below::

  apiVersion: appprotect.f5.com/v1beta1
  kind: APLogConf
  metadata:
    name: logconf
  spec:
    content:
      format: default
      max_message_size: 64k
      max_request_size: any
    filter:
      request_type: all

.. note::
  From: https://github.com/nginxinc/kubernetes-ingress/tree/v3.2.0/examples/custom-resources/app-protect-waf

Deploy The Manifests
----

::

  $ kubectl apply -f syslog.yaml
  $ kubectl apply -f ap-jeruk-uds.yaml
  $ kubectl apply -f ap-dataguard-alarm-policy.yaml
  $ kubectl apply -f ap-logconf.yaml
  $ kubectl apply -f waf.yaml
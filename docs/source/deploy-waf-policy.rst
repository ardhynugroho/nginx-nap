Enable App Protect For Arcadia App
====

Back to *APP* node. Navigate to ``/home/ubuntu/setup``

Main WAF Policy
----

The ``waf.yaml`` file::

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

NGINX App Protect Policy
----

The ``ap-dataguard-alarm-policy.yaml`` file::

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

User Defined App Protect Signature
----

``ap-jeruk-uds.yaml``::

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

Syslog and Logconf Definition
----

The ``syslog.yaml`` file::

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

The ``ap-logconf.yaml`` file::

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

  $ kubectl apply -f syslog.yaml


from: https://github.com/nginxinc/kubernetes-ingress/tree/v3.2.0/examples/custom-resources/app-protect-waf

Deploy The Manifests
----

:

  $ kubectl apply -f syslog.yaml
  $ kubectl apply -f ap-jeruk-uds.yaml
  $ kubectl apply -f ap-dataguard-alarm-policy.yaml
  $ kubectl apply -f ap-logconf.yaml
  $ kubectl apply -f waf.yaml
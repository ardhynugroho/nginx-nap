WAF Policy
====

from: https://github.com/nginxinc/kubernetes-ingress/tree/v3.2.0/examples/custom-resources/app-protect-waf

Apply in order::

  kubectl apply -f syslog.yaml
  kubectl apply -f ap-jeruk-uds.yaml
  kubectl apply -f ap-dataguard-alarm-policy.yaml
  kubectl apply -f ap-logconf.yaml
  kubectl apply -f waf.yaml

then enable WAF policy in VS-Arcadia

  kubectl apply -f vs-2.yaml
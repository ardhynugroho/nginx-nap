.. toctree::
    lab-setup
    install-docker
    install-k3s
    install-nic
    deploy-arcadia-app
    deploy-waf-policy
    security-test
    deploy-local-registry

Topology
====

ubuntu client --> DoS (docker) --> NAP (KIC) --> App


Tools
====

- wrk
- owaspzap

Setup
====

1. k3s server



2. deploy 

NMS
10.1.1.7
primary
app
10.1.1.4
primary
docker
10.1.1.5
primary
ubuntu client
10.1.1.6
primary

skenario:
2. deploy ingress-ctl with NAP
-- done
sudah siap:
KIC
APP
====

peserta hands-on:

3. deploy arcadia vs-1.yaml
-- no WAF enabled in yaml

4. open arcadia via bookmark arcadia app
-- explore if working properly

3. attack arcadia  --> login form
-- put <script> as username on addr bar --> not blocked

4. deploy vs-2.yaml
-- update vs yaml

3. attack arcadia --> login form
-- put <script> as username on addr bar --> blocked

4. deploy NMS
5. manage from NMS
5. security monitoring

additional
4. enable arcadia money transfer --> vs-3.yaml 
5. & app3 friend referral --> vs-4.yaml


Admin username: admin

    Admin password: tN8oICAX5fR8jSI5D2O2lXtuAcnNuz


    
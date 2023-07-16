XSS Attack Test
====

#. Open a terminal emulator and login to *APP* node 

#. In *APP* node

    .. code-block::
        
        $ cd /home/ubuntu/arcadia
        
    and then deploy ``vs-2.yaml`` file

    .. code-block::

      $ kubectl apply -f vs-2.yaml

#. Open another terminal emulator and login to *APP* node then monitor the syslog

    .. code-block::

      $ ssh app

      $ podname=`kubectl get pods | awk '/^syslog/{print $1}'`; kubectl exec -it $podname -- tail -f /var/log/messages

#. From Firefox browser, open http://app.arcadia.com/ then click *Login* button

    .. image:: img/test-a1.png

   You can see the request logging start to scroll

#.  Try to attack by type ``<script>`` in *Username* input then click *Log me in* button

    .. image:: img/test-a2.png

#. *Rejected Request* page displayed in the browser and see the log match the support ID

    .. image:: img/test-a3.png

    .. image:: img/test-a4.png
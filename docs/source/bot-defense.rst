Bot Defense Testing
====

Test Using cURL
---- 

#. Open a terminal emulator in *Client* node, and create HTTP request

    .. code-block::

        $ curl -I http://app.arcadia.com

#. You can see request is PASSED with ALERT

    .. image:: img/bot-a2.png

Test with cURL acting as ApacheBench
----

Now we set user agent identity as ApacheBench

#. Create the request and set the User-Agent to "ApacheBench/2"

    .. code-block::

        $ curl -A "ApacheBench/2" http://app.arcadia.com

#. You can see request is blocked and REJECTED and client classified as *Malicious Bot*

    .. image:: img/bot-b2.png

Using Firefox as GoogleBot
----

Now we try to use Firefox with modified user-agent.

#. Set Firefox to pretend to be GoogleBot using *User-Agent Switcher* add-on

    .. image:: img/bot-c2.png

    Then click the *Apply (container)* button.
    
#. Create request to the Arcadia Apps http://app.arcadia.com

#. You can see the request is blocked and REJECTED and classified as *Malicious Bot*. You also can see *bot_anomalies* as *Search Engine Verification Failed*.

    .. image:: img/bot-c3.png
Bot Defense Testing
====

cURL as Itself
----

#. You're now in *Client* node, then create HTTP request

    .. code-block::

        $ curl -I http://app.arcadia.com

#. Request was allowed but with an alert

    .. image:: img/bot-a2.png

cURL as ApacheBench
----

#. Create request and set the User-Agent to "ApacheBench/2"

    .. code-block::

        $ curl -A "ApacheBench/2" http://app.arcadia.com

#. Request is blocked and categorized as *Malicious Bot*

    .. image:: img/bot-b2.png

Firefox as GoogleBot
----

#. Set Firefox to pretend to be GoogleBot using *User-Agent Switcher* add-on

    .. image:: img/bot-c2.png

    Then *Apply (container)*
    
#. Create request to the Arcadia Apps

#. Request blocked and categorized as *Malicious Bot*

    .. image:: img/bot-c3.png
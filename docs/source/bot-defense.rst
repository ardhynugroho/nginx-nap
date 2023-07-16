Bot Defense Testing
====

cURL as Itself
----

#. Create request

    .. code-block::

        $ curl -I http://app.arcadia.com

#. Request allowed with alert

    .. image:: img/bot-a2.png

cURL as ApacheBench
----

#. Create request

    .. code-block::

        $ curl -A "ApacheBench/2" http://app.arcadia.com

#. Request blocked and categorized as *Malicious Bot*

    .. image:: img/bot-b2.png

Firefox as GoogleBot
----

#. Set Firefox to pretend to be GoogleBot using *User-Agent Switcher* add-on

    .. image:: img/bot-c2.png
    
#. Create request to the Arcadia Apps

#. Request blocked and categorized as *Malicious Bot*

    .. image:: img/bot-c3.png
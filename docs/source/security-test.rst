Test
====

Testing Without App Protect
----

**@APP node**

Apply ``vs-1.yaml`` manifest under ``/home/ubuntu/arcadia``::

  $ kubectl apply -f vs-1.yaml

**@Client node**

Open http://app.arcadia.com/ then click *Login* button

.. image:: img/test-a1.png

Type ``<script>`` in Username input then click *Log me in* button

.. image:: img/test-a2.png

You can see, the page is re-loaded.

Enable App Protect For Arcadia Virtual Server
----

Now we're going to enable application protection feature in *NGINX Plus Ingress Controller*

**@APP node**

Apply ``vs-2.yaml`` manifest under ``/home/ubuntu/arcadia``::

  $ kubectl apply -f vs-1.yaml

.. warning:: back to Firefox browser @ *Client*

1. Type ``<script>`` in Username input

.. image:: img/test-a2.png

#. Click *Log me in* button

Testing With App Protect Enabled
----


goto arcadia login page
user "jeruk" as user name --> blocked
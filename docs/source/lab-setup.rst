About The Lab
====

Topology
----

.. image:: img/topologi.jpeg

*Client* node will be used as jump host and test client. 
It uses RDP protocol to access.

*App* node is where the test application will be hosted.
The test app is micro-services based hence *k3s* cluster installed in this node.

Your Deployment
----

Check you deployment status.
You can see *ACCESS* button in *Client* node.
Click the button to see access option to this node.

.. image:: img/deployment.png

Reset *ubuntu* User Password
----

Now we will change *ubuntu* user password as *ubuntu*

In your deployment, from *APP* node select *ACCESS > Web Shell*

.. image:: img/webshell.png

Then change *ubuntu* user password as *ubuntu*::

    # passwd ubuntu

.. image:: img/ch-ubuntu-passwd.png

Access *Client* Node Using xRDP
----

Everything will be done over remote desktop.
This method protects from losing session when network disconnect happen.
You will need a RDP client installed in your laptop / PC.

In your deployment, from *Client* node select *ACCESS > xRDP > 1280x800*.

.. image:: img/xrdp.png

Then click on downloaded RDP file to open in RDP client.
Enter credential *ubuntu/ubuntu* to login.

.. image:: img/xrdp2.png

After login, open *Terminal Emulator* from dock menu.

.. image:: img/dock-menu.png

then remove ``known_hosts`` file::

    $ rm /home/ubuntu/.ssh/known_hosts

Now access to *APP* node and use *ubuntu* as password when prompted::

    $ ssh app
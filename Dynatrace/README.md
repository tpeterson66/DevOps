# Dynatrace

## General Notes

Dynatrace can be ran using a managed environment or a SaaS environment. Customers can choose depending on the requirements. SaaS is hosted in AWS, Azure and GCP are coming soon. A managed environment can be deployed on-prem, Azure or other solutions.

Agents communicate with Dynatrace over HTTPS tcp/443

SaaS clusters are updated automatically every 2 weeks
OneAgent updates are available every 4 weeks and are optional. OneAgent cannot be older than 9 months or 12 months with a premium support license.

Dynatrace SaaS Architecture:

Using Cassandra for timeseries monitoring, Elastic Search is used for monitoring and synthetic monitoring.

SaaS Image
Storage Image

Dynatrace Managed:
Hosted and managed by the partner or the customer. This is not running in dynatrace envrionments. Still using Cassandra, Elastic Search, NGINX load balancer, etc.

Cluster Management Console is available to adminstrators of the cluster. 
Dynatrace uses mission control and is used to monitor and manage the cluster from Dynatrace support.

Managed clusters are updated every 4 weeks and are mandatory!, cluster versions are supported for 3 months. OneAgent is updated every 4 weeks and are optional - Need to be within 9 months or 12 months with premium license.


Monitoring Envrionments:
AKA - Environment and Tenant

ActiveGate is a proxy between OneAgent and Dynatrace. This is used to reduce the firewall requirements. This will also compress traffic before sending the logs to dynatrace. There is no extra configuration, install oneagents can connect to it and rest is handled automatically.

Environment ActiveGate - Available on Dynatrace SaaS and managed
Bound to a specific environment/tenant
Only handles traffic from OneAgent instances that belong to the same monitoring envrionment
Can only handle traffic from OneAgents, cannot handle traffic from other ActiveGates
This is downloaded from the monitoring environment itself
Deploy Dynatrace -> Install ActiveGate


Cluster ActiveGate - Only available on Managed environments, not available with SaaS
Bound to a dynatrace managed cluster
Can handle traffic from OneAgents to any environment that exists on that cluster
Can handle traffic from OneAgents and other environment activegates

ActiveGates
Integration with other platforms - AWS, Azure, vCenter, Kuberentes
Syntetic tests
Store memory dumps
Extensions
RUM Beacons
Mainframe monitoring

Connections from ActiveGate or OneAgent can be sent through proxy - can be passed throught the CLI for install and there is a configuration file created to manage the proxy settings.

Envrionment ActiveGate for multiple environments
    There is a multitenant.properties file which can be used to manage this setup

CMC - Cluster Management Conslole - Managed environments
Mission control - Dynatrace SRE service

Data sent back to Mission Control:
Usage and Billing - License usage and available licensing
System Settings - configuration of the environment
Event tracking - Configuration changes and events in the cluster
Healh Statistics - Issues with the cluster
Software Updates - Software versions installed and pending updates

OneAgent - 
Currently supports Linux/Unix, Windows, functions, azure, etc.
Communication from OneAgent to Dynatrace
Data is buffered locally and sent once a minute
Differnet ways of installing:
    Manually
    Automatically
        GPO Windows
        Ansible/Puppet/Chef, etc.
OneAgent auto-update is enabled by default but can be disabled globally, per hostgroup or per host.

Full Stack will allow OneAgent to monitor the server and also the applications running on the server, NodeJS, Nginx, PHP, etc. This is not required for SQL servers.

Setting up the service...

```bash
#!/bin/bash

[Unit]
Description=Easytravel StartUp

[Service]
User=ubuntu
ExecStart=/home/ubuntu/easytravel-2.0.0-x64/runEasyTravelNoGUI.sh --startgroup UEM --startscenario "Standard with REST Service and Angular2 frontend"
ExecStop=/bin/kill -2 $MAINPID
```

https://confluence.dynatrace.com/community/display/DL/easyTravel


Process Group Instance - a single process that belogs to a designated process
a process can be identified as running on one unique hose or container, etc.
Technology aligned metrics include:
Process CPU
JVM Metrics
AppServer metrics
System performance
Web server requests

Processes are host-centric, associated with a single machine in your environmnet
Each node in the smartscape corresponds to a process group instance
Each connection represents a TCP/IP request - 2 hours for a solid line, dash line if not active for 72 hours, after 72 hours, the line will be removed.
Dashed lines show inactive connections between hosts in 2 hours



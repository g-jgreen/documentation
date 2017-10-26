---
title: Sigfox integration
description: Learn how to connect and integrate your Sigfox devices
tags:
- sigfox
weight: 9
---

Waylay Sigfox integration goes beyond simple visualization. When it comes to Sigfox support, waylay platform addresses all challenges of the enterprise grade integration:

* [Payload transformation](features/transformers) 
* [Webscripts](features/webscripts)
* Data storage and visualization 
* REST endpoints to retrieve captured data as a time series data (with different aggregation periods, statistical computation etc.)
* Automatic (meta model) associations of sigfox devices to resource groups and assosiated rules
* First time provisioning
* Tenant based UI


# Data collection and rules processing

Once the Sigfox devices are connected via transformers, waylay will immediately start collecting data. 

# Sigfox provisioning
Provisioning involves the process of preparing and equipping a network and a device to allow it to provide (new) services to its users. 

For first time provisioning, we use a great feature of waylay - automatic task creation for new resources, based on the resource type. That simply means that __every time a new resource is discovered, which is associated with a particular resource type, all tasks for that resource are automaticaly created__. More about it you can find here: [Provisioning feature](/features/provisioning/)

This is the example of the provisioning template:

![template](/features/provisioning/template.png)

# Visualisation

To visualize your devices we recommend using our [Waylay Grafana application](features/grafana).

Here are the screenshots of our sample tracking application:

![Map drill down](features/sigfox/tracking_1.png)


![Map drill down](features/sigfox/tracking_2.png)

![Map drill down](features/grafana/details.png)



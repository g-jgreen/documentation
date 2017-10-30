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

# Connecting sigfox devices
In order to connect sigfox device to waylay, you should make use of [webscripts](features/webscripts) and [transformers](features/transformers), as described in [LPWAN intergation document](features/lpwan/). Reason for two steps integration (webscripts and then transformers) is that we want to unify the way LPWAN devices are integrated, regardless whether they are managed by Sigfox, LoRa or NB-IoT. In all these cases, a device payload format that comes from different backends can be different, even though the object still encodes the same sensor data measurements in the data part of the payload (as the hex value). If the sensor data is encoded in the same way, it means that we can use the same transformer to decode the measurements.


# Data collection and rules processing

Once the Sigfox devices are connected via webscripts and transformers, waylay will immediately start collecting data. In order to start using LPWAN devices in your rules, you can start by looking into one simple rule: [data threshold example](patterns/stream-data-threshold-crossing/)

![rule](rules/stream-data-threshold-crossing/stream_threshold_crossing.png)

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



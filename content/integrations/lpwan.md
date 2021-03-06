---
title: LPWAN (Sigfox and LoRa) integration
description: Learn how to integrate LPWAN devices (both LoRa and Sigfox) using webscripts and transformers
tags:
- lpwan
weight: 7
---

# Introduction
The same LPWAN devices can be connected to multiple networks: public and private LoRa networks from different providers and in some cases devices are even multi-technology allowing them to connect both over Sigfox and LoRa networks. In all these cases, the JSON payload format that comes from different backends can be different, even though the object still encodes the same sensor data measurements in the data part of the payload (as the hex value). If the sensor data is encoded in the same way, it means that we can use the same [transformer](features/transformers) to decode the measurements.

{{% alert info %}}
A transformer always represents one particular data encoding schema.
{{% /alert %}}

![LPWAN](features/lpwan/LPWAN_1.png)

{{% alert info %}}
Different input payload formats can hit the webscript, e.g. when the same device family is connected to both private and public LoRa network, as the "cloud" backend servers (LoRa network servers) may come from different providers. 
{{% /alert %}}

More about [webscripts](features/webscripts) and [transformers](features/transformers)

# Webscripts, one or many per transformer?
Webscripts allow integrators to attach different webhook calls for different LPWAN backends. When createing these webscripts, the  integrator essentially has two choices:

* Create one webscript per device type covering all backend API's. This one big webscript does the payload normalization for all  backends before calling one particular device payload transformer.
* Create one webscript per backend API/transformer combination. Every time a new LPWAN backend is added, a new webscript is created per transformer. 

In the first case, the integrator will always have one webscript/transformer pair, while in second case, with every new backend API, the integrator will have a new webscript, always calling the same transformer.


## One webscript for all backend API's
In case that we use one webscript for all backends, our configuration will look like this:
![LPWAN](features/lpwan/case_2.png)

Every time a new LoRa backend server is added, which has a different payload format, we must update this webscript. Advantage of doing the integration this way is that there is always one single script that manages all different integration use cases for the same device type. 
Another reason to have only one webscript is that if the developer wants to apply [provisioning](/features/provisioning) by direct calls on the meta model of a device (e.g. by assigning it to a particular group to which rules are attached), then it makes more sense to do it only in one place.

Finally, if the integrator has **multiple Sigfox customers**, which reside in different device groups, but all devices use the same transformer, this is a natural way of integrating, since the webscript will not change as new groups are added.

On the other hand, every time a new backend server is added, the existing script must be adjusted. Editing the existing webscript, which is already in production, always introduces a small but possible risk of making some mistakes, breaking all existing integrations. 
Another potential difficulty (for LoRa deployments) is that the input object might come as a XML or JSON in different formats, which need to be parsed before calling a transformer.


## One webscript per backend API
In case a webscript is used per backend API, the schema will look like this:

![LPWAN](features/lpwan/case_1.png)

The advantage of this approach is that there is no risk of breaking any existing integration. On the other hand, the integrator will need to manage different webscripts per `cloud backend API`. If we add to this the fact that an integrator might have different device families or different payload decoders (transformers) for different set of sensors attached to the same device, such configuration can easily become a configuration challenge.






---
title: LPWAN integration (both LoRa and Sigfox) using webscripts and transformers
description: Learn how to integrate LPWAN devices (both LoRa and Sigfox) using webscripts and transformers
tags:
- lpwan
weight: 7
---

# Introduction
In some deployments, the same device family can be connected to both LoRa (private and public) and Sigfox network. In that case, the JSON payload format that comes from different backends can be different, even-though the object still encodes the same measurements in the data part of the payload (as the hex value). The fact that data is encoded in the same way, in our terminology simply means that we can use the same transformer to decode the measurements.

{{% alert info %}}
Transformer always represents one particular data encoding schema.
{{% /alert %}}

![LPWAN](features/lpwan/LPWAN_1.png)

{{% alert info %}}
This can even happen if the same device family is connected to both private and public LoRa network, as the "cloud" backend servers might come from different providers - hence having different payload formats that hit the webscript.
{{% /alert %}}

More about [webscripts](features/webscripts) and [transformers](features/transformers)

# Webscripts, one or many per one transformer?
Webscripts allow integrator to attach different webhook calls from different LPWAN backends. Even in that case, integrator might still be faced with two choices:

* have one webscript for all backend API's and in one big webscript do the payload normalization for all new backends before calling one particular transformer
* have one webscript per different backend API, and with each new intergation, make new payload adjustment using a new webscript, before calling the same transformer.

In first case, integrator will always have one webscript/transformer pair, while in second case, with every new backend API, integrator will have a new webscript, always calling the same transformer.




## One webscript for all backend API's
In case that we use one webscript for all backends, our configuration will look like this:
![LPWAN](features/lpwan/case_2.png)

Every time a new LoRa backend server is added, which has a different payload format, we must update this webscript. Advantage of doing the integration this way is that there is always one single script that manages all different integration use cases for the same device type. On the other hand, every time a new backend server is added, the existing script must be adjusted. Editing the existing webscript, which is already in production, always introduces a small but possible risk of making some mistakes, breaking all existing integrations.
Another possible difficulty is that based on the payload, a developer must somehow guess the "routing algorithm", knowing which exactly payload transformation to apply - before calling the transformer. More over, as the input object might come as a XML, JSON or a string, special care must be taken that the existing script doesn't break somewhere in the middle.

One interesting integration pattern can be to use webscripts only for different LoRa backends, while directly connecting transformer to the Sigfox backend, as presented below:
![LPWAN](features/lpwan/case_2_1.png)

## One webscript per different backend API
In case that one webscript is used per different backend API, schema will look like this:

![LPWAN](features/lpwan/case_1.png)

Advantage of this approach is that there will be no risk of breaking any existing integration. On the other hand, integrator will need to manage different webscripts per `cloud backend API`. If we add to this the fact that an integrator might have different device families or different payload decoders (transformers) for different set of sensors attached to the same device, such configuration can easily become a configuration challenge.






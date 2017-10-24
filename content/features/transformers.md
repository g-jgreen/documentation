---
title: Transformers 
description: Learn how to transform any payload that comes to waylay
tags:
- transformers
weight: 3
---

![transformers](/features/transformers/transformers.png)

# Introduction
Waylay rule engine is protocol agnostic. Among other things, that simplifies templating rules. For instance, we can use the same rule for smart meters that are connected over different networks (Sigfox, LoRA) and different protocols (HTTPS, MQTT or websockets). 
In order to bridge different protocols, you need to use [Waylay Broker](/api/broker-and-storage/) or you can push data directly towards rule engine using [REST over HTTPS](/api/rest/#real-time-stream-data). In addition to bridging different protocols, Broker also stores messages in three different storages as presented in the architecture [overview](/architecture/overview).

Such approach is very robust, but there are use cases when this is still not enough. Bridging protocols is great, but one thing that Broker imposes is implicit: JSON payload format that is waylay specific. 

Transform functions - **transformers** allow you to pre-process messages before being forwarded to the Broker. That way you can do additional payload decoding or data enrichment before forwarding and storing data in waylay. 

In most cases, transformers should be combined together with [webscripts](features/webscripts) - especially when we integrate LoRa or Sigfox devices [LPWAN integration](features/lpwan).

Let's now see the code:


```
//this is your domain and corresponding API credentials

const { waylay_domain, API_KEY, API_PASS } = options.globalSettings
const { data, resource } = options.requiredProperties

const transformed = transform(data)
console.log(transformed)

function transform (data) {
    data = JSON.parse(data)
    return Object.assign(data, {
        temperature: data.temperature / 10
    })
}

waylayUtil.storeData(API_KEY, API_PASS, resource, transformed, waylay_domain, send)

```

here we assume that we only need to adjust the temperature measurements (dividing it by 10) that comes in this format:

```{ data: { temperature : 244 } } ```


In the transformer above, first we __transformed the data__ and then forwarded and stored it under the resource name __resource__ using `waylayUtil` package.
Transformers can also be accessed directly over [REST](/api/rest/#execute-a-specific-transformer-version). 

{{% alert info %}}
Transformers are stored in waylay in the same way as sensors and actuators. They are also versioned. 
{{% /alert %}}





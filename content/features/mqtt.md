---
title: Using Waylay Broker and MQTT
description: Learn how to use MQTT, Broker and how to bridge different protocols
weight: 3
---

# Device onboarding and authentication in Waylay

Every IoT platform should offer the following capabilities:

* device identity
* secure connection
* device model
* data model (message payload definition)
* firwmare upgrades

In waylay, we don't manage device firmware upgrades. We also don't enforce device model. In that sense, waylay is not an IoT platform, we rather see ourselves as the orchestration platform that sits on top of other systems - including IoT platforms. Nevertheless, waylay offers integration with end devices with limitations as mentioned above.

Boostraping of device is often the most difficult problem in IoT (and probably most ignored issue by IoT 'novice'). In waylay, we offer a unique solution for device identity management, but we don't enforce the boostrap procedure. This is up to a device manufacturer to decide. Each tenant receives a master key, with which he can generate unique device keys (see later in the document).

Once a device has a unique id and credentials, it can send data to the cloud, it can as well subscribe to the events, or accept actuator commands (turn off/on lights etc). In some cases, devices can as well inform other systems about its capabilities through discovery protocol (e.g. CoAP) or similar. Devices usually connect to the cloud back-end using MQTT, Websockets, XMPP, CoAP, DDS, AMQP etc.. 
In waylay, **we decided to go for MQTT**.


[Waylay Broker](/api/broker-and-storage/) lets you store and distribute messages. It is important to mention that **Waylay Rule engine is protocol agnostic**. That means that different protocols are terminated at the Broker. Broker supports  different protocols: HTTP(S), WebSockets and MQTT. 

If the data comes directly from the devices, the appropriate choice would be MQTT (together with the identity  manager - **Device Gateway**).  HTTP(S), WebSockets are appropriate choice for cloud-to-cloud or intra-cloud integration. In case of HTTP(S) integration, you will always need waylay API key and secret. In case that data comes directly from the devices, you will need our identity manager:

![manager](/features/mqtt/device_gateway.png)

Once the data is sent, Broker does two things: it stores data and forwards it to the **Waylay Rule Engine**.  Data is stored in two different databases, **Time Series Database** and **Document Database** (Cloud Persisted Cache). In Cloud Persisted Cache, data is stored without any pre-processing, with original JSON object as it was received. When JSON object (or array of JSON objects) comes to the Broker, Broker also tries to save data in the Time Series Database. In order to achieve that, Broker inspects incoming JSON object or array of objects and stores every metric that is found in the JSON object.

Now let's focus on MQTT integration.


# MQTT endpoints

The Waylay platform supports both the MQTT and the MQTTS protocol (MQTT over TLS).

**We recommend using the secure endpoint** if your device can afford the overhead in CPU and bandwidth.

**MQTTS (secure):** `mqtts://data.waylay.io:8883/`

**MQTT (insecure):** `mqtt://data.waylay.io:1883/`

# MQTT authentication credentials

For this example, we are going to use an MQTT client called **MQTTfx** — available at [http://mqttfx.jfx4ee.org/](http://mqttfx.jfx4ee.org/).

Before you can connect to our MQTT broker, you need a set of credentials to authenticate your device. In order to receive valid connection token (per device) you must use Waylay Device Hub.

![MQTT Credentials](/features/mqtt/credentials.png)

If you're using MQTTfx and the TLS secured endpoint, don't forget to enable "SSL/TLS" with the "*CA signed server certificate*" option.

# MQTT authorization

Each set of credentials can only publish and subscribe to one specific topic on the domain that you belong to.

We have already created a set of credentials, and configured our client to connect to the broker using Device Hub.

The ID of my device that belongs to those credentials is `beb714f2-7b34-4239-a74c-c672f66be2e3` on the `app.waylay.io` domain.

This is a unique ID that identifies our device and is used to construct the MQTT topics.

# Subscribing

To receive messages we can subscribe to

`app.waylay.io/resources/beb714f2-7b34-4239-a74c-c672f66be2e3/commands`

![Subscribing to a topic](/features/mqtt/subscribe.png)

# Publishing
Similarly we can send messages by posting some data to the following topic:

`app.waylay.io/resources/beb714f2-7b34-4239-a74c-c672f66be2e3/events`

# Bridging protocols

This is the exciting part. The Waylay broker allows us to bridge protocols — send a message via Web Sockets on a browser and receive a message on your MQTT enabled device!

![Subscribing to a topic](/features/mqtt/websockets.png)
*Make sure to include the resource ID in the message.*

![Subscribing to a topic](/features/mqtt/received.png)

Works like a charm!

If you want to know more, you can find more detailed information on our [documentation portal](/usage/broker-and-storage/)

If you're excited to give it a try, [request a demo](https://waylay.io/)!

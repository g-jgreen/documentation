---
title: Using the Waylay MQTT broker
author: Gilles De Mey
date: 2017-02-02T17:18:19+01:00
---

MQTT is a popular protocol choice for low-power devices to send metrics to an broker.

As Wikipedia describes it:

> It is designed for connections with remote locations where a "small code footprint" is required or the network bandwidth is limited.

Enough talking, let's dive in and see how it works.

# MQTT endpoints

The Waylay platform supports both the MQTT and the MQTTS protocol (MQTT over TLS).

**We recommend using the secure endpoint** if your device can afford the overhead in CPU and bandwidth.

**MQTTS (secure):** `mqtts://data.waylay.io:8883/`

**MQTT (insecure):** `mqtt://data.waylay.io:1883/`

# MQTT authentication credentials

For this demo, we're going to use an MQTT client called **MQTTfx** — available at [http://mqttfx.jfx4ee.org/](http://mqttfx.jfx4ee.org/).

Before you can connect to our MQTT broker, you need a set of credentials to authenticate your device. In order to receive valid connection token (per device) you must use Waylay Device Hub.

![MQTT Credentials](/tutorials/mqtt/credentials.png)

If you're using MQTTfx and the TLS secured endpoint, don't forget to enable "SSL/TLS" with the "*CA signed server certificate*" option.

# MQTT authorization

Each set of credentials can only publish and subscribe to one specific topic on the domain that you belong to.

I've already created a set of credentials, and configured my client to connect to the broker using Device Hub.

The ID of my device that belongs to those credentials is `beb714f2-7b34-4239-a74c-c672f66be2e3` on the `app.waylay.io` domain.

This is a unique ID that identifies our device and is used to construct the MQTT topics.

# Subscribing

To receive messages we can subscribe to

`app.waylay.io/resources/beb714f2-7b34-4239-a74c-c672f66be2e3/commands`

![Subscribing to a topic](/tutorials/mqtt/subscribe.png)

# Publishing
Similarly we can send messages by posting some data to the following topic:

`app.waylay.io/resources/beb714f2-7b34-4239-a74c-c672f66be2e3/events`

# Bridging protocols

This is the exciting part. The Waylay broker allows us to bridge protocols — send a message via Web Sockets on a browser and receive a message on your MQTT enabled device!

![Subscribing to a topic](/tutorials/mqtt/websockets.png)
*Make sure to include the resource ID in the message.*

![Subscribing to a topic](/tutorials/mqtt/received.png)

Works like a charm!

If you want to know more, you can find more detailed information on our [documentation portal](/usage/broker-and-storage/)

If you're excited to give it a try, [request a demo](https://waylay.io/)!

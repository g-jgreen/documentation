---
title: Broker and Storage
description: How to use the Waylay broker and storage APIs
weight: 3
---

Waylay Broker url is: [https://data.waylay.io](https://data.waylay.io)

We also have a small [test application](https://data.waylay.io/test?domain=yourdomain) that lets you play with the different options.

# Resources

All data handled by the broker is linked to a `resource`.  A resource is a generic identifier and can represent devices, persons, cars, customers, anything…

# Events and commands

For each `resource` we provide two channels:

* `events` are messages emitted by the `resource`. eg temperature readings or alarms
* `commands` are messages directed at the `resource`. eg turn on the light, send an email, apply new configuration

# Authentication

You will most of the time need to provide 2 things when connecting to the broker:

* your domain, eg customer.waylay.io can be provided in the url or in the body of the request
* credentials (apiKey, apiSecret), provided by http basic authentication or where not possible in the url (websockets)

For more sensitive environments we also have a device gateway where you can get per-device credentials. These credentials only allow sending or receiving data on the device's channel.


# Posting messages towards Broker

The waylay data endpoint lets you store and distribute messages. This can be performed over different protocols: [http](#http), [websockets](#websockets) or [mqtt](#mqtt).

As soon as data is send to the Broker, data is stored in two different databases, **time series database and document database**. In the document storage, data is stored without any pre-processing, with original JSON object as it was received. When JSON object (or array of JSON objects) comes to the Broker, Broker also tries to save data in the time series database. In order to achieve that, broker will inspect incoming JSON object and store every metric that is found in the JSON object.  

To keep your data private you use your waylay api key and secret + you provide the domain where you normally access the waylay system. This will also enable the forwarding of your data to your tasks or buckets.

A submitted message is defined by 3 things

* `domain` this identifies your waylay account, eg `sandbox.waylay.io`
* `resource`  this is the identifier of the thing the submitted data is coming from (phone, car, person, server, ...)
* `payload` the content of the message, this can be any key-value pair and as most of the time provided as a json object. eg: `{"temp":21, "humidity": 0.35}`

For instance, the resource can be the `phone` and the parameters something like `temperature, humidity, acceleration` etc.

*Important Note* : Data will be stored with the timestamp when the object arrived at the Broker. Should you wish to insert data with other timestamp, you must in the JSON object provide a timestamp with a value that is in epoch in milliseconds. For instance: `{"temp":21, "humidity": 0.35, "timestamp" : 1475139600000}`

# <a name="http"></a> HTTP REST API

The REST API is mainly intended for devices that have an HTTP stack available and don't need to send huge amounts of data. It also allows you to fetch the current and last 100 items from the store.

First you will need to fetch your API key from the profile page.

## Available urls

```text
GET           /resources/:resourceId/events              // last n / sse / ws publish
GET           /resources/:resourceId/events/subscribe    // ws
GET           /resources/:resourceId/events/publish      // ws
POST          /resources/:resourceId/events

GET           /resources/:resourceId/commands            // last n / sse / ws subscribe
GET           /resources/:resourceId/commands/subscribe  // ws
GET           /resources/:resourceId/commands/publish    // ws
POST          /resources/:resourceId/commands
```

 * Websocket urls are marked with `ws`
 * *Server-Sent Events* urls are marked with `sse`
 * The resources return the last n events or a stream in case of websocket or server sent events

### Posting data to storage

```bash
curl -i \
    --user apiKey:apiSecret \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"foo":123, "bar":"hello"}' \
    https://data.waylay.io/resources/testresource/events?domain=sandbox.waylay.io
```

or
```bash
curl -i \
    --user apiKey:apiSecret \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"foo":123, "bar":"hello", "domain":"sandbox.waylay.io"}' \
    https://data.waylay.io/resources/testresource/events
```
or
```bash
curl -i \
    --user apiKey:apiSecret \
    -H "Content-Type: application/json" \
    -X POST \
    -d '{"foo":123, "bar":"hello", "resource":"testresource", "domain":"sandbox.waylay.io"}' \
    https://data.waylay.io/messages
```

# Websockets

## Per resource

You can also set up web sockets for a specific resource

Endpoints to connect to using secure web sockets:

```text
wss://data.waylay.io/resources/:resourceId/commands/subscribe (listening to commands)
wss://data.waylay.io/resources/:resourceId/commands/publish (publishing commands to an other device)
wss://data.waylay.io/resources/:resourceId/events/subscribe (listening to events from a device)
wss://data.waylay.io/resources/:resourceId/events/publish (publishing events)
```

The [test application](https://data.waylay.io/test?domain=yourdomain) lets you play with websocket support.

## Global

The global websocket API is mainly meant for publish functionality, like connecting other brokers to the waylay data endpoint.

`wss://data.waylay.io/socket?domain=sandbox.waylay.io` with HTTP BASIC authentication using your waylay API key and secret

The endpoint allows you to submit messages in JSON format.

```json
{
  "resource": "car_1ABC123",
  "engine_temp_c": 80,
  "doors_locked": false,
  ...
}
```

When submitting invalid data you will get a response back with an error message.

```json
{
  "error": "Json parse error",
  "details": [
    "/resource <- String value expected"
  ]
}
```

# <a name="mqtt"></a> MQTT

Our MQTT endpoints are meant to be used by low-power devices. Devices need to be registered on the device hub before they can send/receive messages over MQTT.

More info is available in this blog post:
[MQTT blog](http://waylayio.github.io/announcement/2016/07/01/announcing-mqtt-on-waylay.html)

# Retrieving data

## Time series data

### Getting raw time series data

You can specify *from* (epoch time in milliseconds) and *to* (it can be omitted, then it will take a current time), example:
```bash
curl -i \
    --user apiKey:apiSecret \
    https://data.waylay.io/resources/testresource/series/temperature? \
    domain=sandbox.waylay.io&from=1472947200000&until=1474588800000
```

### Aggregates

You can get data on which already grouping and/or aggregation is computed:

* mean
* medium
* min
* max
* sum

Grouped by

* none (just skip in the query)
* auto
* second
* minute
* hour
* day
* week

Example:
```bash
curl -i \
     --user apiKey:apiSecret \
     https://data.waylay.io/resources/testresource/series/temperature? \
     domain=sandbox.waylay.io&&from=1472947200000&until=1474588800000&grouping=hour&aggregate=mean
```

## Document data

You can always retrieve up to the last 100 data points for every resource over the REST calls. Coming back to the example where resource is the phone, waylay platform would store 100 data points, where each data point would hold information about underlying parameters (temperature, humidity etc.)

### Getting latest value from storage

```bash
curl -i \
    --user apiKey:apiSecret \
    https://data.waylay.io/resources/testresource/current?domain=sandbox.waylay.io
```

### Getting history from storage
```bash
curl -i \
    --user apiKey:apiSecret \
    https://data.waylay.io/resources/testresource/series?domain=sandbox.waylay.io
```

## Streaming using WebSockets

You can stream data for a specific resource by setting up a WebSocket to the following url

```text
wss://data.waylay.io/resources/testresource/socket?domain=app.waylay.io&apiKey=...&apiSecret=...
```

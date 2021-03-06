---
title: Broker and Storage
description: How to use the Waylay broker and storage APIs
weight: 3
---

# Waylay Broker

Waylay Broker is at this URL: [https://data.waylay.io](https://data.waylay.io)

We also have a small [test application](https://data.waylay.io/test) that lets you play with the different options.

# Authentication

When connecting to the broker, you need to provide your credentials (apiKey, apiSecret) by http basic authentication or where not possible in the url (websockets)

For more sensitive environments we also have a device gateway where you can get per-device credentials. These credentials only allow sending or receiving data on the device's channel.


# Resources

All data handled by the broker is linked to a `resource`.  A resource is a generic identifier and can represent devices, persons, cars, customers, anything…

# Events and commands

For each `resource` we provide two channels:

* `events` are messages emitted by the `resource`. eg temperature readings or alarms
* `commands` are messages directed at the `resource`. eg turn on the light, send an email, apply new configuration

# Posting messages towards Broker

The waylay data endpoint lets you store and distribute messages. This can be performed over different protocols: [http](#http), [websockets](#websockets) or [mqtt](#mqtt).

As soon as data is send to the Broker, data is stored in two different databases, **time series database and document database**. In the document storage, data is stored without any pre-processing, with original JSON object as it was received. When JSON object (or array of JSON objects) comes to the Broker, Broker also tries to save data in the time series database. In order to achieve that, broker will inspect incoming JSON object and store every metric that is found in the JSON object.  

To keep your data private you use your waylay api key and secret. This will also enable the forwarding of your data to your tasks or buckets.

A submitted message is defined by 2 things

* `resource`  this is the identifier of the thing the submitted data is coming from (phone, car, person, server, ...)
* `payload` the content of the message, this can be any key-value pair and as most of the time provided as a json object. eg: `{"temp":21, "humidity": 0.35}`

For instance, the resource can be the `phone` and the parameters something like `temperature, humidity, acceleration` etc.

*Important Note* : Data will be stored with the timestamp when the object arrived at the Broker. Should you wish to insert data with other timestamp, you must in the JSON object provide a `timestamp` with a value that is in epoch in milliseconds. For instance: `{"temp":21, "humidity": 0.35, "timestamp" : 1475139600000}`

# <a name="http"></a> HTTP REST API

The REST API is mainly intended for devices that have an HTTP stack available and don't need to send huge amounts of data. It also allows you to fetch the current and last 100 items from the store.

First you will need to fetch your API key from the profile page.

## Available urls

> Available urls

```bash
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

## Posting data (object) to the storage and rule engine

When you post a message, by default, the message is both forwarded to the rule enging and stored in three different databases (document store, time series database and metamodel).

> Example of posting data using resource events endoint:

```bash
curl -i --user apiKey:apiSecret  -H "Content-Type: application/json" -X POST
    -d '{
          "foo":123,
          "bar":"hello"
      }'
    https://data.waylay.io/resources/testresource/events
```

> Example of posting data with resource defined in the payload:

```bash
curl -i  --user apiKey:apiSecret -H "Content-Type: application/json" -X POST
    -d '{
        "foo":123,
        "bar":"hello",
        "resource":"testresource"
        }'
    https://data.waylay.io/messages
```

There are multiple ways to post the same message towards the Broker.

## Posting array of objects
You can post objects as an array.

> BULK import

```bash
curl -i  --user apiKey:apiSecret
    -H "Content-Type: application/json"
    -X POST \
    -d '[
      {   
          "foo": 12,
          "bar":"hello",
          "resource":"testresource1",
      },  {   
          "foo": 33,
          "bar":"world",
          "resource":"testresource2",
      }]'
    https://data.waylay.io/messages
```

## Forwarding data to the rule engine, without the storage

> Example of posting data to the engine only, using resource events endoint:

```bash
curl -i --user apiKey:apiSecret  -H "Content-Type: application/json" -X POST
    -d '{
          "foo":123,
          "bar":"hello"
      }'
    https://data.waylay.io/resources/testresource/events?store=false
```

## Forwarding data to the storage, without forward to the engine

> Example of posting data to the engine only, using resource events endoint:

```bash
curl -i --user apiKey:apiSecret  -H "Content-Type: application/json" -X POST
    -d '{
          "foo":123,
          "bar":"hello"
      }'
    https://data.waylay.io/resources/testresource/events?forward=false
```

## Posting data with a specified time-to-live

> Example of posting data which will only be available for 3600s:

```bash
curl -i --user apiKey:apiSecret  -H "Content-Type: application/json" -X POST
    -d '{
          "foo":123,
          "bar":"hello"
      }'
    https://data.waylay.io/resources/testresource/events?ttl=3600
```
When posting data, you can specify how long the data needs to be available in the system (both in the timeseries database
 and the document database). After this time the data is automatically removed.
 
You specify this by the query parameter `ttl`, either specified as a number of seconds,
or with a period in the format `#[w,d,h,m,s]` ( as in # weeks/days/hours/minutes/seconds )

> Example of posting data which will be available for 52 weeks:

```bash
curl -i --user apiKey:apiSecret  -H "Content-Type: application/json" -X POST
    -d '{
          "foo":123,
          "bar":"hello"
      }'
    https://data.waylay.io/resources/testresource/events?ttl=52w
```


# Websockets

## Per resource

You can also set up web sockets for a specific resource

> Endpoints to connect to using secure web sockets:

```bash
wss://data.waylay.io/resources/:resourceId/commands/subscribe (listening to commands)
wss://data.waylay.io/resources/:resourceId/commands/publish (publishing commands to an other device)
wss://data.waylay.io/resources/:resourceId/events/subscribe (listening to events from a device)
wss://data.waylay.io/resources/:resourceId/events/publish (publishing events)
```

The [test application](https://data.waylay.io/test) lets you play with websocket support.
Remark that the `subscribe` connections are kept alive by empty `{}` json messages if no traffic has passed in 1 minute.

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

> Getting raw time series data

```bash
curl -i --user apiKey:apiSecret
    'https://data.waylay.io/resources/testresource/series/temperature? \
    from=1472947200000&until=1474588800000'
```

> Getting the latest value for a series

```bash
curl -i --user apiKey:apiSecret
    'https://data.waylay.io/resources/testresource/series/temperature/latest'
```

You can specify *from* (epoch time in milliseconds) and *to* (it can be omitted, then it will take a current time), example:


### Aggregates

> Group by example:

```bash
curl -i \
     --user apiKey:apiSecret \
     'https://data.waylay.io/resources/testresource/series/temperature? \
     from=1472947200000&until=1474588800000&grouping=hour&aggregate=mean'
```

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


## Messages

> Getting latest message from storage

```bash
curl -i --user apiKey:apiSecret \
    https://data.waylay.io/resources/testresource/current
```

> Getting latest messages from storage

```bash
curl -i --user apiKey:apiSecret \
    https://data.waylay.io/resources/testresource/series
```

You can always retrieve up to the last 100 messages for every resource over the REST calls. Coming back to the example where resource is the phone, waylay platform would store 100 messages, where each message would hold information about underlying parameters (temperature, humidity etc.)

<aside class="notice">
In default pricing, we offer up to 100 latest points. This can as well be much higher if required.
</aside>

## Streaming all messages using NDJSON

This is a firehose stream of all messages that are sent to the broker. If you can not keep up with reading the stream messages will be dropped!
The connection is kept alive by sending empty `{}` json messages if no traffic has passed in 1 minute.

```bash
curl -i --user apiKey:apiSecret https://data.waylay.io/messages
```

## Streaming using WebSockets

> Streaming using WebSockets

```bash
wss://data.waylay.io/resources/testresource/socket?apiKey=...&apiSecret=...
```

You can stream data for a specific resource by setting up a WebSocket to the following url.
Remark that the connection is kept alive by empty `{}` json messages if no traffic has passed in 1 minute.

# Deleting data
## Messages

> Removing all messages

```bash
curl -i --user apiKey:apiSecret -X DELETE \
    https://data.waylay.io/resources/testresource/messages
```

You can remove all latest messages for a resource. This will not delete timeseries data for the properties of those messages.

## All data for a resource
> Removing all data

```bash
curl -i --user apiKey:apiSecret -X DELETE \
     https://data.waylay.io/resources/testresource
```

> Removing all data before some date

```bash
curl -i --user apiKey:apiSecret -X DELETE \
     https://data.waylay.io/resources/testresource?until=1501538400000
```

You can delete all data (both messages and timeseries data) for a resource.

Specifying the query parameter `until` will only delete the data until (and including) the provided timestamp (milliseconds since epoch).
The parameter also allows to specify a relative period in the format `#[w,d,h,m,s,ms]`. This period will be substracted from
the current time to become the until timestamp

> Remove all data older then 7 days

```bash
curl -i --user apiKey:apiSecret -X DELETE \
     https://data.waylay.io/resources/testresource?until=7d
```
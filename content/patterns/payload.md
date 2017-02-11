---
title: JSON payload transformation and enrichment
description: Learn how apply payload transformation using streamBridgeSensor and script sensor
weight: 4
tags: [ "Development", "Rules"]
categories: [ "Development" ]
series: [ "Common Patterns" ]
---
In this example, we will assume that we get the room temperature via the stream interface (device connected using Sigfox, LoRA, MQTT,...), and that we want to enrich the payload with the outside temperature before pushing that message further (either for storage, email, SMS etc...).

This rule will be using conditional sensor execution feature (flow control), as described in the previous [example](/patterns/flow-control/). We are this time using `streamBridgeSensor`, even though we could have used the `streamDataSensor` as well. `StreamBridge` sensor actually does nothing with stream data, it only forwards it [via rawData](/api/sensors-and-actuators/#sensor-example). Every time it receives new data, it also toggles its state. And that's it.

In order to fetch the outside temperature, we will use the sensor that uses external API service, called `temperature_1`. This sensor is configure to execute on the [state change](usage/tasks-and-templates/) * -> *, which means that any time bridgeSensor receives the data, this sensor will fetch the new measurement via the API call.

![image](/rules/payload/payload1.png)

For payload transformation, we used the script sensor. Waylay allows you to store [new sensors and actuators](api/sensors-and-actuators/) (similar to lambda functions), or like in this case, you can as well define the script inside the template, without storing it:
```
var stream = waylayUtil.getRawData(options, "streamBridgeData")
var temp = waylayUtil.getRawData(options, "temperature_1")

var rawData = {
    insideTemperature: stream.streamData.temperature,
    outsideTemperature : temp.temperature,
    condition: temp.state
}

send(null, {observedState : "done", rawData : rawData})
```

Inside the script, you can use all javascript functions, a lot of [sandboxed packages](api/sensors-and-actuators/#sandbox) and many waylay specific [utility functions](api/sensors-and-actuators/#utility-functions).


Let's start a task using this template (e.g. saved as "payload") in the reactive mode like this:
```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "payload processing",
    "template": "payload",
    "resource": "testresource",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```


now let's push some data via [broker](/api/broker-and-storage/):

```
 curl --user apiKey:apiSecret
    -H "Content-Type: application/json"
    -X POST  
    -d '{
         "temperature": 21,
         "resource": "testresource",
         "domain": "sandbox.waylay.io"
      }'
      "https://data.waylay.io/messages?store=false"
 ```

If we run this task in the debug mode, we can also see the debug messages any time a new data arrives:

```
13:43:32.731 DEBUG Node streamBridgeData sensor streamBridgeData rawData = { "streamData" : { "temperature" : 21 } }
13:43:32.731 INFO Node streamBridgeData sensor streamBridgeData returned state toggle2
13:43:32.763 DEBUG temperature_1 2017-02-09T12:43:32.763Z INFO {"coord":{"lon":3.72,"lat":51.05},"weather":[{"id":701,"main":"Mist","description":"mist","icon":"50d"}],"base":"stations","main":{"temp":0.59,"pressure":1027,"humidity":86,"temp_min":0,"temp_max":1},"visibility":3300,"wind":{"speed":2.6,"deg":70},"clouds":{"all":75},"dt":1486641300,"sys":{"type":1,"id":4839,"message":0.1617,"country":"BE","sunrise":1486624064,"sunset":1486659100},"id":2797656,"name":"Gent","cod":200}
13:43:32.764 DEBUG Node temperature_1 sensor temperature rawData = { "temperature" : 0.59, "pressure" : 1027, "humidity" : 86, "temp_min" : 0, "temp_max" : 1, "wind_speed" : 2.6, "clouds_coverage" : 75, "sunrise" : 1486624064, "sunset" : 1486659100, "longitude" : 3.72, "latitude" : 51.05, "name" : "Gent", "condition" : "Mist", "icon" : "http://openweathermap.org/img/w/50d.png" }
13:43:32.764 INFO Node temperature_1 sensor temperature returned state Cold
13:43:32.774 DEBUG Node scriptSensor_1 sensor scriptSensor rawData = { "insideTemperature" : 21, "outsideTemperature" : 0.59, "condition" : "Cold" }
```

As we can see, the payload script has transformed the message into this:
```
{   
    "insideTemperature" : 21,
    "outsideTemperature" : 0.59,
    "condition" : "Cold"
}
```

Let's now send this message via email and store it into Azure Cloud:

![image](/rules/payload/payload_store.png)

{{% alert info %}}
debug actuator was formatted with message:
`Outside temperature is {{scriptSensor_1.outsideTemperature}}, inside temperature is {{scriptSensor_1.insideTemperature}}`
{{% /alert %}}

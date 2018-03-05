---
title: How to synchronize different data streams
description: Learn how to combine events from parallel streams
weight: 7
---

This is one of the most exciting features of Waylay!

With flow engines, designers are constrained to follow the “message flow”, from "left to right". Interesting problem arises when 2 inputs come at different times. How long do you wait for the next one to arrive before deciding to move on in decisions? How long is the data point/measurement valid?
Wouldn't be great if we can just annotate how long any particular information is valid?

In waylay, we can simply use eviction policy to define how long we trust the sensor output. Let's see how this works in practice:

![image](/rules/mix_streams/mix_streams.png)

What we can see in this example are two streamDataSensors, each configured with 5 seconds eviction policy. Each sensor will get triggered any time we push data (first sensor will be triggered when resource `test1` pushes data and the other will get executed for `test2` resource)

We will start a task using this template (e.g. saved as "mix_streams") in the reactive mode like this:
```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing",
    "template": "mix_streams",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

Let's first push data via [broker](/api/broker-and-storage/) for resource `test1`:

```
curl --user apiKey:apiSecret
 -H "Content-Type: application/json"
 -X POST  
 -d '{
      "temperature": 23,
      "resource": "test1",
      "domain": "sandbox.waylay.io"
   }'
  "https://data.waylay.io/messages?store=false"
```

![image](/rules/mix_streams/test1.png)

Let's wait more than 5 seconds, and push data for `test2`

```
curl --user apiKey:apiSecret
 -H "Content-Type: application/json"
 -X POST  
 -d '{
      "temperature": 23,
      "resource": "test2",
      "domain": "sandbox.waylay.io"
   }'
  "https://data.waylay.io/messages?store=false"
```

![image](/rules/mix_streams/test2.png)

{{% alert info %}}
Note how sensor `streamDataSensor1` had its state evicted after 5 seconds.
{{% /alert %}}

Let's now push both data at the same time and let's see what happens:
![image](/rules/mix_streams/both.png)

Great! Only when both streams arrived within 5 seconds, Gate named BothAbove, which was configured to be in TRUE state if and only if, the streamSensorData sensors were both above the threshold was triggered.

{{% alert info %}}
debug actuator attached to the gate was formatted with message:
`temp1 {{streamingDataSensor_1.parameter}} and temp2 {{streamingDataSensor_1.parameter}}`
{{% /alert %}}

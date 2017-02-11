---
title: Mixing push and pull events, with conditional sensor execution
description: Learn how to execute pull sensor after stream processing
weight: 5
---
In this example, we will learn how to trigger a polling sensor after stream data is processed. We used the same template from the first [example](/patterns/stream-data-threshold-crossing/). Now we have added a polling sensor that triggers on * -> *, meaning that it will trigger every time after the stream data node is executed (which results in the new state: Below, Equal or Above).


![image](/rules/push-and-pull-1/mix_push_pull1_fig1.png)

{{% alert info %}}
Please note the use we use exactly the same way the resource field as in the first example.
{{% /alert %}}

If we start a task using this template (e.g. saved as "template3") in the reactive mode like this:
```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing",
    "template": "template3",
    "resource": "testresource",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

{{% alert info %}}
Note that we stared a task with resource named `testresource`,
{{% /alert %}}

and if data gets pushed via [broker](/api/broker-and-storage/):

```
 curl --user apiKey:apiSecret
    -H "Content-Type: application/json"
    -X POST  
    -d '{
         "temperature": 23,
         "humidity": 73,
         "resource": "testresource",
         "domain": "sandbox.waylay.io"
      }'
      "https://data.waylay.io/messages?store=false"
 ```

We can see the debug message any time new data arrives (with temperature above 21)

![image](/rules/push-and-pull-1/mix_push_pull1_fig2.png)

{{% alert info %}}
debug actuator was formatted with message:
`Temperature is {{streamingDataSensor_1.parameter}} and outside temperature {{currentWeather_1.temperature}}`
{{% /alert %}}

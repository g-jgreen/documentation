---
title: Mixing push and pull events, general case
description: Learn how to combine push and pull events in parallel
weight: 6
---
This example will be very similar to [the previous one](/patterns/push-and-pull-1/), where we conditionally executed weather sensor every time we received the stream data. This example is a little bit different, in a sense that both sensors will be executed independently. Stream data sensor will be executed as soon as it receives stream data, while the polling sensor will be checking outside temperature every 5 minutes (300 seconds).


![image](/rules/push-and-pull-2/fig1.png)

{{% alert info %}}
Please note that the polling sensor is configured with polling period of 5 minutes, and eviction time of 10 minutes.
{{% /alert %}}

Now, let's configure the gate. In this example, we are only interested in having stream data above the threshold as defined in the `streamDataSensor`, and we want to be sure that the collection of the outside temperature was successful (since we selected all possible states for the node `temp`).

There is also another interesting property we used, `the eviction time`. This way, we will avoid taking action (by attaching actuator to the gate), if the information that comes from the temp sensor is not any more valid. For instance, if the external API is down for longer than 10 minutes, we will avoid taking action, since the Gate in that case will never be in the state TRUE.


![image](/rules/push-and-pull-2/gate.png)



If we start a task using this template (e.g. saved as "template4") in the reactive mode like this:
```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing",
    "template": "template4",
    "resource": "testresource",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

{{% alert info %}}
Note that even though we have started the task in reactive mode, we still can poll for data on every node individually (in this case `temp` sensor has polling defined on the node level).
{{% /alert %}}

We can see that the temp sensor has already collected weather information (it will do this every 5 minutes). We also see that Gate has not triggered any debug message yet, since the streamData sensor is not observed yet.

![image](/rules/push-and-pull-2/fig3.png)

Let's now send some data via [broker](/api/broker-and-storage/):

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

Right after this, we can see the debug message that was attached to the streamData, and at the same time, the debug message that was attached to the outcome of the Gate (with state TRUE).

![image](/rules/push-and-pull-2/fig4.png)

{{% alert info %}}
debug actuator was formatted with message:
`Temperature is {{streamingDataSensor_1.parameter}} and outside temperature {{currentWeather_1.temperature}}`
{{% /alert %}}

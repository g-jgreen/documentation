---
title: Threshold crossing with stream data
description: Learn how to use stream data for simple threshold crossing
weight: 1
tags: [ "Development", "Rules"]
categories: [ "Development" ]
series: [ "Go Web Dev" ]
---

This is the simplest rule to create. Just use the streamDataSensor, put in the input properties metric that we are interested in and set the threshold. 


![image](/rules/stream_data_threshold_crossing/stream_threshold_crossing.png)

{{% alert info %}}
Please note the use of the resource field on the node level and only execute on data option enabled.
{{% /alert %}}

The `resource` is a unique identifier of a ‘thing’. When a ‘thing’ pushes streaming data to the Waylay platform, it provides its unique identifier, i.e. a resource name. Each resource can push multiple parameters to the Waylay broker. The Waylay framework will automatically distribute resource parameters to tasks and nodes with the corresponding resource name. E.g. with the `execute on data` option, sensors with the corresponding resource name will automatically get invoked when new streamed data with the same resource name becomes available. The resource name can be specified at the task level and at the node level. In case we have many sensors in the task that share the same resource name, or if we want to invoke tasks that share the same template for different sensors (e.g. water meters), we may want to specify it at the task level and inherit it at the node level via the **$** symbol.

If we start a task using this template (e.g. saved as "template1") in the reactive mode like this:
```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing",
    "template": "template1",
    "resource": "testresource",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

In case we want to start a task without a template, we could as we have done this by simply [declaring the rule in the request] (/api/rest/#create-a-task-with-rule-defined-in-the-request):

```
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
  "sensors": [
    {
      "label": "streamDataSensor_1",
      "name": "streamingDataSensor",
      "version": "1.1.0",
      "resource" : "$",
      "position": [173, 158]
    }
  ],
  "actuators": [
    {
      "label": "debugDialog_1",
      "name": "debugDialog",
      "version": "1.0.4",
      "properties": {
        "message": "Temparature is {{streamingDataSensor_1.parameter}}"
      },
      "position": [600, 199]
    }
  ],
  "triggers": [
    {
      "destinationLabel": "debugDialog_1",
      "sourceLabel": "streamDataSensor_1",
      "statesTrigger": ["Above"]
    }
  ],
  "task": {
    "type": "reactive",
    "start": true,
    "name": "Rule 1",
    "resource": "testresource"
  }
}' "https://sandbox.waylay.io/api/tasks"
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

![image](/rules/stream_data_threshold_crossing/stream_data_fig2.png)

{{% alert info %}}
debug actuator was formatted with message:
`Temparature is {{streamingDataSensor_1.parameter}}`
{{% /alert %}}



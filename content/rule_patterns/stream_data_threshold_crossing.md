---
title: Threshold crossing with stream data
description: Learn how to use stream data for simple threshold crossing
weight: 1
---

This is the simplest rule to create. Just use the streamDataSensor, put in the input properties metric that you are interested in and set the threshold. 


![image](/rules/stream_data_threshold_crossing/stream_threshold_crossing.png)

{{% alert info %}}
Please note the use of the resource field on the node level and only execute on data option enabled.
{{% /alert %}}

The `resource` is a unique identifier of a ‘thing’. When a ‘thing’ pushes streaming data to the Waylay platform, it provides its unique identifier, i.e. a resource name. Each resource can push multiple parameters to the Waylay broker. The Waylay framework will automatically distribute the resource parameters to the tasks and nodes with the corresponding resource name. E.g. with the `execute on data` option, the sensors with the corresponding resource name will automatically get invoked when new streamed data with the same resource name becomes available. The resource name can be specified at the task level and at the node level. In case you have many sensors in your task that share the same resource name, you may want to specify it at the task level and inherit it at the node level via the **$** symbol.

For instance, if you run this template in the reactive mode, with task resource named `testresource`, and data gets pushed via [broker](/usage/broker-and-storage/):

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

 You can see the debug message any time new data arrives (with temperature above 21)

![image](/rules/stream_data_threshold_crossing/stream_data_fig2.png)

{{% alert info %}}
debug actuator was formatted with message:
`Temparature is {{streamingDataSensor_1.parameter}}`
{{% /alert %}}

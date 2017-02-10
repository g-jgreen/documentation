---
title: State pattern matching
description: Learn how to use Function node for pattern matching
weight: 11
tags: [ "Development", "Rules"]
categories: [ "Development" ]
series: [ "Go Web Dev" ]
---

In this example will use the stream node the Function node. Stream node is configured the same way as in one of the previous [examples](rule_patterns/stream_data_threshold_crossing/). In order to track stream sensor state changes, we will use `sequence` formula, as described [here](api/sensors-and-actuators/#sequence)

For instance, function below will either return 1 or 0. 1 indicates that a match of the sequence has been found, which in this case was state transitions `hello -> world` for the node `node`. 

`<sequence([hello,world], node.state)>`

You can also use this snippet multiple times in your function. For instance you can check state transitions for these 3 nodes.

`<sequence([hello,world], node1.state)>`  + `<sequence([hello,world], node2.state)>` + `<sequence([hello,world], node3.state)>`

and test whether the result equals 3.

Here is our template:

![image](/rules/pattern/pattern.png)

In this example, function node formula is defined as `<sequence([Below,Above, Below], streamingDataSensor_1.state)>` with `threshold` 1.

{{% alert info %}}
Please note that we also used [state transition](/rule_patterns/flow_contrl/) * -> * to trigger Function node computation after streamSensor has processed new data. 
{{% /alert %}}

If we start a task using this template (e.g. saved as "pattern_matching") in the reactive mode like this:

```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing",
    "template": "pattern_matching",
    "resource": "testresource",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

and if pushed via [broker](/api/broker-and-storage/) which has this sequence of temperatures (3, 23, 3):

```
curl --user apiKey:apiSecret  -H "Content-Type: application/json" -X POST  
  -d '{ 
        "temperature": 3, 
        "humidity": 73, 
        "resource": "testresource", 
        "domain": "sandbox.waylay.io"
     }'
  "https://data.waylay.io/messages?store=false"
sleep 1
curl --user apiKey:apiSecret -H "Content-Type: application/json" -X POST  
  -d '{ 
       "temperature": 23, 
       "humidity": 73, 
       "resource": "testresource", 
       "domain": "sandbox.waylay.io"
    }'
  "https://data.waylay.io/messages?store=false"
sleep 1
curl --user apiKey:apiSecret -H "Content-Type: application/json" -X POST  
  -d '{ 
       "temperature": 3, 
       "humidity": 73, 
       "resource": "testresource", 
       "domain": "sandbox.waylay.io"
    }'
 "https://data.waylay.io/messages?store=false"
 ```

First in the debug window we can verify that new data arrives (metric view)

![image](/rules/pattern/raw.png)

and in the state transition view, we can also see Funciton node being in Equal state (orange color) every time it matches the sequence `(Below->Above->Below)`. Awsome!

![image](/rules/pattern/states.png)


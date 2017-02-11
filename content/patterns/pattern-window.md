---
title: State pattern matching - within a time window
description: Learn how to detect a pattern within a time window
weight: 13
tags: [ "Development", "Rules"]
categories: [ "Development" ]
series: [ "Common Patterns" ]
---

This example builds on top of the other two examples: [state pattern matching](/patterns/pattern/) and [raise the alarm if the event found for predefined period of time](/patterns/alarm-with-delay/). If you have not read them yet, please studied them first.

In this example (like in the previous), the function node formula is defined as `<sequence([Below,Above, Below], streamingDataSensor_1.state)>` with `threshold` 1.

![image](/rules/pattern_delay/pattern_delay.png)

{{% alert info %}}
Please note that we also used [state transition](/patterns/flow-control/) * -> Equal to execute Delay node. That means that it will only be triggered in the Function node found the right pattern.
{{% /alert %}}

If we start a task using this template (e.g. saved as "pattern_matching_delay") in the reactive mode like this:

```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Pattern matching",
    "template": "pattern_matching_delay",
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
and wait 10 seconds after that, we shall see the alarm:

![image](/rules/pattern_delay/pattern_delay1.png)

If you continue sending data, and if the pattern repeats itself, but in shorter period (meaning that the next data arrives that changes the pattern), alarm will not be raised.
As you can see in the picture, by the time the Delay sensor was in the `Trigger` state, Function node was in back in state `Below`, since the sequence on the input data changed in meantime. That meant that no ALARM was raised.

![image](/rules/pattern_delay/pattern_delay2.png)


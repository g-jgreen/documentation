---
title: Raise the alarm if there is no data for predifined period of time
description: Learn how to use Delay node and stream sensor
weight: 10
---

This [template](rule_patterns/alarm_with_delay/) will be almost exactly the same as the previous one ("Raise the alarm if the stream data is above the threshold for predifined period of time"). So, if you have not studied that one, please read it first.


Here is our template. Condition to raise the alarm if the stream data is above the threshold for predifined period of time was achived using `AND Gate`, which was configured to be `TRUE` when  both `Delay` sensor was in the state `Triggered` and the `stream` sensor was above the threshold. 

This time we have configured the state transition for `Delay` sensor as * -> * and the **eviction policy**. That would mean that we would fire the alarm if there was no new data coming for longer than 5 seconds. Have a look

![image](/rules/no_data/no_data1.png)

If we start a task using this template (e.g. saved as "no_data") in the reactive mode like this:

```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing with no data",
    "template": "no_data",
    "resource": "testresource",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

and if push data via [broker](/api/broker-and-storage/) which has this sequence of temperatures (23, 3), with the delay of 6 seconds in between, we shall see the alarm (attached to the gate) every time after 5 seconds.

```
curl --user apiKey:apiSecret -H "Content-Type: application/json" -X POST  
  -d '{ 
       "temperature": 23, 
       "humidity": 73, 
       "resource": "testresource", 
       "domain": "sandbox.waylay.io"
    }'
  "https://data.waylay.io/messages?store=false"
sleep 6
curl --user apiKey:apiSecret -H "Content-Type: application/json" -X POST  
  -d '{ 
       "temperature": 3, 
       "humidity": 73, 
       "resource": "testresource", 
       "domain": "sandbox.waylay.io"
    }'
 "https://data.waylay.io/messages?store=false"
 ```

Let's now send some more data. We will be pushing data that is below and above the threshold. Have a look:

![image](/rules/no_data/no_data_alarm.png)

{{% alert info %}}
What we can observed from the state diagram is that we had Gate in `TRUE` (alarm) state only when new data was not coming for longer than 5 seconds. 
{{% /alert %}}


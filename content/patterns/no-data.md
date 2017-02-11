---
title: Raise the alarm if there is no data for predefined period of time
description: Learn how to use Delay node and stream sensor
weight: 12
---

Stream node is configured the same way as in one of the previous [examples](patterns/stream-data-threshold-crossing/). In order to track stream sensor state changes, we will use the `Delay` sensor. `Delay` sensor, which comes in default waylay installation is very simple: when it gets executed, it waits for a fixed amount of milliseconds before returning the state `Triggered`. In case that it gets executed again while already counting, it will reset the count and start counting from 0 again. Which means that if the delay period was defined to 5 seconds, and it was executed at `t0`, then again at `t0`+3sec, it will eventually be in the state `Triggered` after `t0`+8 seconds.

We have configured the state transition of the `Delay` sensor as * -> * and with the **eviction policy**. That would mean that we would fire the alarm if there was no new data coming for longer than 5 seconds. Have a look

![image](/rules/no-data/no_data1.png)

{{% alert info %}}
We used **eviction policy** on the delay sensor, which means that we will reset `Triggered` state once it is fired.
{{% /alert %}}

{{% alert info %}}
We also used [**state transition**](/patterns/flow-control/) `* -> *` to execute `Delay` node any time new data comes.
{{% /alert %}}

If we start a task using this template (e.g. saved as "no-data") in the reactive mode like this:

```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing with no data",
    "template": "no-data",
    "resource": "testresource",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

and if push data via [broker](/api/broker-and-storage/) we will notice that we will have an alarm after 5 seconds.

```
curl --user apiKey:apiSecret -H "Content-Type: application/json" -X POST  
  -d '{
       "temperature": 23,
       "humidity": 73,
       "resource": "testresource",
       "domain": "sandbox.waylay.io"
    }'
  "https://data.waylay.io/messages?store=false"
 ```

Let's now send some more data. We will be pushing data with different frequency. Exact values are not important. Have a look, this is the stream data view:

![image](/rules/no-data/no_data_stream.png)

And this is the state view of the same data stream:
![image](/rules/no-data/no_data_states.png)

{{% alert info %}}
What we can observed from the state diagram is that we have the `Delay` sensor in the `Triggered` (alarm) state when there was no new data for longer than 5 seconds.
{{% /alert %}}

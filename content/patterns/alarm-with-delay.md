---
title: Raise the alarm if the stream data is above the threshold for predefined period of time
description: Learn how to use Delay node, stream sensor and AND Gate
weight: 13
---

This example builds on top of the previous [one](patterns/no-data/). If you have not studied that one, please read it first.
In order to track stream sensor state changes, we will use the `Delay` sensor. `Delay` sensor, which comes in default waylay installation is very simple: when it gets executed, it waits for a fixed amount of milliseconds before returning the state `Triggered`. In case that it gets executed again while already counting, it will reset the count and start counting from 0 again. 

Which means that if the delay period was defined to 5 seconds, and it was executed at `t0`, then again at `t0`+3sec, it will eventually be in the state `Triggered` after `t0`+8 seconds.

Here is our template. Condition to raise the alarm if the stream data is above the threshold for predefined period of time was achieved using `AND Gate`, which was configured to be `TRUE` when  both `Delay` sensor was in the state `Triggered` and the `stream` sensor was above the threshold.

We have configured the state transition of the `Delay` sensor as * -> Above and with the **eviction policy**. That would mean that we would fire the alarm if the stream data was above the threshold longer than 5 seconds. 

Have a look

![image](/rules/alarm_delay/alarm_delay1.png)

{{% alert info %}}
We used **eviction policy** on the delay sensor, which means that we will reset `Triggered` state once it is fired. That way we can search for multiple cases when the stream data stays above the threshold value.
{{% /alert %}}

{{% alert info %}}
We also used [**state transition**](/patterns/flow-control/) `* -> Above` to trigger Delay node if the stream data was above the threshold.
{{% /alert %}}


{{% alert info %}}
Since `Delay` sensor is triggered by the stream node as `* -> Above` we can decide on the task level whether we want to trigger the delay node  if the stream sensor is above the threshold for a given time, or, whether we want to trigger the delay node if the stream sensor is above the threshold without any new event coming in meantime, which would potentially reset the count.
{{% /alert %}}

![image](/rules/alarm_delay/reset-task.png)

In case that the option to reset observations on each invocation was set to **true**, and the delay period was defined to 5 seconds, and the stream sensor was above threshold at `t0`, then again at `t0`+ 3 sec, delay sensor will eventually be in the state `Triggered` after `t0` + 8 seconds.

In case that the option to reset observations on each invocation was set to **false**, and the delay period was defined to 5 seconds, and the stream sensor was above threshold at `t0`, then again at `t0`+ 3sec, delay sensor will eventually be in the state `Triggered` after `t0`+5 seconds. Event at `t0`+ 3sec would not make any difference, since the stream sensor was not reset between two measuremetns (unless the eviction policy on the stream sensor was set to less than 3 seconds).

If we start a task using this template (e.g. saved as "delay") in the reactive mode like this:

```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing with delay",
    "template": "delay",
    "resource": "testresource",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

and if push data via [broker](/api/broker-and-storage/) which has this sequence of temperatures (23, 3), with the delay of 6 seconds in between, we shall see the alarm (attached to the gate). If the delay in between these two measurements was less than 5 seconds, alarm would not be triggered.

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

Let's now send some more data. We will be pushing data that is below and above the threshold, but only in the last sequence of measurements, the delay between these two values would be longer than 5 seconds. Have a look:

![image](/rules/alarm_delay/delay_2.png)

{{% alert info %}}
The red bar for the `delaySensor` shows every time the delay sensor was in state `Triggered`. Still the gate was only once in the `TRUE` state (light green bar), when both delay sensor was in the state `Triggered` and the `stream` sensor was above the threshold.
{{% /alert %}}

---
title: Timings in waylay - merging data streams and applying formula
description: Learn how to use stream data, eviction policy and conditional execution of sensors
weight: 16
tags: [ "Development", "Rules"]
categories: [ "Development" ]
series: [ "Common Patterns" ]
---

In this template, we have 2 stream nodes, with resource A, B attached respectively, and the gate that is in `TRUE` state when both stream nodes are above the threshold (could be also another stream sensors with other states, that is irrelevant for this tutorial). The gate "opens" the `Function` node (via `*->TRUE`), which then calculates formula based on the two stream raw values, and then finally, if that value is above the threshold (state `Above`) fires either actuator (via `Above`) or sensor(`*->Above`). More about state triggering you can find [here](/usage/tasks-and-templates/).

In this toturial we will describe two different concepts: eviction policy and differences between attaching actuator or sensor to the `Function` node. `Function` node is defined as `<streamingDataSensor_A.parameter> - <streamingDataSensor_B.parameter>` with threshold set to 0. Stream sensors are set with threshold crossing on temperature of 21.

First we will start with all expert settings turned off, no eviction policies and without reseting sensor states before new data arrives. 

![image](/rules/streams/rule_1.png)

{{% alert info %}}
Please note the use of the resource fields **A** and **B** on stream nodes, and the task was started in reactive mode, with **reset Reset observations on each invocation** option false.
{{% /alert %}}

The `resource` is a unique identifier of a ‘thing’. When a ‘thing’ pushes streaming data to the Waylay platform, it provides its unique identifier, i.e. a resource name. Each resource can push multiple parameters to the Waylay broker. The Waylay framework will automatically distribute resource parameters to tasks and nodes with the corresponding resource name. E.g. with the `execute on data` option, sensors with the corresponding resource name will automatically get invoked when new streamed data with the same resource name becomes available. The resource name can be specified at the task level and at the node level. In case we have many sensors in the task that share the same resource name, or if we want to invoke tasks that share the same template for different sensors (e.g. water meters), we may want to specify it at the task level and inherit it at the node level via the **$** symbol. More about this you can find [here](/usage/tasks-and-templates/)

If we start a task using this template (e.g. saved as "streamRule") in the reactive mode like this:
```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing",
    "template": "streamRule",
    "type": "reactive",
    "resetObservations" : false,
  }' https://sandbox.waylay.io/api/tasks
 ```

We will push data using [broker](/api/broker-and-storage/):

```
curl --user apiKey:apiSecret 
  -H "Content-Type: application/json"
  -X POST  
  -d '{ 
       "temperature": 23, 
       "resource": "A", 
       "domain": "sandbox.waylay.io"
    }'
    "https://data.waylay.io/messages?store=false"
 ```
and we will run the similar call to push data to resource `B`. When A is 23 and B is 22, Formula will compute to `Above` threshold.

If we want to push all data at once, we can use this call as well
```
curl -i  --user apiKey:apiSecret -H "Content-Type: application/json" -X POST \
    -d '[
      {
          "temperature": 23,
          "resource":"A"
      },  {
          "temperature": 22,
          "resource":"B"
      }]' https://data.waylay.io/messages?store=false
```

Let's watch video (till 0:00 to 3:44): {{<youtube civZ8i4YBGY >}} 

What we can notice is that stream nodes keep thier states in between getting new data. They never come back to priors. Also, as soon as new data arrives, `Gate` goes to either `TRUE` or `FALSE` state. Since the `Function` node is only triggered on `*->TRUE`, it will only compute first time `Gate` goes to `TRUE` state or when one of the stream nodes goes to `Below->Above` (they both must be `Above` for the Gate to get to `TRUE`), since only then, Gate will eventually switch from `FALSE` to `TRUE` again.
Also notice how actuator and sensor which are attached to the `Function` node act differently. Actuator attached to the `Function` directly (via `Above` state) will always fire when the Funciton is in `Above` state. Other sensor (`justDoIt`), only when the `Function` goes from `*->Above`, which in our case, means only when `Gate` state changes which then causes Function to compute, which leads formula state change, in our case from `Equal` to `Above`. 
If that is not what we want, and would rather compute the `Function` any time new data arrives, for any of two nodes, then we go the next example, where we change `resetObservations` on the task level from `false` to `true`.

Let's watch this video again (From 3:44 to 4:59): [video](https://youtu.be/civZ8i4YBGY?t=3m44s)

Now we are getting formula computed any time new data arrives. Notice that the sensor `justDoIt` triggers only when the `Function` node goes from `Equal->Above`.

In case we want Formula to always work with **latest data**, first we need to define what we mean by latest data. By making **eviction window on the stream sensors, we are actually defining the time window in which we will merge two streams**. In the following example, we will use 5 seconds eviction for each stream sensor, which means that within 5 seconds data needs to come for both sensors, in order for Gate to evaluate to `TRUE`, if both streams were `Above` the threshold.
![image](/rules/streams/rule_2.png)

Let's watch this video again (From 4:59 to 6:49): [video](https://youtu.be/civZ8i4YBGY?t=4m59s)

Finally, let's see what happens when we add the eviction policy on the Function node:

![image](/rules/streams/rule_3.png)

Let's watch this video again (From 6:49): [video](https://youtu.be/civZ8i4YBGY?t=6m49s)

Since we used the eviction policy on the `Function` node, the scriptSensor starts also executing any time Function got into `Above` state (`*->Above`). If we only needed an actuator, we would not need eviction policy to be defined on the `Function` node, since the actuator is triggered any time the `Function` node is evaluated to the `Above` state.



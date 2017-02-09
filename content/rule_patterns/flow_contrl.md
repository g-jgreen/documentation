---
title: Flow based rules
description: How to create simple flow based rules
weight: 3
---

The waylay engine belongs to the group of inference engines, and it is based on the Bayesian Networks. What does it mean? Without going too much into maths, let’s just say that every node in the graph infers its state to all other nodes, and that each node “feels” what other node is experiencing at any moment in time. More about that is described in this [blog](http://www.waylay.io/blog-one-rules-engine-to-rule-them-all.html)

Unlike flow rule engines, there is no left-right input/output logic. Information flow happens – in all directions, all the time. Unlike decision trees, the waylay engine does not model logic by branching all possible outcomes. Waylay has more elegant solution for that - based on logical gates.

Nevertheless, there are cases when we need to control the order of sensor execution (e.g. sensor requires information collected by other sensors). In waylay, there two different ways to do that, one is simply based on the [sequence number](/rule_patterns/sequence/), and the other one based on the conditional execution of the sensors. 

In case we only care that sensors are executed in a given order, sequence feature is the way to go. Should the execution of the sensor depend on the outcome of the previous sensor (including successful execution), then the conditional execution of the sensor is the feature we need.

Let's see how this works in practise:

![image](/rules/flow/flow.png)


Each node needs to be configured using the [state change trigger](usage/tasks-and-templates/) feature:

![image](/rules/flow/trigger.png)

We start a task using this template (e.g. saved as "flow") in the periodic mode like this:

```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Leakage detection",
    "template": "flow",
    "resource": "testresource",
    "type": "periodic",
    "frequence": 900000,
    "start": true
  }' https://sandbox.waylay.io/api/tasks
 ```

In this case, leakage alarm is computed based on the water consumption collected every 15 minutes. 

{{% alert info %}}
We could have as well started this template in the reactive mode, providing that the leakage alarm was pushed to the Waylay platform. In that case leakage detection sensor would not be a polling sensor but the stream sensor.
{{% /alert %}}




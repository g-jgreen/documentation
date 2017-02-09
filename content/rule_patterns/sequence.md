---
title: Control flow using sequence feature
description: Learn how to control execution of sensors with sequency feature
weight: 8
---

The waylay engine belongs to the group of inference engines, and it is based on the Bayesian Networks. What does it mean? Without going too much into maths, let’s just say that every node in the graph infers its state to all other nodes, and that each node “feels” what other node is experiencing at any moment in time. More about that is described in this [blog](http://www.waylay.io/blog-one-rules-engine-to-rule-them-all.html)

Unlike flow rule engines, there is no left-right input/output logic. Information flow happens – in all directions, all the time. Unlike decision trees, the waylay engine does not model logic by branching all possible outcomes. Waylay has more elegant solution for that - based on logical gates.

Nevertheless, there are cases when we need to control the order of sensor execution (e.g. sensor requires information collected by other sensors). In waylay, there two different ways to do that, one is simply based on the sequence number, and the other one based on the [conditional execution of the sensors](/rule_patterns/flow_contrl/). 

In case we only care that sensors are executed in a given order, sequence feature is the way to go. Should the execution of the sensor depend on the outcome of the previous sensor (including successful execution), then the conditional execution of the sensor is the feature we need.

In this example, we only care that sensors are executed in a given order. Let's see how this works in practise:

![image](/rules/sequence/sequence.png)

{{% alert info %}}
Note the small icon with a sequence number if the top left corner
{{% /alert %}}

We start a task using this template (e.g. saved as "sequence") in the periodic mode like this:

```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "sequence test",
    "template": "sequence",
    "type": "periodic",
    "frequence": 10000,
    "start": true
  }' https://sandbox.waylay.io/api/tasks
 ```

In this case, we "roll" dices every 10 seconds, where `dice2` waits for `dice1` to finish and `dice3` will be executed after `dice2`.





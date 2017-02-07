---
title: Flow control
description: How to create simple flow based rules
weight: 2
---

The waylay engine belongs to the group of inference engines, and it is based on the Bayesian Networks. What does it mean? Without going too much into maths, let’s just say that every node in the graph infers its state to all other nodes, and that each node “feels” what other node is experiencing at any moment in time. More about that you can find in this [blog](http://www.waylay.io/blog-one-rules-engine-to-rule-them-all.html)

Unlike flow rule engines, there is no left-right input/output logic. Information flow happens – in all directions, all the time. Unlike decision trees, the waylay engine does not model logic by branching all possible outcomes. Waylay has more elegant solution for that - based on logical gates.

Neverthelss, there are cases in when you want to control the order of sensor execution. In waylay, there two different ways to do that, one is simply based on the [sequence number](/rule_patterns/sequence/), and the other one based on conditional execution of the sensors.

Let's see how this work in practise:




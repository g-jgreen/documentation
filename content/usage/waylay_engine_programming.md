---
title: Waylay engine - Bayesian Inference based programming using smart agent concept
description: Bayesian Inference based programming using smart agent concept
weight: 3
---

<style>
  img {
    border-radius: 5px;
    margin: 0 auto;
    display: block;
  }
</style>

![image](usage/programming_guide/movie1.gif)


{{% alert info %}}
This is the second part of the introduction article on the waylay rule engine. More general info can be found [here](usage/waylay_engine).
"How to" videos are on this [link](usage/videos), and finally different rule patterns are explained here: [rule patterns](patterns/)
{{% /alert %}}

{{% alert info %}}
In this article, we primarily cover default engine capabilities, further referred as SaaS offering. For advanced expert mode, you may find more info in our granted patent application [US20160125304](https://www.google.com/patents/US20160125304). Expert mode engine is only available to selected enterprise customers.
{{% /alert %}}

# Introduction

## Rational agent
The rational agent is a central concept in artificial intelligence. An agent is something that perceives its environment through sensors and acts upon that environment via actuators. For example, a robot may rely on cameras as sensors and act on its environment via motors.

![Smart agent concept](/api/images/smart_agent.jpg)

## Bayesian Network
A Bayesian network is probabilistic directed acyclic graphical model that represents a set of random variables and their conditional dependencies via a directed acyclic graph.

One simple example of a Bayesian network: rain influences whether the sprinkler is activated, and both rain and the sprinkler influence whether the grass is wet.

![BN](usage/programming_guide/bn.png)

{{% alert info %}}
Example taken from [wikipedia](https://en.wikipedia.org/wiki/Bayesian_network)
{{% /alert %}}


## Conditional probability table (CPT) 

In statistics, the conditional probability table (CPT) is defined for a set of discrete (not independent) random variables to demonstrate marginal probability of a single variable with respect to the others.
In previous example, CPT table might look like this:
![cpt](usage/programming_guide/cpt.png)

Using CPT table, one can answer questions, such as: "What is the probability that it is raining, given the grass is wet?" or “What is a probability of sprinkler being turned on giving the grass is wet” or “What is a probability of grass being wet giving it is raining” … 

One might even go further and introduce cloudy weather or humidity as variables for the same problem, like in the example below:

![cpt](usage/programming_guide/cpt_2.jpeg)

# Waylay abstractions on top of Bayesian network
In default SaaS offering, the waylay designer models only the independent random variables – which we call a sensor, while the conditional dependencies are only modelled using CPT (so in the picture above, relation sprinkler<-rain would not be possible). 
Also, in SaaS offering, the conditional dependencies are expressed using “simplified” CPT table (where we only create zeros and ones in the table), which we call __gates__. 

__Actuations__ are simple functional calls (fire and forget) associated with outcomes (observations) of either sensors or gates – which must be completely observed (posterior probability is 1) – meaning the sensor has returned the state or gate is in one of the states with posterior probability 1. 

{{% alert info %}}
For instance the rule: *send SMS (actuation) in case that the weather condition (sensor) is storm (state)*, would be modelled with only one sensor, without gates, where actuator is attached to the weather sensor.
{{% /alert %}}
![cpt](usage/programming_guide/storm.png)

# Waylay Sensors and Actuators 
In waylay, the random variable (node) is a sensor that encapsulates a particular random variable that can be observed via attached sensor function. For every node, there are three groups of settings:

* __Settings that control when the sensor will be executed__: by polling, execute on data stream using the resource concept, execute on the task tick (polling/cron…), sequence number, state change from another sensor triggering the execution etc.
* __Settings that control how long the sensor information is valid__ (eviction by time or by resetObservation flag - which would simply reset the observed node just before the sensor function executes)
* __Input parameters that are use by sensor functions__ (such as city, device id etc.)

{{% alert info %}}
More about task/node parameters you can [find here](usage/tasks-and-templates) 
{{% /alert %}}

**Sensor function** is a stateless call that returns back either a state or raw data or both. Here is one example of the JSON result:

```
{
  "state": "OK",
  "rawData": {
    "temperature": 23.34,
    "humidity": 45
  }
}
```

{{% alert info %}}
In case that sensor is not observed, or the node is reset by the task (what we call a resetObservation) the sensor states will go back to priors. In SaaS offering, that means that the priors will be the same for all states, with total sum of all priors being 1 (e.g. if node has two states, it will the prior will be 0.5 for each state). 
{{% /alert %}}

__Actuator function__ is a simple fire and forget call that either *triggers on a given state, set of states, or the state change of the node* to which the actuator is attached.

{{% alert info %}}
More about sensors and actuators you can find on this [link](api/sensors-and-actuators) 
{{% /alert %}}


## CPT table as a gate
In waylay, we have come up with simple abstractions for CPT, which we call gates and we define three types of CPT: AND, OR and GENERAL.

First two gates (AND, OR) **somewhat resemble Boolean Logic**, even though there are quite some differences to what people might expect:

* First difference is that **all gates can be attached to a “non binary”** sensor (sensor having more than two states), 
* and second major difference is that **you should not assume that both sensors need to be observed in order to have the gate state with posterior probability 1** (in case of AND gate that would be FALSE state, while for OR gate that would be TRUE state, see later). That second difference is very important if we attach an actuator or sensor to the gate, as they both expect gate to be completely observed (1) before actuation or triggering another sensor which is attached to that gate.

## AND gate 
Example of AND gate for two nodes with only two states, where we model the only condition that leads to TRUE state.

![and](usage/programming_guide/AND.png)

and corresponding CPT table:
![and](usage/programming_guide/AND_GATE.png)


{{% alert info %}}
If we look at the CPT table, we can see that **as soon as** one of the nodes is in the state FALSE, the gate will be in state FALSE. On the other hand, both nodes must be observed to state TRUE, to have the AND gate in state TRUE too. 

The same gate can be applied to more than 2 nodes, and more than 2 states per node. 
{{% /alert %}}

## (X)OR gate
Example of OR gate for the same nodes, where we model only the condition that leads to FALSE state.

![or](usage/programming_guide/OR.png)

and corresponding CPT table:
![or](usage/programming_guide/OR_GATE.png)


This table tells that only if both nodes return state TRUE the gate will be in the state TRUE.  Again, we can apply the same gate for multiple nodes and with more than 2 states, but CPT table looks always the same, with only one combination leading to FALSE state.

Here is the example with two sensors, with two states (TRUE, FALSE) attached to AND and OR gate, randomly changing their states over time. 0.5 means that sensor is not yet observed (initial condition), while 1.0 means that sensors are in one of two possible states. On the other hand, AND and OR gate values represent posterior probabilities, that are changing from 0.5, to .75 and 1.0, depending on the CPT table. For instance, in the initial condition, where both sensor states are with priors 0.5 for both TRUE and FALSE state, AND gate will be 0.75 likely in state FALSE, while OR gate with posterior probability of 0.75 in TRUE state.

![gates](usage/programming_guide/gates_1.png)

This is the same example as before, with only difference that now sensor’s states are evicted after a while (using eviction flag), which means sensors switch from being fully observed (1.0) back to priors 0.5, which also changes posterior conditions for attached gates:

![gates](usage/programming_guide/gates_2.png)

As mentioned earlier, there is also a possibility to link any set of states for any number of nodes, like in this example, where we link 36 different outcomes, from 2 nodes with 6 states, to desired outcome using general gate. **Unlike using decision trees, which would require 72 nodes in the graph (6*6*2), we can achieve the same with only 3 nodes!**

![gates](usage/programming_guide/general.png)

This is the example where we use three different gates at the same time. Please note that nothing prevents a developer from stacking gates on top of each other!

![gates](usage/programming_guide/general_1.png)

Difference between SaaS view and expert view for one template: when we model a template in the SaaS portal, we are actually creating a Bayesian network (picture below). 

![saas](usage/programming_guide/saas.png)

In this picture, you see already some of the sensors being observed, with posteriors changing for each node as this happens:

![gates](usage/programming_guide/expert_mode.png)

# Task control
 Let’s take closer look into one task:

 ![task](usage/programming_guide/task_1.png)

As mentioned earlier, whether a particular sensor’s function will execute depends only on the node or task settings. We can decide to run each sensor separately, with polling, or to execute sensor based on the task clock (cron/polling/…), or by getting sensor triggered on the outcome of another sensor, or trigger the sensor execution when stream data arrives. We can even mix these conditions together. 

# Task Context
Once the sensor executes, both state and raw data is passed into the task context. That context is accessible to all sensors and actuators at any time. In the picture below, with red box we show the node’s context when it becomes available in the task context, while with a yellow arrow, we represent the state for any given sensor (how long it stays in a given state depends on the eviction and the next sensor invocation).

 ![task](usage/programming_guide/task_2.png)

 For instance, here we can see that node 5, just before execution had already a possibility to access the context of other 4 nodes (their states and raw data). From this is obvious, that by just chaining sensors to each other, without any gate, we can easily implement any flow-based rule.

# Inference 
Once the sensor execution was successful, few things happen: state is propagated thought the network using inference algorithm; every node or gate that has attached actuators will evaluate whether the actuator needs to fire; finally, the result of the sensor execution is stored in the task context (red boxes). The task context is always available to all sensor functions. 
In the picture below, we show the node states in colour only if they are set with probability 1. 

We will show two examples, where the same sensors are first attached to AND gate, and second example, where the same sensors are attached to OR gate. Observations (labelled by red and green boxes on top) will be the same in both cases. Yellow icon, just below the boxes shows when the inference happens (right after any node observation). We also assume that there is an actuator attached to gate with condition TRUE, which is represented by a small yellow arrow on the gate graph.
 ![and_actuator](usage/programming_guide/AND_actuator.png)


 ![inference](usage/programming_guide/inference_1.png)

Depending on the eviction policy, state of the sensor might remain the same till the next observation, or simply node can reset to priors (white arrow), after the eviction time is reached. 

In the first example above, node1 and node2 have the same eviction policy, which makes the gate to be fully observed only as long as both nodes are fully observed too (see section on CPT table). In the second example, states stayed observed till the next observation (sensor function) is executed.

In the third example, resetObservations flag was set true, which would make the node automatically reset to priors just before the execution of the attached sensor function.
Using the same example, but now with OR gate we can see how would rule evolve in time. 

The same example as above, but this time with OR gate:

 ![or_actuator](usage/programming_guide/OR_actuator.png)


 ![inference](usage/programming_guide/inference_2.png)


# Where to go from here?

## Check what you can do more with this engine:

Now that you have learned more about waylay inference engine programming principles, check out this link: [rule patterns](patterns/), where you can learn more about different integration patters, such as:

* Raise the alarm if the stream data is above the threshold for predefined period of time
* Counting the number of alarms within a time window or number of samples
* Flow based rules
* CEP raw data processing
* Using gates as the control flow
* Simple control using gates
* Raise the alarm if there is no data within a time window
* State pattern matching - within a time window
* JSON payload transformation and enrichment
* Mixing push and pull events, with conditional sensor execution
* Mixing push and pull events, general case
* How to synchronized different data streams
* Control flow using sequence feature
* Threshold crossing with stream data
* Timings in waylay - merging data streams and applying formula


## AI stuff....
Bayesian Networks, AI ...

* If you are interested to know more about Bayesian Networks, this book is a classic [Bayesian Networks, Probabilistic Reasoning in Intelligent Systems by Judea Paerl](https://www.amazon.com/Probabilistic-Reasoning-Intelligent-Systems-Representation/dp/1558604790). 
* [Artificial Intelligence: A Modern Approach](https://www.amazon.com/Artificial-Intelligence-Modern-Approach-3rd/dp/0136042597), by Peter Norvig, Stuart J. Russell, is an excellent AI book, and has a nice chapter on Probabilistic reasoning and Bayesian Networks.
* just google...



written by Veselin Pizurica
















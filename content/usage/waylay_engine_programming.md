---
title: Waylay Rules Engine Introduction - Part 2
description: Learn about the default capabilities of the Waylay engine, its use of the smart agents concept and Bayesian inference based programming
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
This is the second part of the introduction article on the waylay rule engine. More general info can be found in the first part [here](usage/waylay_engine).
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
In our previous example, CPT table might look like this:
![cpt](usage/programming_guide/cpt.png)

Using CPT table, one can answer questions such as: "What is the probability that it is raining, given that the grass is wet?" or “What is the probability of the sprinkler being turned on giving that the grass is wet” or “What is the probability of the grass being wet giving thatnit is raining” … 

One might even go further and introduce cloudy weather or humidity as variables into the same problem, like in the example below:

![cpt](usage/programming_guide/cpt_2.jpeg)

# Waylay abstractions on top of Bayesian network
In our default SaaS offering, the waylay designer models only the independent random variables – which we call sensors, while the conditional dependencies are only modelled using CPT (so in the picture above, the relation sprinkler<-rain would not be possible). 
Also, in our SaaS offering, the conditional dependencies are expressed using “simplified” CPT table (where we only create zeros and ones in the table), which we call __gates__. 

__Actuations__ are simple functional calls (fire and forget) associated with outcomes (observations) of either sensors or gates – which must be completely observed (posterior probability is 1) – meaning the sensor has returned the state or gate is in one of the states with posterior probability 1. 

{{% alert info %}}
For instance the rule: *send SMS (actuation) in case that the weather condition (sensor) is storm (state)*, would be modelled with only one sensor, without gates, where the actuator is attached to the weather sensor.
{{% /alert %}}
![cpt](usage/programming_guide/storm.png)

# Waylay Sensors and Actuators 
In waylay, the random variable (node) is a sensor that encapsulates a particular random variable that can be observed via the attached sensor function. For every node, there are three groups of settings:

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



# Building logical statements using CPT table
Let's consider these two sentences:

* I am very happy when I eat chocolate **AND** when I watch football. 
* I am very happy when I eat chocolate **OR** when I watch football. 

From this simple example, we see how often we use AND in the sentence to express OR relation. 

In waylay, we have come up with simple abstractions for CPT, which we call gates, and we define three types of CPT tables: 

* `AND`, 
* `OR`, 
* `GENERAL`

The first two gates (`AND`, `OR`) **somewhat resemble Boolean Logic**, even though there are quite some differences to what people might expect:

* The first difference is that **all gates can be attached to a “non binary”** sensor (sensor having more than two states), 
* The second major difference is that **you should not assume that both sensors need to be observed in order to have the gate state with posterior probability 1** (in case of AND gate that would be FALSE state, while for OR gate that would be TRUE state, see later). That second difference is very important if we attach an actuator or sensor to the gate, as they both expect the gate to be completely observed (1) before actuation or before triggering another sensor which is attached to that gate.

{{% alert info %}}
In case of doubt, our suggestion is to always start with a `GENERAL` gate in case you need an `either` relation, meaning 'either this state of nodeX or that state of nodeY'
{{% /alert %}}


## GENERAL gate 
Let's assume we roll a dice and want to have a `TRUE` state of the `Gate_1` when **either** `dice_1` is in state `ONE` OR `dice_2` is in state `THREE`. The GENERAL gate settings will look like this:

![general](usage/programming_guide/general_CPT1.png)

At runtime, you should see something like this:

![general](usage/programming_guide/multiple_GENERAL_OR.png)




## AND gate 
Example of AND gate for two nodes with only two states, where we model the only condition that leads to TRUE state.

![and](usage/programming_guide/AND.png)

and corresponding CPT table:

![and](usage/programming_guide/AND_GATE.png)


{{% alert info %}}
If we look at the CPT table, we can see that **as soon as** one of the nodes is in the state FALSE, the gate will be in the state FALSE. On the other hand, both nodes must be observed to state TRUE, to have the AND gate in state TRUE as well. 

The same gate can be applied to more than 2 nodes, and more than 2 states per node. 
{{% /alert %}}

## (N)OR gate
Example of OR gate for the same nodes, where we model only the condition that leads to FALSE state.

![or](usage/programming_guide/OR.png)

and corresponding CPT table:

![or](usage/programming_guide/OR_GATE.png)


This table tells that only if both nodes return state TRUE the gate will be in the state TRUE.  Again, we can apply the same gate for multiple nodes and with more than 2 states, but the CPT table looks always the same, with only one combination leading to FALSE state.
The reason why some people consider this as a NOR gate is because in boolean logic, NOR is a gate that for two binary inputs produces TRUE state only when both inputs are FALSE. In our case, we can model any state combinations which lead to a single FALSE state of the gate, so in that sense, we are trying not to confuse users even more.

Here is the example with two sensors, with two states (TRUE, FALSE) attached to AND and OR gate, randomly changing their states over time. 0.5 means that the sensor is not yet observed (initial condition), while 1.0 means that the sensors are in one of two possible states. On the other hand, AND and OR gate values represent posterior probabilities, that are changing from 0.5, to .75 and 1.0, depending on the CPT table. For instance, in the initial condition, where both sensor states are with priors 0.5 for both TRUE and FALSE state, AND gate will be 0.75 likely in state FALSE, while OR gate with posterior probability of 0.75 in TRUE state.

![gates](usage/programming_guide/gates_1.png)

This is the same example as before, with the only difference being that now the sensors' states are evicted after a while (using eviction flag), which means sensors switch from being fully observed (1.0) back to priors 0.5, which also changes posterior conditions for attached gates:

![gates](usage/programming_guide/gates_2.png)

As mentioned earlier, there is also a possibility to link any set of states for any number of nodes, like in this example, where we link 36 different outcomes, from 2 nodes with 6 states, to desired outcome using general gate. **Unlike using decision trees, which would require 72 nodes in the graph (6*6*2), we can achieve the same with only 3 nodes!**

![gates](usage/programming_guide/general.png)

This is the example where we use three different gates at the same time. Please note that nothing prevents a developer from stacking gates on top of each other!

![gates](usage/programming_guide/general_1.png)

The difference between the SaaS view and the expert view for one template is this one: when we model a template in the SaaS portal, we are actually creating a Bayesian network (picture below). 

![saas](usage/programming_guide/saas.png)

In this picture, you see already some of the sensors being observed, with posteriors changing for each node as this happens:

![gates](usage/programming_guide/expert_mode.png)


# Task control
 Let’s take a closer look into one task:

 ![task](usage/programming_guide/task_1.png)

As mentioned earlier, whether a particular sensor’s function will execute depends only on the node or task settings. We can decide to run each sensor separately, with polling, or to execute sensor based on the task clock (cron/polling/…), or by getting sensor triggered on the outcome of another sensor, or trigger the sensor execution when stream data arrives. We can even mix these conditions together. 

# Task Context
Once the sensor executes, both state and raw data is passed into the task context. That context is accessible to all sensors and actuators at any time. In the picture below, with the red box we show the node’s context when it becomes available in the task context, while with a yellow arrow, we represent the state for any given sensor (how long it stays in a given state depends on the eviction and the next sensor invocation).

 ![task](usage/programming_guide/task_2.png)

 For instance, here we can see that node 5, just before execution, already had a possibility to access the context of other 4 nodes (their states and raw data). From this it is quite obvious that just by chaining sensors to each other, without any gate, we can easily implement any flow-based rule.

# Inference 
Once the sensor execution was successful, a few things happen: state is propagated through the network using inference algorithm; every node or gate that has attached actuators will evaluate whether the actuator needs to fire; and finally, the result of the sensor execution is stored in the task context (red boxes). The task context is always available to all sensor functions. 

In the picture below, we show the node states in colour only if they are set with probability 1. 

We will show two examples, where the same sensors are first attached to the AND gate, and then in the second example, where the same sensors are attached to the OR gate. Observations (labeled by red and green boxes on top) will be the same in both cases. The yellow icon just below the boxes shows when the inference happens (right after any node observation). We also assume that there is an actuator attached to the gate with condition TRUE, which is represented by a small yellow arrow on the gate graph.
 ![and_actuator](usage/programming_guide/AND_actuator.png)

In this short video, we show the example where both observations become TRUE, triggering the actuation on the AND gate:

![inference](usage/programming_guide/and_movie1.gif)

Let's see some other possible scenarios:

 ![inference](usage/programming_guide/inference_1.png)

Depending on the eviction policy, the state of the sensor might remain the same till the next observation, or the node can simply reset to priors (white arrow), after the eviction time is reached. 

In the first example above, node1 and node2 have the same eviction policy, which makes the gate to be fully observed only as long as both nodes are fully observed too (see section on CPT table). In the second example, states stayed observed till the next observation (sensor function) is executed.

In the third example, resetObservations flag was set true, which would make the node automatically reset to priors just before the execution of the attached sensor function.

Using the same example as above, onlyt now with the OR gate, we can see how would the rule evolve in time. 

 ![or_actuator](usage/programming_guide/OR_actuator.png)


 ![inference](usage/programming_guide/inference_2.png)

Looking at the last example, you can notice that the actuation happened twice, when the first sensor returned the TRUE state, and then when the second one returned the TRUE state, since the inference happens any time there is a new observation in the network, and in both cases, the OR gate resulted in TRUE state. Should such things be avoided, the designer can either choose to actuate on the state change (only when first time the gate becomes TRUE), or by limiting how often actuation happens, using [triggering policy](usage/tasks-and-templates).

![inference](usage/programming_guide/or_movie1.gif)

# Where to go from here?

## Check what you can do more with this engine:

Now that you have learned more about the waylay inference engine programming principles, check out this link: [rule patterns](patterns/), where you can learn more about different integration patterns, such as:

* Raise the alarm if the stream data is above the threshold for the predefined period of time
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
* How to synchronize different data streams
* Control flow using sequence feature
* Threshold crossing with stream data
* Timings in waylay - merging data streams and applying formula


## AI stuff....
Bayesian Networks, AI ...

* If you are interested in learning more about Bayesian Networks, this book is a classic [Bayesian Networks, Probabilistic Reasoning in Intelligent Systems by Judea Paerl](https://www.amazon.com/Probabilistic-Reasoning-Intelligent-Systems-Representation/dp/1558604790). 
* [Artificial Intelligence: A Modern Approach](https://www.amazon.com/Artificial-Intelligence-Modern-Approach-3rd/dp/0136042597), by Peter Norvig, Stuart J. Russell, is an excellent AI book, and has a nice chapter on Probabilistic reasoning and Bayesian Networks.
* Or just google it.. :)




![movie](usage/programming_guide/long-movie.gif)

Written by Veselin Pizurica.












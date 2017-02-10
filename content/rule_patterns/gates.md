---
title: Simple control using gates
description: How to create simple rules - better alternative to decision trees
weight: 1
---

The waylay engine belongs to the group of inference engines, and it is based on the Bayesian Networks. What does it mean? Without going too much into maths, let’s just say that every node in the graph infers its state to all other nodes, and that each node “feels” what other node is experiencing at any moment in time. More about that is described in this [blog](http://www.waylay.io/blog-one-rules-engine-to-rule-them-all.html)

Now, before we get more specific about this use case, let’s have a look at the existing solutions. Assume a simple example: you are asked to create a rule from 2 input data sources (e.g. temperature and humidity). Each data source measurement is sampled in one of three states (e.g. low, medium and high). The final decision of the reasoning process is a TRUE/FALSE statement, that depends on these 2 inputs.

Let’s assume we want to model this example using decision trees or flows. 

![image](/rules/gates/tree.png)


As the figure above shows, this leads to 18 leaf nodes (red/green dots) and overall 31 nodes for only two variables! The depth of the tree grows linearly with the number of variables, but the number of branches grows exponentially with the number of states. Decision trees are useful when the number of states per variable is limited (e.g. binary YES/NO) but can become quite overwhelming when the number of states increases.


Waylay rule engine allows compact representation of logic. Combining two objects/variables, as in the example, is simplified by adding `Gate` nodes. The relation between variables and their states as described above can be expressed via boolean representation. Let's have a look:

![image](/rules/gates/rule1.png)

In this case, we were interested in only 2 special cases, when both nodes are in the state `Above`, or when both nodes were `Equal` or `Above` the threshold. This is how we define these two rules, using two different gates `AND` gate and `GENERAL` gate:

## AND gate configuration
With AND gate, we simply define which combination of states we are interested in. We can add as many nodes as we want, in this example we only have two nodes:

![image](/rules/gates/AND.png)

## Multiple selection (GENERAL) gate
With this gate, we simple define which multiple combinations of nodes/states we are interested in. 

![image](/rules/gates/general.png)

## Example with REST API's

Now let's try to use external API's. In the following example, we will use the weather API and the air quality API. For the first AND gate, we are only interested to see if the weather is in state `Mist` and if the air quality is `Unhealthy`, while in the other Gate (Gate_1), we are checking if the weather is bad (`Rain`, `Mist`, `Fog`) and if at the same time, air quality is bad (with different severity levels). Here is the general gate:

![image](/rules/gates/gates_general.png)


Now let's check the weather outside. As we can see from the picture, at the moment of writing, we had a miserable weather and very unhealthy air in Belgium. Sad.   

![image](/rules/gates/air_quality_weather.png)

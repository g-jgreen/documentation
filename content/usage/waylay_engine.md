---
title: Waylay rule engine
description: Waylay engine - one rules engine to rule them all
weight: 2
---

# Waylay engine - one rules engine to rule them all

Much of the power of IoT stems from the fact it allows us to take more accurate decisions in real-time. This enables use cases for notification, automation and predictive maintenance, provided one has the tools to react in real-time on real-time data. An advanced rules engine can fulfill that role by ingesting real-time data, reasoning on those data and invoking automated actions based on the result of that reasoning process.

Now, before we get more specific about waylay’s technology, let’s have a look at the existing solutions. Assume a simple example: you are asked to create a rule from 2 input data sources (e.g. temperature and humidity). Each data source measurement is sampled in one of three states (e.g. low, medium and high). The final decision of the reasoning process is a TRUE/FALSE statement, that depends on these 2 inputs.

Let’s assume we want to model this example using decision trees or flows.

![tree](/usage/engine/tree.png)

As the figure above shows, this leads to 18 leaf nodes (red/green dots) and overall 31 nodes for only two variables! **The depth of the tree grows linearly with the number of variables** , but **the number of branches grows exponentially with the number of states**. Decision trees are useful when the number of states per variable is limited (e.g. binary YES/NO) but can become quite overwhelming when the number of states increases. Anyone who tried this approach before knows you can end up with something of this sort:

![tree](/usage/engine/tree.gif)

Debugging becomes a real challenge and updating the logic over time a daunting task. Things get even more complicated when the state of the variables depends on a threshold or depends on more complex computations. Communicating the rationale of the logic to others (whether in the department, project partners or customers) requires you to label every edge, expressing that specific “sub-rule” in the graph. Others would then need to trace the tree path top/down to figure out the logic that is expressed this way.

**Flow diagrams or pipes** are an alternative technology that has been used to build rules for IoT applications. On top of the complexity inherited from decision trees, tools such as **node red introduce “injector nodes”** (responsible for injecting data into the engine – mostly protocol related) and **“split” nodes** – (where the output of one node is needed as the input to other nodes). With flows you have two additional problems to deal with: parsing of the message payload which somehow becomes part of the “template”, and more importantly, it constrains the logic designer to think in linear way, from left to right, following the “message flow”. Interesting problem arises when 2 inputs come at different times. How long do you wait for the next one to arrive before deciding to move on in decisions? How long the data point/measurement is valid?

**Complex Event Processing (CEP)** engines and the **Apache Spark** platform are also popular in the IoT world. CEP allows for easy matching of time-series data patterns coming from different sources. CEP suffers from the same modelling issues as trees and other pipeline processing engines. However, it frees developers from dealing with context locking, a common issue in use cases where logic combines inputs from different sources. Apache Spark is another alternative. It not only processes streams of data at scale, but also allows “querying” that data at scale using SQL-like syntax. This ability makes Apache Spark a viable alternative to CEP platforms, since Apache Spark allows you to create simple rules that can run within stream “windows” of time and make decisions with the ease of SQL queries. In our view, Apache Spark is a data aggregation/event processing and data analytics (batch and stream) platform – and not the rules engine per se.

Finally, a few words on **Business Process Management (BPM)** engines. One of the issues with BPM engines is that your logic often gets broken somewhere in the middle, as illustrated in this cartoon by @MarkTamis:

![BPM](/usage/engine/bpm.jpg)


BPM was invented when business processes were rigid and not changing for years – they were not meant to be used in dynamic environments.

Therefore, in our opinion, current rules engines have some serious drawbacks in the context of IoT:

* **The logic** created with these engines is **hard to simulate and debug**.
* Current rules engines **don’t cope well with dynamic changes of the environment**.
* All of them **have difficulties combining data from physical devices/sensor (mostly PUSH mode) and data from the API world (mostly PULL mode)**.
* **The logic representation is not compact**, making debugging and maintenance more complex.
* These rules engines **don’t provide us with easy ways to gain additional insights: why a rule has fired and under which conditions**?
* **They can’t model uncertainties**, e.g. what to do when sensor data is noisy or is missing due to a battery or network outage.


# The waylay platform


The waylay engine belongs to the group of **inference engines**, and it is based on the Bayesian Networks. What does it mean? Without going too much into maths, let’s just say that every node in the graph infers its state to all other nodes, and that each node “feels” what other node is experiencing at any moment in time. If you wish to know more about our vision of using Bayesian Networks in IOT context, please have a look here: [A Cloud-Based Bayesian Smart Agent Architecture for Internet-of-Things Applications](http://www.slideshare.net/waylay/waylay-conference-on-cognitive-iot)

![propagation](/usage/engine/propagation1.png)

Unlike flow rule engines, there is no left-right input/output logic. Information flow happens – in all directions, all the time. Unlike decision trees, the waylay engine does not model logic by branching all possible outcomes. Unlike flows or pipes the waylay engine does not use “injector nodes” or “split” input/outputs nodes. Unlike BPMs, the waylay engine is not directly wiring the control flow. So, you may wonder, how you work with a rule engine like that?

In waylay, we have come up with the concept of **smart objects, sensors and actuators**. That means that some of the nodes in the graph represent objects as the source of information, such as a door (which can be open or closed), weather forecast, CRM system, smart washing machine or just the temperature in a house. That way, you are not any more concerned (nor constrained) about the logic at the moment you are sensing the environment. One side effect of this abstraction is that this approach **enables role separation between persons that are responsible for sensor gathering from persons who are responsible for knowledge modelling**.

This way of **inference modelling also allows both push(over REST/MQTT/websockets) and pull mode (API, database..) to be treated as the first class citizens**. For the engine, that makes no difference, as soon as the new insight is provided, it is inferred to all other nodes in the network. The best way to picture this is to imagine that you are looking at the raindrops falling on the surface. What you will notice is that the “communication” between drops resembles a wave function and that the size of the circle is proportional to the time the drop has fallen (bigger the circle, earlier the drop has fallen). Also you can notice that the wave amplitude is getting weaker over time.

![image](/usage/engine/rain_drops.gif)

Another important aspect of the waylay engine is that allows **compact representation of logic**. Combining two objects/variables, as in the example above about decision trees, is simplified by adding one aggregation node. The relation between variables and their states as described above can be expressed via **boolean representation**. That results in a graph with 3 nodes only (compared to 31 nodes in the case of a decision tree, as described above). More about this in some future blog posts.

In more advanced use cases, **waylay also enables probabilistic reasoning**. In that case, you assign actuators to fire when a node is in a given state with a given probability. Moreover, we can as well associate different actuators to different possible likelihood outcomes for any node in the graph.

**All sensors, actuators and logic are stored as templates in the cloud**. That is also the place where reasoning engine resides. When we put all things together, what we get is **a smart reasoning platform with compact logic for easy maintenance, with dynamic workflows  in fully async mode, using push/pull mode of operation, that is integration extendable and not to forget, built in the cloud, for the cloud**.

Have a look in the design editor (picture below), and try to read with us what you see on the screen:

“If the weather is warm and the NEST thermostat settings are too high, adjust the NEST thermostat. Also, if the NEST thermostat is out-of-range, try to adjust it, may be just the range settings are not correct. And what if is someone is ringing at the front door? Turn on the lights, and stream the camera to the cloud, if I am not at home. And what if the person who suffers from dementia leaves the house while I am not there? Send me an SMS right away.” One of many stories you can build and tell, only looking at our designer.

![image](/usage/engine/designer_home.png)

A great thing about waylay’s platform is that the web designer **allows adding new actuators and sensors at runtime**. You can even create and simulate new rules before having sensors and actuators implemented. Also, every sensor/actuator and design logic has a template support – something you can share with other team members, domain experts and customers. **The waylay engine with all functionality is accessible via REST/MQTT or websocket interface**, and our web designer is nothing more but a web UI developed on top of a REST interface. Our engine also includes a small subset of **CEP processing unit**, allowing [formula computation](/api/sensors-and-actuators/#function-node) and pattern matching on the level of the raw data or observed node states.

To find more about the waylay engine and internals, read further documentation page. 


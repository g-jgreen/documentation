---
title: Tasks and Templates
description: Learn about Waylay tasks and templates
weight: 3
---
# Tasks
In waylay terminology, tasks are instantiated rules. There are two ways tasks can be instantiated:

* one-off tasks, where sensors, actuators, logic and task settings are configured at the time the task is instantiated.  
* tasks instantiated from templates, where task creation is based on the template(which describes sensors, actuators and logic) and the task settings. 

# Template configuration settings
## Actuator configuration panel

Each time one of the sensors in a task is invoked and outputs new data and/or state, it is evaluated whether any of the actuators should trigger. Note that the system behaves asynchronously, so data output is not synchronised between different sensors. For example, if you have 5 sensors that pull info from the Internet and there is a small delay between the arrival of data for each of these, logic will evaluate 5 times. This feature is great for scalability as it avoids that the complete system gets locked when e.g. one of the sensor is not responsive or suffers from large latencies. However, when the logic evaluates multiple times, it could also lead to actuators being triggered multiple times. In case this is not desired, there are ways around that as explained below.
When you have multiple independent graphs in one task, the output of data and/or state in one graph will not trigger any actuator in another graph in the same task.  

![](https://raw.githubusercontent.com/waylayio/documentation/master/images/actuatorTriggerPolicy.png)

### State trigger

Whenever the logic of the task gets evaluated it is checked whether the sensor, function or gate  to which the actuator is attached is in one of the selected states. If it is, the actuator gets triggered, independent of previous states of the sensor, function or gate. This is applicable to all actuators in a task, independent of which sensor has output new data and/or state.

### State change trigger

Whenever the logic of a task is evaluated, it is checked whether the sensor to which the actuator is attached has gone through a state change, e.g. from state A to state B.
There is a special symbol *:

* For a state change : * -> A, the actuator will trigger if the state changes from any state different from A to A (so it will not trigger if the previous state was A). The actuator will also trigger if the previous state was not 100% known , e.g. before the first sensor observation or because the eviction time of the sensor was exceeded (see below for more details on eviction time).
* For a state change : A-> *, the actuator will trigger if the state changes from state A to any other state (so it will not trigger if the new state is A).

### Combining state trigger and state change trigger

State trigger and state change trigger can be combined. In that case, the logic will be evaluated and the actuator will trigger once (and only once) if any condition is met.

### Trigger policy

The trigger policy allows you to control the frequency of execution of the actuators.

* **Every time** : the actuator will trigger whenever a condition is met for it to be triggered, as explained above.
* **Only once** : the actuator will trigger only once and never after, independent whether conditions are met or not.
* **Frequency** : the actuator will trigger at most once within the specified time window.


## Sensor configuration panel

Sometimes you want to control the sensor execution order and/or timing. One way you can achieve this (if you use periodic or cron task) is via sequence number attached to the sensors. If you need conditional sensor execution, you should use state trigger feature described below.

![](https://raw.githubusercontent.com/waylayio/documentation/master/images/nodeTriggerSettings.png)

### State change trigger

Assume a sensor_y that should be triggered upon a state change of sensor_x. This can be done by connecting sensor_x to sensor_y and specifying the desired state change in the right panel for sensor_y, e.g. state change from state A to state B.
There is a special symbol * : 

* For a state change : * -> A, the sensor_y will execute if the sensor_x state changes from any state different from A to A (so it will not execute if the previous state was A). The sensor_y will also execute if the previous state of sensor_x was not 10% known, e.g. because the eviction time of the sensor_x was exceeded.
* For a state change : A-> *, the sensor_y will execute if the sensor_x state changes from state A to any other state (so it will not execute if the new state is A).

### Resource

The resource is a unique identifier of a ‘thing’. When a ‘thing’ pushes streaming data to the Waylay platform, it provides its unique identifier, i.e. a resource name. Each resource can push multiple parameters to the Waylay broker. The Waylay framework will automatically distribute the resource parameters to the tasks and nodes with the corresponding resource name. E.g. with the ‘execute on data’ option described below, the sensors with the corresponding resource name will automatically get invoked when new streamed data with the same resource name becomes available. The resource name can be specified at the task level and at the node level. In case you have many sensors in your task that share the same resource name, you may want to specify it at the task level and inherit it at the node level via the $ symbol.


### Advanced settings

* **Execute on data**: The sensor will be invoked if new data is available. That data needs to be linked to a resource that is also attached to the sensor. For example, if data from resource ‘machine1’ is streamed to Waylay, and the sensor has as resourcename ‘machine1’, the sensor will be invoked as soon as new streaming data gets available. This feature allows the framework to react in real-time on real-time streaming data.
* **Execute on tick**: The sensor or function get invoked on the task tick. This setting is disabled in case of a conditional execution of the sensor, since such sensors are meant to be executed only when a condition is met and not on the task tick.
* **Eviction time**: The eviction time defines the time after which a sensor goes back to its priors.  For example, in case a sensor has N states, by default, the system assumes that the sensor is in each of the N states with a probability 1/N after the eviction time.The eviction time is specified in seconds. If left empty, the sensor will never go back to its priors. Eviction time is a useful feature to cope with things like broken sensors, intermittent connectivity or non-responsive APIs. It allows you to specify the period of time during which you can still rely on previous state information.
* **Polling period**: The polling period defines the frequency of the tick at which the sensor is invoked. When the polling period per node is defined, the sensor will not be invoked at the task tick. When left empty, the polling period defined at task level will define the tick at which the sensor is invoked. Note that the polling period is ignored for sensors that are conditionally executed based on the state of another sensor, function node or gate. The per node polling period is useful when you combine semi-static with highly dynamic sensors in one task. In such cases, it is useful to define different polling frequencies for the different sensors.
* **Sequence number**: By default, all sensors and function nodes are executed in parallel at the task tick. In some cases you may want to impose a certain order, e.g. you want to collect new data first before executing the function node. This order is implied by the sequence number. Sensors and function nodes with a low sequence number are executed first. In case multiple nodes have the same sequence number, they are executed in a random order, but before nodes with a higher sequence number.


# Task settings

In case that the task is deployed as "one-off", where sensors, actuators, logic and task settings are configured at the time the task is instantiated, you can deploy the task either via waylay designer or [REST calls](/api/rest/#create-a-task-with-rule-defined-in-the-request). In the screenshot below, you can see how this can be done from UI.

![](https://raw.githubusercontent.com/waylayio/documentation/master/images/taskDeploy.png)

As mentioned earlier, tasks can also be instantiated from templates, via [REST](api/rest/#create-a-task-from-a-template)

In both case, the following settings apply:

* **Task name**: Name of the task. Does not need to be unique, Waylay assigns a unique taskID to each task.
* **Task resource**: is the resource name defined at the task level. Please see the section ‘Advanced Settings” in the Sensor section on how to inherit the task resource at the node level.
* **Start task**: Will start the task immediately upon creation. This is the default behaviour.
* **Task type**:
 * **Periodic**: The task tick is at a configurable periodicity.
 *  **Cron**: allows to execute tasks according to a cron expression.
 * **One-time**: Task is only executed once.
 * **Reactive**: Reactive tasks do not have a task tick. Reactive tasks are typically used for tasks that require actions based on streaming data.
* **Advanced settings**:
 * **Execute in parallel**: execute all sensors and functions in parallel. When sequence numbers are defined, this option will be unchecked. When still selecting this option, it will override the sequence number and still execute sensors in parallel.
 * **Reset observations on each invocation**: This will reset the states of sensors to their default values right before the next task tick. This feature is useful in scenarios where you do not need to maintain states across task ticks. When you invoke sensors, the state updates provided as output of the sensor invocations may arrive asynchronously. In order to avoid accidental actuator triggering based on old states (from the previous task tick), you may need to reset observations before each task tick.


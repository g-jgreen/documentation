---
title: Getting Started
description: Learn how to first get started with the Waylay platform
weight: 2
---

This document provides a quick introduction to the basic concepts behind the waylay application. It will allow you to get up to speed faster by providing you an insight in why waylay was built the way it is built.

Waylay consists of the following building blocks:

* Data cache for pushed sensor data.
* Sensors - a generalized form of input connectors.
* Logic consisting of mathematical preprocessing and actual logic.
* Actuators - a generalized form of output connectors.

![Introduction](https://raw.githubusercontent.com/waylayio/documentation/master/images/schema.png)

# Data Cache

Waylay supports both push and pull models for data, see also the sensor section below. Data can get pushed to the waylay platform over REST, Websockets or MQTT. Sensor data can get pushed directly from gateways or devices or from SW systems that have already collected device data. A broker inside the waylay platform will then push that data to:

* the data cache, where a limited number of samples are kept.
* time series database
* the global context of related tasks, where push sensors pick up the data.

As shown in the drawing above, you can also create sensors that pull short-term historical data from the short-term data cache or time series database.

# Sensors

Sensors can be considered a generalized form of input connector for the waylay platform. You can create sensors to acquire data from physical devices, databases, applications or online services. You do this by means of writing Javascript and defining metadata. Waylay provides many examples which you can use as a baseline to create your own sensors, specific to your application. On a technical level, a sensor can be considered as a function that, when called, returns the state it is in.

# Output

A sensor has two possible outputs:

## Output State

 Each sensor has a limited amount of discrete states which it can be in, eg ON/OFF or LOW/MEDIUM/HIGH.
These states will be used when logic is applied. As an example, for the temperature sensor, you could define states as HOT (>30C), WARM (20C-30C), MILD (10C-20C), COLD (0C-10C) and FREEZING (<0C).
The sensor then returns the state information back to the logic and you can start building logic using these states.

## Output Raw Data

This is the data that was collected or pushed in its raw form, like continuous value parameters such as eg temperature, light and memory used. In some cases, you may also want to use this raw data in the mathematical preprocessing step of your logic. Therefore this data is stored in the task context that can be used in your logic.

# Invocation

Sensors can be invoked in two ways:

* by pushing raw data to the sensor or task, this will in turn trigger a recalculation of the sensor state.
* by pulling for data, depending on the type of task the sensor will be triggered at defined moments. The sensor will then fetch its raw data, e.g. via an HTTP GET call and use that data to calculate its state.


The basic idea is that once you create your logic, you do not need to be very much concerned about the push or pull level details, that is handled at the level of the sensor definition. The best examples to start from for are: pull sensor: temperatureSensor push sensor: runtimeDataSensor

# Logic

The logic consists of two parts, an optional mathematical preprocessing step via functions and then the actual logic.

## Mathematical Preprocessing

Mathematical preprocessing is done in function nodes and allows you to work on raw data to e.g. take the average, mix, max over a number of samples or minutes or to combine data from multiple sensors. The outcome of a function node is again a state, i.e. the result of the mathematical preprocessing is compared against a threshold and the state is ABOVE, EQUAL or BELOW that threshold.

## Logic
The actual logic supports Boolean operations like AND, OR gates and more generic gates that allow you to specify which combinations of inputs are TRUE or FALSE. You can connect more than two sensors or function nodes to the gates. The platform also allows to have multi-level gates, i.e. where the outcome of one gate forms to the input to another gate. This way you can build quite powerful logic. There are two important concepts that you need to understand:

* Logic reasons based on state information.
* The logic gets evaluated as soon as any of the sensors or function nodes changes state. So it is a completely asynchronous process that does not require sensor inputs to be synchronized. This flexibility allows you to build logic that combines push and pull sensors in one logical scenario.

# Actuators

Based on the outcome of the logic, you may want to take action, such as sending an alert, writing something in a database or acting on a physical system. You can take action based on any node being in a particular state, by attaching actuators to the particular node. As for the sensors, the waylay framework allows you to add your own definitions of actuators.

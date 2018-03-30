---
title: Waylay Technical Information Guide
description: Technical Information Guide
weight: 1
---

# Scope
This document is a technical information guide for the Waylay Orchestration and Automation Platform. It provides more details about the different components and the architecture of the platform.

# Introduction

When most people hear the term IoT, they naturally think about sensors embedded in appliances or machines, wireless connectivity and an IoT platform. That IoT platform securely onboards the devices, stores the sensor data and provides dashboards. This is a classical IoT solution.

However, when enterprises want to reap the full benefits of IoT, this is not enough. Enterprises have existing IT infrastructure consisting of a mix of onsite IT and cloud services; customer support and field support may benefit from data in the IoT platform to accelerate fault resolution and inter-organizational collaboration can improve when sharing the data with partners and customers.

The situation even becomes more complex when enterprises deploy multiple IoT solutions e.g. for different vertical applications, or because they rely on multiple suppliers for a specific solution.

The mission of Waylay is to transform IoT solutions into business solutions by orchestrating across all the different components mentioned above. Waylay makes the integration effort faster, smarter, scalable and future proof.

![Introduction](/usage/technical_information_guide/solution.png)

More specifically, Waylay strongly believes that a lot of the value to be created through IoT will require IoT platforms to work together and integrate with IT back-end infrastructure, cloud applications and APIs. Waylay provides this bridge between the device and the IT world. 

Further more, Waylay strongly believes in automation: to cope with the vast amount of data provided in IoT, automation is key. Not only automation within the IoT solution itself, but extending the automation perimeter to enterprise IT assets and even external applications in order to improve operational processes.

At its core, Waylay has a flexible rules engine that can be used for orchestration and automation. It integrates with a variety of sensors and SW based data sources, processes the data coming from those sources according to a configurable rules set, and takes action based on the outcome of these rules.

In order to connect to different data sources, Waylay comes with an extendable framework where **plugins** provide access to third party systems. Rules are created using a **visual programming** interface, with integrated debugging capabilities.
The same rules can be applied across a large set of devices or assets via a template mechanism. The platform capabilities are exposed over a [**REST API**](/api/rest/), which allows for easy integration, into an end-to-end solution.

This document provides a high level technical introduction to the Waylay platform. First, it describes the various functional components. Next, it gives an overview of typical use cases in which the Waylay platform is deployed. Finally, the document ends with a platform architecture overview.

# Functional description

The Waylay platform has been built around the concept of smart agents, a concept that comes from the artificial intelligence domain.

![Smart agent concept](/api/images/smart_agent.jpg)

A smart agent architecture is built around 3 distinctive components:

* **Sensors**: these are inputs to the platform that come from the environment. In the Waylay architecture, we make use of software-defined sensors that can capture inputs from both physical sensors as well as SW systems, e.g. databases or APIs.
* **Logic**: this part determines what needs to be done with the sensor inputs, it automatically processes those inputs.
* **Actuators**: these components take action on the environment based on the outcome of the logic. In the Waylay architecture, we make use of SW-defined actuators that can take a diverse set of actions such as sending out SMSs or emails, writing something to a database, creating a ticket or acting back on a physical device.

We will now have a closer look at these three components. For convenience, we will use the terms sensors and actuators, rather than SW-defined sensors and SW-defined actuators.

# Sensors
Waylay has a built-in framework that supports sensors towards different systems. The Waylay platform comes with a number of off-the-shelf available sensors, that are provided as a library of plugins. This includes connectors to all types of databases, cloud applications, APIs and enterprise IT systems but for example also native integration with IoT networks such as Sigfox or LoRa.

![Smart agent concept](/usage/technical_information_guide/sensors.png)

This framework has a number of important features:

*  It is **extendable**. This means that third parties can write their own extension to the platform, e.g. a sensor to a new system, by using the built-in sensor development framework of the platform. The platform is **hot pluggable**, which means that those new sensors can get deployed without restarting the environment. This means that new sensors can be developed on a project basis without any dependency on the Waylay platform roadmap, which provides a fast time-to-market.
*  The framework supports both **push** and **pull** sensors. Pull sensors are sensors that pull data from the outside environment (e.g. fetch some data from a database or querying an API). Push sensors allow external systems to push data without an explicit pull request, this is e.g. often the case with sensor data. Push data enters the Waylay platform through a broker which forwards it to the sensors and logic in a normalized format.
*  One class of sensor inputs comes from IoT platforms. Waylay can integrate both with horizontal IoT platforms (IoT platforms that can be deployed across different verticals) as well as vertical­ specific IoT solutions, as long as they support some form of push/pull mechanism. See also the section on architecture for more information.

The sensor plugins consist of two parts: JavaScript code and metadata. The source code of off­the­shelf plugins are available as examples as well as clear developer documentation on how to create additional plugins.

# Actuators
Similar to the sensor framework, Waylay provides a built-in framework that support actuators towards different systems. Actuators allow to execute actions based on the outcome of rules. The Waylay platform comes with a number of off­the­shelf available actuators, that are provided as a library of plugins.

This framework has a number of important properties:

* It is **extendable and hot pluggable**. This means that third parties can write their own extension to the platform, e.g. an actuator to a new system, by using the built-in capabilities of the platform. The platform is hot pluggable, which means that those new actuator connectors can get deployed, without restarting the environment, making it a perfect solution for third party developers active on the platform.
* Again Waylay can also actuate back to IoT platforms that then can perform actions onto physical devices. As for the sensors, The actuator plugins consist of two parts, JavaScript code and metadata. The source code of off-the-shelf plugins are available as examples as well as clear developer documentation on how to create additional plugins.
Below you find a screenshot of the development environment for new actuators, that is provided as part of the Waylay management console. Screenshot of actuator development framework:

![Actuator view](/usage/technical_information_guide/actuator_view.png)

# Logic creation

Rules are created using a visual programming environment with drag­and­drop functionality, see the screenshot below. Once rules have been created, they are saved as JSON files. The visual programming environment allows the developer to make use of the library of sensors and actuators, logical gates as well as mathematical function blocks.

![Designer view](/usage/technical_information_guide/designer.png)

The visual programming environment also comes with a simulation function that allows to visually interpret the execution of the logic and has debug functionality with various debug levels. Moreover, it allows to test logic based on historical data, by reading them from CSV files.

# Templates and tasks
Templates are generic rules that have not yet been associated to a particular device or instance. The same template can be instantiated many times as tasks, by associating device specific parameters to a specific template. This mechanism is operationally very efficient in the sense that templates only need to be developed once, but can then be instantiated many times. As an example, assume you generate a template for an appliance and in the field, you have 100k appliances deployed: then you would have one template and 100k tasks running on the waylay platform.
The Waylay admin console provides an inventory of all tasks that are currently running, as well as lifecycle management on a per task level: create, delete, start, stop, debug. In addition, an actuator log provides a historical overview of the actuators that have been triggered. This type of functionality greatly helps with troubleshooting.

# Data cache
The Waylay platform provides the capability to cache a limited number of samples for each data resources. This can be useful when creating logic that needs to track trends over time (delta, mix, max, etc.).

# API
Platform functions are exposed over a [REST API](/api/rest). This API can be leveraged by other platforms to automatically trigger actions on the Waylay platform, e.g. automatically starting tasks when a new device is onboarded.
Secondly, the API can also be leveraged in end user applications. As an example, you may have pre-defined templates in the Waylay platform while end users supply a couple of configuration parameters that allow to instantiate a new task from that template. Alternatively, in some cases, it may also make sense for end users (business or consumer) to create simple automation or notification tasks over the API.

![Applications](/usage/technical_information_guide/applications.png)





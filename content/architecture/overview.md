---
title: Overview
description: Get a sense of how every component is connected
---

Waylay architecture is composed of the following components:

* Cloud Broker (MQTT, WebSockets and REST)
* Cloud Persisted Cache
* Time series Database
* Resource Metadata Database
* Inference Engine with advanced stream based correlation and formula processing
* REST server
* CEP functional nodes
* Waylay IDE (web based)
* SDK and Templates (for sensors, actuators, rules)
* Node.js executor nodes

![architecture](https://raw.githubusercontent.com/waylayio/documentation/master/images/architecture.png)

# Broker

[Broker](api/broker-and-storage/) lets you store and distribute messages. This can be performed over different protocols: HTTP, WebSockets or MQTT. To keep your data private, you need to use waylay API key and secret. This will also enable both cloud storage and forwarding of your data towards waylay Inference Engine. As soon as data is send to the Broker, data is stored in two different databases, time series database and document database (Cloud Persisted Cache). In Cloud Persisted Cache, data is stored without any pre-processing, with original JSON object as it was received. When JSON object (or array of JSON objects) comes to the Broker, Broker also tries to save data in the time series database. In order to achieve that, broker will inspect incoming JSON object and store every metric that is found in the JSON object.

## Cloud persisted cache REST interface
You can always retrieve up to the last 100 messages for every resource over the [REST calls](api/broker-and-storage/#document-data).

## Time series database REST interface
Waylay automatically stores metric data in the time series database. Via [REST interface](api/broker-and-storage/#time-series-data) you can retrieve raw data or aggregated data (per interval with aggregation metrics e.g. avg, mean, max, stdev etc).

## Resource metadata with REST interface
[Provisioning API](api/rest/#provisioning-api) allows you to associate metadata with resource. Resources are either discovered by Waylay (as soon as data is pushed towards Waylay Broker) or you can as well create them using REST call. Next to the resource CRUD related calls, waylay also allows you to create ResourceType entities, and let you link resource to a type using metadata. As soon as a resource is linked to a resource type, all metadata values of that type are linked to that resource. Resource can still overwrite any specific attribute in its metadata model.

# SDK and templates (sensors, actuators, rules)
In waylay, [sensors, actuators and rules](/api/sensors-and-actuators/) are nothing more than small snippets of JSON files. They can be re-used between different templates. Out of the box, in PaaS offering, waylay supports only node.js based actuators and sensors (very similar approach to AWS lambda architecture). For OEM deployments, we as well provide java SDK.

## Open Source

There are many sensors, actuators and templates that we support out of the box. They are all open source and ready for use by all.

# REST server
Every piece of the waylay functionality is exposed over the [REST interface!](/api/rest) Among others, that includes:

* test & create & update sensors, actuators and templates
* execution of actuators and sensors
* instantiation of tasks with or without templates
* sensors/actuators/tasks and templates versioning and migration
* real time updates of the rule engine outcomes together with realtime data (using HTML5 Server-Sent Events)

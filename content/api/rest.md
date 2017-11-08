---
title: API Reference
description: Learn how to use the Waylay REST API
weight: 1
---

# Authentication
> Once you have retrieved your keys, you can verify whether your keys and the REST server work E2E by issuing the following command:

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/ping"
```

Before you can start using the REST API, you must visit your profile page in the waylay application and fetch your API keys:

![enter image description here](/api/images/profile.png)


<aside class="notice">
you can test the same from the UI (see picture above), but since in the rest of the document we will be using curl command, the best is that you at this point in time do the same from the command line.
</aside>

# Task related calls

In waylay terminology, tasks are instantiated rules. There are two ways tasks can be instantiated:

* one-off tasks, where sensors, actuators, logic and task settings are configured at the time the task is instantiated.  
* tasks instantiated from templates, where task creation is based on the template(which describes sensors, actuators and logic) and the task settings. 

## Create a task
There are mainly 2 ways to create a task, either by specifying the rule in the request, or by specifying the template with which the task needs to be instantiated.

## Create a task with rule defined in the request
```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
  "sensors": [
    {
      "label": "currentWeather_1",
      "name": "currentWeather",
      "version": "1.0.3",
      "sequence": 1,
      "properties": {
        "city": "Gent, Belgium"
      },
      "position": [173, 158]
    },
    {
      "label": "isWeekend_1",
      "name": "isWeekend",
      "version": "1.0.3",
      "sequence": 1,
      "position": [179, 369]
    }
  ],
  "actuators": [
    {
      "label": "TwitterDM_1",
      "name": "sendTwitterDM",
      "version": "1.0.1",
      "properties": {
        "screenName": "pizuricv",
        "message": "Great weekend!"
      },
      "position": [600, 199]
    }
  ],
  "relations": [
    {
      "label": "ANDGate_1",
      "type": "AND",
      "position": [353, 264],
      "parentLabels": ["currentWeather_1", "isWeekend_1"],
      "combinations": [["Clear", "TRUE"]]
    }
  ],
  "triggers": [
    {
      "destinationLabel": "TwitterDM_1",
      "sourceLabel": "ANDGate_1",
      "statesTrigger": ["TRUE"],
      "invocationPolicy": 1
    }
  ],
  "task": {
    "type": "periodic",
    "start": true,
    "name": "Rule created on 12/8/2015, 1:38:56 PM by veselin@waylay.io",
    "pollingInterval": 900
  }
}' "https://sandbox.waylay.io/api/tasks"
```

You can create a task without a need to create a template first. In order to create a task you will need to specify the following in the request:

* sensors, list of sensors with required properties
* actuators, list of actuators with required properties
* relations, list of relations(gates) between sensors
* triggers, list of conditions under which actuators get executed.
* task, task related settings

Sensor and actuator settings are:

* label , node label
* name , sensor/actuator name
* version,
* position, array such as [245, 205],
* properties, key-value object of required properties
* resource , resource - applicable only for sensors
* sequence , sequence - applicable only for sensors, if omitted default is 1

Trigger settings are:

* destinationLabel, label of the actuator / sensor
* sourceLabel, label of the sensor / relation
* invocationPolicy, integer number that defines how long to wait before firing the same actuator again, even if the condition is met.
* statesTrigger, array of states under which to fire the actuator
* stateChangeTrigger, object containing stateFrom and stateTo which can be a specific state or *

Relations express logical gates that can be defined between sensors. There are 3 types of relations: AND, OR and GENERAL.

Relations settings are:

* combinations, array of arrays, such as ["Above", "Above"], ["Below", "Below"]. Only GENERAL gate will have more than one array of combinations
* label: "ANDGate_1"
* parentLabels, array of labels of sensors that are attached to this relation
* position, array such as [245, 205],
* type,  "AND", "OR" or "GENERAL"

Task settings are:

* name
* start, flag to start a task, default yes
* type (onetime, cron, reactive, periodic)
* other task type related settings, see further below

<aside class="notice">
Once task is deployed, you can still change task/node/sensor/actuator settings using PATCH calls (see later)
</aside>


## Create a task from a template

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
  "name": "test1",
  "template": "internet.json",
  "resource": "hello",
  "start": false,
  "type": "scheduled",
  "cron": "0/30 * * * * ?"
}' "https://sandbox.waylay.io/api/tasks"
```

In order to start a task from the template, you need to provide the following inputs:

* name: task name
* template: template name
* resource: resource name
* start: whether task is started after creation

### Cron task
Cron specific input settings:

* type : scheduled
* cron: cron expression as defined in [Cron format](http://www.quartz-scheduler.org/documentation/quartz-1.x/tutorials/crontrigger)

### Periodic task
```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
  "name": "test2",
  "template": "internet.json",
  "resource": "hello",
  "start": false,
  "type": "periodic",
  "frequency": 1000
}' "https://sandbox.waylay.io/api/tasks"
```

Periodic specific input settings:

* type : periodic
* frequency: polling frequency in milliseconds (default 10 seconds)
* pollingFixedRate : fixed rate or fixed delay (default fixed false - meaning fixed delay)
* resetObservations: whether to clear observation before next invocation (default true)
* parallel: whether to run sensors in parallel or sequentially (default true, meaning parallel)


<aside class="notice">
In case that you set the task to run sequentially (parallel flag=false), order of sensor's execution will be based on the cost of the sensor (from lower to higher).
</aside>

### Onetime task
```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
  "name": "test3",
  "template": "internet.json",
  "resource": "hello",
  "type": "onetime"
}' "https://sandbox.waylay.io/api/tasks"
```

Onetime specific input settings:

* type: onetime


## Create a task with sensor properties in the request
> In this example, we change addresses of the `Ping` sensors and the resource of node `Ping_2`:

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
"name": "test4",
"template": "internet.json",
"resource": "hello",
"start": false,
"type": "scheduled",
"cron": "0/30 * * * * ?",
"nodes": [{
  "name": "Ping_1",
  "properties": {
    "sensor": {
      "name": "Ping",
      "version": "1.0.1",
      "label": "Ping_1",
      "requiredProperties": [
        {"address": "www.waylay.io"}
      ]
    }
  }
}, {
  "name": "Ping_2",
  "properties": {
    "resource": "newresource"
    "sensor": {
      "name": "Ping",
      "version": "1.0.1",
      "label": "Ping_2",
      "requiredProperties": [
        {"address": "sandbox.waylay.io"}
      ]
    }
  }
}]}' "https://sandbox.waylay.io/api/tasks"
```
You can also override node/sensor/actuator settings of the template before starting the task. These are the fields you can override:

-   nodes.[\*].properties.cost (sequence number)
-   nodes.[\*].properties.resource (string)
-   nodes.[\*].properties.evictionTime (millis)
-   nodes.[\*].properties.pollingPeriod (millis)
-   nodes.[\*].properties.pollingFixedRate (boolean)
-   nodes.[\*].properties.sensor.requiredProperties.\*
-   nodes.[\*].properties.actions.[\*].requiredProperties.\*


## Update a task

This allows you update the task configuration. See also the documentation on [getting a task's configuration](#getting-an-existing-task-s-configuration).

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X PUT -d '{
  "name": "test1",
  "template": "internet.json",
  "resource": "hello",
  "start": false,
  "type": "scheduled",
  "cron": "0/30 * * * * ?"
}' "https://sandbox.waylay.io/api/task/1"
```

## Delete a task

> Delete a task

```bash
curl --user apiKey:apiSecret -X DELETE "https://sandbox.waylay.io/api/tasks/1"
```

## Start a task

```bash
curl --user apiKey:apiSecret -X POST "https://sandbox.waylay.io/api/tasks/1/command/stop"
```

## Stop a task

```bash
curl --user apiKey:apiSecret -X POST "https://sandbox.waylay.io/api/tasks/1/command/start"
```

## Getting a single task by id

Get information about a single task. Response will include template definition and task's type and settings.

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks/{taskID}"
```

## Getting an existing task's configuration

Using this resource you can get the original task configuration that was posted to /api/tasks. Useful if you want to:

 * duplicate a task
 * update a task with a slightly modified configuration
 * run a batch injection on it's template with the same configuration

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks/{taskID}/conf"
```

## Query multiple tasks
> This call gives first 10 tasks (default behaviour), and if you need to filter your tasks, you can use a query language.

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks"
```
You can also query for tasks.


### Task querying filtering

Query parameters are:

* filter (fuzzy search on multiple properties)
* name
* resource
* type (scheduled, periodic, ...)
* status (running, stopped, failed)
* ids (comma separated string)
* id (can be added multiple times)
* tags (comma separated string)
* tag (can be added multiple times)
* plugin (`mySensor` or `mySensor:1.0.3`)
* template (use `'null'` for selecting tasks that don't have a template)

_All query parameters are combined with logical AND operator_. That means that if you combine more than one parameter together you will only receive tasks that match all conditions.


> Query task by name. For instance in this call you can retrieve all tasks that start with _taskName_.

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks?name=taskName*"
```
You query task by a name using * characters to get a list of tasks that matches the input string.


If you query task by resource, input must match the resource name exactly. You can still receive more tasks in case they all have the same resource name.

> Query to match tasks exactly by name

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks?resource=resource1"
```

> Quering tasks and paging

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks?startIndex=1"
```


> Default number of returned results is 10, and you can change this using _hits_ parameter. For instance, this call will retrieve maximum 50 tasks, starting search from the task index 50. (second page of 50-per-page results)

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks?startIndex=50&hits=50"
```


Related parameters:

* startIndex
* hits (default 10, max. 100)


## Get the total count of tasks
In order to retrieve the total task count, check the header of the response (X-Count)

> In order to retrieve the total task count, check the header of the response (X-Count). In this example, we receive back 27 tasks:

```bash
$ curl --user apiKey:apiSecret -I "https://sandbox.waylay.io/api/tasks"
```
```http
HTTP/1.1 200 OK
Server: nginx/1.6.2
Date: Wed, 07 Jan 2015 10:50:32 GMT
Content-Type: application/json
Content-Length: 0
Connection: keep-alive
X-Count: 27
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, DELETE, PUT
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Expose-Headers: X-Count
Strict-Transport-Security: max-age=31536000; includeSubdomains
```

> Example: get the total count of running tasks

```bash
$ curl --user apiKey:apiSecret -I "https://sandbox.waylay.io/api/tasks?status=running"
```
```http
HTTP/1.1 200 OK
Server: nginx/1.6.2
Date: Wed, 07 Jan 2015 10:50:32 GMT
Content-Type: application/json
Content-Length: 0
Connection: keep-alive
X-Count: 5
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, DELETE, PUT
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Expose-Headers: X-Count
Strict-Transport-Security: max-age=31536000; includeSubdomains
```

## Note on tasks and resources

Tasks and task nodes can be linked to a `resource`. There are some special node-related values you should know about:

* `$` - resource name will be inherited from the task resource name
* `$taskId` - resource name will be inherited from the task ID

As an example if you have 3 nodes with resource `$` and the task has resource `foo`, all three node-sensors will be triggered when data is injected for resource `foo`.

# Batch operations

There are 2 ways to perform batch operations. 
* asynchronously by queueing the operation on `/batch` (beta feature)
* synchronously by applying the operation /tasks (deprecated, might time out with 50x errors)

## Batch operation queue (beta)

### list the queue

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/batch"
```

You get back an array with all queued and a history of max 20 batch operations ordered descending by time submitted.

```json
[
  {
    "id":"f7fa8b2a-f7be-403c-9af7-e95c654b399f",
    "time":"2017-10-05T13:21:10.389Z",
    "operation":"Modify tasks by query: REMOVE"
  },
  {
    "id":"310282dd-377a-4a32-b1ed-599d0a1e9011",
    "time":"2017-10-05T13:21:10.388Z",
    "operation":"Modify tasks by query: REMOVE",
    "result":{"successful":[1,2],"failed":[]}
  }
]
```

### post a batch operation

This api is the same as the direct batch operations api but:
* instead of a `PATCH /tasks` you do a `POST /batch` (including query string params for filtering)
* You get back an ID instead of the results
* The results can then asynchronously be fetched using `GET /batch/:id`

```bash
curl --user apiKey:apiSecret -X POST "https://sandbox.waylay.io/api/batch?resource=testResource"
-H "Content-Type:application/json" -d '{ "operation": "command", "command": "remove" }'
```

```json
{
  "id":"f7fa8b2a-f7be-403c-9af7-e95c654b399f",
  "time":"2017-10-05T13:21:10.389Z",
  "operation":"Modify tasks by query: REMOVE"
}
```

## Direct operations (deprecated)

All the batch operations work with the same filters as querying for tasks, except the `filter` parameter which is not allowed because it's not exact.

### Delete multiple tasks

```bash
curl --user apiKey:apiSecret -X PATCH "https://sandbox.waylay.io/api/tasks?ids=1,3,9"
-H "Content-Type:application/json" -d '{ "operation": "command", "command": "remove" }'
```

or

```bash
curl --user apiKey:apiSecret -X DELETE "https://sandbox.waylay.io/api/tasks?ids=1,3,9"
```

### Modify existing tasks

```bash
curl --user apiKey:apiSecret -X PATCH "https://sandbox.waylay.io/api/tasks?ids=1,3,9"
-H "Content-Type:application/json" -d '{"operation": "xxx", ...}'
```

These calls will modify existing tasks in-place. Below an example of what such a request looks like:


### Commands

This allows to start or stop a bunch of tasks. Valid commands are [start, stop, remove, reload]

The body should look like this

```json
{
  "operation": "command",
  "command": "stop"
}
```

#### Reload tasks

This is mainly for applying template updates to existing tasks

```json
{
  "operation": "command",
  "command": "reload"
}
```


### Plugin updates

This will apply plugin version updates and re-instantiate the tasks.

The body should look like this (fromVersion can be an exact version or *any*)

```json
{
  "operation": "updatePlugins",
  "updates": [
    {
      "name": "myActuator",
      "fromVersion": "1.0.1",
      "toVersion": "1.0.3"
    },
    {
      "name": "mySensor",
      "fromVersion": "1.1.0",
      "toVersion": "1.3.2"
    },
    {
      "name": "mySensor",
      "fromVersion": "any",
      "toVersion": "2.0.0"
    }
  ]
}
```

<aside class="notice">
You are responsible to make sure this new plugin version stays compatible with the old provided properties
</aside>

<aside class="notice">
This is only allowed for tasks that have no linked template. For updating tasks that have been instantiated from a template you have to update the template and restart the tasks
</aside>

#### Modify task properties

This allows you to modify sensor / actuator properties while keeping the task Id.

The format used to modify properties is the same as when you create a [task from a template](#creating-a-task-from-a-template). Updates will be merged with any previously provided properties.

```json
{
  "operation" : "updateProperties",
  "nodes" : [ {
    "name" : "node1",
    "properties" : {
      "sensor" : {
        "requiredProperties" : [ {
          "prop1" : "updatedValue"
        }, {
          "prop1" : "updatedValue"
        } ]
      }
    }
  }, {
    "name" : "node2",
    "properties" : {
      "actions" : [ {
        "label" : "actuator1",
        "requiredProperties" : [ {
          "prop1" : "updatedValue"
        } ]
      } ]
    }
  } ]
}
```

# Templates
Templates are generic rules that have not yet been associated to a particular device or instance. The same template can be instantiated many times as tasks, by associating device specific parameters to a specific template. This mechanism is operationally very efficient in the sense that templates only need to be developed once, but can then be instantiated many times. As an example, assume you generate a template for an appliance and in the field, you have 100k appliances deployed: then you would have one template and 100k tasks running on the waylay platform. 

## Create a new template
You can create a template using "simplified" logic representation (without Bayesian Network):

> Template with sensors, actuators and relations

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
  "name" : "testSimpleJSON",
  "sensors": [
    {
      "label": "currentWeather_1",
      "name": "currentWeather",
      "version": "1.0.3",
      "sequence": 1,
      "properties": {
        "city": "Gent, Belgium"
      },
      "position": [173, 158]
    },
    {
      "label": "isWeekend_1",
      "name": "isWeekend",
      "version": "1.0.3",
      "sequence": 1,
      "position": [179, 369]
    }
  ],
  "actuators": [
    {
      "label": "TwitterDM_1",
      "name": "sendTwitterDM",
      "version": "1.0.1",
      "properties": {
        "screenName": "pizuricv",
        "message": "Great weekend!"
      },
      "position": [600, 199]
    }
  ],
  "relations": [
    {
      "label": "ANDGate_1",
      "type": "AND",
      "position": [353, 264],
      "parentLabels": ["currentWeather_1", "isWeekend_1"],
      "combinations": [["Clear", "TRUE"]]
    }
  ],
  "triggers": [
    {
      "destinationLabel": "TwitterDM_1",
      "sourceLabel": "ANDGate_1",
      "statesTrigger": ["TRUE"],
      "stateChangeTrigger": {
        "stateFrom": "*",
        "stateTo": "FALSE"
      },
      "invocationPolicy": 1
    }
  ]
}' "https://sandbox.waylay.io/api/templates"
```

In order to create a template you will need to specify the following in the request:

* sensors, list of sensors with required properties
* actuators, list of actuators with required properties
* relations, list of relations(gates) between sensors
* triggers, list of conditions under which actuators get executed.
* template name

Sensor and actuator settings are:

* label, node label
* name, sensor/actuator name
* version,
* position, array such as [245, 205],
* properties, key-value object of required properties
* resource , resource - applicable only for sensors
* sequence , sequence - applicable only for sensors, if omitted default is 1

Trigger settings are:

* destinationLabel, label of the actuator / sensor
* sourceLabel, label of the sensor / relation
* invocationPolicy, integer number that defines how long to wait before firing the same actuator again, even if the condition is met.
* statesTrigger, array of states under which to fire the actuator
* stateChangeTrigger, object containing stateFrom and stateTo which can be a specific state or *

Relations express logical gates that can be defined between sensors. There are 3 types of relations: AND, OR and GENERAL.

Relations settings are:

* combinations, array of arrays, such as ["Above", "Above"], ["Below", "Below"]. Only GENERAL gate will have more than one array of combinations
* label: "ANDGate_1"
* parentLabels, array of labels of sensors that are attached to this relation
* position, array such as [245, 205],
* type,  "AND", "OR" or "GENERAL"



## Create a new template using BN

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST
-d '{
    posterior: [ {
                    nodes: [ "CONNECTION", "Ping_1", "Ping_2", "Ping_3" ],
                    function: [ 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0 ]
                  } ],
    nodes: [ {
                states: [ "OK", "NOK" ],
                name: "CONNECTION",
                properties: {
                    position: [ 497, 235 ],
                    comment: "created by waylay",
                    cost: 1
                },
                type: "discrete",
                mode: "nature"
              },
              {
                states: [ "Not Alive", "Alive" ],
                name: "Ping_1",
                properties: {
                  position: [ 214, 317 ],
                  comment: "created by waylay",
                  cost: 1,
                  sensor: {
                    name: "Ping",
                    version: "1.0.1",
                    label: "Ping_1",
                    requiredProperties: [ { address: "www.google.com" } ] }
                },
                type: "discrete",
                mode: "nature",
                priors: [ 0.5, 0.5 ]
              },
              {
                states: [ "Not Alive", "Alive" ],
                name: "Ping_2",
                properties: {
                  position: [ 144, 163 ],
                  comment: "created by waylay",
                  cost: 1,
                  sensor: {
                    name: "Ping",
                    version: "1.0.1",
                    label: "Ping_2",
                    requiredProperties: [ { address: "www.waylay.io" } ] }
                },
                type: "discrete",
                mode: "nature",
                priors: [ 0.5, 0.5 ]
              },
              {
                states: [ "Not Alive", "Alive" ],
                name: "Ping_3",
                properties: {
                  position: [ 359, 62 ],
                  comment: "created by waylay",
                  cost: 1,
                  sensor: {
                    name: "Ping",
                    version: "1.0.1",
                    label: "Ping_3",
                    requiredProperties: [ { address: "www.yahoo.com" } ] }
                  },
                type: "discrete",
                mode: "nature",
                priors: [ 0.5, 0.5 ]
              } ],
            name: "internet2.json"
          }' "https://sandbox.waylay.io/api/templates"
```
You can also create a new template that is defined as a Bayesian Network. Compared to previous call, this call allows you to define gates as a **Conditional Probability Table** (CPT) and also allows you to attach actuators to the **likehood** of a node being in a given state:

## List all templates

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/templates"
```

### Template listing filtering

Query parameters are:

* filter (fuzzy search on multiple properties)
* name
* ids (comma separated string)
* id (can be added multiple times)
* plugin (`mySensor` or `mySensor:1.0.3`)

_All query parameters are combined with logical AND operator_. That means that if you combine more than one parameter together you will only receive tasks that match all conditions.

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/templates?plugin=mySensor"
```

## Get a template

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/templates/internet.json"
```

## Update a template

Templates can be updated using the http PUT method. This however will not update any tasks using the template. You will need to do a batch reload operation on the tasks to accomplish that.

```bash
curl --user apiKey:apiSecret -X PUT "https://sandbox.waylay.io/api/templates/mytemplate"
-H "Content-Type:application/json" -d '{"name": "mytemplate", ...}'
```

## Delete template

```bash
curl --user apiKey:apiSecret -X DELETE "https://sandbox.waylay.io/api/templates/internet.json"
```

## Modifying existing templates (batch)

```bash
curl --user apiKey:apiSecret -X PATCH "https://sandbox.waylay.io/api/templates?plugin=myActuator"
-H "Content-Type:application/json" -d '{"operation": "xxx", ...}'
```

All the batch operations work with the same filters as querying for templates, except the `filter` parameter which is not allowed because it's not exact. Some examples:

* `/templates?ids=mytemplate,myothertemplate` (specific templates)
* `/templates?plugin=mySensor` (mySensor any version)
* `/templates?plugin=mySensor%3A1.0.1` (mySensor 1.0.1)


### Plugin updates

This will apply plugin version updates to the templates.
Optionally you combine this with a reload of all tasks instantiated from the updated templates. (`reloadTasks` optional boolean property that defaults to false)

The body should look like this (fromVersion can be an exact version or *any*)

```json
{
  "operation": "updatePlugins",
  "updates": [
    {
      "name": "myActuator",
      "fromVersion": "1.0.1",
      "toVersion": "1.0.3"
    },
    {
      "name": "mySensor",
      "fromVersion": "1.1.0",
      "toVersion": "1.3.2"
    },
    {
      "name": "mySensor",
      "fromVersion": "any",
      "toVersion": "2.0.0"
    }
  ],
  "reloadTasks": true
}
```

<aside class="notice">
You are responsible to make sure this new plugin version stays compatible with the old provided properties
</aside>


## Running a template over a batch dataset (beta)

```bash
curl --user apiKey:apiSecret -X POST "https://sandbox.waylay.io/api/templates/mytemplate/run" -H "Content-Type:application/json" \
-d '{
      "data": [
        [{
           "resource": "resource1", 
           "temperature": 20
         }, 
         {
           "resource": "resource2", 
           "co2": 100,
           "humidity": 0.4
         }],
        [{
           "resource": "resource1",
           "temperature": 21
         }
        ]
      ], 
      "conf": {
        "parallel": false,
        "executeActuators": false,
        "resource": "resource1",
        "nodes":[
          {
            "name": "temp", 
            "properties": {
              "resource":  "resource1"
            }
          }
        ]
      }
    }'

```

You can run a template without creating a task by providing it with groups of resource-based data to inject. This allows running a template on a backlog of data while getting the results back as a stream while they are being produced.

These are the options you can set:

* `parallel` (default `false`) when set to `true` this will make processing faster as we will handle multiple batches at the same time. Make sure that your sensors can handle concurrent invocation!
* `executeActuators` (default `false`) by default we do not execute actuators, set this to `true` if you want actuation to happen. 
* `resource` (optional) sets the global resource for the running of the template. Relates to [note on tasks and resources](#note-on-tasks-and-resources).

<aside class="notice">
Any time based features are disabled as we are running the template at a faster speed than normal. No cron, no periodic invocation, no time-based node eviction. The `delaySensor` however will still work as expected and slow down processing.
</aside>

The request contains 2 parts, the `data` which is an array of arrays and `conf` for providing the template overrides like you do when [instantiating a task from a template](#create-a-task-with-sensor-properties-in-the-request).
Data is provided as an array of arrays where the outer array will control the number of invocations performed on the task. The resulting stream will have as many items as this array.
The inner array constitutes of all messages that should arrive at the task during that invovation. They will be mapped to nodes using the `resource` property.

The results are returned as a [application/x-ndjson](http://ndjson.org/) stream. Whenever an invocation ends you will receive a new json concatenated with a newline. The request will end once all data has been worked through.
In case of a single invocation this response can also be parsed as `application/json`

```json
{
  "nodes": {
    "alarm": {
      "state": "OK",
      "probability": 1
    },
    ...
  },
  "sensors":{
    "alarm": {
      "triggered": true,
      "result": true,
      "state": "OK",
      "rawData": {},
      "log": []
    },
    ...
  },
  "actuators": {
    "alarm": {
      "sms_send": {
          "triggered": true,
          "result": true,
          "message": "SMS sent",
          "log": []
        }
      },
      ...
    },
    ...
  }
}
\n
{ 
... second result here ...
}
\n
```


# Plugs (Sensors, Actuators and Transformers)

Note: More about how to write plugs can be found [here](/api/sensors-and-actuators/)

## Plug types

### Sensors

Sensors can be considered a generalized form of input connector for the waylay platform. You can create sensors to acquire data from physical devices, databases, applications or online services. You do this by means of writing Javascript and defining metadata. Waylay provides many examples which you can use as a baseline to create your own sensors, specific to your application. On a technical level, a sensor can be considered as a function that, when called, returns the state it is in.

### Actuators

Based on the outcome of the logic, you may want to take action, such as sending an alert, writing something in a database or acting on a physical system. You can take action based on any node being in a particular state, by attaching actuators to the particular node. As for the sensors, the waylay framework allows you to add your own definitions of actuators.

### Transformers

Transformers can be used to transforming incoming messages, like decoding, transforming or validation.

## Get list of all sensors

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/sensors"
```

## Execute sensor

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "properties": {
      "city": "Gent"
    }
  }' \
  "https://sandbox.waylay.io/api/sensors/weatherSensor/versions/1.0.1"
```

You can sensor specific parameters in the call, like in this example where we provide city name to the weather sensor:

## Get list of all actuators

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/actions"
```

## Execute actuator

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "properties": {
      "address": "veselin@waylay.io",
      "subject": "test",
      "message": "hello world"
    }
  }' \
  "https://sandbox.waylay.io/api/actions/Mail/versions/1.0.1"
```

You can provide actuator specific parameters in the call, like in this example where we provide e-mail address and message to mail actuator.

## Get list of all transformers

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/transformers"
```

## Execute a specific transformer version

The payload to transform should be provided as string in `properties.data`

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "properties": {
      "data": "{\"temperature\": 123.4}",
      "resource": "resource1"
    }
  }' \
  "https://sandbox.waylay.io/api/transformers/transformTemperatureFloat/versions/1.2.1"
```

## Execute the latest transformer version

The payload to transform should be provided as string in `properties.data`

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "properties": {
      "data": "{\"temperature\": 123.4}",
      "resource": "resource1"
    }
  }' \
  "https://sandbox.waylay.io/api/transformers/transformTemperatureFloat"
```

# Node related calls
In waylay terminology, sensor is it attached to the node.
During the runtime of the tasks, you can either inspect the node, or set the state, or execute attached sensors.


## Get current states
Get current states(posteriors) and raw data for the node

```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks/759/nodes/Ping_1"
```

## Get supported states
```bash
curl --user apiKey:apiSecret "https://sandbox.waylay.io/api/tasks/759/nodes/Ping_1/states"
```

## Set the state
```bash
curl --user apiKey:apiSecret -X POST  -d 'state=Alive' "https://sandbox.waylay.io/api/tasks/759/nodes/Ping_1"
```

## Execute attached sensor
> In this call below, we will execute Ping sensor on the task 759:

```bash
curl --user apiKey:apiSecret -X POST  -d 'operation=start' "https://sandbox.waylay.io/api/tasks/759/nodes/Ping_1"
```
At any time you can execute a sensor attached to the node. Please be aware that the state change will be inferred in that task right after the sensor execution.


# Provisioning API

Provisioning API allows you to associate metadata with resource. Resources are either discovered by Waylay (as soon as data is pushed towards Waylay Broker) or you can as well create them using REST call. Next to the resource CRUD related calls, waylay also allows you to create ResourceType entities, and let you link resource to a type using metadata (please see example below). As soon as a resource is linked to a resource type, all metadata values of that type are linked to that resource. Resource can still overwrite any specific attribute in its metadata model. Let's see how this work in practice:

## Create resource

> In this example, we create a resource _mydevice_id_ and add two additional attributes: _tenant_ and _label_:

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" -X POST \
    -d '{"id":"mydevice_id", "tenant":"tenant1", "label": "helloWorld"}' \
    "https://sandbox.waylay.io/api/resources"
```

> Example of creating a resource and immediately linking it to the resource type:

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" \
  -X POST \
  -d '{
    "id": "myDevice_id",
    "resourceTypeId": "resourceType_Id",
    "tenant": "tenant1",
    "name": "helloWorld"
  }'
  "https://sandbox.waylay.io/api/resources"
```

Reserved keywords for metadata:

Symbol|Type|Meaning
--- | --- |--- |
`resourceTypeId`|optional[String]||
`name`|optional[String]|name of the resource, like testresource
`provider`|optional[String]|LoRA, Sigfox..
`providerId`|optional[String]|provder_123
`tenant`|optional[String]|customer tenant name
`tags`|optional[List[String]]|(sequence of strings) // example ["Proximus", "myTag", "locationC"]
`location`|optional [Location type]| see below
`firmware`|optional[String]|1.2_1234
`lastMessageTimestamp`|optional[Integer]|(epoch time of the last contact)
`metrics`|optional[list[ResourceMetric]]| see below

Reserved keywords for Location type:

Symbol|Type|
--- | --- |
`lat`|Double|
`lon`|Double|

Reserved keywords for ResourceMetric:

Symbol|Type|Example
--- | --- |--- |
`name`|String|Temperature
`valueType`|String|integer, double, boolean, string, enum
`valueChoices`|optional[list[String]]| ["OK", "NOK"]
`metricType`|String|count / gauge / counter / timestamp (for events) _default gauge_
`unit`|optional[String]|SI units or non-SI units like Fahrenheit...
`maximum`|optional[Double]|0
`minimum`|optional[Double]|60


> Example of creating a resource with a metric in the request:

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" -X POST
-d '
    {
      "id":"mydevice_id3",
      "tenant":"tenant1",
      "label":"helloWorld",
      "metrics" : [
        {
          "name" : "Temperature",
          "unit":"C",
          "valueType": "double",
          "metricType": "counter" }]
      }'"https://sandbox.waylay.io/api/resources"
```

Reserved keywords for Metric type:

Symbol|Meaning
--- | --- |
`rate`|a number per second (implies that unit ends on ‘/s’)
`count`|a number per a given interval (such as a statsd flushInterval)
`gauge`|values at each point in time
`counter`|keeps increasing over time (but might wrap/reset at some point) i.e. a gauge with the added notion of “i usually want to derive this to see the rate”
`timestamp`|value represents a unix timestamp. so `sically a gauge or counter but we know we can also render the “age” at each point.

More about metric types you can find here [metric20org](http://metrics20.org/spec/)



> Example of creating a resource with location:

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" -X POST \
-d '{"id":"mydevice_id4", "tenant":"tenant1", "label":"helloWorld", "location" : {"lat" : 51, "lon":  3.71 }}' \
"https://sandbox.waylay.io/api/resources"
```

## Update resource

In order to update a resource, you need to put your resource Id in the path

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" -X PUT \
    -d '{"resourceTypeId":"resourceType_Id", "tenant":"tenant1", "name": "helloWorld"}' \
    "https://sandbox.waylay.io/api/resources/myDevice_id"
```


## Partial resource update

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" -X PATCH \
    -d '{"resourceTypeId":"resourceType_Id"}' \
    "https://sandbox.waylay.io/api/resources/myDevice_id"
```
Partial updates allow you to add/modify individual fields on a resource.



<aside class="notice">
This call also allows you to do upserts, if the resource for the provided id does not exist it will be created
</aside>

## Delete resource

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" -X DELETE \
    "https://sandbox.waylay.io/api/resources/mydevice_id"
```
In order to delete a resource, you need to put your resource Id in the path


## Retrieve resource

```bash
curl -i --user apiKey:apiSecret "https://sandbox.waylay.io/api/resources/mydevice_id"
```

In order to get a resource, you need to put your resource Id in the path


## Query resources
> Paging is handled by `skip` and `limit` parameters

```bash
curl -i --user apiKey:apiSecret "https://sandbox.waylay.io/api/resources?filter=car"
```

Resources can be queried by doing a GET request, if needed you can filter on these fields using the query string:

 * filter (partial match on multiple fields)
 * tag (can be added multiple times)
 * id (can be added multiple times)
 * provider
 * customer
 * resourceTypeId
 * lat, lon and distance (like 200km, 100m, ...)
 * q ([elasticsearch query string](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax))

## Create resource type

> In this example, we create a resource type and at the same time, we define metric types:

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" -X POST \
  -d '{"id":"resourceType_Id", "customeField":"value", "metrics" : [{"name" :"Temperature", "unit":"C", "valueType": "double", "metricType": "counter" }]}' \
   "https://sandbox.waylay.io/api/resourcetypes"
```


Reserved keywords for resource type:

Symbol|Type|Example
--- | --- | --- |
`id`|String|D12345 or UUID
`name`|Option[String]| device_123
`provider`|optional[String]|Proximus
`providerId`|optional[String]|123
`tenant`|optional[String]|customer1
`metrics`|optional[List[ResourceMetric]]| list of metrics, see below

## Delete resource type

```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" -X DELETE \
   "https://sandbox.waylay.io/api/resourcetypes/resourceType_Id"
```

## Retrieve resource type

```bash
curl -i --user apiKey:apiSecret "https://sandbox.waylay.io/api/resourcestypes/resourceType_Id"
```

In order to get a resource type, you need to put your resource type Id in the path

## Query resource types
> Paging is handled by `skip` and `limit` parameters

```bash
curl -i --user apiKey:apiSecret "https://sandbox.waylay.io/api/resourcetypes?filter=car"
```

Resources can be queried by doing a GET request, if needed you can filter on these fields using the query string:

 * filter (partial match on multiple fields)
 * id (can be added multiple times)
 * q ([elasticsearch query string](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax))
 
## Automatically create tasks by associating a template with a resource type

The waylay task engine can automatically provision tasks for each new resource. This is configured in the metadata of the resource type. All you need to add is a field `templates` that contains what templates should be used and what task configuration should be applied to these managed tasks.

> Resource type definition:

```json
{
    "id": "4b80d00a-89f0-41a0-b6e5-d4423caca844",
     ...
     "templates": [
        {
            "templateName": "templatex",
            "type": "periodic",
            "frequency": 60000
        },
        {
            "templateName": "templatey",
            "type": "scheduled",
            "cron": "0 0 12 * * ?"      
        }
     ]  
}
```

If for example an existing resource's type is set to the above type type then 2 tasks will be created.

In general these managed tasks are created/removed for these actions:

 * Resource created
 * Resource removed
 * Resource's resourceType field updated
 * ResourceType's templates field is updated
 * ResourceType is removed

# Real-time (STREAM) data

The waylay application allows you to push raw data and states to the running tasks. Normally this is done via [WaylayBroker](/api/broker-and-storage/) which allows you to terminate many different protocols (MQTT, WebSockets and REST), but if you wish, you can as well do it directly, calling STREAM related API call on the engine itself.

## Push real-time raw data
> Here is a REST invocation call that pushes temperature:

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
        "resource": "home_X_room1",
        "data":{
          "object": "home_X_room1",
          "type": {
            "unit": "C",
            "dataType": "double",
            "collectedType": "instant"
          },
          "parameterName": "temperature",
          "value": 23.0,
          "collectedTime": 1420629467,
          "validPeriodSecs": 600
        }
      }' "https://sandbox.waylay.io/api/data"
```
If you need to process real time data in your sensors (like location, temperature etc.), you have two options:

* use configuration property (see the interface spec) and fetch the data at runtime in the execute call
* ask the framework to provide you with real time data and fetch the data from the task context (during the execution call of the sensor).

In case that real time data is provided to the sensors via the context (option 2), the plugin developer has put the responsibility of providing the real time data to the person that implements the REST call. That person could e.g. implement an MQTT to REST bridge to accomplish this.
When making use of this REST call, you must use the resource parameter as the identifier of your device (or any other "thing"). This is the same resource identifier that is associated with the task when you create it. In this way, the waylay framework can link the pushed raw data and the tasks(and sensors) that require this data.

When tasks gets invoked, the framework will provide the pushed raw data to all tasks (and the sensors) that match the resource identifier. You can create as many tasks as you want using the same resource identifier.



Here is the app view where you can test this feature(designer in debug mode):

![](/api/images/global.png)


You can also push several parameters at once, and you can as well skip most of the parameter's attributes. For instance, with this call, we are pushing geolocation to the waylay platform, by specifying only longitude and latitude values. By default, waylay puts the _validPeriodSecs_ of the parameter to 60 seconds, and _collectedTime_ to the time the data was received:  

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST
-d '{
  "resource": "datasource",  
  "data": [ {
            "parameterName": "latitude",
            "value": 51
          },
          {
            "parameterName": "longitude",
            "value": 3.73
          }
        ]
  }' "https://sandbox.waylay.io/api/data"
```

For more information please check *Plugin SDK document*.

## Pushing states to the task
You can inject the state directly to the particular node in the task (as described before in the node section).

```bash
curl --user apiKey:apiSecret  --data "state=OPEN" -X POST https://sandbox.waylay.io/api/tasks/4/nodes/Door
```

> For example, if you have a door with two states OPEN/CLOSED, you can push a state change from an external system to the task.

```bash
curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
        "resource": "room_1",
        "nodes": [ {"node":"Door", "state": "OPEN"}]
      }' https://sandbox.waylay.io/api/data
```

# Alarms
Alarms on the Waylay platform are a way of tracking/following up on a condition/state of a resource.

## Create an alarm
```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" 
  -X POST 
  -d '{ 
          "type" : "io.waylay.alarm.test", 
          "timestamp" : "2011-09-06T12:03:27.845Z", 
          "text" : "Some alarm documentation", 
          "status" : "ACTIVE", 
          "severity" : "MAJOR",
          "source" : { "id" : "12345", "self" : "..." } 
        }' 
   "https://alarms.waylay.io/alarm/alarms"
```
To create an alarm, you need to provide the following inputs:

* type: type of the alarm
* text: description of the alarm
* severity: any of `CRITICAL`, `MAJOR`, `MINOR` or `WARNING`
* source: a JSON object with an `id` field indicating the resource 

Optional parameter :

* status: any of `ACTIVE`, `ACKNOWLEDGED` or `CLEARED` (if not specified, created alarm will have status `ACTIVE`)
* timestamp : ISO date string or number (indicating milliseconds since epoch) (if not specified, timestamp will be set to the receive time)

If an `ACTIVE` or `ACKNOWLEDGED` alarm with the same `source.id` and `type` exists, no new alarm is created. Instead, the existing alarm is updated 
by incrementing the `count`property and a new audit record of type `io.waylay.alarm.EventOccuredAgain` is added to the `history`. 

## Update an alarm
```bash
curl -i --user apiKey:apiSecret -H "Content-Type: application/json" 
  -X PUT 
  -d '{
        "severity" : "minor",
        "status" : "acknowledged"
      }'
  "https://alarms.waylay.io/alarm/alarms"
```
Only `severity` and `status` can be updated. Either one or both must be specified.

You can only update an `ACTIVE` or `ACKNOWLEDGED` alarm. Updating a `CLEARED` alarm will result in a response code `412 Precondition Failed`

Please notice that if the update actually doesn't change anything (i.e. request body contains data that is identical to
already present data in the database), there will be no audit record added.

## Deletion of a single alarm
```bash
curl --user apiKey:apiSecret 
  -X DELETE "https://alarms.waylay.io/alarm/alarms/02eee99c-cd32-4fd0-9a35-89fa15570ccc"
```

## Deletion of alarms in bulk 
```bash
curl --user apiKey:apiSecret 
  -X DELETE "https://alarms.waylay.io/alarm/alarms?source=..."
```
You can delete multiple alarms by specifying at least one filter in the query string. 
The possible filters are the same as the filters for quering the alarms (see below): `type`, `status`, `source`, `dateFrom`, `dateTo`

## Get an alarm
```bash
curl --user apiKey:apiSecret "https://alarms.waylay.io/alarm/alarms/02eee99c-cd32-4fd0-9a35-89fa15570ccc"
```

> Will return someting like

```json
{
    "id": "02eee99c-cd32-4fd0-9a35-89fa15570ccc",
    "self": "/alarm/alarms/02eee99c-cd32-4fd0-9a35-89fa15570ccc",
    "creationTime": "2017-09-12T15:23:33.075Z",
    "type": "io.waylay.alarm.test",
    "text": "Some alarm documentation",
    "timestamp": "2017-09-12T15:23:33.074Z",
    "source": {
        "id": "bruno"
    },
    "severity": "MAJOR",
    "status": "CLEARED",
    "count": 1,
    "history": [
        {
            "id": "02114638-5d25-4031-b22a-40c883eb4c79",
            "type": "io.waylay.alarm.AlarmRaised",
            "text": "Alarm raised",
            "timestamp": "2017-09-12T15:23:33.076Z"
        },
        {
            "id": "03bd1347-6d2b-4d90-bdb1-1b44972af3d1",
            "type": "io.waylay.alarm.AlarmUpdated",
            "text": "Alarm updated",
            "timestamp": "2017-09-23T11:18:56.358Z",
            "changes": [
                {
                    "attribute": "status",
                    "oldValue": "ACTIVE",
                    "newValue": "CLEARED",
                    "type": "io.waylay.alarm.change.status"
                }
            ]
         }
    ]
}
```

An alarm has following fields:

Name          | Type | Description
------------- | ---- | ----------------- |
`id` | UUID |Uniquely identifies an alarm.
`self` | URI |Link to this alarm.	
`creationTime` | ISO date string | Time when alarm was created in the database.
`type` | 	String	|	Identifies the type of this alarm.
`timestamp` | 	ISO date string	|	Time of the alarm.	
`text` | 	String	|	Text description of the alarm
`source` | 	JSON Object | The resource that the alarm originated from, as object containing the "id" property.
`status` | 	String	| The status of the alarm: `ACTIVE`, `ACKNOWLEDGED` or `CLEARED`. 
`severity` | String	| The severity of the alarm: `CRITICAL`, `MAJOR`, `MINOR` or `WARNING`. 
`count` | Long | The number of times this alarm has been sent.
`history` | List of AuditRecord | History of modifications tracing property changes.

The `history` keeps a record of changes that have happened to the alarm. There are 3 different types of changes:

* `io.waylay.alarm.AlarmRaised`: creation of the alarm
* `io.waylay.alarm.EventOccuredAgain`: a request to create an alarm happened, but an alarm of the same `type` in status `ACTIVE` or `ACKNOWLEDGED` existed 
 on the same `source` object at that moment
* `io.waylay.alarm.AlarmUpdated`: some attribute(s) of the alarm where updated. The audit record will contain a list of `changes` that happened.

## Query multiple alarms
```bash
curl --user apiKey:apiSecret "https://alarms.waylay.io/alarm/alarms"
```
> This above call gives the first 50 alarms. If you need to filter the alarms, you can use a query language

```bash
curl --user apiKey:apiSecret 
  "https://alarms.waylay.io/alarm/alarms?source=6&status=ACTIVE&status=CLEARED"
```

> This would give you a result like

```
{
    "self": "/alarm/alarms?status=ACTIVE&status=CLEARED&source=6",
    "next": "/alarm/alarms?status=ACTIVE&status=CLEARED&source=6&page=2",
    "total": 361,
    "alarms": [
        {
            "id": "586ac2f2-fbec-426a-b696-d63d6cb153ac",
            "self": "/alarm/alarms/586ac2f2-fbec-426a-b696-d63d6cb153ac",
            "creationTime": "2017-08-23T11:16:37.856Z",
            "type": "alarmtest",
            "text": "Another test alarm",
            "timestamp": "2017-08-23T11:16:08Z",
            "source": {
                "stuff": "blabla",
                "id": "6"
            },
            "severity": "MINOR",
            "status": "CLEARED",
            "count": 1,
            "history": [
                {
                    "id": "54597bdb-7409-4c47-b7ba-f08922b67ca2",
                    "type": "io.waylay.alarm.AlarmRaised",
                    "text": "Alarm raised",
                    "timestamp": "2017-08-23T11:16:37.856Z"
                },
                {
                    "id": "03bd1347-6d2b-4d90-bdb1-1b44972af3d1",
                    "type": "io.waylay.alarm.AlarmUpdated",
                    "text": "Alarm updated",
                    "timestamp": "2017-08-23T11:18:56.358Z",
                    "changes": [
                        {
                            "attribute": "status",
                            "oldValue": "ACTIVE",
                            "newValue": "CLEARED",
                            "type": "io.waylay.alarm.change.status"
                        }
                    ]
                }
            ]
        },
        {
            "id": "df036bf8-4b32-4bd8-8ee7-42800ab26bf5",
            "self": "/alarm/alarms/df036bf8-4b32-4bd8-8ee7-42800ab26bf5",
            "creationTime": "2017-08-18T15:54:51.180Z",
            "type": "alarmType",
            "text": "Another test alarm",
            "timestamp": "2009-02-13T23:31:30.128Z",
            "source": {
                "id": "6"
            },
            "severity": "MAJOR",
            "status": "ACTIVE",
            "count": 2,
            "history": [
                {
                    "id": "e64de65c-e3ef-482d-9eb7-32ca17d1e147",
                    "type": "io.waylay.alarm.AlarmRaised",
                    "text": "Alarm raised",
                    "timestamp": "2017-08-18T15:54:51.183Z"
                },
                {
                    "id": "b708f1e2-9da4-442b-ac6c-0120b0b11c08",
                    "type": "io.waylay.alarm.EventOccuredAgain",
                    "text": "Alarm event occured again",
                    "timestamp": "2017-08-21T07:26:47.209Z"
                }
            ]
        },
        ...
}
```

You can also query for alarms

Query criteria can be specified in the query string. Available criteria:

* `type`: filter on type
* `status`: filter on status
* `source`: filter on id of the source
* `dateFrom`: long (milliseconds since epoch) to filter on timestamp ( >= dateFrom)
* `dateTo`: long (milliseconds since epoch) to filter on timestamp ( <= dateTo)

Different query parameters are combined with logical AND operator. Specifing the same query parameter (only for `type`, `status` and `source`) more then once, 
will be handled with a logical OR operation.

That means that if you combine e.g. `status` and `source` parameter, you will get only alarms on the specified `source` with the given `status`, 
but if you specify e.g. `status` twice (like `status=ACTIVE&status=ACKNOWLEDGED`) you will get all `ACTIVE` and `ACKNOWLEDGED` alarms


Paging is also supported through the query string with following options (results are sorted by descending `timestamp`):

* `page`: page number (default: 1)
* `size`: size of a page (default: 50)


The response does contain `total` number of alarms that fullfill the criteria. Also the response contains links to the current page `self`, 
to the `next` page if there is a next page and the `previous` page if there is one.
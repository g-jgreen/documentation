---
title: Sensors and Actuators
description: Learn how to create your own sensors and actuators
weight: 2
---

# Introduction

Waylay is a cloud-based agent architecture that observes its environment via **software-defined sensors** and acts on its environment through **software-defined actuators**. A (very) high level blog about it you can find here [blog](http://www.waylay.io/blog-iot-meets-artificial-intelligence.html).
![Smart agent concept](/api/images/smart_agent.jpg)

In short, if you implement a weather sensor, it should return a state such as "Rain" or "Sunny", but it can as well provide information (rawData) such as temperature, humidity etc. Every sensor must either return **state** or **rawData** (it can also return both). Obviously, in order to execute a sensor, you will need some input, like _city_. How to declare what you need in the plug, and how the framework will provide this input to the sensor will be explained later in the document.

For the actuator implementation, there is no need to return any data, you just need to fire a script and that's it, this can be an SMS, mail, tweet, REST call or any other thing.

Actuator must be attached to sensors or gates, and it gets triggered when a particular condition is met. That condition can be a state or the state change of a sensor or gate. That implies that **only sensors that return states can be linked to actuators**.

Note: there is also possibility to write **java based plugs, but this feature is only supported in OEM package**. Java based plugs can be of your interest in case you want to write complex mathematical calculations which can't be handled by the [Functional node](#function-node). For more information how to write such plugs, please e-mail to info@waylay.io

# Javascript plugs
Via waylay platform you can write plugins in javascript. This is a sensor editor window that you get in the app:

![Sensor view](/api/images/sensorview.png)

## Sandbox
Every script is executed in the sandbox environment with a number of packages pre-installed. You can simply access them from the script, no need to require them. You have access to these (and only these) NPM packages:

* Q as Q,
* cheerio as cheerio,
* request as request,
* XMLHttpRequest as xhr,
* google cloud messaging as gcm,
* underscore as \_\_,  (a double underscore)
* unirest as unirest,
* twilio as twilio,
* mysql as mysql,
* mssql as mssql,
* postgres as pg,
* mqtt as mqtt,
* twitter as twitter,
* console as console,
* jsonPath as jsonPath,
* handlebarsjs as handlebarsjs,
* coap as coap,
* jsforce (salesforce) as jsforce,
* nodeHive as nodeHive,
* odoo (openERP) as odoo,
* async as async (from sandbox 0.8.8),
* ftp as FTPClient (from sandbox 0.8.10),
* concat-stream as concat (from sandbox 0.8.10),
* waylay util package as waylayUtil

In case you need more libraries, let us now at support@waylay.io.

Important thing to mention is that your script (both for sensors and actuators) **MUST send back a value**, regardless whether it was successful or not. So try to catch issues and send them back if you want. To send things back, call the method *send()*. If you call it without arguments, that is fine, but in case that this was a sensor, well then it is not that great. If you need a  working example, just click new sensor or new actuator in the app and editor with default implementation will appear on the screen.


In case of a sensor implementation, you want to send back a result, so you must call a method *send(null, value)*, where value is a JSON object with:

* observedState (string)
* rawData (JSON with key:value pairs)
Note that if you want to send a valid response back, the fist argument *must* be a *null*, otherwise, the framework will treat a first argument as the error. In case you wonder why, well, let us just say that we try to be compatible to [JSON-RPC spec](http://en.wikipedia.org/wiki/JSON-RPC)

## Sensor

> If you start by clicking "Create Sensor", you can see the following script created for you:

```javascript
// sensors should never throw exceptions but instead send an error back

if(options.requiredProperties.testProperty1) {
  var randomValue = Math.random();
  value = {
    observedState: randomValue > 0.5 ? "hello" : "world",
    rawData: {  message: "message", x: 2.34, random: randomValue, property: options.requiredProperties.testProperty1}
  };
  send(null, value);
}else{
  send(new Error("Missing property testProperty1"));
}
```
Every sensor must return `state`, `rawData` or both. For instance, if you implement a weather sensor, it should return a state such as “Rain” or “Sunny”, but it can as well provide information (rawData) such as temperature, humidity etc. Obviously, in order to execute a sensor, you will need some input, like city. How to declare what you need in the plug, and how the framework will provide this input to the sensor will be explained later in the document.
You can create sensors to acquire data from physical devices, databases, applications or online services. You do this by means of writing Javascript and defining metadata. Waylay provides many examples which you can use as a baseline to create your own sensors, specific to your application. On a technical level, a sensor can be considered as a function that, when called, returns the state it is in.

### Output

A sensor has two possible outputs:

#### Output State

 Each sensor has a limited amount of discrete states which it can be in, eg ON/OFF or LOW/MEDIUM/HIGH.
These states will be used when logic is applied. As an example, for the temperature sensor, you could define states as HOT (>30C), WARM (20C-30C), MILD (10C-20C), COLD (0C-10C) and FREEZING (<0C).
The sensor then returns the state information back to the logic and you can start building logic using these states.

#### Output Raw Data

This is the data that was collected or pushed in its raw form, like continuous value parameters such as eg temperature, light and memory used. In some cases, you may also want to use this raw data in the mathematical preprocessing step of your logic. Therefore this data is stored in the task context that can be used in your logic.

As you can see, this is just simple javascript, nothing fancy. The only thing you need to know at this point is that these scripts will be executed by a Node.js server, somewhere in the cloud. More precisely Node.js 4.x LTS. For details on supported ES6 api you can visit [node.green](http://node.green/).



## Sensor example
> This sensor is also handy if you want to get familiar with boolean gates or if you want to test formula computation using a [Function node](#function-node).

```javascript
var randomValue = Math.random();
var state;
if(randomValue > 0.85)
  state = "ONE";
else if(randomValue > 0.7)
  state = "TWO";
else if(randomValue > 0.55)
  state = "THREE";
else if(randomValue > 0.4)
  state = "FOUR";
else if(randomValue > 0.25)
  state = "FIVE";
else
  state = "SIX";
value = {  
    observedState:  state,
    rawData : {  random: randomValue}  
};
send(null,value);
```

In this example, this sensor will roll the dice, return one of the six states, and also return a random value. Random value can later been access via the RAW Data context (see below).

<aside class="notice">
In order to properly execute the script, sensor must return back send(null, value), where value is JSON object in form 
{ 
  observedState: "state",
  rawData : {
    key:value
  }
}
</aside>

<aside class="notice">
If you want to send an error with errorMessage, just call send(errorMessage).
</aside>


## Returning value from the sensor

> Example of the sensor response

```json
{
    "observedState":"Mist",
    "rawData": {
      "temperature":5.21,
      "pressure":999,
      "humidity":100,
      "temp_min":5,
      "temp_max":6,
      "wind_speed":2.1,
      "clouds_coverage":90,
      "sunrise":1486192543,
      "sunset":1486226593,
      "longitude":3.72,
      "latitude":51.05,
      "name":"Gent",
      "condition":"Mist",
      "icon":"http://openweathermap.org/img/w/50n.png"
    }
}
```
Note that you **always must return the value from the script**. It is either a state, or rawData or both.


Below you see an example of a result of a sensor invocation returned by the waylay webapp:
![](/api/images/sensorResult.png)

<aside class="notice">
If you want to send an error with errorMessage, just call send(errorMessage).
</aside>


## Actuator
You create an actuator the same way you create a sensor. 

> If you start by clicking "Create Actuator", you can see the following script created for you:

```javascript
// actuators should never throw exceptions but instead send an error back

if(options.requiredProperties.testProperty1){
  console.log("hello " + options.requiredProperties.testProperty1);
  send();
}else{
  send(new Error("Missing property testProperty1"));
}
```

## Actuator example
> This actuator creates a zendesk ticket.

```javascript
var username =  options.globalSettings.ZENDESK_USER;
var token = options.globalSettings.ZENDESK_KEY;
var subject = options.requiredProperties.subject;
var message = waylayUtil.template(options, options.requiredProperties.message);
var domain = options.globalSettings.ZENDESK_DOMAIN || "waylay";

console.log(message);

if(username && token && subject && message){

  var url = "https://"+domain+".zendesk.com/api/v2/tickets.json";
  var data = {
      "ticket" : {
          "requester" : {
              "name" : "waylayPlatform",
          }, "subject" : subject,
              "comment" : message
      }
  }
  var options = {
    url: url,
    json: data,
    auth:{
        user: username+"/token",
        pass: token
    }
  };

  var callback = function(error, response, body) {
    if (!error && (response.statusCode == 200 || response.statusCode == 201)) {
      send();
    }else{
      console.log(response);
      send(new Error(JSON.stringify(response)));
    }
  };

  request.post(options, callback);
}else{
  send(new Error("Missing properties"));
}
```
Similar to the sensor framework, Waylay provides a built­in framework that support actuators towards different systems. Actuators allow to execute actions based on the outcome of rules. 
Actuators are triggered as the result of the sensor execution (sensor state, or state changes). Writing actuator code is very similar to writing the sensor call. The only exception is that actuars are "fire and forget calls". They don't return states or rawData. In case you want to pass some data to the task context, please check this  [link](#actuator-related-raw-data). This actuator also makes use of [global settings](#global-settings) and [template call from utility package](#template)

<aside class="notice">
Note that you always must return send() from the actuator. If you want to send an error with errorMessage, just call send(errorMessage).
</aside>

# Metadata

```json
    {"name": "StockPrice",
        "description": "Stock exchange sensor, stock price value",
        "author": "Veselin",
        "version": "1.0.1",
        "iconURL": "http://app.waylay.io/icons/stock.png",
        "documentationURL": "",
        "category": "Stock",
        "states": [
            "Below",
            "Above"
        ],
        "configuration": [
            {
                "name": "threshold",
                "type": "DOUBLE",
                "mandatory": true,
                "sensitive": false
            },
            {
                "name": "stock",
                "type": "STRING",
                "mandatory": true,
                "sensitive": false
            }
        ],
        "rawData": [
            {
                "parameter": "volume",
                "dataType": "double",
                "collectedType": "instant",
                "unit": "double",
                "isObject": true
            },
            {
                "parameter": "high",
                "dataType": "double",
                "collectedType": "instant",
                "unit": "double",
                "isObject": true
            },
            {
                "parameter": "low",
                "dataType": "double",
                "collectedType": "instant",
                "unit": "double",
                "isObject": true
            },
            {
                "parameter": "price",
                "dataType": "double",
                "collectedType": "instant",
                "unit": "double",
                "isObject": true
            },
            {
                "parameter": "moving_average",
                "dataType": "double",
                "collectedType": "computed",
                "unit": "double",
                "isObject": true
            },
            {
                "parameter": "percent",
                "dataType": "double",
                "collectedType": "instant",
                "unit": "double",
                "isObject": true
            }
        ]
    }
```

As part of a sensor/actuator plugin definition, you also need to provide metadata. If you use waylay editor, metadata will be created automatically.
For sensor plugins the following metadata needs to be defined:

* *Name*: name of the sensor
* *Version*: three-digit version number.
* *Author*: author of the sensor.
* *Category*: sensors below to categories that group similar sensors. If the category does not exist yet, it will be created.
* *Documentation URL*: URL to external documentation for the sensor.
* *Icon URL*: URL to the icon that will be used in the webapp in combination with the sensor.
* *States*: define the states that the sensor can return to the node in your logic.
* *Properties*: inputs required to invoke the sensor.
* *Raw data*: raw data returned by the sensor.
* *Description*: Description of the sensor.

For actuator plugins, the following metadata needs to be defined:

* *Name*: name of the actuator
* *Version*: three-digit version number.
* *Author*: author of the actuator.
* *Category*: actuators below to categories that group similar actuators. If the category does not exist yet, it will be created.
* *Documentation URL*: URL to external documentation for the actuator.
* *Icon URL*: URL to the icon that will be used in the webapp in combination with the actuator.
* *Properties*: inputs required to invoke the actuator.
* *Description*: Description of the actuator.


These metadata of the sensors and actuators are also exposed over the REST interface.

For instance, this is a REST response of one sensor:


# Context
Every plug (both actuator and sensor) can access the context. Why is that needed? Let's imagine that you want to create a Mail actuator. You will need some information to create an email (subject, content, from, to etc...), and you will need API keys(if you use Mandrill for instance) or SMTP server settings. Plug should be able to tell this to the framework, and that is partially done via the metadata properties as described above.
Basically there are four ways plugs can access additionally information at runtime:

* using metadata to define properties required
* accessing global settings (e.g. API keys etc..)
* runtime data (measurements)
* task context

## Properties
> For instance, in the code you retrieve properties like this:

```javascript
var url = options.requiredProperties.url
```
These properties are normally provided to the script at configuration time. Typical examples of properties are URLs, API keys or connection settings.

You are also required to provide this info in the metadata of the plug (right hand side of the editor), i.e. these Required Properties are not automatically parsed from the JavaScript.

## Global settings
You can also declare global settings which are available to sensors and actuators. These settings are visible in the profile page. This way you can for instance declare API keys that rarely change.
When you define sensor or actuator, you can access these settings this way (where you need to replace the KEY with the exact key you have declared before):

`options.globalSettings.KEY`

> for instance you can write a code that requires a token like this:

```javascript
var token = options.globalSettings.token
```


This way you can decide whether you want to provide a token at the time you start a task from a template, or you want to declare it in the global settings.


## Raw Data
> If you want to get a temperature of the node Home, you would need to get it like this:

```javascript
var temperature = options.rawData.Home.temperature
```

> Now you can combine first two things together, so ask at configuration time a node name and then ask for temperature, by declaring that you need a node name in the Required Properties of the webscript:

```javascript
var temperature, nodeName = options.requiredProperties.node;
if (nodeName && options.rawData[nodeName]) {
  temperature = options.rawData[nodeName].temperature;
}
```
Every plug can access raw data at runtime, even when that raw data was collected by another sensor. The only limitation is that you need to know the name of the node that you want to get the data from. Later we shall see how we can access rawData using [**waylay utility package**](#utility-functions).

The raw data is provided in the form
`options.rawData[node_name]`


## Node related raw data
You can also access the current state and the last execution time of the sensor:

* `options.rawData[<nodeName>].state` and
* `options.rawData[<nodeName>].collectedTime` (in mills)


This is useful in case you want for instance to do a sequence computation on the states of the nodes, for more info, see later section on this.

## Actuator related raw data
> This is *not ideal*, but in case you need this, let me directly show you the code of one possible actuator implementation, that is only sending JSON object:

```javascript
send(null, {message: "hello world"});
```

> Notice that I was sending back value with a message. Normally, actuators are "fire and forget" by calling only _send()_ , but this one is sending back a value - attaching the result in the context to the node to which this actuator belongs! Later, you might want to do restore with this backup file:

```javascript
var nodeName = options.requiredProperties.node;
if(!options.actuatorData || !options.actuatorData[nodeName]){
    console.info("nothing to do");
    send();
}
else{
    var value = options.actuatorData[nodeName].message;
    /*you get back "hello world"
    .... your code goes here */
    send();
}
```

Similar to raw data context, an actuator also can push some (limited) results back to the task context.


Note: we will learn later how do the same with one liner, using [**waylay utility package**](#utility-functions).

## Task Data
> In your plug code, you access these settings this way:

```javascript
var resource = options.task.RESOURCE
var task = options.task.TASK_ID
var node_name = options.task.NODE_NAME
```

> For instance, if you want to create an actuator that would control the running task (please see REST documentation for more info), this is how you can do it this way:

```javascript
var taskID = options.requiredProperties.taskId || options.task.TASK_ID;
var command = options.requiredProperties.command;
var username =  options.globalSettings.API_KEY;
var password = options.globalSettings.API_PASS;

request.post(
    'https://'+ username + ':' + password +'@app.waylay.io/api/tasks/'+taskID+'/command/'+command,
    function (error, response, body) {
        if (!error && response.statusCode == 200) {
            send();
        } else
            send(new Error("Error executing the action"));
    }
);
```

In the task context, you can retrieve the following task-related data:

* resource name (task resource name)
* task ID (task ID)
* node name (node name of the sensor to which this call is attached at the moment of execution)


Note that this way you can call any REST waylay call. The script above in this example will either start or stop a task (command input), while the task ID can either come from the input param, or if not provided, it will act on the current task. This way, for instance, you can stop the task when a particular condition is met.

<aside class="notice">
Note that there is a better way to retrieve resource name by using waylay util package.
</aside>

## Node Data
> In your plug code, you access these settings this way:

```javascript
var name = options.node.NAME
var resource = options.node.RESOURCE
```

In the node context, you can retrieve the following node-related data:

* resource name (node resource name, in case it is defined it will be different from the resource name on the task level)
* node name (node name of the sensor to which this call is attached at the moment of execution)



# Utility functions
The name of the package is **waylayUtil**. This package provides 4 types of utility functions:

## Retrieve raw data
> to retrieve rawData as JSON for the node "nodeName"

```javascript
var rawData =  waylayUtil.getRawData(options, "nodeName");
```

> to retrieve parameter "parameterName" from rawData of the node "nodeName".

```javascript
var param =  waylayUtil.getRawData(options, "nodeName", "parameterName");
```

With this function you can either retrieve complete rawData as JSON object (2 arguments) of another node, or just the parameter of that node (3 arguments).

Unlike other calls in the util package, **waylayUtil.getRawData throws the exception if the data is not available**.  The reason is that we assume that when you call *getRawData* you really expect this data always to be available to you. Otherwise, actuator, or other sensor that expect data from another sensor will not be functioning correctly. That also allows you to see the errors in a debugger window or in the Actuator logger.

<aside class="warning">
  Unlike other calls in the util package, waylayUtil.getRawData throws the exception if the data is not available.
</aside>

## Retrieve cached raw data
> to retrieve parameter "latitude" from rawData of the node that invoke the script. This way you can for instance cache things that you need to retrieve only once (like location API).

```javascript
var rawData =  waylayUtil.getCacheData(options, "latitude");
```

This call is handy if you have a parameter that doesn't change between consecutive calls, such as geolocation of the fix location. In case you used API key to retrieve this location, makes little sense to invoke 3rd party REST endpoint every time sensor is executed.

For instance: you want to fetch geo location for a given address via the API service. Once the call is successful, in the result you can provide as the raw data "latitude" and "longitude". Next time, these values will be automatically in the rawData of that node, so by simply calling `waylayUtil.getCacheData` on both parameters will give you this information, avoiding a need to call REST call again.


## Retrieve stream data
> Example: to retrieve parameter "latitude" from the stream data for the node that has resource matching the stream resource (which sends parameter "latitude").

```javascript
var rawData =  waylayUtil.getStreamData(options, "latitude");
```
> In the following example, we want to make sure that the sensor returns the error, if it was executed by a task/node tick (via polling or cron). In that case, the stream object is empty.

```javascript
var streamdata = waylayUtil.getStreamData(options);
if(_.isEmpty(streamdata))
    send(new Error("No Streamdata"));
    else{
      var  value = {
            observedState: newState,
            rawData: {
                streamData: streamdata
            }
        };
    send(null, value);
}
```

If you have configured a node to get executed when new data arrives, you can retrieve that data using this call. If the sensor is executed by a task/node tick (via polling or cron), the stream object is empty.



## Retrieve resource name

```javascript
var resourceName =  waylayUtil.getResource(options);
```

When you associate the sensor with a given resource name, you can use this function in the sensor code to retrieve that name. Please keep in mind that some words are reserved:

* $  (resource name will be inherited from the task resource name)
* $taskId  (resource name will be inherited from the task ID)

This call will automatically translate $, $taskId into the runtime resource name.

## E-mail validation
returns true if the input entry is a valid email address.

```javascript
var boolean =  waylayUtil.validateEmail("test@gmail.com");
```


## Retrieve input property
Function to retrieve input parameter. This is a simple shortcut for the call: `options.requiredProperties.city`.

```javascript
var rawData =  waylayUtil.getProperty(options, "city");
```

## Evaluate inputs (eval)


```javascript
var rawValue =  waylayUtil.evaluateData(options, input);
```

With this call, you can create a formula, with input in this format:

`<node1.rawdat1> or <node1.rawdat1> OPER <node2.rawdat2> `  

Compared to [Function node](#function-node) eval function can't make statistical computations.



## JSONPath expression
waylay util packages uses [JSONPath expression](https://www.npmjs.com/package/node-red-contrib-jsonpath) to select rawdata, with some small addiotions, have a look at examples:

> Accessing the array of data points, or array of objects:

```javascript
var diff = waylayUtil.evaluateData(options,
    <node1.temperature> + <node3.items[0].temperature>)
```

> this way you can access the last point in the array:

```javascript
var diff = waylayUtil.evaluateData(options,
    <node1.temperature> + <node3.items[(@.length-1)].temperature>)
```

> If the array is array of objects, you can continue till the value you are interested in:

```javascript
var diff = waylayUtil.evaluateData(options,
    <node1.temperature> + <node3.items2[(@.length-1)].item.temperature>)
```

> You can also use selectors:

```javascript
var diff = waylayUtil.evaluateData(options,
    <node3.items3[?(@.name == 'piet')].temperature> + <node3.items3[?(@.name == 'veselin')].temperature>)
```

> You can also make a sentences this way (which is interesting thing to do if you want to send the actuator message with the content data from other sensors):

```javascript
var temp = waylayUtil.evaluateData(options,
    "Temperature is " + <node3.items3[?(@.name == 'piet')].temperature>)
```

> If you want to filter on a parameter that is greater or lower than a particular value, you must use &lt and &gt notation, for instance get all temperatures with values greater than 23 degrees:

```javascript
var temp = waylayUtil.evaluateData(options,
    <node3.items3[?(@.temperature &gt 23)].temperature>)
```

> You can also retrieve an array:

```javascript
var array = waylayUtil.evaluateData(options, "<node3.items.*>")
```

> There are also some small extensions to the library, mostly operations on arrays:
To get a count of elements:

```javascript
var count = waylayUtil.evaluateData(options, "<node3.items[count]>")
```

> You can also use some stats, in case that you select the array:

```javascript
var diff = waylayUtil.evaluateData(options,
    <node3.data[max]> - <node3.data[min]>)
```

> Produce a string from an array:

```javascript
var str = waylayUtil.evaluateData(options, "<node3.text[stringify]>")
```

> Produce a string from an array, joined by "and"

```javascript
var str = waylayUtil.evaluateData(options, "<node3.text[stringify, and]>")
```


## Template
> Template call using handlebars template language

```javascript
var message = waylayUtil.template(options, "Hello {{node.rawID}}")
```

In case you want to use actuators such as e-mail, you might wish to create an HTML based content. In that case you might want to use template call rather than evaluateData call. Note also that in order to provide rawData input, we use other delimiters {{}}. For more info, please check [handlebarsjs documentation](http://handlebarsjs.com/). If you want to specify _resource_ in template, use **{{RESOURCE}}**

We also provide a few handlebars helper functions, which are annotated by {{{}}}:

* add, so you can do this {{{add node1.value node2.value}}}
* subtract, so you can do this {{{subtract node1.value node2.value}}}
* multiply, so you can do this {{{multiply node1.value node2.value}}}
* divide, so you can do this {{{divide node1.value node2.value}}}
* date, or day N, where N is positive or negative number, so you can do {{{date}}} or {{{date -1}}} for yesterday
* time, local time {{{time}}}

## Distance function
> Distance function

```javascript
var dist = waylayUtil.getDistance(options, "nodeName1", "nodeName2");
```

You can use this function for nodes that have geo location in the raw data in format:

* longitude  
* latitude

> You can simply call the function this way, by providing all data:

```javascript
var dist = waylayUtil.getDistance(lat1, lon1, lat2, lon2);
```

# Function node

The Function node operates on the raw data that is stored in the task context.

## Function computation

If you have correctly created the metadata file of your sensor plugin, then the function editor will autocomplete the raw data that it can use for calculation. In case you have not defined the raw data as part of the sensor metadata, you will need to type everything manually. The screenshot below shows the autocompletion:
![](/api/images/formulaEditor.png)

The function processing has a number of built-in capabilities that are described below:

## Built-in functions
You can fetch the raw data from any node this way: `<node.value1>`. That allows you to do something like this:
`abs( <node.value1> - <node.value2>)`

You can use all built in functions available in exp4j: [Exp4j syntax](http://www.objecthunter.net/exp4j/#Built-in_functions)

Built-in functions:

* abs: absolute value
* acos: arc cosine
* asin: arc sine
* atan: arc tangent
* cbrt: cubic root
* ceil: nearest upper integer
* cos: cosine
* cosh: hyperbolic cosine
* exp: euler's number raised to the power (e^x)
* floor: nearest lower integer
* log: logarithmus naturalis (base e)
* log10: logarithm (base 10)
* log2: logarithm (base 2)
* sin: sine
* sinh: hyperbolic sine
* sqrt: square root
* tan: tangent
* tanh: hyperbolic tangent

When raw data values are used in a function, arrows between their corresponding nodes and the function processing node will be auto-created by the waylay application:
![](/api/images/formulaNodes.png)

Note that you should never try to connect sensors to the Function node, this is not going to work, just start typing the function in the Function node, that is all.

## Using previous values
You can also fetch the data from previous measurements using `[-n]` syntax:

`<node.value1> - <node.value1>[-1]`

In the example above `<node.value1>[-1]` means: the value of the raw data parameter _value1_ at the previous invocation time.


## Using time difference
You can also use a delta in time between measurements in your function with `dt` like this:

`abs( <node.value1> - <node.value1>[-1]) / dt` to get kind of first derivative computation

`dt` is replaced by time delta between invocations in seconds

## Statistical computation
You can also use some extensions for statistics such as `min, max, avg, std, count` this way:

`<max(node.value1)> - <min(node.value1)> `

`<count(5, node.pressure)>` or like string search:

`<count(Gent, node2.current_city)>`

* Statistics (avg, min, max, std) either takes 1 argument (value) or 3 arguments (number, [time/samples], value)
* Count either takes 2 arguments("searchKey", value) or 4 arguments ("searchKey", number, [time/samples], value)

## Aggregation types
You have 3 types of aggregation:

* overall aggregation
* by time
* by number of samples


You can also mix different types in one function like this:

`<max(3, minutes, node.value1)> - <min(5, samples, node2.value1)> `

`<max(3, samples, node.value1)> - <min(3, minutes, node2.value1)> `

`<count(5, 3, minutes, node.pressure)>`

You can also count the number of times a node was in a given state, for instance, the number of time a node was in the state "OK" for the last three samples:

`<count(OK, 3, samples, node.state)>`


Note: limitation is that you can't mix different aggregation types(samples and time) for the same parameter. But you can use overall aggregation (without samples, or time) and combine it with one of other aggregation types(samples or time).

## Distance calculation

For any two nodes that return longitude and latitude via raw data, you can compute the distance using this function:

`distance(node1,node2)`

Distance is returned in km.


## Sequence
You can also search for a sequence of states, if you want to monitor for changes of node states in time.

`<sequence([hello,world], node.state)>`

Function above will either return 1 or 0. 1 indicates that a match of the sequence has been found.

For instance, if you want to know whether 3 nodes will be in "hello,world" sequence, you can create function this way:

`<sequence([hello,world], node1.state)>`  + `<sequence([hello,world], node2.state)>` + `<sequence([hello,world], node3.state)>`

and test whether the result equals 3.


## Stream data

In the waylay application, stream data is put in the GLOBAL context before sensor is executed (waylay takes care that that context is valid for each sensor). You can access it via in javascript:
`options.rawData.GLOBAL.<param>` , nevertheless you should always use utility function as mentioned earlier to achieve the same [stream data function](#retrieve-stream-data):

`var rawData =  waylayUtil.getStreamData(options, "param");`


In the Function node, you MUST omit options.rawData and use only this notation: `<GLOBAL.param>`

Before deploying a new task, you can always check in the debug window that computation is actually happening. In the example below we used a dice sensor and couple of Function nodes. Note that you can as well put one Function node on top of others:

![](/api/images/formulaDebug.png)

---
title: Microsoft Azure IoT
description: This section explains how to connect your Microsoft Azure IoT instance to Waylay in order to get your data into the Waylay platform and to actuate back on your devices based on the outcome of the rules that you create with the Waylay engine.
weight: 1
---

# Connecting Azure IoT to Waylay

## Prerequisites

* Access to IoT Hub and Function apps in Azure
* Service account with permissions to IoT hub and Function app
* IoT connected device
* Access to the Waylay platform

Main building blocks of this integration are presented below:
![architecture](/features/iothubs/Azure/architectureAzure.png)

{{% alert info %}}
Note: For more technical information see [this whitepaper](https://docs.google.com/document/d/1yezzjqfpmfwwVLvlWjmt_52WO7HZ4WeRJyVq-WZtwMM/edit?usp=sharing) or [Github](https://github.com/waylayio/firmwares/tree/master/GrovePiCloudIoT/azureExample).
{{% /alert %}}


## Configuring Azure cloud platform

## Azure IoT Hub
### __Creating IoT hub__

You need to create an IoT hub to connect your devices with the Azure cloud platform.

1. Sign in to the [Azure portal](https://portal.azure.com)
2. Select `New` > `Internet of Things` > `IoT Hub`
![CreateIoTHub](/features/iothubs/Azure/createIoTHub1.png)
3. In the IoT hub pane, enter the following information for your IoT hub.
![CreateIoTHub](/features/iothubs/Azure/createIoTHub2.png)

### __Device registry (device provisioning)__

1. Choose `IoT Devices` under your created IoT Hub.
2. On top choose `add` to registry new device. 
3. Give deviceId and choose your authentication type (in this example we take a symmetric key with auto generate keys)
![deviceRegistry](/features/iothubs/Azure/deviceRegistry.png)

{{% alert info %}}
Note: you can also [create a device identity](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-node-node-getstarted#create-a-device-identity) with a script. 
{{% /alert %}}


## Configuring publish data from device
### __General__ 
There are four languages we can use to implement the client code;

* .NET
* Java
* Node.js
* Python

With IP-capable devices you can use the protocols AMQP, MQTT and HTTPS (which are standard implemented in the SDK of Azure)

{{% alert info %}}
Note: in this example we will use Node.js and the MQTT protocol to send are telemetry data from our device to the IoT Hub.
{{% /alert %}}

### __Example of client code__
This example (Based on MQTT Implementation) will push data from a RaspberryPi3 with a GrovePi configured Light Sensor to our IoT hub. Below you can see the configuration of your client code by using the SDK's of Azure.
```
'use strict'

// you can change protocols by uncomment/comment the different protocols
var Protocol = require('azure-iot-device-mqtt').Mqtt
// var Protocol = require('azure-iot-device-amqp').AmqpWs;
// var Protocol = require('azure-iot-device-http').Http;
// var Protocol = require('azure-iot-device-amqp').Amqp

var Client = require('azure-iot-device').Client
var Message = require('azure-iot-device').Message

// with the connectionstring of a device you can only connect to one particular device
// var connectionString = '<connectionstring of deviceId>'

// with this connectionstring you can connect with all the devices you want. You only need to change the deviceId and you need a shared acces policy that have the right permissions. iothubowner default has all the permissions
var connectionString = '<connectionString of shared acces policies;DeviceId=<this deviceId>>'
var client = Client.fromConnectionString(connectionString, Protocol)

const GrovePi = require('node-grovepi').GrovePi
let LightAnalogSensor = GrovePi.sensors.AirQualityAnalog
```
* To get the connection string of your device go to your IoT hub choose `IoT Devices`and select your device. On your right you will see the connectionstring.
* To get the connection string of your shared acces policies go to your IoT hub choose `shared acces plicies`and select your policy. On your right you will see the connectionstring. 

{{% alert warn %}}
Don't forget to add the deviceId to your connectionstring
{{% /alert %}}

The publishing of the data looks something like this:

```
var sendInterval = setInterval(function () {
      const sensorValue = LightAnalogSensor.read().toString()
      const data = JSON.stringify({
        'lightValue': sensorValue
      })

      var message = new Message(data)
      console.log('Sending message: ' + message.getData())
      client.sendEvent(message)
      }, 3000)
```

As you can see we will get the value of the ligthsensor every 3 seconds and send it to the IoT hub.

{{% alert info %}}
Note: you can find the full code on [Github](https://github.com/waylayio/firmwares/blob/master/GrovePiCloudIoT/azureExample/publishPiDataAzure.js). Don't forget to take a look at the [readme.md](https://github.com/waylayio/firmwares/blob/master/GrovePiCloudIoT/azureExample/README.md) for more information.
{{% /alert %}}


## Function app
### __General__ 
At this moment IoT hub receives all the messages from all his devices that are registerd. All these messages/evenst are available at the IoT hub built-in endpoint messages/events. With Function app we can make a trigger for whenever a message is available at that built-in endpoint of IoT hub.

### __Configuration__
First of all, you need to create the Function app of Azure itself. Therefore, you can follow the [tutorial](https://docs.microsoft.com/en-us/azure/azure-functions/functions-create-first-azure-function) until the chapter of http trigger.

Now we are going to create a function with a trigger from the IoT hub built-in endpoint. 

1. Continuing on the previous tutorial we click on the plus which standing next to the submenu Functions.
2. Next choose the template IoT Hub (Event hub)
3. Choose your preferable language (in this example we take javascript), your name.
![CreateFunctionApp](/features/iothubs/Azure/createFunctionApp.png)
4. Now you need to click on new with Event hub connection. Then you will get a popup.
![CreateFunctionApp](/features/iothubs/Azure/createFunctionApp1.png)
5. Choose IoT hub and select your IoT hub and choose the endpoint `Events (built-in endpoint)`
6. The event hub consumer group must be set to `$Default` and the Event hub name must be the same as your IoT Hub name.
{{% alert info %}}
For more information about consumergroups read built-in enpoints on [Microsoft docs](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-create-through-portal#endpoints).
{{% /alert %}}
7. At this moment we created the function. We only need to make one adjustment namely, go to your function > `Integrate` > `Triggers`  and change the event hub cardinality to `One`. Also check if the Event Parameter name is set to `IoTHubMessage` so there will be no problems with copy the code below.

At this moment we created are function correctly. Click on your function and you will see the actual code. Now you can delete that code and paste the code below in it.

```
var http = require('http')
const Waylay = require('@waylay/client')

module.exports = function (context, IoTHubMessage) {
  const domain = '<domain of Waylay>'
  const token = '<token of Waylay>'
  const url = '<url of Waylay>'
  const waylay = new Waylay({
    domain,
    token,
    data: {
      baseUrl: url
    }
  })

  // here you get the deviceId from the device who's sended the telemetry data
  const deviceId = context.bindingData.systemProperties['iothub-connection-device-id']

  context.log(deviceId + ' ' + IoTHubMessage.lightValue)
  waylay.data.postSeries(deviceId, IoTHubMessage)

  context.done()
}

```


As you can see we have implemented the package Waylay/client. This needs to be uploaded and installed.

{{% alert info %}}
More information about [@waylay/client](https://www.npmjs.com/package/@waylay/client)
{{% /alert %}}

First of all you need to create a file `package.json` with the following content: 

```
{
 "name": "package",
 "version": "1.0.0",
 "description": "",
 "main": "index.js",
 "author": "",
 "license": "ISC",
 "dependencies": {
   "@waylay/client": "^1.0.5"
 }
}
```


Now you need to go to your function and on your right you need to click on view files. There you can upload your package.json. After this you need to install your dependencies. Follow therefore these next steps;

1. Navigate to Function app
2. Go to platform features
3. Choose console in development tools
4. Go to your function ``` cd <your function> ```
5. npm install


### __Check if the data is being pushed to Waylay__ 
Now you can run your script from your device and check if the data is arriving. Go to `https://<customerDomain>/#/resources/<deviceId>` and look up your resource with the DeviceId you specified. If all goes well you should see your data under data > all messages.


## Configuring Waylay platform
### __General__
In order to actuate back on a device, we will use the following template
![overview](/features/iothubs/overview.png)

{{% alert info %}}
Here you can find the [template](https://staging.waylay.io/#/templates/IoTazureHTTP) you need.
{{% /alert %}}

The stream sensor will receive data for a particular resource. Device data (which means the lightvalue) is pushed from a device to the IoT hub, and then via the Function app of Azure been forwarded to the Broker. The Sensor has in this examples 2 triggers: `Above` and  `Below`, when its  `Above` or `Below` a specific value it activates or deactivates a light.

The actuator will send the response back to the device via the IoT hub. We will do that by an Http request with direct methods which means we will call a method from our device. Good to know, we can give a payload with this method.

{{% alert info %}}
For more information about sensors and actuators go to this [link](https://docs.waylay.io/api/sensors-and-actuators/).
{{% /alert %}}

### __Creating a test template__
Below you can see which parameters needed to be adjust and with which meaning. In brackets you can see the solution you need to take for this example.

* replace ${apiKey} and ${apiSecret} with your own keys
* replace `{{RESOURCE}}` if you want another targetdevice then your telemetry device. 
* replace ${methodName} with the methodname of a function of your targetdevice. (adjustingLedState)
* replace ${IoTHubConnection} with the connectionstring of your IoT Hub. 
* replace ${policyKey} with a key of your shared acces policies. Note: don't forget you need at least device and service rights to do this.
* replace ${policyName} with the name of your shared acces policy.
* replace ${expiresInMins} with the time in minutes before your SAS token expires. (60)
* replace ${responseTimeout} with the time in miliseconds when there will come a responsetimeout. (200)
* replace ${Resource} with the device's Id that's sending telemtry data. 

```
curl --user ${apiKey}:${apiSecret} -H "Content-Type:application/json" -X POST -d '{
"name" : "azureIoTTemplateExample",
 "sensors": [
   {
     "label": "streamDataSensor_1",
     "name": "streamingDataSensor",
     "version": "1.1.1",
     "resource" : "$",
     "position": [150, 150],
     "properties": {
       "parameter": "lightValue",
       "threshold": 350
     }
   }
 ],
 "actuators": [
   {
     "label": "lightOff",
     "name": "publishToAzure",
     "version": "0.0.8",
     "properties": {
       "targetDevice": "{{RESOURCE}}",
       "methodName": "${methodName}",
       "payload": "{ \"lightStatus\": \"OFF\" }",
       "IoTHubConnection": "${IoTHubConnection}",
       "policyKey": "${policykey}",
       "policyName": "${policyname}",
       "expiresInMins": ${expiresInMIns},
       "responseTimeout": ${responseTimeout}
     },
     "position": [512,365]
   },
   {
     "label": "lightOn",
     "name": "publishToAzure",
     "version": "0.0.8",
     "properties": {
       "targetDevice": "{{RESOURCE}}",
       "methodName": "${methodName}",
       "payload": "{ \"lightStatus\": \"ON\" }",
       "IoTHubConnection": "${IoTHubConnection}",
       "policyKey": "${policykey}",
       "policyName": "${policyname}",
       "expiresInMins": ${expiresInMIns},
       "responseTimeout": ${responseTimeout}
     },
     "position": [350,172]
   }
 ],
 "triggers": [
   {
     "destinationLabel": "lightOn",
     "sourceLabel": "streamDataSensor_1",
     "statesTrigger": ["Below"]
   },
   {
     "destinationLabel": "lightOff",
     "sourceLabel": "streamDataSensor_1",
     "statesTrigger": ["Above"]
   }
 ],
 "task": {
  "name": "AzurePublishingTemplate",
   "resource": "${resource}",
   "type": "reactive",
   "resetObservations": false,
   "parallel": false,
   "start": true
 }
}' "https://staging.waylay.io/api/templates"
```


## Configuring C2D (cloud-to-device) messages 
### __General__
Now we are almost ready. We are able to send request from the Waylayplatform to the cloud. At this moment we only need to receive this messages from the cloud on our targetdevice. First I'm going to explain short what happening. So the data is actuating form the Waylayplatform with the HTTP protocol to the cloud. Afterwards this C2D message will be send to the specific MQTT topic of that particular device. So now we only need to listen to our IoT Hub for receiving messages.

### __Example of Code__
Below you can see the code for the created function adjustingLedState. On request.payload.lightStatus we will receive the data that is sended from the Waylayplatform.
```
function adjustingLedState (request, response) {
  console.log(request.payload.lightStatus)
  if (request.payload.lightStatus === 'ON') {
    led.turnOn()
  } else {
    led.turnOff()
  }

  response.send(200, function (err) {
    if (err) {
      console.error('An error ocurred when sending a method response:\n' + err.toString())
    }
  })
}
```


Now we add the method to our client. So he knows he needs to 'listen' to this method.
```
var connectCallback = function (err) {
  if (err) {
    console.error('Could not connect: ' + err)
  } else {
    console.log('Client connected')
    client.onDeviceMethod('adjustingLedState', adjustingLedState)

    client.on('error', function (err) {
      console.error(err.message)
    })

    client.on('disconnect', function () {
      clearInterval(sendInterval)
      client.removeAllListeners()
      client.open(connectCallback)
    })
  }
}

client.open(connectCallback)
```

{{% alert info %}}
Note: you can find the full code on [Github](https://github.com/waylayio/firmwares/blob/master/GrovePiCloudIoT/azureExample/publishPiDataAzure.js). Don't forget to take a look at the [readme.md](https://github.com/waylayio/firmwares/blob/master/GrovePiCloudIoT/azureExample/README.md) for more information.
{{% /alert %}}



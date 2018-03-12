---
title: Google IoT Core
description: Connecting IoT Core with Waylay
weight: 8
---

# Connecting Google Cloud IoT Core to Waylay using Webscripts

Prerequisites

* Google Cloud Project
* Access to Google Cloud IoT Core and Pub/Sub
* Service account with admin rights to nr. 2
* IoT connected device
* Access to the Waylay platform

Illustration
![architecture](/features/iothubs/architecture.png)

## Configuring Google IoT Core

## Device Registry

First off all create a new device registry by clicking on ‘Create device registry’ under IoT Core.

![iotcore](/features/iothubs/iotcore.png)

Provide the new registry with:

* Unique identifier
* Cloud region 
* Protocol (default ‘HTTP and MQTT’)
* Pub/Sub Default Telemetry topic (Telemetry Topic is The default Topic for sending the device’s data to)
* You can choose for a sub Telemetry topic if you wish to divide your data into sub pieces of information.
* Device state topic (State Topic is where the device publishes his current state upon)
* (Optional CA certificate) Certificates are used to verify signatures of device credentials

{{% alert info %}}
Note: you can always change the Telemetry/State topics after creation of the device registry
{{% /alert %}}


## Devices

Click on your newly created device registry and click the button ‘add device’.

{{% alert info %}}
Note: for mass deployment you can use the Google Pub/Sub API.
{{% /alert %}}

Fill in the fields required for creating a new device

* Unique Identifier
* Device communication (default ‘allow’)
* Authentication (default ‘RS256’)

Generating a RS256 public / private key for mac / linux users:

```
ssh-keygen -t rsa -b 4096 -f jwtRS256.key
# Don't add passphrase
openssl rsa -in jwtRS256.key -pubout -outform PEM -out jwtRS256.key.pub
cat jwtRS256.key
cat jwtRS256.key.pub
```

For windows users: 

https://docs.joyent.com/public-cloud/getting-started/ssh-keys/generating-an-ssh-key-manually/manually-generating-your-ssh-key-in-windows

Enter the public key into the field ‘Public key value’
Save the private key locally for later use (Device Authentication Flow)

For more information on device security: 

https://cloud.google.com/iot/docs/concepts/device-security?hl=en_US&_ga=2.157914809.-245746767.1518525898&_gac=1.254003772.1519056691.EAIaIQobChMIuOLgjq-y2QIVLrXtCh0gpQYKEAAYASAAEgLsiPD_BwE

{{% alert info %}}
Note: If your physical device has a low computational power you should use the lower weight Elliptic curve algorithms.
{{% /alert %}}


## Device Authentication flow
![autenticationflow](/features/iothubs/authenticationflow.png)

The device creates a JWT in order to connect to the MQTT Bridge, the device connects using the deviceId and JWT. MQTT Bridge verifies the signature and connects the device.

## Pub/Sub Topics and Subscriptions
Topics are used for sending data to, on this data you can subscribe afterwards. There are 2 types of subscriptions:

* Push (Pushes data from topic subscription into an endpoint, example: Waylay)
* Pull

In the case of connecting Google Cloud IoT Core to the Waylay Broker we will make a new Subscription on our default Telemetry Topic provided in our Device Registry.

In the Google Cloud Menu go to ‘Pub/Sub’ and choose ‘Topics’, you will now see a list of preconfigured Topics. Click the 3 dots next to your Default Telemetry Topic and click on ‘New Subscription’.

![subscription](/features/iothubs/subscription.png)

Enter a unique name identifier and choose the delivery type.

{{% alert info %}}
For sending data to waylay select ‘Push into an endpoint url’ -> This will be the url of the Webscript that will manipulate the data to push it to the Waylay Broker (**see next section**).
For pushing data from a Subscription to the Waylay Webscript you should contact us for verifying the domain name for you. Contact us at support@waylay.io
{{% /alert %}}

## Webscript

Create a webscript on your own domain. Use following code to manipulate the data that comes from your Topic.

```javascript
waylay.data.baseUrl = 'https://data.waylay.io'

function handleRequest (req, res) {
  const { body } = req
  const { attributes, data } = body.message
  
  try {
    const payload = new Buffer(data, 'base64').toString('utf8')  
    const { deviceId } = attributes
    
    const parsedPayload = JSON.parse(payload)
    
    // This creates a Resource inside the waylay platform with name = deviceId
    waylay.data.postSeries(deviceId, parsedPayload)
      .then(() => {
        res.sendStatus(204)
      })
      .catch(err => res.status(500).send(err))
  } catch (err) {
    console.error(err)
    res.status(400).send(err)
  }
}
```

## Client code for pushing data to Google Pub/Sub in Node.JS

2 options:

* MQTT
* Google Pub/Sub Client 

**MQTT implementation**

Example implementation of the MQTT client by Google can be found on:
https://github.com/GoogleCloudPlatform/nodejs-docs-samples/tree/master/iot/mqtt_example

**Google Pub/Sub Client implementation**

Their implementation of the client can be found on:
https://github.com/googleapis/nodejs-pubsub

In a practical example you can pull data from an IoT connected device and publish it to a topic on Google Cloud Pub/Sub. The device ID you specify in the client code resembles to device ID you setup with your device. This will be translated to a resource in the waylay engine.

## Sending state back depending on what you configured in Waylay Templates.


{{% alert info %}}
Note: By pushing from your Telemetry Topic into the Waylay Webscript the Waylay Broker automatically creates a ‘Resource’ for you. This resource can be found on:
{{% /alert %}}

https://staging.waylay.io/#/resources/ 

Quick overview on how we implement Rules in Waylay:

![overview](/features/iothubs/overview.png)

The resource node (SENSOR) streams data from a particular resource. (Your resource’s data is being pushed on whatever frequency you push data from your device to the Google Pub/Sub Topic).
The Sensor has in this examples 2 boundaries; Above and Below, when its Above or Below a specific value it activates or deactivates a light. This actuation is just a simple Message that is pushed to a Topic that your device can listen to in order to take action depending on the message.  

To make a Template yourself go to the end of the page and see section **testing standard template**

For further information on how the Designer, Sensors and Actuators work go to:
https://docs.waylay.io/api/sensors-and-actuators/

## Allowing Waylay to publish to your Topics

![crossplatform](/features/iothubs/crossplatform.png)

This is needed for the activation of the Webscript that publishes your data based on your rules back your predefined Topics. In order to achieve this you have to give our Service Account a Role of Publisher in your policy.
Our serviceAccount email is:  ```quiet-mechanic-140114@appspot.gserviceaccount.com```

{{% alert info %}}
If you get an unauthorized error you can use a different approach:
{{% /alert %}}


Go to ‘Pub/Sub’ -> ‘Topics’ -> Select your topic -> click the three bullets -> Permissions -> Add Members -> Fill in the member field with: ```quiet-mechanic-140114@appspot.gserviceaccount.com```

Select role: ```Pub/Sub publisher```

Click Add.

![permissions](/features/iothubs/permissions.png)

More information on these policies: 
https://cloud.google.com/pubsub/docs/access-control

## Actuating back to your state Pub/Sub Topic

In the Waylay designer search for: ```GoogleIoTCoreWebscriptActuator```

Parameters to provide in the actuator:

* Waylay webscript URL: Webscript URL of the Webscript with the code below
* Google Project Id
* Google Pub/Sub Topicname
* JSON to publish ex.: ```{"lightValue”: "500”}```

Subscribing to your state Pub/Sub Topic on your physical device
Examples can be found here:
https://github.com/googleapis/nodejs-pubsub/blob/master/samples/subscriptions.js

## Testing a standard template

Webscript:

Import dependency: @google-cloud/pubsub / version:	0.16.4	
```javascript
function handleRequest (req, res) {
  const { projectId, topicname, json } = req.body

  const PubSub = require('@google-cloud/pubsub')

  const pubsubClient = new PubSub({
    projectId: projectId
  })

  function publishMessage () {
    const jsonData = JSON.stringify(json)
    const dataBuffer = Buffer.from(jsonData, 'utf8')

    pubsubClient
      .topic(topicname)
      .publisher()
      .publish(dataBuffer)
      .then(results => {
        const messageId = results[0]
        console.log(`Message ${messageId} published.`)
        res.send('Message published')
      })
      .catch(err => {
        console.error('ERROR:', err)
      })
  }
  
  publishMessage()
}
```

* Device with unique Id
* Active Topic linked to a device
* Active State Topic linked to a device (with permission configured that Waylay can push into this topic)
* Active Subscription which pushes into a Webscript endpoint (see section Webscript)
* Webscript with the code provided above
* Acces to the Waylay platform

Things to provide in this template:

* replace ${yourResource} with your deviceId
* replace ${yourProjectId} with your Google Cloud Platform ID
* replace ${yourTopicname} with the Topic's name to push state data to (this is configured for each registry (See Device section))
* replace ${userApiKey} and ${userApiSecret} with your credentials (can be found on Waylay platform under profile)

```json
curl --user ${userApiKey}:/${userApiSecret} -H "Content-Type:application/json" -X POST -d '{
"name" : "googleIoTExample",
 "sensors": [
   {
     "label": "streamDataSensor_1",
     "name": "streamingDataSensor",
     "version": "1.1.0",
     "resource" : "${yourResource}",
     "position": [150, 150]
   }
 ],
 "actuators": [
   {
     "label": "lightOff",
     "name": "GoogleIoTCoreWebscriptActuator",
     "version": "0.0.2",
     "properties": {
       "url": "${webscripturl}",
       "json": "{ \"lightStatus\": \"off\" }",
       "projectId": "${yourprojectid}",
       "topicname": "${yourtopicname}"
     },
     "position": [512,365]
   },
   {
     "label": "lightOn",
     "name": "GoogleIoTCoreWebscriptActuator",
     "version": "0.0.2",
     "properties": {
       "url": "${webscripturl}",
       "json": "{ \"lightStatus\": \"on\" }",
       "projectId": "${yourprojectid}",
       "topicname": "${yourtopicname}"
     },
     "position": [512,172]
   }
 ],
 "triggers": [
   {
     "destinationLabel": "lightOn",
     "sourceLabel": "streamDataSensor_1",
     "statesTrigger": ["Above"]
   },
   {
     "destinationLabel": "lightOff",
     "sourceLabel": "streamDataSensor_1",
     "statesTrigger": ["Below"]
   }
 ],
 "task": {
   "type": "reactive",
   "start": true,
   "name": "Rule 1",
   "resource": "testresource"
 }
}' "https://staging.waylay.io/api/templates"
```
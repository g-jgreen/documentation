---
title: Google IoT Core
description: Connecting IoT Core with Waylay
weight: 1
---

# Connecting Google Cloud IoT Core to Waylay

## Prerequisites

* Google Cloud Project
* Access to Google Cloud IoT Core and Pub/Sub
* Service account with admin rights to IoT Core and Pub/Sub
* IoT connected device
* Access to the Waylay platform

Main building blocks of this integration are presented below:
![architecture](/features/iothubs/architecture.png)

## Configuring Google IoT Core

## Device Registry (device provisioning)

First off all, for every new device, you need to create a new device registry by clicking on `Create device registry` under IoT Core.

![iotcore](/features/iothubs/iotcore.png)

You will be asked to provide:

* Unique identifier
* Cloud region 
* Protocol (`HTTP` or `MQTT`)
* Pub/Sub Default Telemetry topic (Telemetry Topic is The default Topic for sending the device’s data to)
* You can choose for a sub Telemetry topic if you wish to divide data flow.
* Device state topic (State Topic is where the device publishes his current state)
* (Optional CA certificate) Certificates are used to verify signatures of device credentials

{{% alert info %}}
Note: you can always change the Telemetry/State topics after creation of the device registry
{{% /alert %}}


## Devices

Click on your newly created device registry and click the button `add device`.

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

[Generating RS256 Public / Private key on Windows](https://docs.joyent.com/public-cloud/getting-started/ssh-keys/generating-an-ssh-key-manually/manually-generating-your-ssh-key-in-windows)

Enter the public key into the field ‘Public key value’
Save the private key locally for later use (Device Authentication Flow)

For more information on device security: 

[https://cloud.google.com/iot/docs/concepts/device-security](https://cloud.google.com/iot/docs/concepts/device-security)

{{% alert info %}}
Note: If your physical device has a low computational power you should use the lower weight Elliptic curve algorithms.
{{% /alert %}}


## Device Authentication flow
![autenticationflow](/features/iothubs/authenticationflow.png)

The device creates a JWT based on the Private key and Project Id in order to connect to the MQTT Bridge, the device connects using the deviceId and JWT. MQTT Bridge verifies the signature and connects the device. 

## Client code for pushing data to Google Pub/Sub in Node.JS

2 options:

* MQTT
* Google Pub/Sub Client 

**MQTT implementation**

Example implementation of the MQTT client by Google can be found on:
https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/master/iot/mqtt_example/cloudiot_mqtt_example_nodejs.js

Authentication flow of this example: (see **device authentication flow**)

**Google Pub/Sub Client implementation**

Their implementation of the client can be found on:
https://github.com/googleapis/nodejs-pubsub

Normally, you device client will collect data from some sensory inputs and publish it to a topic on the Google Cloud Pub/Sub. The `device ID` you specify in the client code should be a `device ID` that you setup with your device. This will be translated to a resource in the waylay engine (later in this example).

## Example Client code in detail

This example (Based on **MQTT Implementation**) will push data from a RaspberryPi3 with a GrovePi configured Light Sensor to our **default telemetry topic**. The publishing of the data looks something like this:

```javascript
  const mqttTopic = 'default-telemetry-topic'

  const sensorValue = LightAnalogSensor.read().toString()
  const payload = JSON.stringify({
    'lightValue': sensorValue
  })

  // Publish "payload" to the MQTT topic. qos=1 means at least once delivery.
  // Cloud IoT Core also supports qos=0 for at most once delivery.
  client.publish(mqttTopic, payload, { qos: 0 }, function (err) {
    if (!err) {
      console.log(err)
    } 
    console.log('message published!')
  })
```

The MQTT client connects to the MQTT bridge which is default configured. See lines 

{{% alert info %}}
Note: For this end to end test with a static value change to payload on line `161` to a JSON object: ```{"lightValue": "500"}```. This will publish a message with a static value of 500. 
{{% /alert %}}

This example can be found on: 

https://github.com/GoogleCloudPlatform/nodejs-docs-samples/blob/master/iot/mqtt_example/cloudiot_mqtt_example_nodejs.js

To run this example: 

```
node index.js --projectId={ProjectId} --registryId={RegistryId} --deviceId={DeviceId} --privateKeyFile={PathToKeyFile} --cloudRegion={CloudRegion} -- algorithm=RS256
```


## Using Cloud Functions to send Topic data to Waylay

Now that you are pushing data from your device to your Topic we can use Cloud Functions from Google to redirect this data to the Waylay Engine.

Go to `Cloud Functions` and click `Create Function` 

![cloudfunction](/features/iothubs/cloudfunction.png)

* choose your Topic where your Device data is being pushed to
* copy the following code:

```javascript
// Require the Waylay Client
const Waylay = require('@waylay/client')

// Set the domain value
const domain = ${customerDomain}

// Generate a token to authenticate
const token = ${yourtoken}

exports.subscribe = (event, callback) => {
  // Instantiate the Waylay Client
  const waylay = new Waylay({
    domain,
    token
  })
  
  waylay.data.baseUrl = 'https://data-${customerDomain}'

  const pubsubMessage = event.data

  const attributes = event.data.attributes

  // deviceId is in the event.data.attributes
  const deviceId = attributes.deviceId

  // Convert to message type from Buffer to String
  const payload = Buffer.from(pubsubMessage.data, 'base64').toString()

  // Parse the payload
  const parsedPayload = JSON.parse(payload)

  // Post the data in a form of series to Waylay
  waylay.data.postSeries(deviceId, parsedPayload)
    .then(() => callback())
  	.catch(err => console.log(err))
};
```

Switch over to `package.json` and add the Waylay dependency

```json
{
  "dependencies": {
    "@waylay/client": "^1.0.5"
  }
}
```


For more information on the Waylay client package:

https://www.npmjs.com/package/@waylay/client


{{% alert info %}}
The Cloud Function automatically creates a subscription on your Topic which pushes all the incomming data to an endpoint of your choice.
{{% /alert %}}

## Check if the data is being pushed to Waylay

Create the Cloud Function and push new data from your Device to your Topic. Now check if the data is arriving;
Go to `https://${customerDomain}/#/resources/${deviceId}`. If all goes well you should see your data under `data` -> `all messages`

## Actuating back on a device

In order to actuate back on a device, we will use the following template

![overview](/features/iothubs/overview.png)

The stream sensor will receive data for a particular resource. Device data is pushed from a device to the Google Pub/Sub Topic, and then via the google function forwarded to the Broker.
The Sensor has in this examples 2 triggers: `Above` and `Below`, when its `Above` or `Below` a specific value it activates or deactivates a light. 

The actuator is just a simple waylay webscript call, which will pass as the argument json message that will be via the webscript pass to the device over google pub channel.
For further information on actuators, please go to this [link](api/sensors-and-actuators)

## Creating a test template
Things to provide in this template:

* replace ${yourResource} with your deviceId specified in the MQTT client code
* replace ${yourProjectId} with your Google Cloud Platform ID
* replace ${yourTopicname} with the Topic's name to push state data to (this is configured for each registry (See Device section))
* replace ${userApiKey} and ${userApiSecret} with your credentials (can be found on Waylay platform under profile)
* replace ${webscripturl} with your Webscript url created in the section below

```
curl --user {userApiKey}:{userApiSecret} -H "Content-Type:application/json" -X POST -d '{
"name" : "googleIoTExample",
 "sensors": [
   {
     "label": "streamDataSensor_1",
     "name": "streamingDataSensor",
     "version": "1.1.0",
     "resource" : "$",
     "position": [150, 150],
     "properties": {
       "parameter": "lightValue",
       "threshold": "350"
     }
   }
 ],
 "actuators": [
   {
     "label": "lightOff",
     "name": "GoogleWebscriptActuator",
     "version": "0.0.3",
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
     "name": "GoogleWebscriptActuator",
     "version": "0.0.3",
     "properties": {
       "url": "${webscripturl}",
       "json": "{ \"lightStatus\": \"on\" }",
       "projectId": "${yourprojectid}",
       "topicname": "${yourtopicname}"
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
   "type": "reactive",
   "start": true,
   "name": "Rule 1",
   "resource": "testresource"
 }
}' "https://staging.waylay.io/api/templates"
```

## Webscript for actuating back to the device

This webscript is called in the actuator of the Template. You have to create a webscript with this code and copy the link of the webscript to the actuator.

Import dependency: @google-cloud/pubsub / version:	0.16.4	
```javascript
function handleRequest (req, res) {
  // Parmameters of the actuator
  const { projectId, topicname, json } = req.body

  const PubSub = require('@google-cloud/pubsub')

  const pubsubClient = new PubSub({
    // This is your ProjectId provided in the actuator
    projectId
  })

  function publishMessage () {
    // JsonData provided in the actuator
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


## Allowing Waylay (webscript) to publish to the Topics in your GCP

![crossplatform](/features/iothubs/crossplatform.png)

This is needed for the activation of the Webscript that publishes the actuation data based on your rules back to your predefined topic. In order to achieve this you have to give our Service Account a Role of Publisher in your policy.
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

## Subscribing to your state Topic

If your device must take action upon the state being changed you can listen to this state Topic by creating a subscription for it. 

Subscribing to your state Pub/Sub Topic on your physical device
Examples can be found here:
https://github.com/googleapis/nodejs-pubsub/blob/master/samples/subscriptions.js

Each time a message from the Waylay actuator gets pushed into the Webscript, this then gets forwarded to the State Topic. You can subscribe to this Topic on your device. If for example a message with `{"lightStatus":"off"}` comes in you can act on this message and turn off a light.
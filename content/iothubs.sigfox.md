---
title: Sigfox integration
description: Learn how to connect and integrate your Sigfox devices
tags:
- sigfox
weight: 9
---

<style>
	img { border: solid 5px #f2f2f3; }
</style>

Our Sigfox integration addresses all of the challenges of an enterprise grade integration:

* [Payload transformation](features/transformers) 
* Powerful and secure [webscripts](features/webscripts)
* Data storage and visualization 
* Automatic associations with resource groups and rules
* First time provisioning
* A great User Interface

# Connecting Sigfox devices
In order to connect your sigfox device to Waylay we are going to make use of [webscripts](features/webscripts) and [transformers](features/transformers), as described in [LPWAN integration document](features/lpwan/).

{{% alert info %}}
In order to set up the Sigfox integration we first have to create a new webscript where we will forward our data to. For a comprehensive tutorial, check our documentation on [Webscripts](https://docs.waylay.io/features/webscripts/).
{{% /alert %}}

## Sigfox backend

In the Sigfox backend we have to configure each device type we want to connect, this will forward the data of all the associated devices to our platform.

Navigate to the device type you want to configure and create a new custom callback.

![Create a new callback](/features/sigfox/create_new_callback.png)

Choose **"Custom callback"** and continue.

Now it's time to configure our callback, we're going to create a `DATA` `UPLINK` callback, but `BIDIR` (bidirectional) callbacks are also supported to allow you to send a new device configuration to your sigfox device.

![Configure your callback](/features/sigfox/configuration.png)

The `Url pattern` is where we're going to input the URL of the webscript we have created [previously](/features/sigfox#connecting-sigfox-devices).

{{% alert warn %}}
You can choose whichever `HTTP Method` you like, but keep in mind that only the `POST` or `PUT` methods can send additional data to your webhook.
{{% /alert %}}

The `Content-Type` field can be either `application/json` for JSON structured data, `application/x-www-form-urlencoded` for form data or `application/octet-stream` for binary data.

To forward all of the data from your Sigfox devices we recommend the following Body to be sent with the `application/json` content type:

```json
{
  "device": "{device}",
  "data": "{data}",
  "duplicate": "{duplicate}",
  "snr": "{snr}",
  "avgSnr": "{avgSnr}",
  "rssi": "{rssi}",
  "station": "{station}",
  "latitude": "{lat}",
  "longitude": "{lng}",
  "timestamp": "{time}",
  "seqNumber": "{seqNumber}"
}
```

{{% alert warn %}}
If you've created a [private webscript](/features/webscripts/#authentication-making-the-webscript-private), an additional header must be sent to authenticate your device.
{{% /alert %}}

Click **ok** to complete the setup. 

Data will be automatically forwarded to your webscript, but not yet stored!

## Webscript

We can choose to either send our payload to a separate transformer, or handle the transformation in our webscript.

For more information on how transformers work, check our [documentation article](https://docs.waylay.io/features/transformers/).

Assuming we handle the payload in our webscript, the following code example will simply store the JSON payload from our Sigfox device in our time series database:

```javascript
function handleRequest (req, res) {
  const payload = req.body
  
  // send all of the data to our Waylay resource, using the Sigfox device ID
  waylay.data.postMessage(payload.device, payload)
    .then(response => {
      res.send(response)
    })
    // the data broker can send an HTTP error, or a network error can occur!
    .catch(({ response, message }) => {
      if (response) {
        res.status(response.status).send(response.data)
      } else {
        res.status(500).send(message)
      }
    })
}
```

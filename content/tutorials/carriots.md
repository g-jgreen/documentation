---
title:      "waylay Integration with Carriots"
date:       2015-09-08 17:19:06
---
Hi everybody, in this post we will show how to connect waylay platform to Carriots.

# Carriots

From their web site Carriots 'focus on the development of its Platform as a Service solution to build Internet of Things solutions'.
You can find more information in [Carriots About](https://www.carriots.com/about-us/about-carriots)

# Integration

This blog post will show you how you can connect a device and data of it from Carriots to waylay.

# What you need

* A waylay subscription
* A Carriots subscription

If you get the accounts we are ready.
Let’s start

# Entering Carriots Platform

First login your Carriots account you will see a page like this.

![Carriots Dashboard](https://waylayio.github.io/assets/images/carriots_dashboard.png)

In this dashboard you can find everything you want including documentation. You can reach your API keys from top menu; My Settings-->My Account

Now we need to create a device, choose ‘Devices’ from left panel and click ‘+New’ on bottom of ‘Device List’ Customize your device and click ‘Create’.

Now you have a running device.

![Carriots Device](https://waylayio.github.io/assets/images/carriots_device.png)

This is my device’s properties, now it is ready to integrate.

Now we need to create a sensor on waylay platform for this devices data stream.

*    Go your waylay account and choose ‘Your User Name’-->Profile from top menu bar.

*    In left panel you will see ‘Global settings’ add your Carriots API key with ‘Carriots_key’ name.

*    Again from top menu bar choose ‘Create’--> ’+ Sensor’ and paste to following code.

```
var token = options.globalSettings.Carriots_key;
var device  = options.requiredProperties.device;
if(token !== undefined && device !== undefined){
   var options = {
        url: 'http://api.carriots.com/devices/'+device+'/streams',
        headers: {
            "carriots.apikey" : token,
            "Content-Type":"application/json",
            "User-Agent" : device
        }
    };

    var callback = function(error, response, body) {
        if (!error && response.statusCode == 200) {
            var bodyJson = JSON.parse(body);

            var value = {
                rawData:bodyJson,
                observedState : bodyJson.total_documents > 0 ? "Found" : "Not Found"
            };
            console.log(bodyJson);
            send(null,value);
        }else{
            send(new Error("Calling api.carriots.io failed"));
        }
    }    
request.get(options, callback);
}else{
    send(new Error("Missing properties"));
}
```

You can reach this sensor's source on [github](https://github.com/waylayio/Sensors/blob/master/carriotsGetDataStream)

This code created according to Data Stream API of Carriots you can reach to documentation from [Carriots Data Management](https://www.carriots.com/documentation/api/data_management)


If you are done with code now you have to change properties on right panel like in bottom picture.

![Carriots Device](https://waylayio.github.io/assets/images/carriots_options.png)

When you are done click ‘Upload’ on top and open Designer.

Now we are ready to test.

![Carriots Device](https://waylayio.github.io/assets/images/carriots_sensor.png)

Drag&Drop Carriots sensor from Sensors list and connect to mail actuator from Actuators list.

Then enter properties of sensor.

![Carriots Device](https://waylayio.github.io/assets/images/carriots_properties.png)

On Carriots sensor property you should enter ‘Id developer’ from devices properties which you can see above pictures. You can find it by clicking ‘show’ on device.

![Carriots Device](https://waylayio.github.io/assets/images/carriots_deviceID.png)

After entering your 'Id developer' to sensor properties you can reach your device's data stream via mail over waylay.

---
title:      "Control your devices with waylay and Cumulocity"
date:       2015-09-08 17:19:06
author:     Suat Karabacak 
---
In this post we will focus on connecting devices to Cumulocity and forwarding the data to Waylay.

# Cumulocity

[Cumulocity](http://cumulocity.com) is a cloud based development platform. This is what their website mentions:

> Cumulocity lets you build your Internet of Things applications instantly. Design new services and new models for your business!

# What you need

* A waylay subscription
* A Cumulocity subscription
* An abstract or real device to connect to the Cumulocity platform.

# Logging in to the Cumulocity Platform

Now open your browser and go to the Cumulocity administration tool.

`https://yourUserName.cumulocity.com/apps/administration/index.html#/`

Replace `yourUserName` with the username that you used when creating Cumulocity account.

You should end up at the Cumulocity dashboard

![Cumulocity Dashboard](/tutorials/cumulocity/cumulocity_dashboard.png)

Now we have to create a device.

If you have one of these devices on the [Certificated Devices list](https://www.cumulocity.com/dev-center/) you can add it.

![Cumulocity Dashboard](/tutorials/cumulocity/cumulocity_dashboard2.png)

Choose Devicemanagament from list on the top right.

# Configuring your device

![Cumulocity Dashboard](/tutorials/cumulocity/cumulocity_device.png)
On the Devicemanagament page choose ‘All devices’ there will be a device named ‘A Demo Device’ click that and customize device according to your pleasure and click ‘Save the changes’ at bottom.

Now we have a device and we will use waylay to get signal measurements of this devices.
For details check the [Cumulocity Measurement API documentation page](http://www.cumulocity.com/guides/reference/measurements/).

Now go to your Waylay account and click 'Your User Name' --> Profile on top menu.

![Waylay Dashboard](/tutorials/cumulocity/cumulocity_waylay.png)

Choose ‘Global settings’ on left panel.

And add a property named `Cumulocity_Key` with your Cumulocity key.

Now choose ‘Create’ --> ‘+ Sensor’ from top menu.

Replace all code with bottom one, don't forget to change `yourUserName` part on API link with your own.

```
var token = options.globalSettings.Cumulocity_Key;
var dateTo = options.requiredProperties.dateTo || moment().toISOString();
var yesterday = new Date();
yesterday.setDate(yesterday.getDate() - 1);
var dateFrom = options.requiredProperties.dateFrom || moment(yesterday).toISOString();
var source = options.requiredProperties.source;

if(token !== undefined && source !== undefined)
{

     var options = {
        url: 'http://yourUserName.cumulocity.com/measurement/measurements/series?dateTo='+dateTo+'&source='+source+'&dateFrom='+dateFrom,

        headers: {
            Authorization: "Basic "+ token,
            Accept: "application/json"
        }
    };

    var callback = function(error, response, body) {
        if (!error && response.statusCode == 200) {
            var bodyJson = JSON.parse(body);

            var value = {
                rawData:bodyJson,
                observedState : Object.keys(bodyJson["values"]).length > 0 ? "Found" : "Not Found"
            };

            send(null,value);
        }else{
            send(new Error("Calling api.cumulocity failed"));
        }
    }

    request.get(options, callback);
}else{
    send(new Error("Missing token or source"));
}
```

You can find this sensor's code on Github too. [Cumulocity Sensor](/tutorials/images/cumulocityGetMeasurements)

Change ‘States’ , ‘Properties’ and ‘Raw data’ according to the below picture.

![Cumulocity Dashboard](/tutorials/cumulocity/cumulocity_options.png)

If you did both of steps click ‘Save’ on the top and go to the designer from main waylay menu.

Now select sensor that you create and drop it on designer and add an actuator.

I choose the mail actuator. You should end up with something like this.

![Cumulocity Dashboard](/tutorials/cumulocity/cumulocity_sensor.png)

Now we have to modify the mail actuator properties.

![Cumulocity Dashboard](/tutorials/cumulocity/cumulocity_properties.png)

Cumulocity uses the [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) time/date format.

Let’s enter properties.

* dateTo: 2015-09-08T01:55:28Z
* dateFrom : 2014-09-08T01:55:28Z
* source: 10200

The source parameter is ID of device which you can find on the Cumulocity device page.

![Cumulocity Dashboard](/tutorials/cumulocity/cumulocity_deviceID.png)

After entering the mail properties and starting the task you should be receiving your device’s signal measurements by mail.

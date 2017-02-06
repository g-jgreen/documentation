---
title:      How to create a simple application using waylay API
author:     Veselin Pizurica
date:       2015-12-12 10:19:06
---

With waylay you can create very complex rules using simple [template] [rest]. 
In order to create a rule and initiate a task, you need to do define:

* sensors and actuators, 
* conditions under which actuators need to be executed
* relations between sensors and gates
* task definition (periodic, onetime, cron, reactive).

For more info, please check the documentation.

We have created a small boostrap/jquery app that shows how you can create an application on top of waylay. 
The application is available in [github] [repo]. In this application, the end user selects the airco machine (as an asset ID), the condition under which the e-mail should be sent, whether the e-mail should be sent during the week AND/OR weekends and it also shows how to template a message in the body of the e-mail with the exact conditions and measurements under which the incident is reported.

![UI application](http://waylayio.github.io/assets/images/application.png)

This application creates a template object that is send using a REST call towards the waylay platform. Here is the template object:

```
{
    "sensors": [{
        "label": "data",
        "name": "streamingDataSensor",
        "version": "1.0.9",
        "resource": "$",
        "position": [245, 205],
        "properties": {
            "parameter": "compressor hours",
            "threshold": "10000"
        }
    }, {
        "label": "isWeekend",
        "name": "isWeekend",
        "version": "1.0.3",
        "resource": "airco_SN32591230",
        "position": [245, 405],
        "properties": {
            "timeZone": "Europe/Brussels"
        }
    }],
    "actuators": [{
        "label": "Mail",
        "name": "templateMail",
        "version": "0.0.2",
        "position": [492, 156],
        "properties": {
            "from": "support@waylay.io",
            "to": "test@waylay.io",
            "subject": "Alert for {{RESOURCE}}",
            "message": "e-mail text"
        }
    }],
    "relations": [{
        "label": "Gate",
        "type": "GENERAL",
        "position": [481, 313],
        "parentLabels": ["isWeekend", "data"],
        "combinations": [
            ["FALSE", "Above"]
        ]
    }],
    "triggers": [{
        "destinationLabel": "Mail",
        "invocationPolicy": 1,
        "sourceLabel": "Gate",
        "statesTrigger": ["TRUE"]
    }],
    "task": {
        "name": "Create alarm task for machine airco_SN32591230",
        "type": "reactive",
        "resource": "airco_SN32591230",
        "start": true
    }
}
```

Before you use this application, you will need a waylay account and you will need to login to this application using your API keys.
We also added three more features that are similar to our [labs website] [labs]:

* allow you to push runtime data
* allow you to simulate data from the csv file
* show you how to use our cloud cache in combination with freeboard

In order to simulate an incident, you can simply push the data that is above the configured threshold. 

You can also access the live application here: [demo] [demo]

Note: _In case that the rule is the same for all machines, the demo application would look the same but you could just invoke the task using the template name, rather than creating a rule on the fly as decribed above._


[repo]: https://github.com/waylayio/demo-hvac
[rest]: http://docs.waylay.io/Waylay-REST-API-documentation.html#Createthetask
[labs]: http://labs.waylay.io/
[freeboard]: https://freeboard.io/
[demo]: http://demo-customers.waylay.io/


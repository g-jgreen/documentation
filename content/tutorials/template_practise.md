---
title:      "How to creata a template - best practices"
author:      Veselin Pizurica
date:       2015-11-01 10:19:06
---

With our visual designer tool you can debug and create new [templates] [doc]. Using waylay application portal, or via REST [calls] [rest] you instantiate these templates as _tasks_. For instance, if you create a template that gathers smart meter data and sends mail with consumption every Friday, you will instantiate this template for every newly provisioned meter. In this post I will show you the easiest way to create a template that will allow you to instantiate a task with resource name as the only input argument. In order to achieve that, I will create a sensor that as the input argument can take a resource name:

```
var meterNumber = options.requiredProperties.meterNumber || waylayUtil.getResource(options)
```

In this example, the sensor that will fetch the data from the external system needs only one input argument _meterNumber_. The rest of the code is omitted, since this can be either a REST call, db query etc..  The input argument can be either defined on the sensor level (via properties as _options.requiredProperties.meterNumber_), or like in this case, via the resource [concept] [resource]. When you associate the sensor with a resource name, you need specify a resource on the node level as: 

* fixed resource name (e.g. house1, deviceX, meter123...)
* $ (resource name will be inherited from the task resource name)
* $taskId (resource name will be inherited from the task ID)

_getResource_ call will automatically translate $, $taskId at runtime to the proper resource name. Waylay engine will make sure that correct translation happens. There is another use case where you can use resource concept (stream data), but more about that in the future posts.

Once you have created a template you can start a task using a REST [call] [rest]. In this example, we call the template _dailyConsumption_ with resource defined as an integer. That integer will be used as the resource input to fetch the meter data. Once the task is started, this resource name (in this case a number) will be propagated to the correct sensor. 

```
for i in {1..100000}
do
   echo "start task for meter $i"
   curl --user KEY:PWD -H "Content-Type:application/json" -X POST -d '{
   "name": "consumption for meter '$i'\n",
   "template": "dailyConsumption",
   "resource": "'$i'",
   "start": true,
   "resetObservations": true,
   "type": "periodic",
   "frequency": 86400000
 }' https://app.waylay.io/api/tasks
done
```

There is another way to do the same, not using the resource concept, but as you will see below, it is a little bit more complicated. If we look back into this code:
```
var meterNumber = options.requiredProperties.meterNumber || waylayUtil.getResource(options)
```

we can see that the sensor can also receive the input arguments via the property _options.requiredProperties.meterNumber_. So, the other option to start the same task was to use the REST call that sets this property on the sensor level:
```
curl --user <KEY>:<SECRET> -H "Content-Type:application/json" -X POST -d 
   '{
     "name": "test", 
     "template": "dailyConsumption", 
     "resource": "meter 1", 
     "start": true, 
     "type": "periodic", 
     "frequency": 86400000, 
     "nodes": [ {"name": "meterSensorNode", 
               "properties": {
               "sensor": {
                 "name": "meterSensor", 
                 "version": "1.0.1", 
                 "label": "meterSensor_1", 
                 "requiredProperties": [ {"meterNumber": "1"} ] 
                 } 
               } 
            } ] 
   }' https://app.waylay.io/api/tasks
```
[doc]: /usage/tasks-and-templates/ 
[rest]:  /api/rest 
[resource]: /api/sensors-and-actuators/#retrieve-resource-name 


---
title: Using gates as the control flow
description: Learn how to use gates to control the formula computation
weight: 9
---

This example will build on top of [the previous example](/rule_patterns/sequence/), which explores the use of eviciton policy. Both streamDataSensors are configured with eviction time of 5 seconds. Compared to previous example, we have added a Gate, that will be true only if both sensors are in Above state. 
We also use the Function node, which allows us to make computation based on the raw data collected by other sensors. In order to make sure that Function node has data required for computation (in this case call `AvgTemp`), we also used [conditional execution of the sensors feature](rule_patterns/flow_contrl/).
This way, we make sure that we will compute average temperature of two different sensors only if data of sensors come within 5 seconds:


![image](/rules/mix_streams2/mix.png)

{{% alert info %}}
More about Function node you can find [here](/api/sensors-and-actuators/#function-node)
{{% /alert %}}

We will start a task using this template (e.g. saved as "mix_streams_formula") in the reactive mode like this:
```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Stream processing with formula",
    "template": "mix_streams_formula",
    "type": "reactive"
  }' https://sandbox.waylay.io/api/tasks
 ```

Let's pushed data for both resources via [broker](/api/broker-and-storage/):

```
curl --user apiKey:apiSecret 
 -H "Content-Type: application/json"
 -X POST  
 -d '[{ 
      "temperature": 33, 
      "resource": "test1", 
      "domain": "sandbox.waylay.io"
   },{ 
      "temperature": 20, 
      "resource": "test2", 
      "domain": "sandbox.waylay.io"
   }'
  "https://data.waylay.io/messages?store=false"
```

{{% alert info %}}
Formula sensor was configured this way `(<streamingDataSensor_1.parameter> + <streamingDataSensor_2.parameter>)/2`
{{% /alert %}}

Let's see what happens, we have received the average temperature. Great!
![image](/rules/mix_streams/both.png)
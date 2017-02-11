---
title: CEP raw data processing
description: Learn how to use formula computation on raw data
weight: 9
---

This example will build on top of [the previous example](/patterns/sequence/), where we used `Dice` sensor. Here is the sensor script that we will use in the example, which returns one of 6 states, depending on the random number:

```
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
    rawData : {  randomValue: randomValue}  
}; 
send(null,value);
```

{{% alert info %}}
Every sensor must return `state`, `rawData` or both. 
More about Sensors you can find [here](/api/sensors-and-actuators/#how-to-create-a-sensor)
{{% /alert %}}


One thing we should always keep in mind that every sensor runs independently. If the sensor is in the `polling mode` (executes on tick) its execution can still be conrolled by [the state trigger](/patterns/flow-control/) or [sequence](/patterns/sequence/) number. In case that the sensor executes on data (streaming), script will execute every time a new data stream arrives. 

Most of the time, we assume that the rule is some sort of the `state machine`. We can use the sensor `state` to control the execution between different sensors, we can also use different sensors and states to wire the logic (using gates) and we can also attach actuators to the sensor states. Nevertheles, in this example, we will learn how to use **rawData** which can also be 'produced' by the sensors. This is the extract from the script above:
```
value = {  
    observedState:  state, 
    rawData : {  randomValue: randomValue}  
}; 
send(null,value);
```
In order to access the node rawData, `CEP Function node` uses this format:
`(<dice_1.randomValue>` . That way you can build formulas like this:
`<node1.rawdat1> OPER <node2.rawdat2>` etc..  Function node has about 40-50 built-in functions.

{{% alert info %}}
More about Function node you can find [here](/api/sensors-and-actuators/#function-node)
{{% /alert %}}

Our Formula nodes are defined like this:

* `<avg(diceSensor_1.randomValue)>`
* `<min(diceSensor_1.randomValue)>`
* `<max(diceSensor_1.randomValue)>`
* `<avg(3, samples, diceSensor_1.randomValue)>`
* `<avg(5, samples, diceSensor_1.randomValue)>`
* `<Max.formulaValue> - <Min.formulaValue>`
* `<Avg3Samples.formulaValue> - <Avg5Samples.formulaValue>`

Where the last two Formula nodes (sequence 3) calculate on top of other formula nodes (`formulaValue` is the rawData of the Formula node itself - result of the formula computation). Formula node is just like any other sensor, it prodices 3 states (`Below`, `Equal`, `Above`) and rawData. Input arguments for the Formula node are `formula definition` and the `threshold`, which is used for the state evaluation. 

So, let's create the template:

![image](/rules/formula/dice_formula1.png)

{{% alert info %}}
Note how we used the sequence numbers to make sure that rawData was available to Formula nodes. Since the last two nodes used values from other Formula nodes, their sequence number was the highest.
{{% /alert %}}

{{% alert info %}}
In [the next example](patterns/gates-flow/) we will learn how to compute the Formula node in case we want to be absolutely sure that previous nodes have succeeded before executing formula computation.
{{% /alert %}}

So, let's roll the dice and see what happens!
## Debug mode, raw data:
![image](/rules/formula/dice_formula2.png)
{{% alert info %}}
RawData view, we see Formula nodes doing calcaluation on the random value.
{{% /alert %}}

## Debug mode, states view:
![image](/rules/formula/dice_formula3.png)
---
title: Counting the number of alarms within a time window or number of samples
description: Learn how to use the count feature
weight: 15
tags: [ "Development", "Rules"]
categories: [ "Development" ]
series: [ "Common Patterns" ]
---

In this example we will learn how to use the [**count** function](/api/sensors-and-actuators/#aggregation-types) of the `Formula` node. In this example, the formula is defined as `<count(HEADS, 5, minutes, coin_1.state)>` with the `threshold` 10. That means that we will count the number of times the coin flipped to HEADS in the sliding window of 5 minutes. We shall toss the coin every 1 second. 


![image](/rules/count/count_states.png)

{{% alert info %}}
Please note that we use [state transition](/patterns/flow-control/) * -> * to execute Function node. In this example we could as well define it as * -> HEADS - that would not make any difference (actually it would just execute the Function node less often). The example is done this way just to demonstrate that the result of the function computation stays the same even if the coin flips to TAILS. 
{{% /alert %}}

This is the coin sensor used for this example. It will turn HEADS if the random value is above .5.

```json
var randomValue = Math.random(); 
var state;
if(randomValue >= 0.5)
  state = "HEADS";
else
  state = "TAILS";

value = {  
    observedState:  state, 
    rawData : {  randomValue: randomValue}  
}; 
send(null,value);
```
Let's start the task from the template `count` in the periodic mode like this:

```
 curl --user apiKey:apiSecret -H "Content-Type:application/json" -X POST -d '{
    "name": "Count test1",
    "template": "count",
    "type": "periodic",
    "frequency": 1000,
  }' https://sandbox.waylay.io/api/tasks
 ```

Here is the state view. We can observe that Formula node, calles `CountHeads` at one moment counted 10 times that the coin flipped to HEADS.
![image](/rules/count/formula_states.png)

If we look at the formula value we can also see the moment when the count crossed 10. We can also observed that the count was going up only when the random value, used to decided whether the coin is HEAD or TAILS was greater than 0.5.
![image](/rules/count/formula_value.png)

{{% alert info %}}
Note that the count was always going up only beacause we stopped this test earlier than 10 minutes. Otherwise, the count would approximately be around 300 (60seconds * .5 chance * 10minutes)
{{% /alert %}}

Let's now test the "randomness". We shall keep the polling period to 1 second, but the formula will now be `<count(HEADS, 20, samples, coin_1.state)>` and put the threshold again to 10. This time, the count goes over number of samples, not the time window. After about 20 samples, the `Function` node should randomly toggle between Below and Above. Let's have a look:

![image](/rules/count/samples_state.png)

Amazing! We see that the Formula node at the beging was in state Below, and then at one moment, it starts randomly toggling between Above, Equal and Below state.

Let's see what the formula computation was doing. Indeed, we see that the count at one moment reached 10, and after that, it was fluctuating around 10. Fun!

![image](/rules/count/samples_value.png)




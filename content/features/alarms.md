---
title: Alarms
description: Learn how to integrate alarms
tags:
- alarms
weight: 5
---

![alarms](/features/alarms/alarm_tile.png)

# Introduction
IoT applications often make use of notifications via e.g. SMS or email but in some cases a native alarm functionality is required. Waylay supports such a native alarm service, which is exposed over the [REST](api/rest/#alarms) and which has a user interface that is exposed in the Waylay administration console. The alarm functionality integrates with the rules einge, in the sense that Waylay supports actuators that allow you to create or clear alarms in an automated way based on the outcome of rules. 

{{% alert info %}}
Alarm actuators are written on top of the Alarm Service REST interfaces. Waylay supports two alarm actuators off-the-shelf: an actuator that creates alarms and an actuator that receives alarms. These actuators can be extended with your custom implementation. 
{{% /alert %}}

## How this feature can be used in practise?
Alarms allow you to track incident persistency over time. The Waylay Alarm Service gives you the status and the count of the alarms, but also provides interfaces that allow you to acknowledge alarms, change the severity level or simply close the alarm. Since the alarm service is REST exposed, it is possible to integrate the alarm information within your own application. 

# Example of using the Alarms Service

The best way to describe this feature is using one simple rule. We will create alarms as soon as a dice sensor turns odd states (`ONE`, `THREE`, `FIVE`), and clear all alarms of a given type (in this case type `DICE`), when `dice` gives back even states.

![alarm](/features/alarms/alarms_rule.png)

In case the alarm actuator is triggered and the alarm has previously been created but was not yet cleared, the count of the opened alarm will be increased by the Alarm Service. 
After running the task for couple of minutes, this is what we can see:

![alarms](/features/alarms/alarms_table.png)

if we look at one alarm that has count bigger than 1, we can see the following:

![alarms](/features/alarms/alarm_detail.png)






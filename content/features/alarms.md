---
title: Alarms
description: Learn how to integrate alarms
tags:
- alarms
weight: 5
---

![alarms](/features/alarms/alarm_tile.png)

# Introduction
There is often a need to integrate waylay rule engine with alarm applications. With the latest upgrade of waylay, we can now use waylay alarm service, which is exposed over the [REST](api/rest/#alarms). We also added actuators in waylay, which allows our users to use alarms directly via the rule engine.

{{% alert info %}}
Alarm actuators and written based on our REST interfaces. They can be extended with your custom implementation. For instance, we created an alarm actuator that clears all open alarms for a given resource/type combination.
{{% /alert %}}

# Example of using Alarms Service

The best way to describe this feature is using one simple rule. We will create alarms as soon as a dice sensor turns odd states (`ONE`, `THREE`, `FIVE`), and clear all alarms of a given type (in this case type `DICE`), when `dice` gives back even states.

![alarm](/features/alarms/alarms_rule.png)

In case that the alarm is created and not yet cleared, only the count of the opened alarm will be increased. This is a feature of Alarms service, nothing to do with this actuator in particular.
After running the task for couple of minutes, this is what we can see:

![alarms](/features/alarms/alarms_table.png)

if we look at one alarm that has count bigger than 1, we can see the following:

![alarms](/features/alarms/alarm_detail.png)




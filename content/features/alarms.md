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
Alarm actuators are written on top of Alarm Service REST interfaces. They can be extended with your custom implementation. For instance, we created an alarm actuator that clears all open alarms for a given resource/type combination.
{{% /alert %}}

## How this feature can be used in practise?
Dealing with the same resource in multiple tasks is not that trivial. Also, in case you need incident persistency, which spans over the lifecycle of the single task, this feature will for sure make your life simpler. Alarm Service also deals not just with the status and the count of the alarms, but also provides interfaces that allow you to acknowledge alarms, change their severity or simply close them. You can also integrate Alarm Service in your own applications, over REST interface, like you would do using JIRA or zendesk.

# Example of using Alarms Service

The best way to describe this feature is using one simple rule. We will create alarms as soon as a dice sensor turns odd states (`ONE`, `THREE`, `FIVE`), and clear all alarms of a given type (in this case type `DICE`), when `dice` gives back even states.

![alarm](/features/alarms/alarms_rule.png)

In case that the alarm is created and not yet cleared, only the count of the opened alarm will be increased. This is a feature of Alarms service, nothing to do with this actuator in particular.
After running the task for couple of minutes, this is what we can see:

![alarms](/features/alarms/alarms_table.png)

if we look at one alarm that has count bigger than 1, we can see the following:

![alarms](/features/alarms/alarm_detail.png)






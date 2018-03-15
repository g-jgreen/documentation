---
title: AWS IoT Core
description: Connecting IoT Core with Waylay
weight: 1
---

# Connecting AWS IoT Core to Waylay

## Prerequisites

* Access to AWS IoT Core and Lambda
* Account on AWS with the neccesary permissions for nr. 1
* IoT connected device
* Access to the Waylay platform

The main building blocks of this integration are presented below:
![architecture](/features/iothubs/architecture.png)

## Configuring AWS IoT Core

## Device registry

For a new device, you need to create a new thing under `Manage` on the IoT Core page.

1. * If you don't have a thing yet, choose `Register a thing`.
   * If you have a thing, choose `Create`.

![no-things-yet](/features/iothubs/no-things-yet.png)


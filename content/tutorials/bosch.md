---
layout:     post
title:      "Bosch XDK support available with mqtt"
date:       2016-10-18T15:05:00.000Z
author:     Lorenzo Van De Sijpe
---

[![IMAGE ALT TEXT](https://i.ytimg.com/vi/FAlyjBO0-7g/maxresdefault.jpg)](https://www.youtube.com/watch?v=FAlyjBO0-7g "Bosch XDK")

It's now possible to connect the Bosch xdk to the Waylay broker through the mqtt protocol.

In this tutorial we will show you how to setup the environment and the device.

##  Environment setup

Go to Bosch XDK homepage and download the workbench (1.7.0 or up)

The firmware uses eclipse paho mqtt c (1.1.0) and cJSON, both are already included in this repo.

## Project import
In the XDK workbench go to file -> import -> existing project 

![Import step1](https://waylayio.github.io/assets/images/bosch_xdk/importStep1.png)

-> select folder where you extracted the firmware zip or cloned the github project.

![Import step1](https://waylayio.github.io/assets/images/bosch_xdk/importStep2.PNG)

Right click the project and press build, normally this should run without problems. If you encounter 'path not found' or something similar you need to right click the project and rebuild the index (index -> rebuild).

##  Change connection settings

To get the connection parameters for the device you need to go to https://app.waylay.io/#/devicegateway, add a device and pass the parameters into the config file, explained in the next step.

![Device info](https://waylayio.github.io/assets/images/bosch_xdk/deviceInfo.png)

In the "source/mqttConfig.h" file you can change all the settings to connect to the wifi, stream rate and what data you want to send to the broker.

![Config settings](https://waylayio.github.io/assets/images/bosch_xdk/configSettings.png)

## Flash firmware onto device
Before you can flash the firmware on the device you need to put it in bootloader mode. You can do this in one of two ways.

1.  In the workbench on the upper left side (where your device is displayed) you can right click 'goto bootloader'.
2. Turn off device and press button 1 while turning on, if the orange led turns on, let the button go. (this method should be performed only if the first one doesn't work)

Confirm that the device is in bootloader mode. You can do this in one of two ways:

1. In the workbench on the upper left side (where your device is displayed) you can see 'Mode:bootloader'.
2. On the device the red and orange light is on.

![Config settings] (https://waylayio.github.io/assets/images/bosch_xdk/bootloader.jpg)

Press the flash button on the upper left side. After flashing the device should boot and after a couple seconds the orange and yellow led should be on.

![Config settings](https://waylayio.github.io/assets/images/bosch_xdk/running.jpg)

## ## Led and buttons meaning

These leds have different meanings in bootloader and running state.

All the meanings below apply for the running state except for the green led, this applies for both states.

1. Green: charging
2. Yellow: timer active, sending data every 5 minutes (Button 1 turns this on or off.)
3. Orange: active wifi connection
4. Red: should only blink when force send data (Button 2 force sends data to the server)

## Output json

This is the json you have to send to the device over mqtt to make it do some actions.
```
    {
      "Device": "XDK110",
      "Name": "dce1a5ab-a464-4bfa-b9c4-cafd7e125f51",
      "Timestamp": "2663",
      "accelerator_x_mg": -158,
      "accelerator_y_mg": 349,
      "accelerator_z_mg": 760,
      "gyroscope_x_mdeg": -366,
      "gyroscope_y_mdeg": 30761,
      "gyroscope_z_mdeg": -25512,
      "magnetometer_x_uT": 79,
      "magnetometer_y_uT": 39,
      "magnetometer_z_uT": 5,
      "light_mLux": 112320,
      "temperature_mCel": 28170,
      "pressure_pascal": 102122,
      "humidity_percentageRh": 40,
      "timestamp": 1476695653306
    }
```
## Input json

This is the json you have to send to the device over mqtt to make it do some actions.
```
    {
      "forceDataSend": 0,
      "redLed":0,
      "reboot":0
    }
```
This json uses booleans to activate the function.

1. forceDataSend = same as button 2 press, force send the data before the timing interval.
2. redLed = turn on red led.
3. reboot = remoteReboot the device


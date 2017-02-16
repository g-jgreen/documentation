---
title: Sigfox integration
description: Learn how to connect and integrate your Sigfox devices
tags:
- sigfox
weight: 8
---

Waylay's native Sigfox integration allows you to add many Sigfox enabled devices to automatically forward data to the Waylay platform.

# Prerequisites

To connect your devices you must first generate API access keys for the Sigfox group you want to connect.

To generate API credentials you must navigate to **Group** > **Group Name** > **API Access**. If you do not yet have any API credentials, click **new** to generate a new key pair.

{{% alert info %}}
These API credentials are only valid for the group that you have selected. Data can only be collected for devices and device types that belong to this group.
{{% /alert %}}

Sigfox will have generated a **login** and a **password**, these are your **API key** and **API Secret** respectively.

# Authentication

To authenticate with Waylay you will need to enable the Sigfox channel. When you do so, you will be prompted to enter your API access keys.

![Login with Sigfox form](usage/sigfox/login.png)

Once connected you will be taken to the Sigfox configuration screen.

# Configuration

Waylay will automatically discover your device types, and allow you to configure each device type individually.

Simply enter your Sigfox payload configuration and click **save**, data will instantly and automatically be forwarded.
Additionally, Waylay will automatically create Waylay Resource Types for each Sigfox device type.

![Sigfox configuration form](usage/sigfox/configuration.png)

{{% alert info %}}
If you are unsure about your payload configuration, get in touch with your hardware vendor.
{{% /alert %}}

# Visualisation

To visualize your devices we recommend using our [Waylay Grafana application](usage/grafana).

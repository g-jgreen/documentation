---
title: Sigfox integration
description: Learn how to connect and integrate your Sigfox devices
tags:
- sigfox
weight: 8
---

Waylay's native Sigfox integration allows you to add many Sigfox enabled devices to automatically forward and store data to the Waylay platform. 

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


[Transformers](/features/transformers) can also be attached to Sigfox Channel. In that case, transformers are attached to webhooks and are executed as part of the webhook processing. Even though default Sigfox Channel provides "native" Sigfox payload decoding (as a part of the Channel definition), we have seen the cases in which sigfox devices could not be decoded this way, or would need additional post-processing (e.g. metric values need to be divided or multiplied by a value).

{{% alert info %}}
Great thing is that we can use both native sigfox payload decoding (via Channels) and transformers at the same time.
{{% /alert %}}

In this example, we mix both sigfox payload decoding and transformers:

![transformers-sigfox](/features/transformers/sigfox-transformers.png)

# Sigfox provisioning
Provisioning involves the process of preparing and equipping a network and a device to allow it to provide (new) services to its users.

For first time provisioning, we use a great feature of waylay - automatic task creation for new resources, based on the resource type. That simply means that every time new resource is discovered, which is associated with a particular resource type, all tasks for that resource are automaticaly created. More about it you can find here: [Provisioning feature](/features/provisioning/)

This is the example of the provisioning template:

![template](/features/provisioning/template.png)

# Visualisation

To visualize your devices we recommend using our [Waylay Grafana application](usage/grafana).

![Map drill down](usage/grafana/details.png)

---
title: Grafana Plugin
description: Visualize your the data from your assets
weight: 6
---

# Prerequisites

Waylay offers a hosted service that includes the Grafana dashboard and the Waylay plugin.

We assume you already have a Waylay account or installation ready to connect to, and have also requested a hosted version of the dashboard.

# Installation

The Waylay plugin will be pre-installed on our hosted offering of the Grafana dashboard, no installation is required.

{{% alert info %}}
Don't have a Grafana dashboard yet? Request one by [contacting us](support@waylay.io).
{{% /alert %}}

# Configuration

The first thing you have to do is to enable the Waylay [application](http://docs.grafana.org/plugins/apps/#enabling-app-plugins). Once enabled, you can add a Waylay data source and configure it.

To configure your data source you will need your:

* Waylay **domain name**
* Waylay **API key**
* Waylay **API secret**

These credentials can be found on the profile page of your Waylay dashboard.

Use the screenshot below as a reference for setting up your Waylay data source:

![Edit Data Source](usage/grafana/datasource.png)

You can optionally add a customer ID to filter all resources in the dashboard to exclude resource that are not owned by that particular customer.

# Usage

You can use the Waylay data source you have just configured to visualize your data, please refer to the official [Grafana documentation](http://docs.grafana.org/) on [getting started](http://docs.grafana.org/guides/getting_started/) or read up on some of the Grafana [basic concepts](http://docs.grafana.org/guides/basic_concepts/).

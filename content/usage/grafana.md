---
title: Grafana Plugin
description: Visualize your the data from your assets
weight: 6
---

# Prerequisites

To use the Waylay Grafana application you must already have [Grafana](https://grafana.org/) installed and configured. If you're unsure about how to do this, please check out the [Grafana installation documentation](http://docs.grafana.org/installation/).

The minimum supported version is 3.2.0, but we recommend installing the latest version.

We also assume you already have a Waylay account or installation ready to connect to.

# Installation

Installing the Waylay plugin is easy. Simply [download the plugin](https://github.com/waylayio/grafana-plugin/releases/latest) from Github and install it in your Grafana plugin folder (`/var/lib/grafana/plugins` by default).

{{% alert info %}}
If you are unsure on how to install the plugin, please refer to the [official documentation](http://docs.grafana.org/plugins/installation/).
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

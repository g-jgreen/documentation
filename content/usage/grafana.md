---
title: Grafana Plugin
description: Visualize your the data from your assets
weight: 7
---

# Prerequisites

Waylay offers a hosted service that includes the Grafana dashboard and the Waylay plugin.

We assume you already have a Waylay account or installation ready to connect to, and have also requested a hosted version of the dashboard.

# Installation

The Waylay plugin will be pre-installed on our hosted offering of the Grafana dashboard, no installation is required.

{{% alert info %}}
Don't have a Grafana dashboard yet? Request one by [contacting us](mailto:support@waylay.io).
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

# GeoMap

The GeoMap plugin is a custom map plugin developed by Waylay. To use this map simply add the plugin to a panel and add a resource through the 'edit' menu of the panel. The resource you add has to have longitude and latitude. Resources with the exact same latitude and longitude will be put on the same marker, just click the marker to view all the resources on that location.

Links to Grafana template dashboards can be added to the markers. To add this just go to the General tab and add a 'Drilldown' link to the template dashboard. Make sure to check 'include time rnge' & 'include variables'. __**After this you need to go back to the metrics tab so we can add this link to the marker**__.

![Add Link](usage/grafana/drilldownLink.png)

Markers can be configured to have one of four colors and can contain any icon from [ionicons](http://ionicons.com/). Just click an icon and paste the name into the text box. You can also enable/disable the auto zoom and set the zoom level for the auto zoom. How higher the auto zoom (max 1) the bigger the map.

![Map Options](usage/grafana/mapoptions.png)

If changes to the map don't apply immediatly just press the refresh button on the top right corner so the widget can refresh.


Here is the example of the dashboard that uses geo map:
![Map ](usage/grafana/geo_map.png)

From the marker which is places on the map, you can also drill down to per device dashboards. 
![Map drill down](usage/grafana/details.png)


{{% alert info %}}
In case that more than one device are placed on the same location, the marker lists all devices.
{{% /alert %}}



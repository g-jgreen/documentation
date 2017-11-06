---
title: Grafana Plugin
description: Visualize your the data from your assets
weight: 8
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

![Edit Data Source](features/grafana/datasource.png)

You can optionally add a customer ID to filter all resources in the dashboard to exclude resource that are not owned by that particular customer.

# Usage

You can use the Waylay data source you have just configured to visualize your data, please refer to the official [Grafana documentation](http://docs.grafana.org/) on [getting started](http://docs.grafana.org/guides/getting_started/) or read up on some of the Grafana [basic concepts](http://docs.grafana.org/guides/basic_concepts/).

# GeoMap

The GeoMap plugin is a custom map plugin developed by Waylay.

Links to detail tracking dashboards can be added to the markers that will be shown on the map. To add this just go to the General tab and add a 'Drilldown' link to the template (detailed) dashboard.

![Add Link](features/grafana/general.png)

{{% alert info %}}
More about adding detailed tracking dashboards later.
{{% /alert %}}


In order to link resources to the map, you need to go to the `Metrics` setting:
![Metrics](features/grafana/metrics.png)

Here you define in the first `FILTER` resourceTypeId, which will be used as the filtering criteria for resources you want to show on the map. These resources __must have longitude and latitude__ measurements.
In the second row, where you use `FILTER` resourceTypeId, you will define the geofences that will be plotted on the same map. These resources __must have defined geofences__ in the metadata.

{{% alert info %}}
More about adding geofences in the metadata later.
{{% /alert %}}

In this example, we ignore the time series data, __which means that we are plotting only data which is defined in the metadata!__ That also means, that every time a new data point with location is send to waylay, we would need to update resource metadata with it's location. This is typically done by geofence template, explained later. That way, we only show the latest data point per resource.


Next thing to setup are `Options`:
![Map Options](features/grafana/options.png)

Markers can be configured to have one of four colors and can contain any icon from [ionicons](http://ionicons.com/). You can also enable/disable the auto zoom and set the zoom level for the auto zoom. How higher the auto zoom (max 1) the bigger the map. You can also define your own colors and markers for the resource, via medatata.

{{% alert info %}}
If changes to the map don't apply immediatly just press the refresh button on the top right corner so the widget can refresh.
{{% /alert %}}


Here is the example of the dashboard that uses geo map:
![Map ](features/grafana/geo_map.png)


From the marker which is placed on the map, we can also drill down to per device dashboards, as configured before in the `General` settings.

## Detailed (resource based) map

When creating a deatiled map, first we need to define the resource:
![template](features/grafana/template_resource.png)

{{% alert info %}}
Here we show the example where we fitler by provider, but it can be any other metadata field, such a resource type, customer etc.
{{% /alert %}}


`Metric` setting is different then in the overview dashboard, here we only select one resource, and we use the time series data to plot the path:

![Metrics](features/grafana/metrics_tracking.png)

Here is the example of one detailed dashboard:
![Map drill down](features/grafana/details.png)



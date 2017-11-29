---
title: Grafana Dashboard
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

You can optionally add a customer ID to filter all resources in the dashboard to exclude resources that are not owned by that particular customer.

# Usage

You can use the Waylay data source that you have just configured to visualize your data, please refer to the official [Grafana documentation](http://docs.grafana.org/) on [getting started](http://docs.grafana.org/guides/getting_started/) or read up on some of the Grafana [basic concepts](http://docs.grafana.org/guides/basic_concepts/).

# Plugins
The Waylay dashboard comes with these preloaded plugins:

* Graph (default Grafana graph plugin with all functionality) 
* Singlestat (default Grafana singlestat plugin with all functionality)
* Text grafana plugin  
* Table (new with grafana 4.x)
* Heatmap (new with grafana 4.x)
* GeoMap -> Waylay geo map plugin
* AlarmView -> Waylay AlarmView plugin
* Table (depricated)-> Waylay table plugin

![plugins](features/grafana/plugins.png)

# GeoMap

The GeoMap plugin is a custom map plugin developed by Waylay. It is used to show multiple resources on a map by means of markers. The markers allow to click through to more detailed dashboards for a particular resource. 
To add this setting, navigate to the General tab and add the fields for the detailed dashboard in the 'Drilldown/detail link'section. 

![Add Link](features/grafana/general.png)

{{% alert info %}}
More about adding detailed dashboards later.
{{% /alert %}}


In order to link resources to the map, you need to go to the `Metrics` tab:
![Metrics](features/grafana/metrics.png)

Here you define in the first `FILTER` resourceTypeId, which will be used as the filtering criteria for resources you want to show on the map. These resources __must have longitude and latitude__ measurements.
In the second row, where you use `FILTER` resourceTypeId, you will define the geofences that will be plotted on the same map. These resources __must have defined geofences__ in the metadata.

{{% alert info %}}
More about adding geofences in the metadata later.
{{% /alert %}}

In this example, we ignore the time series data, __which means that we are plotting only data which is defined in the metadata!__ That also means, that every time a new data point with location is being sent to Waylay, we would need to update the resource metadata with its location. This is typically done by the geofence template, explained later. That way, we only show the latest data point per resource.


Next thing to setup are `Options`:
![Map Options](features/grafana/options.png)

Markers can be configured to have one of four colors and can contain any icon from [ionicons](http://ionicons.com/). You can also enable/disable the auto zoom and set the zoom level for the auto zoom. The higher the auto zoom (max 1) the bigger the map. You can also define your own colors and markers for the resource via medatata.

{{% alert info %}}
If changes to the map don't apply immediately, just press the refresh button on the top right corner so the widget can refresh.
{{% /alert %}}


Here is an example of the dashboard that uses the GeoMap:
![Map ](features/grafana/geo_map.png)


From the marker which is placed on the map, we can also drill down to per device dashboards, as configured before in the `General` settings.

## Detailed (resource-based) map

When creating a detailed map, first we need to define the resource:
![template](features/grafana/template_resource.png)

{{% alert info %}}
Here we show the example where we filter by provider, but it can be any other metadata field, such as a resource type, customer etc.
{{% /alert %}}

`Metric` setting is different than in the overview dashboard, here we only select one resource, and we use the time series data to plot the path:

![Metrics](features/grafana/metrics_tracking.png)

Here is an example of a detailed dashboard:
![Map drill down](features/grafana/details.png)


# AlarmView plugin

AlarmView plugin is a custom plugin developed by Waylay. In `General` settings, you can also define drill down detailed dashboards:
![settings](features/grafana/alarm_settings.png)

This plugin allows you to map the time series data into the alarm view (in this example, we use alarm_type values):

![settings](features/grafana/alarm_metrics.png)

In this example, the mapping JSON object is defined as follows:

```
{
"2": { "name" : "Temperature Too High", "color" : "d35400","icon": "thermometer"}, 
"3": { "name" : "Temperature Too Low", "color" : "2980b9","icon": "thermometer"}, 
"4": { "name" : "Box cleaned", "color" : "2ecc71","icon": "thermometer"}, 
"5": { "name" : "Entering Geofence", "color" : "9ACD32","icon": ""}, 
"6": { "name" : "Leaving Geofence", "color" : "0000FF","icon": ""}, 
"10": { "name" : "Battery Level Low", "color" : "DDD6AA","icon": ""}, 
"11": { "name" : "NO DATA", "color" : "FAA00F","icon": ""}
}
```

The key of the JSON object is either a metric (number), or a string, since the Waylay time series database can store both numerical and string values. Once the data is mapped:

![alarms](features/grafana/alarms.png)


The same settings in the detailed dashboard can look like this:
![alarms](features/grafana/alarm_resource_settings.png)

# Table 
With grafana 4.x waylay datasource is fully compatible with default table that comes with grafana. This is an example of the table view on few Sigfox devices:

![alarms](features/grafana/table_4.x.png)

In the example above, you can see how for one particular column, you can add external links, like for instance another detailed dashboard. By making use of `$__cell` you can inside the link get a reference to the value of the cell. In the same example, we replaced the column header (from `id` to `Resource`).

{{% alert info %}}
Link from one table cell (`id`) to the detailed grafana dashboard is done this way: `https://<URL>/dashboard/db/details?from=now-24h&to=now&orgId=1&var-resource=$__cell` on the table column `id` . `$__cell` will be automatically replaced by the correct resource id.
{{% /alert %}}

{{% alert error %}}
In case you are migrating tables from 3.x to 4.x and you had links to detailed dashboards, you must now follow this procedure to link different dashboards. 
{{% /alert %}}



In order to change the cell colour for one of the columns, like in the example above, we used default grafana table feature:
![alarms](features/grafana/temp_style.png)


{{% alert info %}}
If metrics are defined in the resource metadata (either by the type or individually), table columns will be pre-populated. In any case, a user can always change columns.
{{% /alert %}}


# Heatmap 
With grafana 4.x waylay datasource is fully compatible with default heatmap that comes with grafana. This is an example of the heatmap view on the temperature measurements for one device:

![alarms](features/grafana/heatmap.png)

# Graph and ALIAS BY
With support for grafana 4.x we have also enriched our datasource to support `ALIAS BY` feature. In the example below, we have replaced in the legend, resource id's by name (friendly name) from metadata for these resources:

![alarms](features/grafana/alias.png)


{{% alert info %}}
For ALIAS BY, you can use any other meta attribute for that resource, and make contructions such as: `$name: $provider - temperature`
{{% /alert %}}

# Geofence template

Here is an example of the geofence template which updates events (later used for the alarm view table) and annotates resource metadata, later used for the resource filtering by table view and to show the last known position on the GeoMap overview.[Repo can be found here](https://raw.githubusercontent.com/waylayio/Templates/master/geoFencePerCustomer)


![template](features/grafana/geoFence_template.png)


# DEPRICATED FEATURES

# Table plugin (**depricated from 3.x**)
Table plugin is a custom plugin developed by Waylay. It shows the following columns:

* resource field
* resource name
* resource description
* last time message (data) was received

![table_view](features/grafana/table_view.png)

Here are the `General` settings, which also allow you to add a drill down detailed dashboard:
![table_general](features/grafana/table_general.png)

In the `Metrics` settings, we define the filter for the resources that we want to see in the table, in this example, one particular location, which was present in the metadata of the resources that are selected. For instance, you can create a rule that automatically updates the location of the resource based on geofence data and then use this filter to show assets in different locations:

![table_metrics](features/grafana/table_metrics.png)






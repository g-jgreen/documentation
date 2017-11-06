---
title: Geofencing/tracking package
description: Geofencing/tracking package
weight: 1
---

![Map drill down](features/grafana/details.png)

# Prerequisites

* Grafana dashboard and the Waylay plugin
* Geofencing sensors and actuators
* Geofencing template

{{% alert info %}}
We assume you already have a Waylay account or installation ready to connect to, and have also requested a hosted version of the dashboard.
{{% /alert %}}

# Setup grafana
In order to setup grafana for geofencing use case, please follow the steps as described [here](features/grafana)

# Scenario
In this package, we will track devices, which send their realtime location to waylay. Based on their location, and list of geofences which you can configure, waylay will create IN/OUT events, show them on the dashboard and if necessary send SMS, email etc.

We shall first  create one resource type, which will link all geofence resources together. 
Geofence resources can be:

* circle defined by one location (coordinate) and radius
* polygon (with 2, or more than 3 coordinates)
* triangle  (with 3 coordinates)

This is how we can create a test data, with one resource type and multiple geolocations:
```
USER=""
KEY=""
DOMAIN="https://<domain>.waylay.io/api"
#create resource type
curl -i --user $USER:$KEY -H "Content-Type: application/json" -X POST -d '{"id":"geofences", "name":"geofences"}' $DOMAIN/resourcetypes
#create resources
curl -i --user $USER:$KEY -H "Content-Type: application/json" -X POST -d '{"id": "Site1", "resourceTypeId":"geofences","geofence" : [[50.725952, 4.204970],[50.730396, 4.204915],[50.732057, 4.209799],[50.729848, 4.215603],[50.727599, 4.215967]]}' $DOMAIN/resources
curl -i --user $USER:$KEY -H "Content-Type: application/json" -X POST -d '{"id": "Site3", "resourceTypeId":"geofences","geofence" : [[50.652937, 3.862838],[50.655207, 3.870875],[50.652824, 3.872014],[50.650925, 3.864013]]}' $DOMAIN/resources
curl -i --user $USER:$KEY -H "Content-Type: application/json" -X POST -d '{"id": "Site2", "resourceTypeId":"geofences","geofence" : [[50.726973, 4.216017]], "radius": 50}' $DOMAIN/resources
curl -i --user $USER:$KEY -H "Content-Type: application/json" -X POST -d '{"id": "Site4", "resourceTypeId":"geofences","geofence" : [[50.674336, 3.872260]], "radius": 200}' $DOMAIN/resources
curl -i --user $USER:$KEY -H "Content-Type: application/json" -X POST -d '{"id": "Site5", "resourceTypeId":"geofences","geofence" : [[50.932800, 4.053299]], "radius": 50}' $DOMAIN/resources
curl -i --user $USER:$KEY -H "Content-Type: application/json" -X POST -d '{"id": "Site6", "resourceTypeId":"geofences","geofence" : [[50.873361, 4.685193]], "radius": 50}' $DOMAIN/resources
curl -i --user $USER:$KEY -H "Content-Type: application/json" -X POST -d '{"id": "Site7", "resourceTypeId":"geofences","geofence" : [[51.192821, 2.841141]], "radius": 50}' $DOMAIN/resources


```


Device with location data comes to waylay as a stream, with at least the following payload (it can as well include other metrics):
```
{
    "longitude": 4.1, 
    "latitude": 51.2
}                       
```
{{% alert info %}}
We can either create a task for one particular device, or even better, set a template for all devices that belong to the same resource Type group as describe [here](features/provisioning). 
{{% /alert %}}

Every time a new data is streamed, a geofence rule, started as a reactive task from the template, will check whether the asset is inside or outside of any of the locations provided in the list.


# Required sensors and actuators

## Required sensors
* __genericGeoFence__ sensor (provides IN/OUT state for the list of geolocations)
* __waylayGetMetadata__ sensor (meta of the resource which can be used to filter further the list of geolocations e.g. customer)
* __getGeofenceLocations__ sensor (provides list of geolocations used by genericGeoFence sensor)

## Required actuators

* __waylayCloudCacheStore__ actuator (to store IN/OUT events)
* __waylayUpdateMetadata__ actuator (to store new locations in the resource metadata, and if needed the name of the geofence site)

{{% alert info %}}
You can as well add any other notification to this template, such as SMS, email etc...
{{% /alert %}}



# Geofence template

Here is the example of the geofence template, which updates events (later used for the alarm view table) and annotates resource metadata (later used for the resource filtering by table view and showing the last known position on the geoMap overview) can be found here [repo](https://raw.githubusercontent.com/waylayio/Templates/master/geoFencePerCustomer).


![template](features/grafana/geoFence_template.png)

# Simulation
You can setup the simulation using our [lab page](http://labs.waylay.io).
Tracking data that you can use for the simulation is here [repo](https://raw.githubusercontent.com/waylayio/data/master/simulationData/tracking/tracking.csv)

![simulation](packages/geofence/simulation.png)

{{% alert info %}}
You need to make sure that you have one reactive task, based on the template above, and then you can click `Start Simulation` button.
{{% /alert %}}





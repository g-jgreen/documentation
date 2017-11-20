---
title: Authorization / Roles
description: Users can be restricted in what they can do
tags:
- authorization
weight: 8
---

# Introduction
If the tenant has multiple users, it might be interesting to restrict what those users can do. Currently we have a predifined roles which can be associated to a user. 


{{% alert info %}}
This feature is still managed by waylay but will become available to the administrator of the waylay tenant soon.
{{% /alert %}}


# Access rights/features
With WaylayDashboard users are able to perform the following operations:

* Manage billing and global settings
* CRUD operations on actuators
* CRUD operations on sensors
* CRUD operations on templates
* CRUD operations on tasks
* CRUD operations on resource types
* CRUD operations on payload transformers
* Run debugger
* Migrate tasks/templates ([see the link](features/migration))



{{% alert info %}}
CRUD - create, read, update, delete.
{{% /alert %}}



# Roles

These are currently three predifined roles available in waylay:

* admin
* operator
* qa

## Admin

The `Admin` user has no restrictions, and next to all availbale operations, he can also edit global settings and set up billing. 

## Operator

The `Operator` user has the following permissions:

  * Manage Plugins (sensors and actuators)
  * View all templates
  * Manage all templates
  * View all tasks
  * Managed own tasks
  * Create debug task
  
## QA

The `QA` user is a read-only role:

  * View all plugins
  * View all templates
  * View all tasks
  * Create debug task
   
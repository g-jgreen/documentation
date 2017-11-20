---
title: Authorization / Roles
description: Users can be restricted in what they can do
tags:
- authorization
weight: 8
---

# Introduction
Once you have multiple users using the waylay platform it might be interesting to restrict what those users can do. Currently we have a basic roles implementation that restricts access to tasks / templates and plugins.

This is still managed by waylay but will become available to the administrator of the project later on.

# Roles

These are the currently available roles

## Admin (default)

The `Admin` user has no restrictions, he can edit global settings and set up billing.

## Operator

The `Operator` user has the following permissions:

  * Manage Plugins
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
   
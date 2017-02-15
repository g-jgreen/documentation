---
title: Migration/version upgrade feature 
description: Learn how to migrate sensors, actuators, tasks and templates at runtime
tags:
- migration
weight: 5
---

# Automation challenges
Business agility implies being able to adjust, change and implement new business processes. Automation platform needs to follow the same philosophy, otherwise, it is as good as yesterday's practices. 
Once we deploy automation tasks in production, several things can happen:

* API endpoints that are in use by sensors/actuators are not available any more (need to be replaced by other providers)
* API endpoints have now different responses than before (parsing needs to be updated)
* we need to update templates and tasks as new service become available
* adjust/change already running tasks


# Sensor/Actuator upgrades

Every sensor and actuator in the waylay tenant platform is versioned. When we decide to update a plug, new version will be stored in the cloud. This is the console view of waylay plugs. For each plug, you can see how many different versions have been created.

![Sensor version](/usage/migration/sensor_version.png)

Here is the example of the Zendesk actuator

![Zendesk](/usage/migration/zendesk1.png)

Let's now build a "devops" template using this actuator:

![Zendesk](/usage/migration/devops_template.png)

Now, let's run the task using REST call:
```
    "name": "DEVOPS machine x1",
    "template": "devops",
    "resource": "machine x1",
    "type": "periodic",
    "frequence": 10000,
  }' https://sandbox.waylay.io/api/tasks
```

Here is the newly created task in the application:

![task](/usage/migration/task.png)

Let's imagine that zendesk API version had changed after this task was created. In the previous example, the URL for the zendesk API service was version one `v1`, coded in the plug like this: 

`var url = "https://"+domain+".zendesk.com/api/v1/tickets.json";`. 

Assume now that the new API version is 2. Now we need to change the zendesk ticket plug (new plug version is now `0.0.2`:

![Zendesk v2](/usage/migration/zendesk2.png)
{{% alert info %}}
In this example we assume that it was just a version number change. But this could as well be something else, like change it the API response, need for additional attributes etc.
{{% /alert %}}

If we look at the task view again, we can see the warning:

![task warning](/usage/migration/task_warning1.png)

If we click the migrate button, we end up on the migration page. We can see that inside the template, we have the same actuator three times configured, all with the same old version `0.0.1`. 

![task migration](/usage/migration/template_migration.png)

Now we need to migrate templates.
{{% alert info %}}
Please note that we couldn't migrate tasks directly without migrating the template first. If tasks were created without the template, we would simply just migrate running tasks, skipping the next step.
{{% /alert %}}

In the template view, we can now migrate all actuators `zendeskTicket`

![update template](/usage/migration/upgrade_zendesk1.png)


Once we saved the template, new icon will show in the command view (left top corner)

![task migration](/usage/migration/migrate_templates2.png)

That brings us back to the migration page. With one click of a button, all running tasks will be updated. Easy!

![task migration](/usage/migration/migration_final.png)





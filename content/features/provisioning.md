---
title: Provisioning
description: Learn how to integrate waylay in your provisioning system
tags:
- provisioning
weight: 2
---

# Introduction
Provisioning involves the process of preparing and equipping a network and a device to allow it to provide (new) services to its users. 

Technically speaking, that implies creating a relation between physical (IoT) device, customer information database (CRM), asset and service database on top of which the service is created. From that perspective, IoT platform is just one part of much bigger puzzle. 

Important thing to note is that there is no one-way of doing these sort of things. There is a huge variety  of systems and applications in the field, so in waylay we try not to be too smart about it - in sense of enforcing one particular provisioning process. Rather, waylay provides set of [API calls](api/rest/#provisioning-api) and best practises, that help our customers implement efficient provisioning process.


# First time provisioning 

For first time provisioning, we use a great feature of waylay - **automatic task creation for new resources, based on the resource type**. 
That simply means that every time new resource is discovered, which is associated with a particular resource type, all tasks for that resource are automaticaly created.

## Provisioning template

Here is the example of **the first time provisioning** use case. In this example, every time a new sigfox device is discovered, two different salesforce tables are queried, one having customer information (matching a device ID to a customer), and the other one with assets (matching a device ID in the asset database). Once both records are found, we update asset database with the information when for the first time device was up, and we also update **the waylay metadata model**, using the actuator built on top of our [**Provisioning API**](api/rest/#provisioning-api). 

![template](/features/provisioning/template.png)

{{% alert info %}}
As mentioned earlier, provisioning process differ between customers. This template is one example of how this process might look like. 
{{% /alert %}}

Now we need to assosiate this template to a resource type.

## Resource type configuration

Here is the list of resource types, let's select Sigfox type (Nucleo)

![types](/features/provisioning/resource_types.png)

One we select the resource type, let's add our provisioning template to this resource type:

![template](/features/provisioning/saveTemplateType.png)

{{% alert info %}}
Note that we can add many more templates (which are either periodic, cron, reactive or onetime). Each time new resource is discovered all these tasks would be started. In this case, we want provisioning template to run only once, hence we selected as a task type: `onetime`.
{{% /alert %}}

Here is the provisiong task, which was executed only once as soon as the device sent data:

![task](/features/provisioning/task.png)

We can also see in the resource view that at the same time we assosiated the customer to the same device (`abccompany`):

![resources](/features/provisioning/resources.png)

In the resource view, we see the complete metamodel for that resource. Some of the properties are inhereted from the resource type.

![metamodel](/features/provisioning/meta_model.png)


# B2B Dashboard
Once device was assigned to a customer, it immediately become available in our B2B dashboard, in this case the customer `abccompany`. Great, all done! 'Zero touch' configuration.

![dashboard](/features/provisioning/dashboard.png)

{{% alert info %}}
More about B2B dashboard you can find [here](/usage/grafana/)
{{% /alert %}}






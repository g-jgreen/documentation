---
title: Webscripts
description: Learn how to use webscripts
tags:
- webscripts
weight: 6
---

![webscripts](/features/webscripts/webscripts_main.png)

# Introduction
There is often a need to integrate waylay with external systems that make use of webhooks or similar technologies that have hardly any possibility to intervene in a way the webhook payload is defined. In waylay, there is already possibility to use payload transformation functions to adjust or decode payloads before they enter in the waylay "ecosystem" called [transformers](/features/transformers), but there we assume that the other integration system has a possibility to define method signature that matches waylay definition of [REST transform functions](/api/rest/#execute-a-specific-transformer-version). Webscripts are **pure cloud functions**, trying not to be "too smart". They let developers define any cloud function they want, secure or not (functions are always over HTTPS, but can be either public or with authentication), which can be invoked over the REST interface.


{{% alert info %}}
Webscripts are pure cloud functions. They let developers define any cloud function they want, secure or not (functions are always over HTTPS, but can be either public or with authentication), which can be invoked over the REST interface.
{{% /alert %}}

# How to create a new webscript

## Creating a new webscript
Creating a new webscript is easy. After clicking`Add Webscript` button, we get to this window.

![webscripts](/features/webscripts/edit_1.png)

## Adding additional npm packages

Great feature of the webscripts is that the integrator can add any npm package he wants! 
![webscripts](/features/webscripts/packages.png)


## Listing all webscripts

Once we save the webscript, it shows in the list: 

![webscripts](/features/webscripts/edit_2.png)


# Testing webscripts

we can always test the webscript, either by clicking the link directly from the list, or by going to the webscript URL in the browswer or just running `curl`

![webscripts](/features/webscripts/test_1.png)

{{% alert info %}}
In this example we used a public webscript URL
{{% /alert %}}


# Accessing logs
We can access logs of every webscript, we can check all requests and responses, and we can also filter logs by log levels:

![webscripts](/features/webscripts/logs_1.png)
![webscripts](/features/webscripts/logs_2.png)

# Making the webscript private
At any moment in time, we can turn public into a private webscript, by clicking `Private` button. 

![webscripts](/features/webscripts/private.png)



Once the webscript is private, you need to click the key button, which would copy the required private key.

![webscripts](/features/webscripts/private_1.png)

## HMAC signature in authorization header

When calling a private webscript, an HMAC signature for the specific webscript can be passed by setting the Authorization-header with value: `hmac-sha256 {signature}` , where the `{signature}` is the key that was copied in the previous step.

## Basic Auth
Another option the integrator has is to use a tenant REST API keys: `client id` and `client secret` and supply them in the webscript call.






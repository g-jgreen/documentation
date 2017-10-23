---
title: Webscripts
description: Learn how to use webscripts
tags:
- webscripts
weight: 6
---

<style>
  img {
    border: solid #F5F5F5 5px;
    border-radius: 5px;
    margin: 0 auto;
    display: block;
  }
</style>

![webscripts](/features/webscripts/webscripts_main.png)

# Introduction
There is often a need to integrate waylay with external systems that make use of webhooks or similar technologies that have hardly any possibility to intervene in a way the webhook payload is defined. In waylay, there is already possibility to use payload transformation functions to adjust or decode payloads before they enter in the waylay "ecosystem" called [transformers](/features/transformers), but there we assume that the other integration system has a possibility to define method signature that matches waylay definition of [REST transform functions](/api/rest/#execute-a-specific-transformer-version).

Webscripts are **pure cloud functions**, trying not to be "too smart". They let developers define any cloud function they want, secure or not (functions are always over HTTPS, but can be either public or with authentication), which can be invoked over the REST interface.

{{% alert info %}}
Webscripts are pure cloud functions. They let developers define any cloud function they want, secure or not (functions are always over HTTPS, but can be either public or with authentication), which can be invoked over the REST interface.
{{% /alert %}}

# How to create a new webscript

## Creating a new webscript
Creating a new webscript is easy. After clicking the `Add Webscript` button you can immediately start programming its behaviour.

![webscripts](/features/webscripts/edit_1.png)

## Adding additional NPM packages

An amazing feature of the webscripts is that the integrator can add any npm package he wants!

![webscripts](/features/webscripts/packages.png)

## Listing all webscripts

Once we save the webscript, it shows up in the overview.

# Testing webscripts

we can always test the webscript, either by clicking the link directly from the list, or by going to the webscript URL in the browswer or just running `curl`.

```curl
❯ curl -i https://webscripts.waylay.io/api/v1/760f3b6a-7247-453e-b299-3a9216a84d2a/public
HTTP/2 200
access-control-allow-origin: *
content-type: text/html; charset=utf-8
etag: W/"d-ebe6c6e6
date: Mon, 23 Oct 2017 11:39:13 GMT
content-length: 13
alt-svc: clear

Hello, world!%
```

{{% alert info %}}
In this example we used a public webscript URL
{{% /alert %}}


# Logs & Debugging
We can access logs of every webscript, we can check all requests and responses, and we can also filter logs by log levels:

![webscripts](/features/webscripts/logs_1.png)

# Making the webscript private
At any moment we can turn a public webscript into a private one by clicking the `Private` button.

![webscripts](/features/webscripts/private.png)

Once the webscript is private you can click the key button — this will copy the secret key to your clipboard.

![webscripts](/features/webscripts/private_1.png)

## HMAC signature in authorization header

When calling a private webscript, a secret key for the specific webscript can be passed by setting the `Authorization` header with value: `hmac-sha256 {signature}` , where the `{signature}` is the key that was copied in the previous step.

```curl
❯ curl -i -H "Authorization: hmac-sha256 7oealrHHgItOTSuJn8udYJTCMrzq8m/F" https://webscripts.waylay.io/api/v1/760f3b6a-7247-453e-b299-3a9216a84d2a/private
HTTP/2 200
access-control-allow-origin: *
content-type: text/html; charset=utf-8
etag: W/"f-7d3dd04f"
date: Mon, 23 Oct 2017 11:49:48 GMT
content-length: 15
via: 1.1 google
alt-svc: clear

Hello, private!%
```

## Basic Auth
Another option the integrator has is to use a tenant REST API keys: `client id` and `client secret` and supply them in the webscript call.

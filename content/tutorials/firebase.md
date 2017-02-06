---
title:      "Firebase: the fastest way to integrate different API backends?"
author:     waylay
date:       2016-02-18 14:59:06
---

Recently [waylay] and [solvice] joined the forces for the [hackapost] event in Brussels. We wanted to integrate our orchestration/notification engine with the planning/optimization API backend of Solvice. Within few hours, we developed "uber like" B2B application, where based on the LoRa enabled sensor, our joint solution triggered optimization and routing of the cars for the fast packet delivery, including notification to the drivers what is the best route to take. Interesting part of this challenge was that both the source and destination of the delivery was not constant.

More info on this particular use case will be in another blog (on the main web site) [waylay blog]. In this post, I only want to focus on one simple way of doing "SOA" integration - especially if you need to do something quick at hackathons.  

# Firebase as a "SOA" bus
Our solution started with LoRa enabled trigger event (_Binary sensor_). Using Proximus [proximus] API backend, we registered a webhook that propagated LoRa events towards the Waylay Broker. Once we saw data in the waylay platform, we were ready to start with integration.

The way you typically deal with integration tasks is to go over the APIs of the third parties, and try to figure out exactly what kind of calls you need, whether the calls are async or not, and what variant of REST/FORM/POST/PUT/JSON/BasicAuth/BearerToken is needed to pass the right info. And that had to be done on both sides. But we had no time for that - we only had few hours to hack it.

Instead of doing this, we figured it out that would be much easier to allocate one firebase project for this hackathon, and use it as a "SOA" bus. Since you can easily POST JSON's in the firebase project endpoints and register webhooks/websockets/SSE's on the data change, we had one simple way of communicating between backends. More over, we could use the same events to update UI, since the frontend would process websockets at the same time as any other backend service.

# Pushover as a device client messenger
Another challenge was to inform a driver on which route to take between two locations. This time, we used a [pushover] service, which allows you to send messages towards Android/iOS devices or web clients via the API. So, next to a firebase actuator, we also created a pushover actuator in waylay and embedded in the message a URL that pointed to the web app. When a "driver" clicked the URL on the phone (pushover notification), his phone would open a web app (in order to accept or deny the assignment). That web app would then use the firebase to send the feedback back to the waylay platform. That in return would either trigger a new calculation on Solvice, or start tracking the delivery (in case the driver accepted the assignment). 
Done! Uber in 4hours!

![Hackathon demo](https://waylayio.github.io/assets/images/hackapost.png)



[waylay]:       http://www.waylay.io/
[waylay blog]:    http://www.waylay.io/blog.html
[solvice]:        http://www.solvice.io/
[hackapost]:      http://hackapost.be/
[firebase]:       https://www.firebase.com/
[proximus]:       https://www.enabling.be/
[pushover]:       https://pushover.net/

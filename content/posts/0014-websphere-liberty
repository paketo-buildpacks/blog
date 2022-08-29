---
title: WebSphere Liberty now available
date: "2022-08-25"
slug: websphere-liberty-now-included-in-liberty-buildpack
author: kevinortega
---

I am pleased to announce that [WebSphere Liberty](https://www.ibm.com/cloud/websphere-liberty) is now included in the [Paketo Liberty](https://github.com/paketo-buildpacks/liberty) buildpack and available to currently entitled WebSphere Liberty users. WebSphere Liberty is built on [Open Liberty](openliberty.io) and is a lightweight, efficient, Java™ EE, Jakarta EE and MicroProfile cloud-native runtime.

The Paketo Liberty buildpack now gives you a choice to use WebSphere Liberty or Open Liberty to run your application.

To use WebSphere Liberty in your container, set the `BP_LIBERTY_INSTALL_TYPE` environment variable to specify the [install type](https://github.com/paketo-buildpacks/liberty#install-types) `wlp`:
```
 pack build --env BP_JAVA_APP_SERVER=liberty \
  --env BP_LIBERTY_INSTALL_TYPE=wlp \
  --buildpack paketo-buildpacks/eclipse-openj9 \
  --buildpack paketo-buildpacks/java myapp
```

Open Liberty continues as the default install type.

Just like Open Liberty, WebSphere Liberty offers a range of profiles to choose from.


![Open Liberty Logo](/images/posts/0014/liberty-profiles.png)

Set the `BP_LIBERTY_PROFILE` environment variable to specify the profile you want to use.

## Learn more:
* [Paketo Liberty buildpack](https://github.com/paketo-buildpacks/liberty/blob/main/README.md)
* [WebSphere Liberty](https://www.ibm.com/docs/en/was-liberty/base?topic=liberty-overview)
* [Open Liberty](https://github.com/OpenLiberty/open-liberty#readme)

---
title: Introducing the Liberty buildpack
date: "2022-04-04T09:38:38-04:00"
slug: introducing-liberty-buildpack
author: kevinortega
---

![Open Liberty Logo](/images/posts/0008/open-liberty-logo.png)

[Liberty](https://github.com/paketo-buildpacks/liberty) is finally available in Paketo and included in the [java](https://github.com/paketo-buildpacks/java) buildpack! Liberty is an open application framework designed for the cloud. It’s small, lightweight, and designed with modern cloud-native application development in mind.

With the Liberty buildpack, you can:
*   Build Java apps from source or a pre-configured on-prem Liberty
*   Install Liberty and user custom features
*   Install Liberty interim fixes
*   Create UBI-based OCI images

## What do you need?
*   Your application source or a pre-configured on-prem Liberty
*   [Docker](https://hub.docker.com/search?type=edition&offering=community)
*   [pack](https://buildpacks.io/docs/tools/pack/)

## Let's get started!

The following examples use the [Open Liberty starter](https://openliberty.io/guides/getting-started.html) application as the application source.
Download the Open Liberty starter application:
```
git clone https://github.com/openliberty/guide-getting-started.git
cd guide-getting-started/start
```

If you're new to buildpacks, I recommend you set a default builder as this removes the need to set a builder each time you build an image.
```
pack config default-builder gcr.io/paketo-buildpacks/builder:base
```

Build the application with a minimal footprint with only the Liberty features required to run the application and IBM Semeru OpenJ9:
```
 pack build --env BP_JAVA_APP_SERVER=liberty \
  --env BP_LIBERTY_PROFILE=jakartaee9 \
  --buildpack paketo-buildpacks/eclipse-openj9 --buildpack paketo-buildpacks/java myapp
```

Your application is now transformed into an OCI image!

## Now what?
With your OCI image, you can run your application locally with the `docker run` command.

```
docker run --rm -p 9080:9080 myapp
```
or deploy your application to any Kubernetes-based platform, such as [Red Hat OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift), by using an [Open Liberty operator](https://github.com/OpenLiberty/open-liberty-operator)

## Build your app from an on-prem Open Liberty installation
You can build from an on-prem Open Liberty installation by using a packaged Liberty server. Run the following command to package your server.
```
bin/server package defaultServer --include=usr
```
You can then supply the packaged server to the build by using the `--path` argument:
```
pack build --path <packaged-server-zip-path> \
 --buildpack paketo-buildpacks/eclipse-openj9 \
 --buildpack paketo-buildpacks/java myapp
```
Alternatively, you can build from a Liberty server installation by changing your working directory to the installation root that contains the `wlp` directory and running the following command:
```
pack build  \
 --buildpack paketo-buildpacks/eclipse-openj9 \
 --buildpack paketo-buildpacks/java myapp
```

## Learn more:

* [Paketo Liberty buildpack](https://github.com/paketo-buildpacks/liberty/blob/main/README.md)
* [Create a UBI-based container image](https://github.com/paketo-buildpacks/liberty/blob/main/docs/using-liberty-stack.md)

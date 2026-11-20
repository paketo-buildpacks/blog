---
title: Spring Cloud Bindings Changes
date: "2026-11-20T17:20:53-06:00"
slug: spring-cloud-bindings-changes
author: dmikusa
---

A quick announcement for our Spring Boot users. Historically, the Spring Boot buildpack has installed the [Spring Cloud Bindings](https://github.com/spring-cloud/spring-cloud-bindings) JAR on behalf of users. This is a helpful library for automatically loading Kubernetes Service Bindings and registering them for autoconfiguration in your Spring Boot applications.

Unfortunately, this project is no longer supported as of Spring Boot 4.2.0. The buildpack installing the library causes applications to crash at runtime with the following message:

```
Spring Cloud Bindings Enabled
Exception in thread "main" java.lang.reflect.InvocationTargetException
Caused by: java.lang.IllegalArgumentException: Unable to instantiate factory class [org.springframework.cloud.bindings.boot.BindingFlattenedEnvironmentPostProcessor] for factory type [org.springframework.context.ApplicationListener]
Caused by: java.lang.NoClassDefFoundError: org/springframework/boot/env/EnvironmentPostProcessor
```

As is typical for the Paketo project, we will follow the path of upstream projects with respect to deprecations and removals, so Paketo's Spring Boot buildpack will switch to disable this functionality automatically when it detects a Spring Boot 4.2.0 or greater application. This is available starting in version 5.41.0 of the Spring Boot buildpack, and version 22.10.0 of the Paketo Java buildpack.

If you are running on an older buildpack with Spring Boot 4.2.0+ applications, you may disable the addition of Spring Cloud Bindings by setting `BP_SPRING_CLOUD_BINDINGS_DISABLED=true` at build time. The buildpack will read this and no longer add the JAR to your application images.

If you are running older Spring Boot applications that use Kubernetes Service Bindings, that's fine. You may continue using them and the buildpack will continue to allow that. You will need to address this in your applications though, or it will block your upgrade to Spring Boot 4.2.0+. You may consider switching to one of the following options:

- Environment variables
- Spring Boot's built-in config tree support (i.e. ConfigMap & Secrets)
- Spring Cloud Config Server
- Loading directly from a secret manager like Vault or one provided by your Cloud Vendor

If you're wondering why this has been removed upstream, it looks like it's due to declining vendor support for Kubernetes Service Bindings and other options that have grown more popular with users. For example, several vendors have dropped support, and the Spring Cloud Bindings project hasn't had a release in over two years.

- Red Hat Service Binding Operator was [deprecated in February 2024 and archived in June 2024](https://github.com/redhat-developer/service-binding-operator).
- VMware Tanzu Service Binding was [deprecated in March 2025](https://github.com/vmware-tanzu/servicebinding).
- Quarkus Kubernetes Service Binding was [deprecated in March 2025](https://quarkus.io/extensions/io.quarkus/quarkus-kubernetes-service-binding).
- The Spring AI project [removed support for Service Bindings due to low usage](https://github.com/spring-projects/spring-ai/issues/6079).

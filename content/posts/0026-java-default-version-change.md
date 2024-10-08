---
title: Paketo Java Buildpacks Updates Default to Java 21
date: "2024-10-08"
slug: paketo-java-buildpacks-updates-default-to-java-21
author: dmikusa
---

It's that time again, time to update the default Java version in Paketo Java buildpacks!

Through our community RFC process, the Paketo Java subteam [adopted an official policy on updating the default version of the JVM](https://github.com/paketo-buildpacks/rfcs/blob/main/text/java/0014-selecting-default-java-version.md), RFC #0014.

The policy states that "the default should be changed once the latest released LTS version of Java is at least one year old". Java 21 was released in September of 2023, and it's now October of 2024 which puts us over a year from the release.

Because we realize this will impact users, we are providing advance notice of this change. We will be adjusting the default version of the JVM to Java 21 starting with the Java buildpack release scheduled for Friday November 1st, 2024.

There are a few things you can do to prepare for this change:

1. Upgrade to Java 21! It's another great release.
2. If you can't upgrade, you can [pin the major Java version](https://paketo.io/docs/howto/java/#install-a-specific-jvm-version) to your required version.
3. Alternatively, you may be able to [set the Java source/target version](https://www.baeldung.com/java-source-target-options) in your project.

If you do pin the version, please make a note or set a reminder to come back and upgrade later.

The project does not recommend pinning the buildpack version. This will prevent the application from being built using the latest patch release of Java and could leave your application vulnerable to know security issues.

That's it! Go forth and modernize your Java apps!
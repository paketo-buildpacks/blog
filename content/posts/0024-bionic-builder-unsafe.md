---
title: Paketo's Bionic Builder Is Unsafe
date: "2023-11-14"
slug: paketo-bionic-builder-is-unsafe
author: dmikusa
---

## Paketo's Bionic Builder Is Unsafe

It's a strange thing for the Paketo Project to call out its builder as being unsafe, but the key detail here is that it's the **Ubuntu Bionic Builder** we're saying is unsafe.

On May 31st, 2023, Ubuntu 18.04 (Bionic Beaver) went out of support for OSS customers ([source](https://ubuntu.com/blog/18-04-end-of-standard-support)). At the same time, the Paketo Project [stopped supporting its Bionic Stacks and Builders based on Ubuntu 18.04](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0057-bionic-eos.md). This was further communicated in a [blog post on July 28, 2023](https://blog.paketo.io/posts/bionic-eos/).

This means that updates have not been published for the Bionic Builder or any of its buildpacks **for almost six months**. That's a long time in the software world, which is why we're saying that it's not safe to use this stack.

Despite this, we are still seeing users performing builds against the Bionic stacks. This comes up in forum posts, Stack Overflow questions, Slack questions, and other channels. We believe that users are not getting the message or are not noticing that they are still using an old builder.

## The Plan

To help notify users that they need to change, **we are going to move forward with a brownout for the Bionic Builder on Monday, November 20th, 2023. It will run from 10 AM EST to 2 PM EST**. We believe this will cover a time range across EMEA, the US East, and the US West. We hope this will be a long enough period that it will break some users' builds/CI systems, and users will notice thus being encouraged to upgrade.

This will be implemented by temporarily removing the image tags from the Bionic builder images (full, base, and tiny). Once the brownout is finished, the image tags will be restored. This will fix user builds.

We hope this will be sufficient to alert any users still on the Bionic Builder.

## What Does This Mean for You?

### Check your Desktop

All users should check their systems and confirm the builder that they are using

With `pack`, users should run `pack config default-builder`. It should say that they are using a Jammy builder.

```
> pack config default-builder
The current default builder is paketobuildpacks/builder-jammy-base
```

If it does not, then run `pack config default-builder paketobuildpacks/builder-jammy-base` (or `-full` or `-tiny`, based on your needs).

### Check your CI pipelines

Users should also check their CI pipelines, build scripts, and other automations for the usage of the Bionic Builders. 

- Users may call `pack build` with the `-B` or `--builder` flag to set a builder. 
- Users may include a `project.toml` file which might have a `builder = <builder>` property set in the `[build]` block to set a builder.
- It is less likely, but users can also call `pack config default-builder <builder>` to set a builder in CI.

Users may also want to check for the names of the older builders in your CI/pipelines:

- `paketobuildpacks/builder:tiny`
- `paketobuildpacks/builder:base`
- `paketobuildpacks/builder:full`
- `paketobuildpacks/builder:buildpackless-tiny`
- `paketobuildpacks/builder:buildpackless-base`
- `paketobuildpacks/builder:buildpackless-full`

Any usage of these builders should be replaced with the equivalent Jammy builder.

- `paketobuildpacks/builder-jammy-tiny:latest`
- `paketobuildpacks/builder-jammy-base:latest`
- `paketobuildpacks/builder-jammy-full:latest`
- `paketobuildpacks/builder-jammy-buildpackless-tiny:latest`
- `paketobuildpacks/builder-jammy-buildpackless-base:latest`
- `paketobuildpacks/builder-jammy-buildpackless-full:latest`

### Upgrade your Spring Boot Apps

[Spring Boot Users will continue to default to the Bionic Stack until Spring Boot 3.2](https://spring.io/blog/2023/09/22/paketo-buildpacks-bionic-end-of-support). Please read the Spring Blog post and perform the actions listed there. That will upgrade your app to use the Jammy stack.

Please also consider upgrading to Spring Boot 3.2 when it is available. Spring Boot 3.2+ will default to using the Jammy builders.

### Help! I need Bionic

We hope that everyone will be able to upgrade, but we recognize that there may be cases where a user cannot upgrade or cannot upgrade immediately.

For these users:

1. Your builds will break during the brownout. Don't panic! They will start working again when the brownout is over. Grab your towel or a [Pan Galactic Gargle Blaster](https://en.wikipedia.org/wiki/Zaphod_Beeblebrox) and wait it out.
2. When the brownout is over, you will need to switch the image tag on your builder to the following:

   - `paketobuildpacks/builder:tiny-unsafe`
   - `paketobuildpacks/builder:base-unsafe`
   - `paketobuildpacks/builder:full-unsafe`
   - `paketobuildpacks/builder:buildpackless-tiny-unsafe`
   - `paketobuildpacks/builder:buildpackless-base-unsafe`
   - `paketobuildpacks/builder:buildpackless-full-unsafe`

3. Starting Jan 1, 2024, we will permanently remove the original image tags (i.e. those without `-unsafe`) from the Bionic builder images (full, base, and tiny). If you have not switched to using the `-unsafe` tags, then your builds will be broken until you switch.


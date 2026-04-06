---
title: "Paketo Buildpacks 2025 User Survey Results"
date: "2026-04-02T14:14:44-05:00"
slug: paketo-buildpacks-2025-user-survey-results
author: dmikusa
---

Earlier this year, we ran the Paketo Buildpacks User Survey to better understand how people are using the project and what they'd like to see from it. We're excited to share the results and how we're going to incorporate your feedback.

Thank you to everyone who took the time to fill it out. Your feedback genuinely helps shape the direction of the project.

## Survey Results

### Overview

We received 18 responses from a broad mix of users, ranging from individual developers working on side projects to engineers at enterprise organizations. The diversity of use cases gives us a good cross-section of how Paketo Buildpacks is being used in the wild.

### Number of Applications

Users are building anywhere from 4 to 100 applications with Paketo Buildpacks. There's a noticeable cluster at the lower end (4–6 apps), reflecting smaller teams or individual projects, but a healthy number of respondents are running at much larger scales — 20, 25, 30, and even 50–100 applications. Paketo Buildpacks is serving both early-stage users and large-scale enterprise deployments, and we need to keep both audiences in mind as we evolve the project.

### Language Support

Java, .NET Core, and Go are the primary languages in use. Java in particular stands out, not just in usage, but also in terms of the feature requests we received in the survey. Java users are among the most active and engaged segment of the community.

One respondent also called out **Zig** as a language they'd like to see Paketo support. Zig continues to mature as a systems programming language and gain broader adoption, so we'll continue to track it. If you're interested in seeing a Zig buildpack, we'd love to [hear from you](https://github.com/orgs/paketo-buildpacks/discussions/categories/general).

### Base Images and Stacks

This section produced some of the clearest signal in the entire survey. Users want **secure, minimal base images**.

The top results:

- **Chainguard Wolfi** — highest interest at 38.5%
- **Distroless Base** — 30.8%
- **Alpine** and **Distroless Static** — 23.1% each

Ubuntu Jammy and Noble remain important and they will continue to be our primary option for users, including our own Ubuntu-based tiny & static base images. But the indication we're seeing from users is toward hardened, minimal images with smaller attack surfaces so we're planning to move in that direction.

We also received some feedback about increasing our options with UBI stacks, and that is another area where the project can grow. If you have thoughts about that, please add some feedback here.

### Architecture Support

AMD64/x86_64 remains dominant and rated as highly important by the vast majority of respondents. ARM64 is clearly gaining ground though, with a significant number of users rating it as important to them. We've been adding support for ARM64 to Paketo buildpacks (Java buildpacks were completed first) and are getting close to having all of our buildpacks ARM64 compatible. For example, we've recently added ARM64 initial support for Ruby & PHP. We'll continue adding support until we support for ARM64 reaches pairity with AMD64.

### Build Tools

The `pack` CLI leads at 61.1%, which makes sense as it's the most direct way to use Paketo Buildpacks. The [Spring Boot Maven plugin](https://docs.spring.io/spring-boot/maven-plugin/build-image.html) (44.4%) and [Gradle plugin](https://docs.spring.io/spring-boot/gradle-plugin/packaging-oci-image.html) (38.9%) are also heavily used, reinforcing how central the Java/Spring ecosystem is to our community. [kpack](https://buildpacks.io/docs/for-platform-operators/how-to/integrate-ci/kpack/) comes in at 16.7%, and small but meaningful minorities are integrating through Tekton, Jenkins, GitLab, and GitHub Actions.

### How Users Get News

The Paketo Blog is the preferred channel at 55.6%, with Paketo Slack second at 27.8%. Twitter, LinkedIn, Mastodon, and CNCF Slack each have smaller but present followings.

If you're not already subscribed via RSS, point your reader at [https://blog.paketo.io/index.xml](https://blog.paketo.io/index.xml). And if you prefer live conversation, come find us in [Paketo Slack](https://join.slack.com/t/paketobuildpacks/shared_invite/zt-2jayv12ro-eTP8AtcmvyIpEtlANfIb~g).

---

## Action Items from your Feedback

Survey feedback is only useful if it leads to action. We've identified four topics that came up repeatedly and that deserve dedicated community discussion. For each one, we've opened a GitHub Discussions thread where you can share your thoughts, ask questions, and — if you're up for it — help make it happen.

Paketo is an all-volunteer project. We don't have a dedicated team waiting to implement a roadmap on a schedule. What we do have is a group of people who care about the project and the time to work on things that matter to them. If any of these topics matter to you, the best thing you can do is participate in the discussions and where possible help by contributing code changes.

### Secure Base Images

[[Discussion Link]](https://github.com/orgs/paketo-buildpacks/discussions/405)

The survey was clear on this one. Users want hardened, minimal base images — Chainguard Wolfi, Distroless, and similar options are in high demand. We want to have a broader conversation about what this should look like for Paketo: which images to prioritize, what official support means, and how to structure the work.

If you're a user with security requirements you'd like to share, or someone who wants to help build and maintain a solution, come join the thread.

### SBOM Standardization with CycloneDX

[[Discussion Link]](https://github.com/orgs/paketo-buildpacks/discussions/407)

In the survey, we heard the need to standardize on CycloneDX as the SBOM format across all Paketo buildpacks. We understand that our present SBOM support is not perfect and want to do better. If you have experience with Paketo Buildpacks and SBOM, and you can share your experiences, we'd love to hear it.

### Production-Ready UBI Buildpacks

[[Discussion Link]](https://github.com/orgs/paketo-buildpacks/discussions/406)

Support for Red Hat's Universal Base Image (UBI) came up in the survey, particularly around pulling dependencies from custom mirrors using Red Hat subscriptions. We're interested in exploring this further, but we'd like to better understand what "production-ready" actually means for users in this space before committing to a direction. If you're running or planning to run Paketo Buildpacks on UBI, please share your environment and requirements in the thread. The more context, the better.

### A Cross-Stack Package Manager Buildpack

[[Discussion Link]](https://github.com/orgs/paketo-buildpacks/discussions/408)

We recently shipped an official `apt-buildpack` for installing packages into Ubuntu-based stacks. Users on RPM-based stacks (like UBI or Amazon Linux) don't have an equivalent. We believe there's room for an official, Go-based Paketo buildpack that supports installing libraries across multiple package managers (i.e. `apt`, `rpm`, and potentially others) in a consistent way. If you're have thoughts on this topic or you are interested in helping design or implement this, especially if you have experience with RPM-based stacks, come join the conversation.

---

## Smaller Issues

A couple of more targeted issues came up in the survey feedback as well. I wanted to respond to this as well.

1. There's an existing open issue around native image support for include/exclude of files: [paketo-buildpacks/native-image#280](https://github.com/paketo-buildpacks/native-image/issues/280).
2. There's a  open issue around adding support to the Java memory calculator for virtual thread support: [paketo-buildpacks/jvm-vendors#33](https://github.com/paketo-buildpacks/jvm-vendors/issues/33).

If either of these affects you and you're interested in contributing, please take a look and reach out on [Paketo Slack](https://join.slack.com/t/paketobuildpacks/shared_invite/zt-2jayv12ro-eTP8AtcmvyIpEtlANfIb~g) or comment directly on the issue. We are looking for help to implement these features which we know are important to our user base.

---

From the entire Paketo Steering Committee & all of our maintainers, thanks again to everyone who filled out the survey! We're happy to hear from you and we're looking forward to the conversations ahead.

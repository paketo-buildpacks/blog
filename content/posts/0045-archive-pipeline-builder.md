---
title: Upcoming Archival of Pipeline Builder
date: "2026-11-07T11:31:50-05:00"
slug: archive-pipeline-builder
author: dmikusa
---

The `pipeline-builder` project has served the Java Maintainers team well over the last six years. Unfortunately, it has gotten increasingly difficult to maintain two CI pipelines. Modern-day GitHub Actions are fraught with peril and require a lot of hardening to be used safely in a large public project (see what happened with Trivy, Axios, and Tanstack). As such, a project-wide decision was made to migrate all of our projects to the `github-config` CI project and focus all of our efforts on making that a secure and efficient way to produce images for our users.

The migration to `github-config` has been completed in Paketo so we are announcing the imminent archival of the pipeline-builder project. The project will be archived at the end of 2026 (end of December 2026). We do not anticipate pushing any more updates or cutting any more releases before that time.

If you are using `pipeline-builder`, we suggest forking the project so you can continue using it and updating it on your own. It does need updates to the tooling and actions used, or those will eventually stop working as GitHub phases out support for old actions & runtimes.

The `github-config` project is not a drop-in replacement, nor is it really intended to be used outside Paketo. It is our internal CI system, and all focus is on making it work for us. You’re welcome to use it, fork it, and copy scripts as examples; it’s OSS so you have that right. We will not accept outside feature requests though, as we're building a CI system for us, not the general public. This notice is to simply say that we reserve the right to change it to fit the project team's needs at any time and without notice.

If you have any questions, please reach out on [Slack](https://join.slack.com/t/paketobuildpacks/shared_invite/zt-2jayv12ro-eTP8AtcmvyIpEtlANfIb~g) or in [Discussions](https://github.com/orgs/paketo-buildpacks/discussions).

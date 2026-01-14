---
title: Paketo Buildpacks 2025 Year in Review
date: "2026-01-14T13:14:44-05:00"
slug: paketo-buildpacks-2025-year-in-review
author: dmikusa
---

As we welcome 2026, it's time to reflect on what has been a great year for the Paketo Buildpacks project. From all of us on the steering committee, we want to extend our gratitude to every contributor, maintainer, and user who has helped grow the project throughout 2025. Whether you've been with us from the beginning or just discovered Paketo Buildpacks this past year, your engagement and feedback have been the driving force behind our continued growth and innovation. Join us as we look back at the milestones and successes of the project in 2025.

## Achievements in 2025

One of our biggest accomplishments in 2025 was significantly expanding ARM64 support across the Paketo ecosystem. The Web Servers, Go, Dotnet, and Python buildpacks all gained ARM64 compatibility this year, joining the Java and Utilities buildpacks which added support previously. This expansion means developers can now build and deploy applications on ARM-based infrastructure with confidence, whether they're targeting cloud platforms, edge computing environments, or Apple Silicon development machines.

We also broadened our platform support by adding both Ubuntu Noble and UBI9 stacks and builders to our offering. This expansion gives teams more flexibility in choosing the base images that best fit their organizational requirements, whether that's aligning with specific compliance needs, enterprise support agreements, or preferred Linux distributions. Having multiple stack options ensures that Paketo Buildpacks can integrate seamlessly into diverse development and production environments.

In a first for the project, we launched the Paketo Buildpacks user survey in 2025! This initiative represents an important step in our community engagement, allowing us to gather direct feedback from users about their experiences, needs, and priorities. If you haven't already participated, this is your last chance. The survey closes at the end of day on January 16th, 2026. Your input will directly shape the project's roadmap and priorities for the coming year. You can find the survey [here](https://blog.paketo.io/posts/paketo-buildpacks-user-survey-2025).

Last but not least, our language-specific buildpacks saw tremendous progress throughout the year, keeping pace with the latest releases and features across multiple ecosystems. The Dotnet buildpack added support for Dotnet 10, while Java users gained access to Java 25, Spring Boot 4, and an exciting new AOT cache feature. Python developers can now use versions 3.13 and 3.14, Go support was extended to versions 1.24 and 1.25, and Node.js buildpacks added support for Node 24. Even the Ruby buildpack, despite having limited maintainer capacity, managed to add support for Ruby 3.4. These updates ensure that Paketo users can take advantage of the latest language features, performance improvements, and security patches as soon as they're available.

## Maintainers

Of course, none of these achievements would have been possible without the dedicated individuals who maintain our buildpacks. We want to send out a special thanks to our team of maintainers.

I can't emphasize this enough, these are the folks that keep the Paketo project running. They ensure the buildpacks you're using day-to-day get released in a timely manner, review pull requests, triage issues, and keep our dependencies up to date. Without them, this project could not continue.

Big thanks to the maintainer teams:

| Team        | Maintainers                                                               |
| ----------- | ------------------------------------------------------------------------- |
| APM Tools   | anthonydahanne, dmikusa, pivotal-david-osullivan                          |
| Builders    | mhdawson, pacostas, jericop, ForestEckhardt                               |
| Content     | anthonydahanne, ForestEckhardt                                            |
| Dotnet      | dmikusa, ForestEckhardt                                                   |
| Go          | jericop, ForestEckhardt                                                   |
| Java        | anthonydahanne, dmikusa, jericop, pivotal-david-osullivan, kevin-ortega   |
| Node.js     | mhdawson, pacostas                                                        |
| Python      | sgaist, jericop                                                           |
| Rust        | dmikusa, ForestEckhardt                                                   |
| Stacks      | mhdawson, pacostas, jericop                                               |
| Tooling     | pacostas, jericop, ForestEckhardt, modulo11, nicolasbender                |
| Utilities   | anthonydahanne, dmikusa, jericop, ForestEckhardt, pivotal-david-osullivan |
| Web Servers | dmikusa, ForestEckhardt                                                   |
| Ruby        | <none>                                                                    |
| PHP         | <none>                                                                    |

## Releases

The impact of our maintainer teams' dedication is perhaps best illustrated by looking at the sheer volume of releases they've shipped throughout 2025. These numbers represent not just code changes, but consistent, reliable delivery of improvements and updates to our users.

| Repository                    | Release Count |
| ----------------------------- | ------------- |
| paketo-buildpacks/python      | 58            |
| paketo-buildpacks/nodejs      | 57            |
| paketo-buildpacks/web-servers | 53            |
| paketo-buildpacks/go          | 51            |
| paketo-buildpacks/dotnet-core | 48            |
| paketo-buildpacks/java        | 25            |
| paketo-buildpacks/ruby        | 8             |
| paketo-buildpacks/php         | 2             |

Five of these eight teams have basically shipped weekly releases, with another shipping by-weekly releases. This is a tremendous effort from our **all volunteer** team. Thank you all so much!

## Contributions

While our maintainers keep the project running, they're supported by a broader community of contributors whose efforts deserve equal recognition. We're incredibly grateful for the dedication and hard work of everyone who has helped push the project forward throughout the year. We appreciate every pull request, since every single contribution, big or small, has made a meaningful impact on the project.

The numbers below tell the story of our collective effort, but they represent so much more than just code changes. Behind each contribution is someone who took time from their day to help improve Paketo Buildpacks for the entire community. We want to recognize and thank each of these amazing individuals who have made 2025 such a productive year:

| Contributor (GitHub Username) | PR Count |
| ----------------------------- | -------- |
| pacostas                      | 260      |
| dmikusa                       | 129      |
| jericop                       | 60       |
| anthonydahanne                | 47       |
| ZephireNZ                     | 31       |
| mhdawson                      | 22       |
| nicolasbender                 | 16       |
| modulo11                      | 10       |
| miller79                      | 8        |
| c0d1ngm0nk3y                  | 8        |
| TheSuperiorStanislav          | 7        |
| pbusko                        | 5        |
| kiril-keranov                 | 5        |
| sgaist                        | 4        |
| robdimsdale                   | 4        |
| kevin-ortega                  | 4        |
| loewenstein-sap               | 3        |
| jnodorp-jaconi                | 3        |
| tomkennedy513                 | 2        |
| SaschaSchwarze0               | 2        |
| RealCLanger                   | 2        |
| mdipirro                      | 2        |
| krzysdabro                    | 2        |
| slandath                      | 1        |
| silvestre                     | 1        |
| mzuber                        | 1        |
| mtatheonly                    | 1        |
| MischaFrank                   | 1        |
| matejvasek                    | 1        |
| marinedayo                    | 1        |
| KrawczowaKris                 | 1        |
| kimkuan                       | 1        |
| jmonteiro                     | 1        |
| jaspreetssethi                | 1        |
| HeavyWombat                   | 1        |
| gauron99                      | 1        |
| fxshlein                      | 1        |
| cslauritsen                   | 1        |
| cmoulliard                    | 1        |
| christopherclark              | 1        |
| bugbounce                     | 1        |
| bitgully                      | 1        |
| arjun024                      | 1        |
| Alchemik                      | 1        |
| AamnaZahid                    | 1        |
| a1flecke                      | 1        |

## Looking Ahead: Opportunities to Get Involved

As we celebrate these accomplishments, we also want to be transparent about where the project needs support going forward. The Ruby and PHP buildpacks, as you may have noticed in the release counts above, have fallen behind the pace of other language teams. We love these buildpacks and want to continue producing them, but the reality is that we currently don't have dedicated volunteer maintainers for either of these projects.

We also have a number of maintainer teams that we believe we'll need some help as we move through 2026. Those include the Node.js team, the Rust team, the Dotnet team, the Go team, and the Web Servers team. These teams have or will soon have only a single maintainer, and for project continuity, we like to have at least two maintainers on a project.

This is not all though. If you ❤️ one of the languages not not listed as needing help, we still welcome your contributions. We like to target having *at least* two maintainers on a project, with more being absolutely welcome.

We also have a few cross team efforts that we're hoping to complete in 2026, which include changes to our CI system and upgrades to the core buildpack libraries (written in Go).

If you're a fan of Paketo and you're interested in helping, please reach out. You **can make a meaningful change** to the Paketo project. It doesn't require working full time, and can often be done in as little as an evening. For more info, please checkout the [post I wrote previously on the subject](https://blog.paketo.io/posts/paketo-buildpacks-contributors-wanted/), or reach out on the [Paketo Slack](https://join.slack.com/t/paketobuildpacks/shared_invite/zt-2jayv12ro-eTP8AtcmvyIpEtlANfIb~g).

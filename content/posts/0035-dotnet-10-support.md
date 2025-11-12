---
title: Paketo Buildpacks add support for .NET 10
date: "2025-11-12"
slug: paketo-dotnet-10-support
author: bmcdonald
---

## .NET 10 is now available

The Paketo Buildpacks team is excited to announce that the same day .NET 10 was released, it is now available to
be used in your Paketo Buildpacks builds!

All you need to do is update the target framework to `net10.0` in your `.csproj` file, and the buildpack will
automatically use the latest SDK and ASP.NET Core runtime.

Please reach out to the team if you have any questions.

### Supported .NET versions

In addition to .NET 10, the Paketo Buildpacks will continue to support both .NET 8 and .NET 9 until at least their EOL
date in November 2026.

### Ubuntu Noble support

The Paketo Buildpacks for .NET now also support Ubuntu 24.04 aka Noble.

For now, this is only works when using the builder `paketo-buildpacks/ubuntu-noble-builder-buildpackless` and then
specifying the buildpack with `--buildpack paketo-buildpacks/dotnet-core`.

Very soon, the Paketo Buildpacks for .NET will also support ARM64, and will be available in
`paketo-buildpacks/ubuntu-noble-builder` which includes automatic detection including other languages like Java and NodeJS.

For more information, check out [this blog post about the new builders](https://blog.paketo.io/posts/builders-stacks-base-images-restructure/).

---
title: Bionic End of Support
date: "2023-07-28"
slug: bionic-eos
author: swigmore
---

As of May 31, 2023, Ubuntu 18.04 (Bionic Beaver) is [out of
support](https://ubuntu.com/blog/18-04-end-of-standard-support) for open-source
customers.

As a result, Paketo will stop supporting Bionic in the project. If you
currently depend on our Bionic-based offerings, this blog post will contain
all of the relevant information about what this means and how to migrate.

## End of Support Details

The removal of Bionic support in Paketo was announced and ratified in the
[Bionic End of Support RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0057-bionic-eos.md).
The following stacks and builders will no longer be supported, meaning
  - (1) we will no longer publish updates (meaning no CVE fixes),
  - (2) the related repositories have been archived, and
  - (3) the images will be removed from Docker and GCR in accordance with our [image retention policy](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0046-image-retention-policy.md), which states we'll retain them for at least two years.


  * [Bionic Tiny Stack](https://github.com/paketo-buildpacks/bionic-tiny-stack)
  * [Bionic Tiny Builder](https://github.com/paketo-buildpacks/tiny-builder)
  * [Bionic Tiny Buildpackless Builder](https://github.com/paketo-buildpacks/buildpackless-tiny-builder)

  * [Bionic Base Stack](https://github.com/paketo-buildpacks/bionic-base-stack)
  * [Bionic Base Builder](https://github.com/paketo-buildpacks/base-builder)
  * [Bionic Base Buildpackless Builder](https://github.com/paketo-buildpacks/buildpackless-base-builder)

  * [Bionic Full Stack](https://github.com/paketo-buildpacks/bionic-full-stack)
  * [Bionic Full Builder](https://github.com/paketo-buildpacks/full-builder)
  * [Bionic Full Buildpackless Builder](https://github.com/paketo-buildpacks/buildpackless-full-builder)

## Migration Path

We strongly recommend migrating your workloads from Bionic to our Ubuntu 22.04
(Jammy Jellyfish) based offerings. Each Bionic stack and builder listed above
has a more or less 1:1 Jammy equivalent available in the project.

If you are using the `pack` CLI version v0.29.0 or prior for your builds, you
can set the default builder for your builds to Jammy via the `pack config default-builder` command:
```
pack config default-builder paketobuildpacks/builder-jammy-base
```
You may notice that current versions of `pack` still suggest using the Bionic builder if you run `pack builder suggest`. This is out-of-date and Paketo is waiting on a new release of `pack` which will correctly suggest the Jammy builders. Please ignore the output of `pack builder suggest` for now and use the builder listed above.
Here is a complete list of the new builders:
- `paketobuildpacks/builder-jammy-full`
- `paketobuildpacks/builder-jammy-base`
- `paketobuildpacks/builder-jammy-tiny`
- `paketobuildpacks/builder-jammy-buildpackless-full`
- `paketobuildpacks/builder-jammy-buildpackless-base`
- `paketobuildpacks/builder-jammy-buildpackless-tiny`
- `paketobuildpacks/builder-jammy-buildpackless-static`
If you are using Spring Boot build tools, you will need to set the builder in your `pom.xml` if you're using Maven or in your `build.gradle` if you're using Gradle. For Maven, instructions [see here](https://docs.spring.io/spring-boot/docs/3.1.2/maven-plugin/reference/htmlsingle/#build-image.examples.custom-image-builder). For Gradle instructions, [see here](https://docs.spring.io/spring-boot/docs/3.1.2/gradle-plugin/reference/htmlsingle/#build-image.examples.custom-image-builder). Use one of the builder's listed above, like `paketobuildpacks/builder-jammy-base`.
## Alternatives

If for some reason you cannot migrate away from Bionic right away, you can create your own
custom stack. While the Paketo project will no longer support Bionic, you can
support this use-case yourself, although it's not recommended over moving to Jammy.

In order to do this, you'll need to look into [Ubuntu ESM
support](https://ubuntu.com/security/esm) in order to get access to extended
Ubuntu Bionic package support. Then, you can follow the [Paketo
documentation](https://paketo.io/docs/howto/create-custom-stack/) on how to
create a custom stack.

## Questions?
If you have any questions, feel free to reach out to us in [Paketo
slack](https://join.slack.com/t/paketobuildpacks/shared_invite/zt-2jayv12ro-eTP8AtcmvyIpEtlANfIb~g):
* Stacks-related questions: [#stacks](https://paketobuildpacks.slack.com/archives/C03K61JJ57A)
* Builder-related questions: [#builders](https://paketobuildpacks.slack.com/archives/C01E8A03W9F)
* General discussion: [#general](https://paketobuildpacks.slack.com/archives/CU8RVQZ1R)


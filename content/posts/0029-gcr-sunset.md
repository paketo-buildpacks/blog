---
title: Paketo Buildpacks Sunsets GCR Images
date: "2025-03-28"
slug: paketo-gcr-registry-sunset
author: dmikusa
---

## Urgent News

We have important news regarding project infrastructure that requires your immediate attention. The Paketo Buildpacks GCP (Google Cloud Platform) project is scheduled to be shutdown in the near future, likely within the next two week.

I apologize that we cannot provide an exact date, as we do not have one ourselves. We were notified recently that our sponsor who was paying the bills for GCP will be halting that sponsorship. As such, we will no longer be storing Paketo images on GCR.

While this might sound concerning, the plan to migrate away from GCP/GCR has been in the works for a long time and most of the heavy lifting has been done for a while. Paketo made a strategic decision years ago to move image hosting to Docker Hub, and all of our buildpack assets have been publishing to Docker Hub for well over a year.

## Remaining Work for Paketo

To complete the transition, the project is focusing on two remaining areas:

1. **Documentation Cleanup**: We know that our docs mention GCR in places. We're working to update these to reference Docker Hub. Please bear with us as we get things updated.

2. **Pipeline Updates**: We're in the process of updating our continuous integration pipelines to stop publishing to GCR. As mentioned before, we have been publishing primarily to Docker Hub, but we had also continued to publish images to GCR. At this time, we'll simply stop publishing to GCR. We hope to get to all of these before the deadline, and are working as fast as possible to accomplish this. If you see any broken pipelines due to this change, please open an issue on Github and report them.

## Action Items for You

1. **Check your pipelines & build scripts**. Look for references to `gcr.io`. If you are referring to an image, for example `gcr.io/paketo-buildpacks/bellsoft-liberica`, you need to make two changes to update that. First, change `gcr.io` to `docker.io`. Second, change `paketo-buildpacks` to `paketobuildpacks`. Docker Hub doesn't support `-`, so that needs to be removed. Alternatively, you can use a [Buildpacks Registry](https://registry.buildpacks.io/) reference. The `pack` cli supports `paketo-buildpacks/bellsoft-liberica` or `urn:cnb:registry:paketo-buildpacks/bellsoft-liberica`. This will look up the buildpack in the registry and load the image to use from there. Note: Spring Boot build tools do not support registry lookup.

2. **Lend a hand and help**. If you have some spare cycles, please jump in and help us with the updates above. Send PRs to help update documentation or open issues to identify problems. It all helps and is appreciated.

3. **Spread the word**. Please help spreading awareness about this infrastructure change. Please share this article on your social networks or with anyone you know that's using Paketo buildpacks and may be affected.

4. **Reach out**. If you have any questions or concerns about the migration, please reach out on our [discussions page](https://github.com/orgs/paketo-buildpacks/discussions).

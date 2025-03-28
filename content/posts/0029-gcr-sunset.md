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

1. **Check your pipelines & build scripts**. Make sure that you are not referencing `gcr.io` for any Paketo images. You can update to `docker.io` or you in most cases you can leave off the image registry and the tooling will use the [Buildpacks Registry](https://registry.buildpacks.io/) to look up the correct images.

2. **Lend a hand and help**. If you have some spare cycles, please jump in and help us with the updates above. Send PRs to help update documentation or open issues to identify problems. It all helps and is appreciated.

3. **Spread the word**. Please help spreading awareness about this infrastructure change. Please share this article on your social networks or with anyone you know that's using Paketo buildpacks and may be affected.

4. **Reach out**. If you have any questions or concerns about the migration, please reach out on our [discussions page](https://github.com/orgs/paketo-buildpacks/discussions).

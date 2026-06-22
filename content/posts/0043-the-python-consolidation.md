---
title: The Python consolidation (and deprecation)
date: "2026-05-08T17:10:21+02:00"
slug: the-python-consolidation
author: sgaist
---

### TL;DR

What actually changed ?

There are less buildpacks doing the same job as before.
Eight have been replaced by only two.

What does it change for you ?

From a pipeline point of view: it should not change anything. The detection works
the same, the results are the same. From a maintenance point of view: you, and
the maintainers, will have less to worry about.

See [the plan](/posts/the-python-consolidation#the-plan) for more details.

## The consolidation

### Why

The [Idiap Research Institute](https://www.idiap.ch) has been a long time user of
buildpacks through either explicit use of the pack command, GitLab Auto DevOps
pipelines or more recently, the local deployment of the [Renku platform](https://renkulab.io/)
that was created by the [Swiss Data Science Center](https://datascience.ch/) and
is now co-developed with Idiap. This platform offers the option to create a
development environment out of your source code through
[Shipwright](https://shipwright.io/) using a build strategy based on the
buildpack's lifecycle.

Idiap's researchers, but also from other academic centers, have adopted uv as
well as Pixi as respectively package and environment managers. However, Paketo's
Python buildpacks supported neither at the time. Bringing the researchers to the
platform meant uv and Pixi support was a must have.

Looking at the available implementation, things did not seem complicated. Pixi is
close to miniconda and uv is somewhere in between poetry and pip (from a
buildpack point of view). So, code wise, nothing really hard. I wrote a PoC for
each of them with the long term goal of donating these new buildpacks to Paketo
so the whole community could benefit. [Issue 977](https://github.com/paketo-buildpacks/python/issues/977)
in the `python` buildpack repository was also proof that more people where
interested to have them as options.

Something lurking in the back of my brain made me think again about this
strategy... So I did some math:

- For both uv and Pixi, two buildpacks are required:
  - One to install the package manager
  - One to use the package manager
- `python-start` must be updated to support the new package managers
- `python` must be updated to add the new buildpacks and, very important, add all
  the permutations to handle them

This meant, in fact, four additional buildpacks to maintain and a higher degree
of complexity for the `python` buildpack.

While most of the mundane tasks such as dependency or tooling update and docker
image creation have been nicely automated, the realty is that there would be
four additional repositories to watch for.

All in all, not the nicest thing for the maintainers. There had to be a better
way. While walking around eating an apple and thinking about it, an idea came:
why not bring them all under one roof ?

### How

Their logic was mostly the same: check for some specific configuration file and
if found, install the corresponding package manager. This should be doable
within one buildpack rather than spread around multiple.

After some preliminary exploration work, the creation of [Paketo Python RFC 0008](https://github.com/paketo-buildpacks/rfcs/blob/main/text/python/0008-consolidate-python-package-managers.md): Consolidate python package managers
was the real starting point.

Let's summarize the main items:

- Smash together all package managers buildpacks -> two in place of eight
  (or twelve if you count the new uv and Pixi buildpacks)
- Simpler `python` buildpack -> less permutations required
- Less overhead for maintainers in the long term
- Easier for contributors to participate
- Easier for buildpack users

This resulted in the creation of:

- [python-package-managers-install](https://github.com/paketo-buildpacks/python-package-managers-install/)
- [python-package-managers-run](https://github.com/paketo-buildpacks/python-package-managers-run/)

that originated in Idiap's GitHub organization and were later transferred to
Paketo once they were deemed mature enough. The former contains all the code
required to install a Python package manager and the latter, the code that makes
use of them.

Once the original set of buildpacks was implemented, uv and Pixi were added. It
was way easier as only two buildpacks needed to be updated (not taking into
account `python-start` and `python`). One other important point is that now,
more package managers are using `python.toml` where only poetry was doing it
when its buildpack was created. Having them all together allows for better
handling of the detection when that file is present.

So now, after adding uv and Pixi support to `python-start` as well as `python`,
there is one last thing to do: get rid of the old buildpacks!

## The deprecation

Since we have now everything under two buildpacks, we can say goodbye to the old
ones. However, this won't happen abruptly so that you, as Paketo users, have
time to ensure your workflows are running smoothly and catch regressions if any
has crept in.

### The plan

For the next two months, the switch to the new buildpacks is an opt in. Set the
`BP_ENABLE_PACKAGE_MANAGERS` environment variable to `true` when building your
images and the detection phase will require and provide the new buildpacks.

After this period, we will switch the flag so you can still opt out if you need
more time to do tests.

Finally, after six more months, we will remove the flag, remove the old
buildpacks from the main `python` buildpack and archive the repositories.

So to summaries:

- 2 months opt-in
- 6 months opt-out
- removal of the old buildpacks

The Docker images will automatically get deleted over time by policy.

In case of issues, you are welcome to contact the maintainers either on Slack or
open an issue in the corresponding GitHub repositories.

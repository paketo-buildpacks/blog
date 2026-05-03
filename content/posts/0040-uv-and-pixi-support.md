---
title: uv and Pixi Now Available
date: "2026-04-29T20:53:59+02:00"
slug: uv-and-pixi-now-available
author: sgaist
---

The Python package manager ecosystem is not set in stone. Most people know the
big players such as pip, its brother pipenv, after which came poetry, and from
the scientific world conda.

Sounds like an already impressive list of options. However this did not stop the
Pythonistas from trying to innovate on that subject.

These past years have seen quite a lot of movement with goals such as better
performance, reproducibility and ease of use.

## Pixi

Building on top of the Conda ecosystem, [pixi](https://github.com/prefix-dev/pixi)
was officially released in 2023. Beside
speed, it provides automated environment file update as well as lock file
generation into its workflow so you don't have to do it yourself.

## uv

Taking on the foundation layed out by pip and its friends, [uv](https://github.com/astral-sh/uv)
was officially released in 2024 with the main goal of providing a super fast and
versatile tool to replace them all.

## What about Paketo Buildpacks?

Starting with Paketo Python Buildpack release [2.45.0](https://github.com/paketo-buildpacks/python/releases/tag/v2.45.0), both `uv` and `pixi` are available as package manager
for your Python projects. In the same spirit as their sibling, you can create
projects using these tools and then point `pack` to them as usual to generate
OCI/Docker images for your needs.

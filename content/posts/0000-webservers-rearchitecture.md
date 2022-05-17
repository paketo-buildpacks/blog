---
title: Introducting new ways to bring your static files to the cloud
date: "2022-05-16"
slug: webservers-rearchitecture
author: joshuatcasey
---

# Introducing the Paketo Web Servers Buildpack

The Paketo team is pleased to introduce the [Web Servers buildpack](https://github.com/paketo-buildpacks/web-servers), available in the full builder as of [version 0.2.74](https://github.com/paketo-buildpacks/full-builder/releases/tag/v0.2.74).

This buildpack allows you to serve static content using the popular NGINX or HTTPD web servers, with a variety of utilities for ease of use. Whether you have static files and a conf file that you want to package in an image, or you need to transform your dynamic content into static files and want the buildpack to generate the necessary conf file, the Web Servers buildpack has you covered.

If the buildpack does not have the capability you need, please let us know on the [Paketo Slack](https://slack.paketo.io/) or by [filing an issue](https://github.com/paketo-buildpacks/web-servers/issues/new).

While Paketo has had the [NGINX](https://github.com/paketo-buildpacks/nginx) and [HTTPD](https://github.com/paketo-buildpacks/httpd) buildpacks for some time, bringing them together in the new Web Servers buildpack enables the exciting capabilities listed below.

## Using `npm` and `yarn` to generate static content

You can now easily deploy your dynamic frontend application as static content, since the Web Servers buildpack allows you to execute arbitrary `npm` or `yarn` scripts by using the [`node-run-script`](https://github.com/paketo-buildpacks/node-run-script) buildpack.
Just add appropriate scripts in `package.json` and use `BP_NODE_RUN_SCRIPTS` to tell the buildpack which scripts to run.

This allows you to create your frontend application in the javascript framework of your choice and then serve it up using either `HTTPD` or `NGINX`.
Since `npm` and `yarn` can be used in the absence of a javascript framework, you can also use this capability to download dependencies, transpile javascript, assemble content, or do anything necessary to translate your source material into static files.

## Zero-Config static sites

What if your app is simple enough that you don't need a custom `httpd.conf` or `nginx.conf`?
Use `BP_WEB_SERVER` to both indicate your server preference and signal to the appropriate buildpack to generate a server config file.

The generated config file can be influenced by various environment variables and service bindings to accomplish common configuration options, so you can:

- Use a custom directory for static files
- Enable push-state routing
- Force HTTPS connections
- Require basic auth

See [How to Build Web Servers with Paketo Buildpacks](https://paketo.io/docs/howto/web-servers/) for configuration details.
The [`No Config File Sample`](https://github.com/paketo-buildpacks/samples/tree/main/web-servers/no-config-file-sample) also has working examples of each of these configurations.

These customizations are meant to work out of the box for both `HTTPD` and `NGINX`. In case you need more details, take a look at the default configuration files (see [`HTTPD`](https://github.com/paketo-buildpacks/httpd/blob/main/default_conf.go) and [`NGINX`](https://github.com/paketo-buildpacks/nginx/blob/main/default_conf.go)).

## Additional utilities

In addition to the new application types described above, utility buildpacks added to the toolchain allow enhancing the images built to server your static files. This enables you to:

- Add CA certificates to the system truststore at build and runtime using the [`ca-certificates`](https://github.com/paketo-buildpacks/ca-certificates/) buildpack
- Set custom start commands using the [`procfile`](https://github.com/paketo-buildpacks/procfile/) buildpack
- Embed environment variables into the launch image using the [`environment-variables`](https://github.com/paketo-buildpacks/environment-variables) buildpack
- Add image labels to the launch image using the [`image-labels`](https://github.com/paketo-buildpacks/image-labels) buildpack
- Run any arbitrary script in `package.json` using the [`node-run-script`](https://github.com/paketo-buildpacks/node-run-script) buildpack, which enables you to transform your frontend application to static files (among many other possibilities)

## Samples

The [Paketo samples](https://github.com/paketo-buildpacks/samples/tree/main/web-servers) have several different application types that can be built into OCI images using Paketo buildpacks. These demonstrate common use cases such as:

- Serving static content with your own conf file, using either [HTTPD](https://github.com/paketo-buildpacks/samples/tree/main/web-servers/httpd-sample) or [NGINX](https://github.com/paketo-buildpacks/samples/tree/main/web-servers/nginx-sample)
- Serving static content with a buildpack-generated conf file, using `BP_WEB_SERVER` to select either [HTTPD](https://github.com/paketo-buildpacks/samples/blob/main/web-servers/no-config-file-sample/HTTPD.md) or [NGINX](https://github.com/paketo-buildpacks/samples/blob/main/web-servers/no-config-file-sample/NGINX.md) 
- Using NPM to build a React app into static files that can be [served by a web server](https://github.com/paketo-buildpacks/samples/tree/main/web-servers/javascript-frontend-sample), using `BP_WEB_SERVER` to select either `HTTPD` or `NGINX`

## Additional Reading

- [HowTo: Webservers](https://paketo.io/docs/howto/web-servers/)
- [HTTPD Reference Docs](https://paketo.io/docs/reference/httpd-reference/)
- [NGINX Reference Docs](https://paketo.io/docs/reference/nginx-reference/)
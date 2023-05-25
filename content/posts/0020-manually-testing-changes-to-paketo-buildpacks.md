---
title: Manually testing changes to a Paketo Buildpack
date: "2023-05-23"
slug: manually-testing-changes-to-paketo-buildpacks
author: anthonydahanne
---

*While this article is mainly about how to manually test Java family Paketo buildpacks, still, most of the instructions should work fine with other Paketo buildpacks; and even non Paketo buildpacks!*

Suppose that you started working on a new feature for the [`spring-boot`](https://github.com/paketo-buildpacks/spring-boot/) buildpack...

## Unit tests first 

Of course, during your development, you will make sure that you did not break any tests, regularly running `go test -v ./...` but you would also add new tests covering your new code; the classic combination `go test -v ./... -coverprofile=coverage.out` followed with `go tool cover -html=coverage.out` will allow you to verify you did not forget to test some errors or edge cases.

## Build and try the buildpack out before publishing it

If the buildpack you are working on provides some integration tests (or end to end tests), I suggest you try and add some use cases to those tests.

If not, then it's likely that the integration tests are running from the [`samples`](https://github.com/paketo-buildpacks/samples/) Github repository; have a look at this [Github Actions Workflow](https://github.com/paketo-buildpacks/samples/actions/workflows/test-all-samples.yml) for example.

### Build the Paketo Buildpack
Most Paketo buildpacks provide a `scripts/build.sh` build script that you can use to build the `detect` and `build` binaries (luckily the required `buildpack.toml` is already at the root of the project).

Just run the script and then check you have your buildpacks `bin` and `detect` executable files generated:

```shell
> scripts/build.sh
> ls bin                                                                                                                                 
build  detect helper main
```

### Mac arm64 note
If you're using a Mac arm64 (M1, M2, etc.), you may need to prepend `GOARCH="amd64"` to `scripts/build.sh` to specify that you want to build for `amd64` (it will help if you publish your image and then try to run it on a  Linux amd64 host); like this:

```shell
GOARCH="amd64" ./scripts/build.sh
```

If you don't, you could see such messages along the way:

```
===> DETECTING
======== Error: paketo-buildpacks/spring-boot@{{.version}} ========
fork/exec /cnb/buildpacks/paketo-buildpacks_spring-boot/{{.version}}/bin/detect: exec format error
```

### Run the Paketo Buildpack

If you try to build a [sample Java project](https://github.com/paketo-buildpacks/samples/tree/main/java/maven) using your newly build `spring-boot` buildpack:

```shell
pack build -p ~/workspaces/paketo-buildpacks/samples/java/maven applications/maven-app \
  -b .
```
`-p` providing the path of the application to build an image for.

`-b .` providing the path of our buildpack we just built (it will be looking for `bin/detect` and `bin/build` under this folder)

Well, you will get an error:

```
===> DETECTING
======== Results ========
pass: paketo-buildpacks/spring-boot@{{.version}}
Resolving plan... (try #1)
fail: paketo-buildpacks/spring-boot@{{.version}} requires jvm-application
```

With Paketo Buildpacks, you typically can't run just one buildpack; most of them are inter-dependent.

In our case, `spring-boot` buildpack `requires` a buildpack providing `jvm-application`; probably the `executable-jar` buildpack will provide it, but then this one will `require` a buildpack providing a JVM, etc.

#### Note about Pack build

You would think that `-b .` would just append our buildpack after the other detected buildpacks provided by the builder... Unfortunately, as soon as you use `-b` once, `pack` will only consider the buildpacks provided in the command line.

There's a way not to spend hours to find the right incantation: observing what the chain is when you let your builder pick the needed `buildpacks`:

```
pack build -p ~/workspaces/paketo-buildpacks/samples/java/maven applications/maven-app
[...]
===> DETECTING
10 of 26 buildpacks participating
paketo-buildpacks/ca-certificates   3.6.1
paketo-buildpacks/bellsoft-liberica 10.2.3
paketo-buildpacks/syft              1.30.0
paketo-buildpacks/maven             6.15.2
paketo-buildpacks/executable-jar    6.7.1
paketo-buildpacks/apache-tomcat     7.13.3
paketo-buildpacks/apache-tomee      1.7.1
paketo-buildpacks/liberty           3.7.1
paketo-buildpacks/dist-zip          5.6.1
paketo-buildpacks/spring-boot       5.25.0
[...]
```

Now, that we know the full chain, we just need to replace the original `paketo-buildpacks/spring-boot` with ours.

```
pack build -p ~/workspaces/paketo-buildpacks/samples/java/maven applications/maven-app \
  -b urn:cnb:builder:paketo-buildpacks/ca-certificates \
  -b urn:cnb:builder:paketo-buildpacks/bellsoft-liberica \
  -b urn:cnb:builder:paketo-buildpacks/syft \
  -b urn:cnb:builder:paketo-buildpacks/maven \
  -b urn:cnb:builder:paketo-buildpacks/executable-jar \
  -b urn:cnb:builder:paketo-buildpacks/apache-tomcat \
  -b urn:cnb:builder:paketo-buildpacks/apache-tomee \
  -b urn:cnb:builder:paketo-buildpacks/liberty \
  -b urn:cnb:builder:paketo-buildpacks/dist-zip \
  -b . 
[...]
===> DETECTING
paketo-buildpacks/ca-certificates   3.6.1
paketo-buildpacks/bellsoft-liberica 10.2.3
paketo-buildpacks/syft              1.30.0
paketo-buildpacks/maven             6.15.2
paketo-buildpacks/executable-jar    6.7.1
paketo-buildpacks/apache-tomcat     7.13.3
paketo-buildpacks/apache-tomee      1.7.1
paketo-buildpacks/liberty           3.7.1
paketo-buildpacks/dist-zip          5.6.1
paketo-buildpacks/spring-boot       {{.version}}
[...]  
```

with the `urn:cnb:builder:` prefix being used to indicate to `pack` that it should take the buildpack from the builder - otherwise you would force the addition of duplicate buildpacks to the end builder; not an issue but will slow down your build.  

Now our buildpack is picked up and our modified code will run. 

About the `{{.version}}`: this is what you get unless you set a specific version in your buildpack `buildpack.toml` - it's up to you to set a test version, it does not bother the rest of the toolchain to use the default `{{.version}}`)

Loggers and plain `fmt.Println` will help you check the values of your variables, etc.

### Publish your Paketo Buildpack changes

It's possible that when you're ready to make a Pull Request to the maintainers of the buildpack you're working on, the maintainers may ask questions on your changes.

If you want to ease their task, you can publish your buildpack with:

```
pack buildpack package anthonydahanne/spring-boot:fix-273 --publish

Successfully published package anthonydahanne/spring-boot:fix-273
```

In this example, I published the image to my free DockerHub account; of course you could use any other public registry.

Now in the PR comments, you can explain which sample you used to test your changes, along with a command-line that the maintainers can run immediately:

```
pack build -p ~/workspaces/paketo-buildpacks/samples/java/maven applications/maven-app \
  -b urn:cnb:builder:paketo-buildpacks/ca-certificates \
  -b urn:cnb:builder:paketo-buildpacks/bellsoft-liberica \
  -b urn:cnb:builder:paketo-buildpacks/syft \
  -b urn:cnb:builder:paketo-buildpacks/maven \
  -b urn:cnb:builder:paketo-buildpacks/executable-jar \
  -b urn:cnb:builder:paketo-buildpacks/apache-tomcat \
  -b urn:cnb:builder:paketo-buildpacks/apache-tomee \
  -b urn:cnb:builder:paketo-buildpacks/liberty \
  -b urn:cnb:builder:paketo-buildpacks/dist-zip \
  -b anthonydahanne/spring-boot:fix-273
```

🥰 Big kudos to you if you ever do that in your PR! 🥰

### Bonus chapter: testing how your Paketo Buildpack interact with the other Buildpacks

In an advanced feature / scenario, you could need to change one or several `PlanEntry`, and in this case, you would want to make sure your changes did not break other buildpacks.

In that case, you would want to test your buildpack with several samples; and it would become very difficult and lengthy to find out all the incantations for each case.

Enter the `composite` buildpacks: let's take the [`java`](https://github.com/paketo-buildpacks/java) buildpack for example.

A `composite` buildpack does not introduce any code; just a composition of `component` buildpacks.

If we continue with the example of a `spring-boot` buildpack change, we need to update those files:

**buildpack.toml** Make sure to change `spring-boot` dependency version
```
   [[order.group]]
     id = "paketo-buildpacks/spring-boot"
     optional = true
-    version = "5.25.0"
+    version = "{{.version}}"
```

**package.toml** Make sure to change the coordinates of the `spring-boot` buildpack to yours
```
[[dependencies]]
-  uri = "docker://gcr.io/paketo-buildpacks/spring-boot:5.25.0"
+  uri = "docker://anthonydahanne/spring-boot:fix-273"
[... end of file ...]
+
+[buildpack]
+uri = "."
```

Now you're good to go to publish your composite buildpack:

```
pack buildpack package anthonydahanne/java:fix-273 --config ./package.toml --publish

Successfully published package anthonydahanne/java:fix-273
```

And of course be able to use it:

```shell
pack build -p ~/workspaces/paketo-buildpacks/samples/java/maven applications/maven-app -b anthonydahanne/java:fix-273
```

##### Updating the builder itself

Now that we can test that the buildpacks inside the composite work well together, we could go even further creating a Paketo builder that would embed this composite and other buildpacks; in case we want to make sure our buildpack is not breaking non-related buildpacks.

Let's update the [`tiny` builder](https://github.com/paketo-buildpacks/builder-jammy-tiny) to include our composite.

**builder.toml** Make sure to change the java buildpacks reference
```
 [[buildpacks]]
-  uri = "docker://gcr.io/paketo-buildpacks/java:9.7.0"
-  version = "9.7.0"
+  uri = "docker://anthonydahanne/java:fix-273"
+  version = "{{.version}}"
   [[order.group]]
     id = "paketo-buildpacks/java"
-    version = "9.7.0"
+    version = "{{.version}}"
```

Now, let's update it:

```
pack builder create anthonydahanne/tiny-builder:fix-273 --config builder.toml --publish
Successfully created builder image anthonydahanne/tiny-builder:fix-273
Tip: Run pack build <image-name> --builder anthonydahanne/tiny-builder:fix-273 to use this builder
```

And finally use it:

```
pack build -p ~/workspaces/paketo-buildpacks/samples/java/maven applications/maven-app --builder=anthonydahanne/tiny-builder:fix-273
```

You'll find in the builders repository ([`tiny`](https://github.com/paketo-buildpacks/builder-jammy-tiny), [`base`](https://github.com/paketo-buildpacks/builder-jammy-base) and [`full`](https://github.com/paketo-buildpacks/builder-jammy-full)) integration test that you could try your builder against; to make sure your changes did not break standard expectations.

## Final notes

With Paketo buildpacks, everything is in the open, so you can definitely test your changes from a single unit test to a full builder that includes your composite, that includes your changed component!

Most of the time though, you will probably just need to be able to build and run your modified buildpack: it's easy and will help your colleagues or maintainers test your changes!
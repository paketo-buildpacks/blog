---
title: From deprecation warnings to Spring Boot performance - the spring-boot buildpack in 2026
date: "2026-04-15"
slug: spring-boot-performance
author: anthonydahanne
---

# Introduction

The `spring-boot` buildpack is a Paketo Buildpack that is used to build Spring Boot applications.

But what is so special about a Spring Boot application compared to other Java applications?

The Spring ecosystem, the integration with cloud environment and performance optimizations are peculiar to this Java framework; let's dive into how this buildpack helps you get the most of Spring Boot.

**Some content in this article was generated with Generative AI; the entirety of the article was reviewed by humans though.**

# Spring Generations

One of the quieter but useful features of the `spring-boot` buildpack is that it will warn you when you are building an application that uses an end-of-life version of Spring Boot.

How does it work? The buildpack reads the `Spring-Boot-Version` entry from your application's `META-INF/MANIFEST.MF` at build time, then checks it against a bundled `spring-generations.toml` file that tracks the full lifecycle of every Spring project — Spring Boot, Spring Cloud, Spring Data, Spring Security, and more.

That file is kept automatically up to date by a [weekly workflow](https://github.com/paketo-buildpacks/spring-boot/blob/main/.github/workflows/update-spring-generations.yml) that queries the [Spring API](https://api.spring.io) and opens a patch-bump pull request whenever new lifecycle data is available.

The content of `spring-generations.toml` looks like this:

```
[[projects]]
  name = "Spring Boot"
  slug = "spring-boot"
  status = "ACTIVE"

    [[Projects.Generations]]
    Name = "3.3.x"
    OSS = "2025-06-30"
    
    [[Projects.Generations]]
    Name = "3.4.x"
    OSS = "2025-12-31"
    
    [[Projects.Generations]]
    Name = "3.5.x"
    OSS = "2026-06-30"
```

At build time, if the detected Spring Boot version falls into a generation whose `oss-end-of-life` date has already passed, the buildpack emits a clearly visible warning:

```
This application uses Spring Boot 2.0.0.RELEASE. Open Source updates for 2.0.x ended on 2019-03-31.
```

The warning is printed in bold yellow so it is hard to miss in your build logs, but it does **not** fail the build — it is purely informational.

This is a small but practical safety net: if you are building an image from a dependency-locked project that nobody has touched in a while, the buildpack will surface the EOL status without you having to check the Spring release calendar manually.

# Spring Cloud Bindings

[Spring Cloud Bindings](https://github.com/spring-cloud/spring-cloud-bindings) is a library that implements the [Kubernetes Service Binding Specification](https://servicebinding.io/#specification). When a Service Binding is mounted in your pod, the library detects it and automatically translates the raw binding files into Spring Boot `Environment` properties — so your app can connect to a bound MySQL, PostgreSQL, Redis, RabbitMQ, Kafka (and more) without you writing any boilerplate configuration.

The `spring-boot` buildpack injects this jar automatically unless you explicitly opt out.

## Two versions, automatically selected

There are two active release lines of the library, and the buildpack picks the right one based on the Spring Boot version found in your `META-INF/MANIFEST.MF`:

| Detected Spring Boot version | Injected library version                   |
|------------------------------|--------------------------------------------|
| ≤ 3.0.0 (Spring Boot 2.x)   | `spring-cloud-bindings` 1.x (e.g. 1.13.0) |
| > 3.0.0 (Spring Boot 3.x)   | `spring-cloud-bindings` 2.x (e.g. 2.0.4)  |

## Where the jar ends up in the container

The buildpack places the jar in its own layer, then creates a **symlink** into the Spring Boot fat-jar's lib directory. This is how it looks inside the running container:

```
/layers/
└── paketo-buildpacks_spring-boot/
    └── spring-cloud-bindings/         ← CNB layer (launch=true)
        └── spring-cloud-bindings-2.0.4.jar

/workspace/
└── BOOT-INF/
    └── lib/
        ├── spring-core-6.2.x.jar
        ├── spring-context-6.2.x.jar
        ├── ...
        └── spring-cloud-bindings-2.0.4.jar  ← symlink → /layers/.../spring-cloud-bindings-2.0.4.jar
```

Because it lands in `BOOT-INF/lib/`, the Spring Boot classloader picks it up automatically — no `CLASSPATH` manipulation, no `loader.path` tricks. From the application's perspective, the jar was always there.

## Runtime activation

The library's auto-configuration is activated at runtime via a system property that the buildpack sets through its launch environment:

```
org.springframework.cloud.bindings.boot.enable=true
```

This is wired up via the `BPL_SPRING_CLOUD_BINDINGS_DISABLED` environment variable (default: `false`, meaning bindings are **enabled**). You can turn it off at runtime without rebuilding:

```
docker run -e BPL_SPRING_CLOUD_BINDINGS_DISABLED=true petclinic:main
```

## Opting out entirely at build time

If you deploy to an environment that does not use Service Bindings — or if you prefer to include the library explicitly in your `pom.xml` so that your security team can track it — you can tell the buildpack not to inject it at all:

```
pack build --env BP_SPRING_CLOUD_BINDINGS_DISABLED=true petclinic:main
```

Or with the Spring Boot Maven plugin (as shown in the examples throughout this article):

```
<BP_SPRING_CLOUD_BINDINGS_DISABLED>true</BP_SPRING_CLOUD_BINDINGS_DISABLED>
```

When this flag is set, no jar is added and no symlink is created — the layer simply does not appear in the image.

# Performance optimization with the Spring Boot buildpack
Optimizing a Spring Boot app for less memory consumption and/or for better start times is obviously something all developers want.

But optimizing an app can have drawbacks too; let's explore in this post the different ways Paketo Buildpacks can help you optimize your Spring Boot apps.

I invite you to first read the articles on the Spring Blog and documentation site, introducing all the concepts I am going to enable here with the Paketo Buildpacks:

* [CDS with Spring Framework 6.1](https://spring.io/blog/2023/12/04/cds-with-spring-framework-6-1): this is where CDS was introduced to Spring users
* [Spring Boot CDS support and Project Leyden anticipation](https://spring.io/blog/2024/08/29/spring-boot-cds-support-and-project-leyden-anticipation): Project Leyden is getting near and will rename and enhance CDS with AOT Cache
* [AOT Cache](https://docs.spring.io/spring-boot/reference/packaging/aot-cache.html): with Java 24+ comes AOT Cache, which is the evolution of CDS

We'll be using the [Spring Petclinic](https://github.com/spring-projects/spring-petclinic) as the example app, and BellSoft Liberica 25 (Petclinic only requires Java 17 but using the latest runtime is usually... faster! and allows for modern optimization features) as the compiler / runtime.

After a fresh checkout of `main`

```
# get rid of gradle configuration: Spring Petclinic supports both Gradle and Maven, and Gradle is evaluated first (by the Java buildpack) although I want this post to be Maven based since that's still what most developers use today...
> rm -rf build.gradle settings.gradle gradle gradlew gradlew.bat
```

## Build the container image using the `pack` CLI
```
# let's choose a decent builder, based on latest Ubuntu LTS, and with only Java related buildpacks
> pack config default-builder paketobuildpacks/builder-noble-java-tiny
Builder paketobuildpacks/builder-noble-java-tiny is now the default builder
> pack build --env BP_JVM_VERSION=25 --env BP_SPRING_CLOUD_BINDINGS_DISABLED=true petclinic:main
> docker run -it petclinic:main
[...]
Started PetClinicApplication in 2.379 seconds
> docker container stats
MEM USAGE / LIMIT
391.8MiB / 15.6GiB
```

## Build the container image using the Spring Boot maven plugin:
```
    <profile>
      <id>main</id>
      <build>
        <plugins>
          <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <configuration>
              <imageBuilder>paketobuildpacks/builder-noble-java-tiny:latest</imageBuilder>
              <image>
                <env>
                  <BP_JVM_VERSION>25</BP_JVM_VERSION>
                  <!-- Spring Cloud Bindings jar injection is only needed if you deploy to a Service Binding aware Kubernetes environment -->
                  <BP_SPRING_CLOUD_BINDINGS_DISABLED>true</BP_SPRING_CLOUD_BINDINGS_DISABLED>
                </env>
              </image>
            </configuration>
          </plugin>
        </plugins>
      </build>
    </profile>
```

You can see [the commit here](https://github.com/anthonydahanne/spring-petclinic/tree/maven-plugin-profile).

```
./mvnw spring-boot:build-image -Pmain
```

This is going to be our baseline for this article

A few notes:
* this post does not intend to be a benchmark article; I'm just gathering some memory / startup time metrics to give an idea
* You don't need to specify `BP_JVM_VERSION=25` if you use an `.sdkmanrc` with `java=25-zulu`
* I have disabled Spring Cloud bindings `BP_SPRING_CLOUD_BINDINGS_DISABLED=true` because it injects the [spring-cloud-bindings jar](https://github.com/spring-cloud/spring-cloud-bindings) that is only helpful if you deploy to a [Service Binding](https://servicebinding.io/#specification) aware Kubernetes environment - if you need it, I'd advise you to include it in your `pom.xml`
* I'm always a little bit nervous comparing a `pack` build with a `./mvnw spring-boot:build-image` - the behaviour can be slightly different: using `pack` both the jar and the image will be built by Paketo Buildpacks (the `maven` build pack will be used); using the Spring Boot plugin, the jar will be built by your local machine (`maven` buildpack not used) - just something to keep in mind if you need special compilation options.

# Spring Boot performance options: Spring Boot extract layout, Spring AOT, CRaC, Native build and AOT Caching (previously known as CDS)

## Spring Boot extract
[Spring Boot extract was introduced with Spring Boot 3.3 in May 2024, although previous versions, not specific to CDS requirement, existed since Spring Boot 2.3 (2020)](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.3.0-M3-Release-Notes#cds-support), it extracts the Spring Boot jar content into a "plain jar" with regular MANIFEST.MF and classpath libs (no Spring Boot classloader)

This deployment optimization does not have any drawbacks, so... use it and maybe in the future we'll make it the default!

### What does it look like?

A standard Spring Boot fat jar bundles everything: the Spring Boot classloader, all dependency jars nested inside `BOOT-INF/lib/`, and your application classes inside `BOOT-INF/classes/`:

```
petclinic.jar
├── META-INF/
│   └── MANIFEST.MF                      ← Main-Class: org.springframework.boot.loader.launch.JarLauncher
├── BOOT-INF/
│   ├── classes/                         ← your application classes
│   │   └── org/springframework/samples/petclinic/...
│   ├── lib/                             ← all dependency jars, nested
│   │   ├── spring-core-6.2.x.jar
│   │   ├── spring-context-6.2.x.jar
│   │   └── ... (100+ jars)
│   └── classpath.idx
└── org/springframework/boot/loader/     ← Spring Boot classloader
    └── launch/JarLauncher.class
```

At runtime, `JarLauncher` reads the nested jars and builds a custom classloader hierarchy which works, but adds overhead on every start.

When `BP_UNPACK_LAYOUT_ONLY=true`, the buildpack runs the following during image creation:

```
java -Djarmode=tools -jar petclinic.jar extract --destination /workspace
```

This unpacks the fat jar into a flat layout directly in the workspace:

```
/workspace/
├── runner.jar                           ← thin jar: just your app classes + META-INF
└── lib/
    ├── spring-core-6.2.x.jar
    ├── spring-context-6.2.x.jar
    └── ... (100+ jars, now real files on disk)
```

The application then starts as a plain `java -cp runner.jar:lib/* com.example.MyApp`, with no custom classloader in the way. The JVM can load classes directly from the filesystem, which is faster and uses less memory than navigating nested zip entries.

### Super easy to do with the spring-boot buildpack!
After a fresh checkout of `main`:

```
> pack build \
 --env BP_JVM_VERSION=25 \
 --env BP_SPRING_CLOUD_BINDINGS_DISABLED=true \
 --env BP_UNPACK_LAYOUT_ONLY=true \
   petclinic:unpack --clear-cache
> docker run -it petclinic:unpack
[...]
Starting PetClinicApplication v4.0.0-SNAPSHOT using Java 25.0.2 with PID 1 (/workspace/runner.jar started by cnb in /workspace)
[...]
Started PetClinicApplication in 2.31 seconds (process running for 2.559)
> docker container stats
MEM USAGE / LIMIT
319.5MiB / 15.6GiB
```

Using the Spring Boot maven plugin:
```
<profile>
    <id>unpack</id>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <imageBuilder>paketobuildpacks/builder-noble-java-tiny:latest</imageBuilder>
                    <image>
                        <name>unpack</name>
                        <env>
                            <BP_JVM_VERSION>25</BP_JVM_VERSION>
                            <BP_SPRING_CLOUD_BINDINGS_DISABLED>true</BP_SPRING_CLOUD_BINDINGS_DISABLED>
                            <BP_UNPACK_LAYOUT_ONLY>true</BP_UNPACK_LAYOUT_ONLY>
                        </env>
                    </image>
                </configuration>
            </plugin>
        </plugins>
    </build>
</profile>
```


## Spring AOT
[Spring AOT (Ahead of Time processing) was introduced with Spring Boot 3 back in 2022](https://youtu.be/mitWK_DwKGs?si=69JOrH2ji9wpvpUX&t=1308), it moves wiring and configuration operations to the build phase, for example.

This is a great way to reduce startup time and memory consumption; but unfortunately it makes your application less dynamic, as AOT class generation and compilation will make assumptions (configured with hints) about your runtime deployment.
For example: if your app has several profiles, the AOT processing will only apply to a given profile chosen during the AOT process (use H2 in dev and MySQL in prod? you have to choose which profile you want AOT to run on)

**Careful! This is not AOT Caching yet!** the names are similar, but they are different and can be combined, more on that in the next chapters.

After a fresh checkout of `main`:

```
> pack build \
 --env BP_JVM_VERSION=25 \
 --env BP_SPRING_CLOUD_BINDINGS_DISABLED=true \
 --env BP_SPRING_AOT_ENABLED=true \
 --env BP_MAVEN_BUILD_ARGUMENTS="-batch-mode -Dmaven.test.skip=true --no-transfer-progress spring-boot:process-aot package" \
   petclinic:aot --clear-cache
> docker run -it petclinic:aot
[...]
Starting AOT-processed PetClinicApplication v4.0.0-SNAPSHOT using Java 25.0.1 with PID 1 (/workspace/BOOT-INF/classes started by cnb in /workspace)
[...]
Started PetClinicApplication in 2.011 seconds
> docker container stats
MEM USAGE / LIMIT
309.5MiB / 15.6GiB
```

Using the Spring Boot maven plugin:
```
<profile>
    <id>aot</id>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <executions>
                    <execution>
                        <id>process-aot</id>
                        <goals>
                            <goal>process-aot</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <imageBuilder>paketobuildpacks/builder-noble-java-tiny:latest</imageBuilder>
                    <image>
                        <env>
                            <BP_JVM_VERSION>25</BP_JVM_VERSION>
                            <BP_SPRING_CLOUD_BINDINGS_DISABLED>true</BP_SPRING_CLOUD_BINDINGS_DISABLED>
                            <BP_SPRING_AOT_ENABLED>true</BP_SPRING_AOT_ENABLED>
                        </env>
                    </image>
                </configuration>
            </plugin>
        </plugins>
    </build>
</profile>
```

## Spring native

[GraalVM Native Image compilation for Spring Boot was made production-ready with Spring Boot 3.0 in November 2022](https://spring.io/blog/2022/09/26/native-support-in-spring-boot-3-0-0-m5), and it represents the most aggressive performance option available: instead of running on a JVM, your application is compiled ahead of time into a self-contained native binary.

The trade-offs are real though:
* the build is **significantly slower** (several minutes vs. seconds for a regular JVM build)
* **no JIT compiler** at runtime — peak throughput may be lower than a warmed-up JVM
* **dynamic features** (reflection, proxies, serialization) require explicit configuration hints; Spring Boot's AOT processing generates most of them, but edge cases exist
* the resulting image is **platform-specific** (linux/amd64 vs. linux/arm64 — no fat jar portability)

In practice, Native Image is the right choice when **startup time and memory footprint** matter more than throughput — think serverless functions, CLI tools, or cost-sensitive autoscaling workloads.

Two buildpacks collaborate here: the `spring-boot` buildpack runs `spring-boot:process-aot` during the Maven build, producing the `META-INF/native-image` reachability metadata; the `native-image` buildpack then invokes `native-image` to compile everything into a binary. You do not need to orchestrate this yourself — enabling `BP_NATIVE_IMAGE=true` is enough for the buildpack group to do the right thing.

After a fresh checkout of `main`:

```
> pack build \
 --env BP_JVM_VERSION=25 \
 --env BP_SPRING_CLOUD_BINDINGS_DISABLED=true \
 --env BP_NATIVE_IMAGE=true \
 --env BP_MAVEN_BUILD_ARGUMENTS="-batch-mode -Dmaven.test.skip=true --no-transfer-progress spring-boot:process-aot package" \
   petclinic:native --clear-cache
> docker run -it petclinic:native
[...]
Starting AOT-processed PetClinicApplication v4.0.0-SNAPSHOT using Java 25.0.1 with PID 1 (/workspace/petclinic started by cnb in /workspace)
[...]
Started PetClinicApplication in 0.117 seconds
> docker container stats
MEM USAGE / LIMIT
90.2MiB / 15.6GiB
```

Using the Spring Boot Maven plugin:
```
<profile>
    <id>native</id>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <executions>
                    <execution>
                        <id>process-aot</id>
                        <goals>
                            <goal>process-aot</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <imageBuilder>paketobuildpacks/builder-noble-java-tiny:latest</imageBuilder>
                    <image>
                        <name>petclinic:native</name>
                        <env>
                            <BP_JVM_VERSION>25</BP_JVM_VERSION>
                            <BP_SPRING_CLOUD_BINDINGS_DISABLED>true</BP_SPRING_CLOUD_BINDINGS_DISABLED>
                            <BP_NATIVE_IMAGE>true</BP_NATIVE_IMAGE>
                        </env>
                    </image>
                </configuration>
            </plugin>
        </plugins>
    </build>
</profile>
```

```
./mvnw spring-boot:build-image -Pnative
```

Note that when using the Spring Boot Maven plugin the local Maven build already runs `process-aot` (via the execution declared above), so the jar handed to the buildpack already contains the `META-INF/native-image` folder — no extra `BP_MAVEN_BUILD_ARGUMENTS` is required.

## Spring CRaC

[CRaC (Coordinated Restore at Checkpoint)](https://openjdk.org/projects/crac/) was introduced to Spring Boot in 3.2 (November 2023). The idea is compelling: take a checkpoint of a fully initialized, warmed-up JVM process, store it as an image layer, and restore from that snapshot on every subsequent start, bringing startup times close to native without giving up the JIT compiler at steady-state throughput.

There is, however, **no Paketo buildpack support for CRaC**, and there is no plan to add it. The fundamental problem is architectural: CRaC requires Linux's [CRIU](https://criu.org) to snapshot a *running* process, and that must happen at runtime (after the application has fully started), not at build time. Concretely:

* checkpointing requires `CAP_CHECKPOINT_RESTORE` (and often `SYS_PTRACE`), privileges that standard buildpack builds deliberately do not have
* the checkpoint must happen inside a running container, mid-execution, after Spring context refresh, not during the layer-contribution phase that buildpacks are designed for (that said we could use the property `-Dspring.context.exit=onRefresh` to trigger a checkpoint at the end of the refresh)
* the resulting snapshot contains in-memory state (open file descriptors, active connections, environment variables 😱) that is inherently application - and environment-specific, making it impossible to produce generically in a build pipeline

If you want to use CRaC today, the established path is to drive it yourself outside of the buildpack: run your application in a privileged container with a CRaC-enabled JDK (e.g. Azul Zulu CRaC or BellSoft Liberica CRaC), trigger the checkpoint via `jcmd <pid> JDK.checkpoint`, then commit the running container to a new image. That flow is well documented by [Azul](https://docs.azul.com/core/crac/crac-guidelines) and [BellSoft](https://bell-sw.com/blog/how-to-use-crac-with-spring-boot-apps-in-a-docker-container/), but it sits entirely outside the Paketo buildpack model.

## Spring AOT Cache (previously known as CDS)

Let's talk JEP (JDK enhancements proposals) and Spring Boot support:

* [JEP-350](https://openjdk.org/jeps/350) is not exactly new (2018-2021), but it introduced the concept of CDS (Class Data Sharing) that eventually Spring Boot 3.3 started leveraging. The spring-boot buildpack then added `BP_JVM_CDS_ENABLED` to support this feature, introducing the concept of "training run" during the buildpack execution. The "training run" being a short-lived execution of the JVM, just the time to load all the beans, and then exits with... a caching file containing a cached version of many classes.
* [JEP-483](https://openjdk.org/jeps/483) now we move into Project Leyden territory: JEP-483 was an intermediate support for AOT Cache in the JVM (the successor to CDS), that shipped with Java 24 - `AOTMode=record` + `AOTMode=create`
* [JEP-514](https://openjdk.org/jeps/514) came with Java 25, with simpler ergonomics. Spring Boot 3.5 started leveraging this feature, so eventually the [spring-boot buildpack implemented its support](https://github.com/paketo-buildpacks/spring-boot/issues/571)

### What does it look like?

The trick behind AOT Cache is a **training run**: a short-lived execution of the application that happens *during the image build*, inside the container being assembled. The JVM starts, Spring loads and wires all beans, the context finishes refreshing — and then the process exits cleanly (via `-Dspring.context.exit=onRefresh`) leaving behind a binary snapshot of everything it parsed and compiled.

The buildpack picks the right JVM flags based on the Java version it detects at build time:

| Java version       | Training run flag                          | Cache file          | Production run flag                       |
|--------------------|--------------------------------------------|---------------------|-------------------------------------------|
| 25+ (JEP-514)      | `-XX:AOTCacheOutput=application.aot`       | `application.aot`   | `-XX:AOTCache=application.aot`            |
| < 25 (JEP-350/483) | `-XX:ArchiveClassesAtExit=application.jsa` | `application.jsa`   | `-XX:SharedArchiveFile=application.jsa`   |

The full training run command executed by the buildpack looks like this (Java 25 path):

```
java \
  -Dspring.context.exit=onRefresh \
  -Dspring.aot.enabled=true \
  -XX:AOTCacheOutput=application.aot \
  -cp runner.jar:lib/* \
  org.springframework.samples.petclinic.PetClinicApplication
```

After the training run completes, the cache file is present alongside the application in the workspace:

```
/workspace/
├── runner.jar
├── lib/
│   ├── spring-core-6.2.x.jar
│   └── ...
└── application.aot      ← written by the training run, baked into the image layer
```

On every subsequent container start, the JVM is handed `-XX:AOTCache=application.aot` and skips re-parsing and re-compiling those classes entirely.

**Critical constraint: the JVM and the filesystem layout must be byte-for-byte identical between the training run and the production run.**

The cache encodes absolute paths to every class file and jar that was loaded. If the JVM binary is at a different path, if a jar is at a different location, or if the JVM version differs even by a patch release, the JVM will silently discard the cache and fall back to a cold start. In a container built by Paketo this is guaranteed — the training run and the production run both happen inside the same image, with the same JVM installed at `/layers/...` and the same application laid out in `/workspace/`. You should never copy an `application.aot` file from one image into another.

### Super easy to do with the spring-boot buildpack!

After a fresh checkout of `main`:

```
> pack build \
 --env BP_JVM_VERSION=25 \
 --env BP_SPRING_CLOUD_BINDINGS_DISABLED=true \
 --env BP_SPRING_AOT_ENABLED=true \
 --env BP_JVM_AOTCACHE_ENABLED=true \
 --env BP_MAVEN_BUILD_ARGUMENTS="-batch-mode -Dmaven.test.skip=true --no-transfer-progress spring-boot:process-aot package" \
   petclinic:aot-cache --clear-cache
> docker run -it petclinic:aot-cache
[...]
Starting AOT-processed PetClinicApplication v4.0.0-SNAPSHOT using Java 25.0.1 with PID 1 (/workspace/BOOT-INF/classes started by cnb in /workspace)
[...]
Started PetClinicApplication in 2.011 seconds
> docker container stats
MEM USAGE / LIMIT
309.5MiB / 15.6GiB
```

Using the Spring Boot maven plugin:
```
<profile>
    <id>aot-cache</id>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <executions>
                    <execution>
                        <id>process-aot</id>
                        <goals>
                            <goal>process-aot</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <imageBuilder>paketobuildpacks/builder-noble-java-tiny:latest</imageBuilder>
                    <image>
                        <env>
                            <BP_JVM_VERSION>25</BP_JVM_VERSION>
                            <BP_SPRING_CLOUD_BINDINGS_DISABLED>true</BP_SPRING_CLOUD_BINDINGS_DISABLED>
                            <BP_SPRING_AOT_ENABLED>true</BP_SPRING_AOT_ENABLED>
                            <BP_JVM_AOTCACHE_ENABLED>true</BP_JVM_AOTCACHE_ENABLED>
                        </env>
                    </image>
                </configuration>
            </plugin>
        </plugins>
    </build>
</profile>
```
---
title: Java Buildpack Support and Debug Enhancements
date: "2021-12-09"
slug: java-rearchitecture
author: dosullivan
---
I’m pleased to announce that the Paketo Java Buildpack has been enhanced to make it even easier to analyze and debug your JVM based applications. A host of features have been added or integrated in the form of environment variable flags, and some features which previously required image rebuilds can now simply be toggled at runtime. This post will outline how to both configure the JVM itself and make use of the following features:

* [Java Native Memory Tracking (NMT)][nmt]
* [Java Flight Recorder (JFR)][jfr]
* [Java Management Extensions (JMX)][jmx]
* [Remote Debugging][debug]
* [Heap Dump on Out-of-Memory-Error][jvm-kill]

### JVM Configuration

The JVM used to build and run your application can be configured in three main ways: the JVM provider, the JVM version, and the JVM type (a full JDK vs JRE).

#### JVM Provider  

By default, the Paketo Java Buildpack uses the Bellsoft Liberica JVM. To use an alternative JVM, you can specify it as a `--buildpack` argument before the Paketo Java Buildpack.

Example (to install the Amazon Corretto JVM):

```
 pack build apps/sample \
 --buildpack gcr.io/paketo-buildpacks/amazon-corretto \
 --buildpack paketo-buildpacks/java
```

A table of alternative JVM providers can be found [here](https://paketo.io/docs/howto/java/#use-an-alternative-jvm).

#### JVM Type & Version

These can be set using environment variables provided to the build command.

`BP_JVM_TYPE` - defaults to `JRE`, this can be set to `JDK` to specify which JVM type is installed in the final run image.

`BP_JVM_VERSION` - defaults to the latest 11.x version available for the JVM provider. You can set this value to another major version to get the latest patch release, e.g. `17`

Example to specify a full JDK & the latest v11 patch:

```
pack build apps/sample \
--env BP_JVM_TYPE=JDK \
--env BP_JVM_VERSION=11
```

### New Features

Support for each of the new features below can be enabled at build time without the participation of other buildpacks and without the need for any build-time environment variables, simply build with the standard ‘pack build’ command for a Java application:

`pack build samples/java --path java/jar`

You can then enable a feature at run time using the `BPL_<feature-name>_ENABLED` environment variable detailed for each feature. Further variables can then be used to customise the default configuration for this feature.

#### **Java Native Memory Tracking (NMT)**  

Native Memory Tracking (NMT) is a feature that tracks internal memory usage in the JVM. Support for this feature has been added to the Paketo Java Buildpack and is now enabled by default. When the JVM exits, it will print a summary of memory usage. In addition, you can use the JDK tool ‘jcmd’ to dump and view the data collected (see the [JVM Type configuration][install-jvm-type] section for details on how to ensure you have a JDK at runtime). There are two runtime configuration options for this feature:

`BPL_JAVA_NMT_ENABLED` - set to `true` by default, however the tracking can cause a 5-10% performance overhead, so this variable can be set to `false` to disable memory tracking when the JVM starts.

`BPL_JAVA_NMT_LEVEL` - set to `summary` by default, this specifies the level of detail for the memory usage data captured. For a more detailed output, it can be set to `detail`.

The following default NMT arguments are passed to the JVM:

```
-XX:+UnlockDiagnosticVMOptions
-XX:NativeMemoryTracking=summary
-XX:+PrintNMTStatistics`
```

Example:

To start a new bash session and capture NMT data from a running container run the following:

`docker exec -it <container-id> /cnb/lifecycle/launcher /bin/bash`

If a JDK was installed, this session should have the JDK tool `jcmd` on the $PATH variable. To capture NMT data you can run:

`jcmd 1 VM.native_memory summary`

NMT data will also be printed at JVM exit:

![NMT](/images/posts/0006/nmt.png)

#### **Java Flight Recorder (JFR)**

Java Flight Recorder is a tool which is integrated into the JVM and allows for the collection of profiling and diagnostic data about your application. Support for this feature has been added, however, it is disabled by default. To enable it, simply use the environment variable:

`BPL_JFR_ENABLED` - set to `false` by default
 
The tool supports a range of configuration options which can be set using the following environment variable:

`BPL_JFR_ARGS` - this supports a comma-separated list of options (full list detailed in the Oracle docs [here](https://docs.oracle.com/javacomponents/jmc-5-4/jfr-runtime-guide/comline.htm#JFRUH193)). If the tool is enabled but no options are specified here, the buildpack will at a minimum configure the tool to write data to a temporary file on JVM exit. 

The following default options will be supplied to `BPL_JFR_ARGS` to allow this:

* `dumponexit=true` - this tells the JFR tool to write recording data to a file when the JVM exits.
* `filename=<system-temp-dir>/recording.jfr` - the location of the dump file, on linux this will be “/tmp/recording.jfr”

If any custom arguments are specified, the above defaults are not applied. When enabled, a JFR argument will be passed to the JVM, for example, the defaults result in the following:

`-XX:StartFlightRecording=dumponexit=true,filename=/tmp/recording.jfr`

Example:

To start a docker container with JFR enabled, setting some custom arguments, run the following:

```
docker run \
--env BPL_JFR_ENABLED=true \
--env BPL_JFR_ARGS=filename=/tmp/my-recording.jfr,duration=60s \
samples/java
```

When you wish to retrieve the recording file, you can run the following to copy it from the container (the location specified in the above 'filename' argument) to your local current directory:

```
docker cp <container-id>:/tmp/my-recording.jfr .
```

### Newly Integrated Features

In addition to the new features now supported by the buildpack, two features which previously required a user to rebuild their image are now integrated into the Paketo Java Buildpack directly. These can simply be enabled at runtime using an environment variable.

#### **Java Management Extensions (JMX)**

JMX is a tool to allow you to connect  to a running JVM application and display real-time data such as memory and CPU usage, garbage collections, thread activity etc. To configure your application to receive connections on a specific port, you can use the following runtime environment variables:

`BPL_JMX_ENABLED` - set to `false` by default, set this to `true` to allow incoming connections

`BPL_JMX_PORT` - set to `5000` by default, this can be set to your desired port for connections.

When enabled, these default JMX arguments will be passed to the JVM:

```
-Djava.rmi.server.hostname=127.0.0.1
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
-Dcom.sun.management.jmxremote.rmi.port=5000
```

#### **Remote Debugging**

To enable and configure the JVM to accept connections for remote debugging, you can use the following runtime environment variables:

`BPL_DEBUG_ENABLED` - set to `false` by default, set this to `true` to allow incoming connections

`BPL_DEBUG_PORT` - set to `8000` by default, this can be set to your desired port for connections.

`BPL_DEBUG_SUSPEND` - set to `false` by default, configures whether execution should be suspended until a remote debugger is attached.

When enabled, these default debug arguments will be passed to the JVM:

`-agentlib:jdwp=transport=dt_socket,server=y,address=*:8000,suspend=n`

#### **JVM Kill Agent**   

The JVM Kill Agent was previously installed by the Paketo Java Buildpack to all container images. Its primary purpose was to cause the JVM process to exit when there was an Out Of Memory Error (OOME). Due to the JVM being run as a ‘direct’ process type, as PID1, it is not possible for the agent to terminate the JVM. 

Functionality to fulfill the same purpose is now included in the JVM itself via the following flag, which is now passed to the JVM by the buildpack by default:

`-XX:+ExitOnOutOfMemoryError`

Related to this functionality, the buildpack also provides a runtime environment variable which allows you to specify the location of a file to write a heap dump to if an OOME occurs:

`BPL_HEAP_DUMP_PATH` - empty by default, and no file is written. If a path is specified, the file will be created and the heap dump will be written there. This will also add two JVM flags to support this functionality:

```
-XX:+HeapDumpOnOutOfMemoryError
-XX:HeapDumpPath=<path>
```

### Notes

The following new buildpacks are now available:

[Java Memory Assistant Buildpack](https://github.com/paketo-buildpacks/java-memory-assistant)
This buildpack installs and enables the [Java Memory Assistant](https://github.com/SAP/java-memory-assistant). This is an advanced agent that can be used for flexible configuration of triggers to create heap dumps.

[JAttach Buildpack](https://github.com/paketo-buildpacks/jattach)
This buildpack installs the [JAttach binary](https://github.com/apangin/jattach), which is a community tool that replaces the `jmap`,`jstack`,`jcmd` & `jinfo` tools that are not present in the OpenJDK JRE.

#### Learn More

* Further examples and features can be found in our ['How To' docs](https://paketo.io/docs/howto/java/)

* Connect with our community in the [Paketo Slack](https://slack.paketo.io/) [#Java](https://paketobuildpacks.slack.com/archives/C0124SD3GTG) channel

[install-jvm-type]:{{< relref "#jvm-type--version" >}}
[nmt]:{{< relref "#java-native-memory-tracking-nmt" >}}
[jfr]:{{< relref "#java-flight-recorder-jfr" >}}
[jmx]:{{< relref "#java-management-extensions-jmx" >}}
[debug]:{{< relref "#remote-debugging" >}}
[jvm-kill]:{{< relref "#jvm-kill-agent" >}}
---
title: Introducing the Paketo .NET Core Buildpack v0.1.0
date: "2021-02-09"
slug: dotnet-core-rearchitecture
author: fgallinajones
---

SOME PICTURE HERE

Paketo is pleased to unveil our new and improved .NET Core Buildpack! With the
release of [Paketo .NET Core Buildpack
0.1.0](https://github.com/paketo-buildpacks/dotnet-core/releases), you’ll enjoy
a host of new features and improvements that we hope will make containerizing
your .NET apps a breeze.

With the new buildpack, you can now:
*   Build .NET 5 apps
*   Provide your app as source code, a framework-dependent deployment (FDD), a
    framework-dependent executable (FDE), or a self-contained deployment
*   Build Visual Basic apps
*   Have source code removed from final app image. Your app container will
    contain only the built artifacts
*   Use a
    [Procfile](https://paketo.io/docs/buildpacks/configuration/#procfiles) to
    specify custom start processes

We also re-wrote the buildpacks using
[packit](https://github.com/paketo-buildpacks/packit), our library for
buildpack developers. This will ensure that the buildpack benefits from future
innovations in the [Cloud Native Buildpacks
specification](https://github.com/buildpacks/spec/blob/main/buildpack.md).

If you’re not sure why you should get excited about .NET 5, check out this
[post from
Microsoft](https://devblogs.microsoft.com/dotnet/announcing-net-5-0/)
announcing its release.

&lt; maybe include some highlights about .NET 5?>

It’s easy to get started with the .NET Core Buildpack. In a matter of minutes,
you can build and run a .NET 5 app with a React frontend **_without ever
touching a Dockerfile_.**

How does it work? Let’s take it from empty directory to running app container:



1. Install the latest [`dotnet`
   CLI](https://docs.microsoft.com/en-us/dotnet/core/install/)
2. Install [`pack`](https://buildpacks.io/docs/tools/pack/#install)
3. Generate the sample app and have a look around
    ```
    dotnet new react -o dotnet-five-react && cd dotnet-five-react && ls -al
    ```
4. Use `pack` with the new .NET Core buildpack to build the source code into a
   runnable image
    ```
    pack build dotnet-five-react --buildpack gcr.io/paketo-buildpacks/dotnet-core:0.1.1
    ```
5. Run the app
    ```
    docker run -it --publish 8080:8080 dotnet-five-react
    ```
6. Check out the results in your browser at:
   [http://0.0.0.0:8080](http://0.0.0.0:8080) or test out the app with `curl`
    ```
    curl 0.0.0.0:8080
    ```

Voila!

![Terminal window animation demonstrating use of .NET Core Buildpack](/images/posts/0005/dotnet-build-demo.gif)

The new .NET Core buildpack is included in the latest [Paketo Base
Builder](https://paketo.io/docs/builders/#base) and [Paketo Full
Builder](https://paketo.io/docs/builders/#full).

Thanks for reading!

Want to learn more about using the .NET Core Buildpack? [Check out our
docs](https://paketo.io/docs/buildpacks/language-family-buildpacks/dotnet-core/).

Feature request? [Open an
issue](https://github.com/paketo-buildpacks/dotnet-core/issues).

Want to chat with .NET Buildpack maintainers? Join
[#dotnet-core](https://paketobuildpacks.slack.com/archives/CUD6SEE7L)
in [Paketo slack](https://slack.paketo.io/).

Want to contribute a bug fix (or buildpack!)? [Learn more about our open source
community.](https://github.com/paketo-buildpacks/community)

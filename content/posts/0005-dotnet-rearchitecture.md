---
title: Introducing a re-architected .NET Core Buildpack!
date: "2021-02-09"
slug: dotnet-core-rearchitecture
author: fgallinajones
---

![.NET Core Logo](/images/posts/0005/dotnet-core-logo.png)

On behalf of the Paketo contributors, I'm pleased to unveil the new and
improved .NET Core Buildpack! With the release of [Paketo .NET Core Buildpack
0.1.0](https://github.com/paketo-buildpacks/dotnet-core/releases), you’ll enjoy
a host of new features and improvements that will make containerizing your .NET
apps a breeze. 🍃

With the new buildpack, you can:
*   Build .NET 5 apps
*   Build your app from source code, from a framework-dependent deployment
    (FDD), from a framework-dependent executable (FDE), or from a
    self-contained deployment
*   Build Visual Basic apps
*   Have source code removed from final app image. Your app container will
    only contain the built artifacts
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

The new .NET Core buildpack is included in the latest [Paketo Base
Builder](https://paketo.io/docs/builders/#base) and [Paketo Full
Builder](https://paketo.io/docs/builders/#full). You can also find it on
[Dockerhub](https://hub.docker.com/r/paketobuildpacks/dotnet-core) and on the
[Buildpacks
Registry](http://registry.buildpacks.io/buildpacks/paketo-buildpacks/dotnet-core).

## Demo
It’s easy to get started with the .NET Core Buildpack. How easy? Let's do a
quick demo using a .NET 5 app wih a React frontend. In a matter of minutes,
we'll have it up and running, **_without ever touching a Dockerfile_.**

![Terminal window animation demonstrating use of .NET Core Buildpack](/images/posts/0005/dotnet-demo.gif)

Let’s take it from empty directory to running app container:

1. Install the latest [dotnet
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
7. You've successfully containerized a .NET 5 app

### Tada!

##
###
![Buildpacks are almost like this magic trick](https://media.giphy.com/media/KmIR3x7UG4cFy/giphy.gif)

## Learn More
* Want to learn more about using the .NET Core Buildpack? [Check out our
docs](https://paketo.io/docs/buildpacks/language-family-buildpacks/dotnet-core/).

* Feature request? [Open an
issue](https://github.com/paketo-buildpacks/dotnet-core/issues).

* Want to chat with .NET Buildpack maintainers? Join
[#dotnet-core](https://paketobuildpacks.slack.com/archives/CUD6SEE7L)
in [Paketo slack](https://slack.paketo.io/).

* Want to contribute a bug fix (or buildpack!)? [Learn more](https://github.com/paketo-buildpacks/community) about our open source community.

Thanks for reading!


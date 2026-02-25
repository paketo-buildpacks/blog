# Blog

## Creating a new post

The existing blog posts are located in the `/content/posts` directory. To generate a new post from a template, run:

```
./scripts/new_post.sh --name 0123-my-post
```

## Adding your author details

To be recognized as an author, please complete the following:

1. Register your name: Add your details to the `hugo.toml` file using the format: `nickname = "Full Name"`.

1. Add a profile picture: Place a square image in the `assets/images/authors` directory named `nickname.jpg` (e.g., `jdoe.jpg`).

Once added, you can reference your nickname in the author: field of your post.

## Running the site locally

You can run the server locally to see your changes using the following command.

```
./scripts/serve.sh
```

## PR Review Process

1. Submit a Pull Request with your changes.

1. A maintainer must review and approve your PR.

1. Once merged, the post will be automatically published. Feel free to share the live link on social media!

## Type of content you can contribute

- Project announcements & updates: New buildpacks, roadmaps, or re-architecture updates
- Version updates: Support for new runtimes (e.g., Java 25, .NET 10, Node 24)
- Guides on how to use buildpacks
- How to contribute and get involved to buildpacks
- Announcements related to new base images/builders (e.g. Bionic EOL, new builder available)
- Community: year-in-review posts and upcoming event announcements

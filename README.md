# dotfiles

This is my cockpit.

## Installation


### Try NOW with prebuilt docker image

This repository continuously maintains a prebuilt docker imgae [`yuseiito-dev`](https://github.com/YuseiIto/dotfiles/pkgs/container/yuseiito-dev).

There are three variants of images, called `pine`,  `bamboo`, `plum`. (Named after the Japanese word "松竹梅" which means "pine, bamboo, plum", representing different levels of quality or luxury.)



If you are unsure about which one to choose, see [VARIANTS.md](./docs/VARIANTS.md) for more details about the differences between the three variants.
You can pull and run it with the following command:

**Pine (Full featured)**

_This image consumes **large** disk space so if you're just looking for a quick try, `bamboo` is recommended._


```zsh
docker run --rm -it ghcr.io/yuseiito/yuseiito-dev:pine-latest

```


**Bamboo (Basic feature)**

```zsh
docker run --rm -it ghcr.io/yuseiito/yuseiito-dev:pine-latest

```


**Plum (Minimum featured)**

```zsh
docker run --rm -it ghcr.io/yuseiito/yuseiito-dev:pine-latest

```


### Build container image from source
 
**Building from source requires Docker, GNU Make, and Git to be installed on your system.**

```zsh
git clone https://github.com/YuseiIto/dotfiles.git
cd dotfiles
make build-$variant

```

`variant`  is one of `pine`, `bamboo`, or `plum` depending on the level of features you want in your container image.

### Applying to brand new system



### Linux Containers (LXC/LXD)

// Comming soon!



## Development

These are basic steps to enhance this repository by adding new tools, packages, files, or configurations. 

Since this repository contains a (relatively) a lot number of tools and configurations, **it is recommended to ask your Coding Agent to navigate you through the process**.

It will make you grasp the structure of this repository and the development process much faster, and you can also ask it to generate code snippets for you.
This repository invites coding agents as a first-class contributor as well as human developers, there are predefined skills and tools for coding agents. It enables even a tiny local models to be helpful for you.

### Adding new tools/packages


### Adding new files/configurations


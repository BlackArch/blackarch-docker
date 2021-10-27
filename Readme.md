# BlackArch Official Docker Images

## Quick reference

Official BlackArch Linux docker images. If you find a problem, please report it [here](https://github.com/BlackArch/blackarch-docker).

* **Maintainers:** BlackArch Linux developer [Stefan Venz](https://github.com/ikstream).
* **Support:** IRC  [irc://irc.blackarch.org:1337/blackarch](irc://irc.blackarch.org:1337/blackarch).

## What is BlackArch?

BlackArch Linux is an Arch Linux-based penetration testing distribution for penetration testers and security researchers. The repository contains more than 2600 tools. You can install tools individually or in groups. BlackArch Linux is compatible with existing Arch installs. For more information, see the [BlackArch's website](https://www.blackarch.org/).

![BlackArch Logo](https://raw.githubusercontent.com/BlackArch/blackarch-artwork/master/logo/ba-font-transp.png)

## About the images

The root filesystem tarballs for the images is auto-generated weekly at 22:30 UTC on Sunday in Github infrastructure using [Github actions](https://github.com/BlackArch/blackarch-docker/blob/master/.github/workflows/scheduled-docker-publish.yml).

### Special note about the novnc image

You need to run the container with the `--security-opt seccomp=unconfined` options, otherwise, it will fail. See https://gitlab.xfce.org/apps/xfce4-terminal/-/issues/116 and https://github.com/mviereck/x11docker/issues/346 for details.

## Availability

Root filesystem tarballs are provided by Github Actions and are **only** available for 1 week once the new build is triggered.

## Updating

BlackArch Linux is a rolling release distribution, so a full update is recommended when installing new packages. In other words, we suggest either execute RUN `pacman -Syu` immediately after your FROM statement or as soon as you docker run into a container.

## Former Developer/Maintainer

[Eduard Tolosa](https://github.com/Edu4rdSHL)

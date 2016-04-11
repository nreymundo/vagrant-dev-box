# vagrant-dev-box
Lightweight Ubuntu box to use as dev env/playground

## Introduction

This will put together a VM using VirtualBox and Vagrant that will have some of the basic software and settings needed to do java development in as well as Selenium-server and browser drivers to execute local tests againsts. 

## Installation

1. Install [Vagrant](https://www.vagrantup.com).
2. Clone this git repository.
3. Run the command `vagrant up`.

This vagrant works for *Virtualbox*, on a 64 bits machine.

## Software that will be installed

- Ubuntu 14.04 LTS
- Maven3
- Intellij IDEA Community Edition (latest version) + Basic config and google coding style for Java by default.
- Option to use Intellij IDEA Ultimate Edition in `bootstrap.sh` (latest version, you'll need a license for it). 
- Git + some basic aliases in `.gitconfig` and tweaks in `.git-prompt.sh`. 
- Java 8 installed and used by default. 
- Java 7 also present in `/usr/lib/jvm/jdk1.7.0_65/`.
- OpenVPN.
- Gitg. 
- [i3](https://i3wm.org/) as the window manager/desktop environment. 
  - i3 is set by default to use `ALT` as the mod key. Using the windows key isn't the best option when running in a Windows host. 
  - [i3 Reference Card](https://i3wm.org/docs/refcard.html) with basic commands and help. 
  - [i3 User's Guide](https://i3wm.org/docs/userguide.html)

## Browser support

- Firefox (latest version).
- Google Chrome (latest version).

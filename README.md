# Embedded Ada Runtime for WiFiMCU

This is fork of AdaCore's repository to support [WiFiMCU](wifimcu.md).

![photo](wifimcu.jpg)

# embedded-runtimes

This repository contains runtimes that add support for various boards to the
GNAT GPL compiler for ARM.

To build the runtimes: make sure GNAT GPL is in your PATH, and then just invoke
make or make all:

    $ cd embedded-runtimes
    $ make all

Those runtimes can be either runtimes updated from the ones delivered with the
compiler, or new ones.

To use such runtimes, in your project file, you have two options: via
an absolute path or by installing the runtimes.

To reference them directly using their absolute path, you need to specify
in your project file the runtime like below:

    for Runtime ("Ada") use Project'Project_Dir &
       "../embedded-runtimes/ravenscar-stm32f769disco/sfp";

To install the runtime, make sure that GNAT is in your PATH, and use

    $ make install

You will then be able to use it as any standard runtime, either via

    $ gprbuild --RTS=ravenscar-sfp-stm32f769disco -P <my_project>

or add in your project:

    for Runtime ("Ada") use "ravenscar-sfp-stm32f769disco";

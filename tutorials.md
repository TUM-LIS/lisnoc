---
title: Tutorials
layout: default
id: tutorials
---

(This is work-in-progress)

The tutorials are supposed to help you with understanding the LISNoC
basics and operation.

All tutorials are based on [verilator](http://www.veripool.org). You
can either download and build it or use the repository version of your
distribution. Be sure to have the `verilator` executable in your path
and set an evironment variable `VERILATOR_INCLUDE` to point to the
path of `verliated.h` etc. Afterwards the tutorials should all run out
of the box. Always run `make` in the individual tutorial folders under
`tutorials`. You then need to execute the testbench binary and observe
the waveform using e.g., `gtkwave`.

The first two tutorials basically help with understanding flow control
and the difference with virtual channels:

* [Tutorial 1: Flow Control](tutorial_01.html)
* [Tutorial 2: Virtual Channel Basics](tutorial_02.html)

Afterwards we will introduce the router, show how to connect it and
demonstrate the use case for virtual channels:

* [Tutorial 3: The Router](tutorial_03.html)
* [Tutorial 4: Multiple Routers](tutorial_04.html)
* [Tutorial 5: Virtual Channel Routers](tutorial_05.html)

Afterwards different NoC topologies are built from the routers:

* [Tutorial 6: The Router](tutorial_06.html)

More to come..

---
title: Virtual Channels
layout: default
id: virtualchannels
---

Compared to physical channels (that are separate NoCs with strict
ordering), virtual channels are a method to reduce the number of wires
between routers by sharing the flit (data) lines among different
transmission channels.

In LISNoC virtual channels are defined by the flow control signals of
the differenct virtual channels. For each channel there is a bit in
each the `valid` and the `ready` signal, leading to `VCHANNELS` wide
flow control signals.

The flow control dependency restrictions are important here. The
transmission of a flit over a virtual channel is defined as:

* Any number of bits in `ready` may be set
* At each rising edge of the clock, only one (or zero) bits of `valid`
  is allowed to be set
* The transfer occurs if any bit in `ready & valid` is set

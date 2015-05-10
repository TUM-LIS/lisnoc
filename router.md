---
title: Router
layout: default
id: router
---

`lisnoc_router` is the basic router implementation. It has the
following basic parameters:

* `FLIT_DATA_WIDTH` is the actual data transfer width per
  flit. Default: `32`
* `FLIT_TYPE_WIDTH` is the extra bits for packet control. The default
  `2` should not be overwritten at the moment
* `VCHANNELS` is the number of virtual channels. Default: `1` that is
  no virtual channels.
* `IN_FIFO_LENGTH` and `OUT_FIFO_LENGTH` define the number of flits
  that the buffers at input and output port can hold. Default: `4`

The number of input and output ports can be configured with
`INPUT_PORTS` and `OUTPUT_PORTS`. Both of them default to `5` (mesh
router).

Beside this the overall NoC parameters need to be set:

* `NUM_DESTS` is the number of destinations. Default: `32`
* `PH_DEST_WIDTH` is the width of the destination field in the header
  flit. It must match `NUM_DESTS`. Default: `5`

The output port lookup for packets is defined with the `LOOKUP`
parameter which has the width `NUM_DESTS*OUTPUT_PORTS`. For each
destination it has a one-hot field that selects the output port. Such
a lookup "table" is of course not a table, but usually synthesized to
a combinational function by your synthesis tool. As the `LOOKUP` is
most easy configured with concattenation, so that the order of ports
is reversed internally.

The router also allows for priorization of packets, meaning that when
two packets want to use the same output buffer it always chooses the
one with the higher priority (contrary to the default policy round
robin). Priorities are enabled with setting `USE_PRIO` to `1` and then
the next `PH_PRIO_WIDTH` bits after the `PH_DEST_WIDTH` bits are used
to define priorities. You should be careful when using priorities.

### Router Overview

The following sketch shows an overview of the router with
`INPUT_PORTS` number of input stages and `OUTPUT_PORTS` number of
output stages. Each input stage is a router and the lookup
function. The switch can switch at maximum `OUTPUT_PORTS*VCHANNELS`
flits er cycle, which is the maximum. The output stages contain the
output port arbitration. The flits are then buffered and the output
arbiter selects the virtual channel to transfer next.

<div style="text-align:center" markdown="1">
![Router](images/lisnoc_router.png "Router")
</div>

On the outside there are flat signals with ordering port number, then
virtual channel. For example a router with two input ports and two
output ports and two vitual channels is connected like:

    [...]
    .in_valid({in_link_1_valid, in_link_0_valid}),
    .in_ready({in_link_1_ready, in_link_0_ready})
    .in_flit({in_link_1_flit, in_link_0_flit}),

    .out_valid({out_link_1_valid, out_link_0_valid}),
    .out_ready({out_link_1_ready, out_link_0_ready})
    .out_flit({out_link_1_flit, out_link_0_flit}),
    [...]

where the signals are defined like

    wire [VCHANNELS-1:0] in_link_0_valid;
    wire [VCHANNELS-1:0] in_link_0_ready;
    wire [FLIT_WIDTH-1:0] in_link_0_flit;
    
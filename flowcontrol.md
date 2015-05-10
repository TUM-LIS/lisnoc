---
title: Flow Control
layout: default
id: flowcontrol
---

Flow control is actually very simple in LISNoC. There are three
signals in total:

* `flit` is the actual flit data plus packet information as described
  in [Packet Format](packets.html)
* `valid` signals that the sender has a flit to transfer this cycle
* `ready` signals that the receiver can receive a flit this cycle

Now a transfer occurs if both `valid` and `ready` are high during a
clock edge. The following diagram shows the transmission of a three
flit packet:

<div style="text-align:center" markdown="1">
![Flow Control](images/lisnoc_flowcontrol.png "Flow Control")
</div>

### Flow Control Dependencies

Such a simple flow control mechanisms needs some restrictions for
design correctness and timing:

* `ready` must never depend combinationally on `valid`, meaning there
  should be no combinational path from `valid` to `ready` in the
  design 
* `valid` should not not depend combinationally on `ready`, but is
  allowed to.
* If the receiver module must depend on the `valid` signal signal it
  is recommended to use a FIFO as buffer. The FIFO `valid` only
  depends on the fill state.
* If an interface is not exposed to the outside (meaning on the
  interface of your NoC module), you may break the dependency
  rules. An example is the output port arbitration inside the
  router. You should not this clearly in the module definition.
* You should always consider that the combinational path defines the
  timing, so that it is advisable to keep dependencies low. It is also
  advantegeous to note on your module interface whether a `valid` or
  `ready` signal arrives early (such as directly from a register) or
  late (as it goes through many gates). That eases system design.
  
---
title: Routing
layout: default
id: routing
---

LISNoC uses distributed routing. This means that the routing decision
for the output port is done in the router, at least depending on the
flit destination.

The destination of each packet is defined in the first flit (header)
as described in [Packet Format](packets.html "Packet Format"). The
number of bits depends on the total number of addressed modules
connected to a NoC, e.g., 16 in a 4x4 mesh with each one module per
router. The bit width (`PH_DEST_WIDTH`) is defined as
`ceil(ld(NUM_DESTS))`.

The routing depends on the topology and the routers usually need a
lookup table to perform the output port lookup. In meshs we employ
dimension routing (like first X than Y direction) for deadlock
avoidance. If you design your own topology be aware of deadlocks!


	


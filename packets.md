---
title: Packet Format
layout: default
id: packets
---

Principally the NoC consists of elements which are connected by links
with a data width `FLIT_DATA_WIDTH`.  Each transfer of a data item on
such a link is a so called NoC flit. To allow the transfer of larger
blocks of memory multiple flits can be combined to NoC
packets. Therefore, a flit is extended with two extra bits for the
type (`FLIT_TYPE_WIDTH`) which are added at the MSB. The bits indicate
whether this is the first flit in a NoC packet (bit 0) and/or this is
the last flit in a NoC packet (bit 1).

As we employ wormhole rounting, such packet is the indivisble routing
unit. If you have a 32-bit data width, that means, that a flit is
34-bit wide. Those flits form a packet by setting the type bits
accordingly. A packet of length N has the flits `<01,flit 0>`, N-2
times `<00,flit i>`, and finally `<10,flit N-1>`. It is also possible
two have packets of length 1 (`<11,flit 0>`).

The first flit always has the special role of the packet header. The
NoC itself only requires that the first `PH_DEST_WIDTH` contain the
destination id. This is used to perform the routing lookup (as we do
distributed routing). The other bits of the header can be used freely
and the connected modules of course use those bits.

Summarized the NoC has two parameters that define the packet
organization:
	
* `FLIT_DATA_WIDTH` Width of the actual flit data.

* `PH_DEST_WIDTH` Number of most significant bits in the header that
  determine the destination of a packet.

For `FLIT_DATA_WIDTH=32` and a NoC with up to 16 connected modules
(`PH_DEST_WIDTH=4`) the NoC packets are organized like this:

<div style="text-align:center" markdown="1">
![Packet structure](images/lisnoc_packet.png "Packet structure")
</div>
	


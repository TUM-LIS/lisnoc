---
title: Welcome
layout: default
---

LISNoC is a free Network-on-Chip implementation, mainly for academic
or teaching purposes, but freely available for any use under the LGPL
license. It is implemented in Verilog.

It is a straight forward implementation with a strong focus on
easiness to understand the code and extendability.

Main features:

<ul>
  <li>Virtual channel support</li>
  <li>Flexible router configuration (number of input
ports, number of output ports,..)</li>
  <li>Strict ordering</li>
  <li>Round-robin arbitration for link multiplexing</li>
</ul>
	
We only finished documentation roughly, in case of questions, please
contact <a href="mailto:stefan.wallentowitz@tum.de">Stefan
Wallentowitz</a>.

<h2> <a id="getting-started" class="anchor" href="#getting-started"
 aria-hidden="true"><span class="octicon
 octicon-link"></span></a>Getting Started</h2>
	
<p>This section shortly summarize the central concepts and
implementation details of LISNoC. Please contact us to get more
details.</p>

<h3>NoC Packet Organization</h3>

<p>Principally the NoC consists of elements which are connected by
links with a data width <tt>FLIT_DATA_WIDTH</tt>.  Each transfer of a
data item on such a link is a so called NoC flit. To allow the
transfer of larger blocks of memory multiple flits can be combined to
NoC packets. Therefore, a flit is extended with two extra bits for the
type (<tt>FLIT_TYPE_WIDTH</tt>) which are added at the MSB. The bits
indicate whether this is the first flit in a NoC packet (bit 0) and/or
this is the last flit in a NoC packet (bit 1).</p>

<p>As we employ wormhole rounting, such packet is the indivisble
routing unit. If you have a 32-bit data width, that means, that a flit
is 34-bit wide. Those flits form a packet by setting the type bits
accordingly. A packet of length N has the flits <tt>&lt;01,flit
0&gt;</tt>, N-2 times <tt>&lt;00,flit i&gt;</tt>, and finally
<tt>&lt;10,flit N-1&gt;</tt>. It is also possible two have packets of
length 1 (<tt>&lt;11,flit 0&gt;</tt>).</p>

<p>The first flit always has the special role of the packet
header. The NoC itself only requires that the first
<tt>PH_DEST_WIDTH</tt> contain the destination id. This is used to
perform the routing lookup (as we do distributed routing). The other
bits of the header can be used freely and the connected modules of
course use those bits.</p>

<p>Summarized the NoC has two parameters that define the packet
organization:</p>
	
<ul>
  <li><tt>FLIT_DATA_WIDTH</tt> Width of the actual flit data.</li>
  <li><tt>PH_DEST_WIDTH</tt> Number of most significant bits
  in the header that determine the destination of a
  packet.</li> </ul>

<p>For <tt>FLIT_DATA_WIDTH=32</tt> and a NoC with up to 16
connected modules (<tt>PH_DEST_WIDTH=4</tt>) the NoC packets
are organized like this:</p>
	
<center><img src="images/lisnoc_packet.png"/></center>


/**
 * This file is part of LISNoC.
 *
 * LISNoC is free hardware: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version.
 *
 * As the LGPL in general applies to software, the meaning of
 * "linking" is defined as using the LISNoC in your projects at
 * the external interfaces.
 *
 * LISNoC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with LISNoC. If not, see <http://www.gnu.org/licenses/>.
 *
 * =================================================================
 *
 * This is the 2x2-port router for the unidirectional ring noc.
 *
 * (c) 2011 by the author(s)
 *
 * Author(s):
 *    Andreas Lankes, andreas.lankes@tum.de
 */

`include "lisnoc_def.vh"

module lisnoc_router_uni_ring( /*AUTOARG*/
   ring_in_flit, ring_in_valid, ring_in_ready,
   ring_out_flit, ring_out_valid, ring_out_ready,
   local_in_flit, local_in_valid, local_in_ready,
   local_out_flit, local_out_valid, local_out_ready,
   clk, rst
   );

   parameter flit_data_width = 32;
   parameter flit_type_width = 2;
   localparam flit_width = flit_data_width+flit_type_width;
   localparam ports = 2;
   parameter ph_dest_width = 5;
   parameter num_dests = 32;

   parameter vchannels = 1;

   parameter in_fifo_length = 4;
   parameter out_fifo_length = 4;

   parameter [ports*num_dests-1:0] lookup = {num_dests{`SELECT_NONE }};

   input clk, rst;


   output [flit_width-1:0] ring_out_flit;
   output [vchannels-1:0]   ring_out_valid;
   input [vchannels-1:0]    ring_out_ready;

   input [flit_width-1:0]  ring_in_flit;
   input [vchannels-1:0]    ring_in_valid;
   output [vchannels-1:0]   ring_in_ready;

   output [flit_width-1:0]  local_out_flit;
   output [vchannels-1:0]    local_out_valid;
   input [vchannels-1:0]   local_out_ready;

   input [flit_width-1:0]  local_in_flit;
   input [vchannels-1:0]    local_in_valid;
   output [vchannels-1:0]   local_in_ready;

   lisnoc_router #(.vchannels(vchannels),.input_ports(ports),.output_ports(ports),
         .lookup(lookup),.num_dests(num_dests), .flit_data_width(flit_data_width),
         .flit_type_width(flit_type_width), .ph_dest_width(ph_dest_width),
         .in_fifo_length(in_fifo_length), .out_fifo_length(out_fifo_length))
     u_router(/*AUTOINST*/
         // noc output interfaces
         .out_flit         ({local_out_flit, ring_out_flit}), // Templated
         .out_valid     ({local_out_valid, ring_out_valid}), // Templated
         .out_ready         ({local_out_ready, ring_out_ready}), // Templated
         // noc input interfaces
         .clk        (clk),
         .rst        (rst),
         .in_ready     ({local_in_ready, ring_in_ready}), // Templated
         .in_flit       ({local_in_flit, ring_in_flit}), // Templated
         .in_valid         ({local_in_valid, ring_in_valid})); // Templated


endmodule // lisnoc_router

`include "lisnoc_undef.vh"

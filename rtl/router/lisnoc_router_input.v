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
 * This module is an input port. It instantiates a FIFO and a decode module
 * for each virtual channel and aggregates the interfaces.
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *
 * TODO:
 *  - when FIFO is empty, the flit can go to decode directly
 */

`include "lisnoc_def.vh"

module lisnoc_router_input( /*AUTOARG*/
   // Outputs
   link_ready, switch_request, switch_flit,
   // Inputs
   clk, rst, link_flit, link_valid, switch_read
   );

   parameter flit_data_width = 32;
   parameter flit_type_width = 2;
   localparam flit_width = flit_data_width+flit_type_width;
   parameter ph_dest_width = 5;

   parameter vchannels = 1;

   parameter ports = 5;

   parameter fifo_length = 4;
   
   // The number of destinations is a parameter of each port.
   // It should in general be equal for all routers in a NoC and
   // must be within the range defined by FLIT_DEST_WIDTH.
   parameter num_dests = 1;

   // The externally defined destination->direction lookup
   // It is the concatenation of directions-width elements starting
   // with destination 0:
   //  { destination0_direction, destination1_direction, ... }
   parameter [ports*num_dests-1:0] lookup = {num_dests{`SELECT_NONE }};

   // Generic stuff
   input clk, rst;
   
   // The link interface
   input [flit_width-1:0] link_flit;  // current flit
   input [vchannels-1:0]   link_valid; // current valid for which channel
   output [vchannels-1:0]  link_ready; // notification when registered

   // The switch interface
   output [ports*vchannels-1:0]       switch_request;     // direction requests
   output [flit_width*vchannels-1:0] switch_flit;        // corresponding flit
   input [ports*vchannels-1:0]        switch_read;        // destination acknowledge

   wire [ports-1:0]                   switch_request_array [0:vchannels-1];
   wire [flit_width-1:0]              switch_flit_array [0:vchannels-1];
   wire [ports-1:0]                   switch_read_array [0:vchannels-1];

   genvar v;
  
   generate
      for (v=0;v<vchannels;v=v+1) begin: vchannel
         wire                   fifo_valid;
         wire [flit_width-1:0] fifo_flit;
         wire                   fifo_ready;

         assign switch_request[(v+1)*ports-1:v*ports] = switch_request_array[v];
         assign switch_flit[(v+1)*flit_width-1:v*flit_width] = switch_flit_array[v];
         assign switch_read_array[v] = switch_read[(v+1)*ports-1:v*ports];
         
         /* lisnoc_fifo AUTO_TEMPLATE (
          .in_ready  (link_ready[v]),
          .out_flit  (fifo_flit[flit_width-1:0]),
          .out_valid (fifo_valid),
          .in_flit   (link_flit),
          .in_valid  (link_valid[v]),
          .out_ready (fifo_ready),
          ); */
         lisnoc_fifo #(.LENGTH(fifo_length),.flit_data_width(flit_data_width), 
         .flit_type_width(flit_type_width))
           fifo (/*AUTOINST*/
                 // Outputs
                 .in_ready              (link_ready[v]),         // Templated
                 .out_flit              (fifo_flit[flit_width-1:0]), // Templated
                 .out_valid             (fifo_valid),            // Templated
                 // Inputs
                 .clk                   (clk),
                 .rst                   (rst),
                 .in_flit               (link_flit),             // Templated
                 .in_valid              (link_valid[v]),         // Templated
                 .out_ready             (fifo_ready));           // Templated

         lisnoc_router_input_route
           # (.num_dests(num_dests),.lookup(lookup),
              .flit_data_width(flit_data_width),.flit_type_width(flit_type_width), 
         .ph_dest_width(ph_dest_width), .directions(ports))
         route(// Outputs
                .fifo_ready     (fifo_ready),
                .switch_request (switch_request_array[v]),
                .switch_flit    (switch_flit_array[v]),
                // Inputs
                .clk            (clk),
                .rst            (rst),
                .switch_read    (switch_read_array[v]),
                .fifo_flit      (fifo_flit),
                .fifo_valid     (fifo_valid));
 
      end // for (i=0;i<vchannels;i=i+1)
      
   endgenerate
   
endmodule // noc_router_input

`include "lisnoc_undef.vh"

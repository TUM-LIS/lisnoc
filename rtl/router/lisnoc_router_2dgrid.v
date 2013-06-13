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
 * This is the 5-port router toplevel.
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s):
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 */

`include "lisnoc_def.vh"

module lisnoc_router_2dgrid( /*AUTOARG*/
   // Outputs
   north_out_flit_o, north_out_valid_o, east_out_flit_o,
   east_out_valid_o, south_out_flit_o, south_out_valid_o,
   west_out_flit_o, west_out_valid_o, local_out_flit_o,
   local_out_valid_o, north_in_ready_o, east_in_ready_o,
   south_in_ready_o, west_in_ready_o, local_in_ready_o,
   // Inputs
   clk, rst, north_out_ready_i, east_out_ready_i, south_out_ready_i,
   west_out_ready_i, local_out_ready_i, north_in_flit_i,
   north_in_valid_i, east_in_flit_i, east_in_valid_i, south_in_flit_i,
   south_in_valid_i, west_in_flit_i, west_in_valid_i, local_in_flit_i,
   local_in_valid_i
   );

   parameter  flit_data_width = 32;
   parameter  flit_type_width = 2;
   localparam flit_width = flit_data_width+flit_type_width;
   parameter  ph_dest_width = 5;
   parameter  num_dests = 16; 
   
   parameter use_prio = 0;
   parameter ph_prio_width = 4;
     
   parameter vchannels = 2;

   localparam ports = 5;

   parameter in_fifo_length = 4;
   parameter out_fifo_length = 4;   
   
   parameter [ports*num_dests-1:0] lookup = {num_dests{`SELECT_NONE}};

   input clk, rst;
   
   output [flit_width-1:0] north_out_flit_o;
   output [vchannels-1:0]   north_out_valid_o;
   input [vchannels-1:0]    north_out_ready_i;
   output [flit_width-1:0] east_out_flit_o;
   output [vchannels-1:0]   east_out_valid_o;
   input [vchannels-1:0]    east_out_ready_i;
   output [flit_width-1:0] south_out_flit_o;
   output [vchannels-1:0]   south_out_valid_o;
   input [vchannels-1:0]    south_out_ready_i;
   output [flit_width-1:0] west_out_flit_o;
   output [vchannels-1:0]   west_out_valid_o;
   input [vchannels-1:0]    west_out_ready_i;
   output [flit_width-1:0] local_out_flit_o;
   output [vchannels-1:0]   local_out_valid_o;
   input [vchannels-1:0]    local_out_ready_i;
   
   input [flit_width-1:0]  north_in_flit_i;
   input [vchannels-1:0]    north_in_valid_i;
   output [vchannels-1:0]   north_in_ready_o;
   input [flit_width-1:0]  east_in_flit_i;
   input [vchannels-1:0]    east_in_valid_i;
   output [vchannels-1:0]   east_in_ready_o;
   input [flit_width-1:0]  south_in_flit_i;
   input [vchannels-1:0]    south_in_valid_i;
   output [vchannels-1:0]   south_in_ready_o;
   input [flit_width-1:0]  west_in_flit_i;
   input [vchannels-1:0]    west_in_valid_i;
   output [vchannels-1:0]   west_in_ready_o;
   input [flit_width-1:0]  local_in_flit_i;
   input [vchannels-1:0]    local_in_valid_i;
   output [vchannels-1:0]   local_in_ready_o;

   /* lisnoc_router AUTO_TEMPLATE(
    .out_flit ({north_out_flit_o,east_out_flit_o,south_out_flit_o,west_out_flit_o,local_out_flit_o}),
    .out_valid ({north_out_valid_o,east_out_valid_o,south_out_valid_o,west_out_valid_o,local_out_valid_o}),
    .out_ready ({north_out_ready_i,east_out_ready_i,south_out_ready_i,west_out_ready_i,local_out_ready_i}),
    .in_flit ({north_in_flit_i,east_in_flit_i,south_in_flit_i,west_in_flit_i,local_in_flit_i}),
    .in_valid ({north_in_valid_i,east_in_valid_i,south_in_valid_i,west_in_valid_i,local_in_valid_i}),
    .in_ready ({north_in_ready_o,east_in_ready_o,south_in_ready_o,west_in_ready_o,local_in_ready_o}),
    ); */
   lisnoc_router #(.vchannels(vchannels),.input_ports(5),.output_ports(5),.lookup(lookup),.num_dests(num_dests),
   .flit_data_width(flit_data_width), .flit_type_width(flit_type_width), .ph_dest_width(ph_dest_width),.use_prio(use_prio),
   .ph_prio_width(ph_prio_width),.in_fifo_length(in_fifo_length),.out_fifo_length(out_fifo_length))
   u_router(/*AUTOINST*/
              // Outputs
              .out_flit                 ({local_out_flit_o,west_out_flit_o,south_out_flit_o,east_out_flit_o,north_out_flit_o}), // Templated
              .out_valid                ({local_out_valid_o,west_out_valid_o,south_out_valid_o,east_out_valid_o,north_out_valid_o}), // Templated
              .in_ready                 ({local_in_ready_o,west_in_ready_o,south_in_ready_o,east_in_ready_o,north_in_ready_o}), // Templated
              // Inputs
              .clk                      (clk),
              .rst                      (rst),
              .out_ready                ({local_out_ready_i,west_out_ready_i,south_out_ready_i,east_out_ready_i,north_out_ready_i}), // Templated
              .in_flit                  ({local_in_flit_i,west_in_flit_i,south_in_flit_i,east_in_flit_i,north_in_flit_i}), // Templated
              .in_valid                 ({local_in_valid_i,west_in_valid_i,south_in_valid_i,east_in_valid_i,north_in_valid_i})); // Templated
   
   
endmodule // lisnoc_2dgrid_router

`include "lisnoc_undef.vh"
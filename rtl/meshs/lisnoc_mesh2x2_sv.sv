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
 * This is the SystemVerilog wrapper for the router.
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s):
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 */

`include "lisnoc_def_mc.vh"

module lisnoc_mesh2x2_sv
  (
   lisnoc_link_if link0_out,
   lisnoc_link_if link0_in,
   lisnoc_link_if link1_out,
   lisnoc_link_if link1_in,
   lisnoc_link_if link2_out,
   lisnoc_link_if link2_in,
   lisnoc_link_if link3_out,
   lisnoc_link_if link3_in,
   input clk, rst
   );
   
   parameter vchannels = 1;
   
   wire [`FLIT_WIDTH-1:0] link0_in_flit_i;
   wire [vchannels-1:0]   link0_in_valid_i;
   wire [vchannels-1:0]   link0_in_ready_o;
   wire [`FLIT_WIDTH-1:0] link0_out_flit_o;
   wire [vchannels-1:0]   link0_out_valid_o;
   wire [vchannels-1:0]   link0_out_ready_i;

   wire [`FLIT_WIDTH-1:0] link1_in_flit_i;
   wire [vchannels-1:0]   link1_in_valid_i;
   wire [vchannels-1:0]   link1_in_ready_o;
   wire [`FLIT_WIDTH-1:0] link1_out_flit_o;
   wire [vchannels-1:0]   link1_out_valid_o;
   wire [vchannels-1:0]   link1_out_ready_i;

   wire [`FLIT_WIDTH-1:0] link2_in_flit_i;
   wire [vchannels-1:0]   link2_in_valid_i;
   wire [vchannels-1:0]   link2_in_ready_o;
   wire [`FLIT_WIDTH-1:0] link2_out_flit_o;
   wire [vchannels-1:0]   link2_out_valid_o;
   wire [vchannels-1:0]   link2_out_ready_i;

   wire [`FLIT_WIDTH-1:0] link3_in_flit_i;
   wire [vchannels-1:0]   link3_in_valid_i;
   wire [vchannels-1:0]   link3_in_ready_o;
   wire [`FLIT_WIDTH-1:0] link3_out_flit_o;
   wire [vchannels-1:0]   link3_out_valid_o;
   wire [vchannels-1:0]   link3_out_ready_i;
   
   assign link0_out.flit    = link0_out_flit_o;
   assign link0_out.valid   = link0_out_valid_o;
   assign link0_out_ready_i = link0_out.ready;  
   assign link1_out.flit    = link1_out_flit_o;
   assign link1_out.valid   = link1_out_valid_o;
   assign link1_out_ready_i = link1_out.ready;
   assign link2_out.flit    = link2_out_flit_o;
   assign link2_out.valid   = link2_out_valid_o;
   assign link2_out_ready_i = link2_out.ready;
   assign link3_out.flit    = link3_out_flit_o;
   assign link3_out.valid   = link3_out_valid_o;
   assign link3_out_ready_i = link3_out.ready;

   assign link0_in_flit_i  = link0_in.flit;
   assign link0_in_valid_i = link0_in.valid;
   assign link0_in.ready   = link0_in_ready_o;
   assign link1_in_flit_i  = link1_in.flit;
   assign link1_in_valid_i = link1_in.valid;
   assign link1_in.ready   = link1_in_ready_o;
   assign link2_in_flit_i  = link2_in.flit;
   assign link2_in_valid_i = link2_in.valid;
   assign link2_in.ready   = link2_in_ready_o;
   assign link3_in_flit_i  = link3_in.flit;
   assign link3_in_valid_i = link3_in.valid;
   assign link3_in.ready   = link3_in_ready_o;
   
   lisnoc_mesh2x2 #(.vchannels(vchannels))
   mesh2x2_v(/*AUTOINST*/
	     // Outputs
	     .link0_in_ready_o		(link0_in_ready_o[vchannels-1:0]),
	     .link0_out_flit_o		(link0_out_flit_o[`FLIT_WIDTH-1:0]),
	     .link0_out_valid_o		(link0_out_valid_o[vchannels-1:0]),
	     .link1_in_ready_o		(link1_in_ready_o[vchannels-1:0]),
	     .link1_out_flit_o		(link1_out_flit_o[`FLIT_WIDTH-1:0]),
	     .link1_out_valid_o		(link1_out_valid_o[vchannels-1:0]),
	     .link2_in_ready_o		(link2_in_ready_o[vchannels-1:0]),
	     .link2_out_flit_o		(link2_out_flit_o[`FLIT_WIDTH-1:0]),
	     .link2_out_valid_o		(link2_out_valid_o[vchannels-1:0]),
	     .link3_in_ready_o		(link3_in_ready_o[vchannels-1:0]),
	     .link3_out_flit_o		(link3_out_flit_o[`FLIT_WIDTH-1:0]),
	     .link3_out_valid_o		(link3_out_valid_o[vchannels-1:0]),
	     // Inputs
	     .clk			(clk),
	     .rst			(rst),
	     .link0_in_flit_i		(link0_in_flit_i[`FLIT_WIDTH-1:0]),
	     .link0_in_valid_i		(link0_in_valid_i[vchannels-1:0]),
	     .link0_out_ready_i		(link0_out_ready_i[vchannels-1:0]),
	     .link1_in_flit_i		(link1_in_flit_i[`FLIT_WIDTH-1:0]),
	     .link1_in_valid_i		(link1_in_valid_i[vchannels-1:0]),
	     .link1_out_ready_i		(link1_out_ready_i[vchannels-1:0]),
	     .link2_in_flit_i		(link2_in_flit_i[`FLIT_WIDTH-1:0]),
	     .link2_in_valid_i		(link2_in_valid_i[vchannels-1:0]),
	     .link2_out_ready_i		(link2_out_ready_i[vchannels-1:0]),
	     .link3_in_flit_i		(link3_in_flit_i[`FLIT_WIDTH-1:0]),
	     .link3_in_valid_i		(link3_in_valid_i[vchannels-1:0]),
	     .link3_out_ready_i		(link3_out_ready_i[vchannels-1:0]));
   
	     
   
   
endmodule // lisnoc_mesh2x2_sv

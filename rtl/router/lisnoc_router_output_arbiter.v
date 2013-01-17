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
 * This is the arbiter for the link, that chooses one virtual channel
 * to transfer to the next hop.
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s): 
 *    Andreas Lankes, andreas.lankes@tum.de
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *
 * TODO:
 *  - check for one-hot coding of channel
 */

`include "lisnoc_def.vh"

module lisnoc_router_output_arbiter(/*AUTOARG*/
   // Outputs
   fifo_ready_o, link_valid_o, link_flit_o,
   // Inputs
   clk, rst, fifo_valid_i, fifo_flit_i, link_ready_i
   );

   parameter flit_data_width = 32;
   parameter flit_type_width = 2;
   localparam flit_width = flit_data_width+flit_type_width;


   parameter vchannels = 1;

   localparam CHANNEL_WIDTH = $clog2(vchannels);
// localparam CHANNEL_WIDTH = 1;

   input                  clk, rst;

   
   // fifo side
   input [vchannels-1:0]            fifo_valid_i;
   input [vchannels*flit_width-1:0] fifo_flit_i;
   output reg [vchannels-1:0]        fifo_ready_o;
      

   output reg [vchannels-1:0]        link_valid_o;
   output [flit_width-1:0]           link_flit_o;
   input [vchannels-1:0]             link_ready_i;


   // channel that was last served in the round robin process
   reg [CHANNEL_WIDTH-1:0]           prev_channel;

   wire [vchannels-1:0]              serviceable;
   assign serviceable = (fifo_valid_i) & link_ready_i;
   
   reg [CHANNEL_WIDTH-1:0]           channel;
   

   reg [CHANNEL_WIDTH-1:0]           sel_channel;
   reg                               channel_selected;

   wire [flit_width-1:0]             fifo_flit_i_array [0:vchannels-1];
   genvar                            v;
   for (v=0;v<vchannels;v=v+1) begin
      assign fifo_flit_i_array[v] = fifo_flit_i[(v+1)*flit_width-1:v*flit_width];
   end
   
   assign link_flit_o = fifo_flit_i_array[channel];

   always @ (*) begin
      if (rst) begin
         link_valid_o = {vchannels{1'b0}};      
         channel  = 3'b000;
         fifo_ready_o  = {vchannels{1'b0}};
      end else begin
         channel  = prev_channel;
         link_valid_o = {vchannels{1'b0}};
         fifo_ready_o  = {vchannels{1'b0}};
         
         sel_channel = channel;
         channel_selected = 0;
         
         repeat (vchannels) begin
            sel_channel = sel_channel + 1;
            if (sel_channel == vchannels)
               sel_channel = 0;
            
            // check if we can serve this channel
            if (serviceable[sel_channel]) begin
               channel = sel_channel;
               channel_selected = 1;
            end 
         end // repeat
         
         if (channel_selected) begin
            link_valid_o[channel] = 1'b1;
            fifo_ready_o[channel] = 1'b1;
         end
      end // if
   end // always

   always @(posedge clk) begin
      prev_channel <= channel;
   end
   
endmodule // lisnoc_router_output_arbiter

`include "lisnoc_undef.vh"

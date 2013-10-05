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
 * This is a deserializer for virtual channels
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s):
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de, 
 *    Alexandra Weber, sandra.eli.weber@mytum.de
 */

// TODO: Make more flexible by lookup vector class->vc

module lisnoc_vc_deserializer(
   //output
   flit_o, valid_o, ready_for_input,
   //input
   flit_i, valid_i, ready_for_output,
   clk, rst
   );

   parameter flit_data_width = 32;
   parameter flit_type_width = 2;
   localparam flit_width = flit_data_width + flit_type_width;

   parameter FLIT_TYPE_HEADER = 2'b01;
   parameter FLIT_TYPE_PAYLOAD = 2'b00;
   parameter FLIT_TYPE_LAST = 2'b10;
   parameter FLIT_TYPE_SINGLE = 2'b11;

   // every vchannel gets the packets of one class
   parameter class_msb = 21;
   parameter class_lsb = 20;
   parameter class_width = 2;

   // number of output vchannels
   parameter vchannels = 2;

   input clk;
   input rst;

   // array of readys from the vchannels
   input [vchannels-1:0] ready_for_output;

   // not-full signal from the fifo
   output reg ready_for_input;

   // one vchannel in (serialized)
   input [flit_width-1:0] flit_i;
   input valid_i;

   // n-vchannel out (multiple vchannels)
   output reg [flit_width-1:0] flit_o;
   output reg [vchannels-1:0] valid_o;

   reg [flit_width-1:0] nxt_flit_o;
   reg [vchannels-1:0] nxt_valid_o;

   reg [class_width-1:0] req_vchannel;
   reg [class_width-1:0] nxt_req_vchannel;

   reg state;
   reg nxt_state;
   

   always @ (*) begin: fsm

      localparam WAITING = 1'b0;
      localparam SENDING = 1'b1;

   case (state)

      WAITING: begin

         nxt_flit_o = 'hx;
         nxt_valid_o = {vchannels{1'b0}};
         ready_for_input = 1'b0;
         if(flit_i[flit_width-1:flit_width-2] == FLIT_TYPE_HEADER || 
            flit_i[flit_width-1:flit_width-2] == FLIT_TYPE_SINGLE) begin
            nxt_req_vchannel = flit_i[class_msb:class_lsb];
            nxt_state = SENDING;
            nxt_flit_o = flit_i;
            ready_for_input = 1'b1;
            nxt_valid_o[nxt_req_vchannel] = 1'b1;
         end else begin
            nxt_req_vchannel = req_vchannel;
            nxt_state = WAITING;
            ready_for_input = 1'b0;
         end
      end


      SENDING: begin : sending
        nxt_flit_o = flit_o;
        nxt_valid_o[req_vchannel] = 1'b1;
        if(ready_for_output[req_vchannel] == 1'b1) begin
               ready_for_input = 1'b1;
               nxt_flit_o = flit_i;
               if(flit_o[flit_width-1:flit_width-2] == FLIT_TYPE_SINGLE || 
                  flit_o[flit_width-1:flit_width-2] == FLIT_TYPE_LAST) begin
                  nxt_state = WAITING;
                  nxt_valid_o[nxt_req_vchannel] = 1'b0;
               end else begin
                  nxt_state = SENDING;
               end
        end else begin
          ready_for_input = 1'b0;
          nxt_state = state;
          nxt_flit_o = flit_o;
       end
      end

   endcase

   end

   always @ (posedge clk) begin
      if(rst == 1'b1) begin
         flit_o = 'hx;
         valid_o = {vchannels{1'b0}};
         state = 1'b0;
      end else begin
         flit_o = nxt_flit_o;
         valid_o = nxt_valid_o;
         req_vchannel = nxt_req_vchannel;
         state = nxt_state;
      end
   end

endmodule

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
 * This is the FIFO used in the input and output port.
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 */

`include "lisnoc_def.vh"

module lisnoc_fifo(/*AUTOARG*/
   // Outputs
   in_ready, out_flit, out_valid,
   // Inputs
   clk, rst, in_flit, in_valid, out_ready
   );
  
   parameter flit_data_width = 32;
   parameter flit_type_width = 2;
   parameter packet_length   = 0;
   
   localparam flit_width = flit_data_width+flit_type_width;

   parameter LENGTH = 16;
   
   input  clk; 
   input  rst; 
   
   // FIFO input side
   input  [flit_width-1:0] in_flit;  // input   
   input  in_valid;                   // write_enable
   output in_ready;                   // accepting new data
   
   //FIFO output side
   output [flit_width-1:0] out_flit;  // data_out
   output out_valid;                   // data available
   input  out_ready;                   // read request

   // Signals for fifo
   reg [flit_width-1:0] fifo_data [0:LENGTH-1]; //actual fifo
   reg [flit_width-1:0] nxt_fifo_data [0:LENGTH-1];

   reg [LENGTH:0]         fifo_write_ptr;

   wire                   pop;
   wire                   push;

   assign pop = out_valid & out_ready;
   assign push = in_valid & in_ready;

   assign out_flit = fifo_data[0];
   assign out_valid = !fifo_write_ptr[0];

   assign in_ready = !fifo_write_ptr[LENGTH];
   
   always @(posedge clk) begin
      if (rst) begin
         fifo_write_ptr <= {{LENGTH{1'b0}},1'b1};
      end else if (push & !pop) begin
         fifo_write_ptr <= fifo_write_ptr << 1;
      end else if (!push & pop) begin
         fifo_write_ptr <= fifo_write_ptr >> 1;
      end
   end

   always @(*) begin : shift_register_comb
      integer i;
      for (i=0;i<LENGTH;i=i+1) begin
         if (pop) begin
            if (push & fifo_write_ptr[i+1]) begin
               nxt_fifo_data[i] = in_flit;
            end else if (i<LENGTH-1) begin
               nxt_fifo_data[i] = fifo_data[i+1];
            end else begin
               nxt_fifo_data[i] = fifo_data[i];
            end
         end else if (push & fifo_write_ptr[i]) begin
            nxt_fifo_data[i] = in_flit;
         end else begin
            nxt_fifo_data[i] = fifo_data[i];
         end
      end      
   end

   always @(posedge clk) begin : shift_register_seq
      integer i;
      for (i=0;i<LENGTH;i=i+1) begin
        fifo_data[i] <= nxt_fifo_data[i];
      end
   end

endmodule // noc_fifo

`include "lisnoc_undef.vh"
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
 * The packet buffer is similar to a FIFO but does only signal a flit
 * at the output when a complete packet is in the buffer. This relaxes
 * backpressure problems that may arise.
 * 
 * (c) 2011-2013 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *
 */

`include "lisnoc_def.vh"

module lisnoc_packet_buffer(/*AUTOARG*/
   // Outputs
   in_ready, out_flit, out_valid, out_size,
   // Inputs
   clk, rst, in_flit, in_valid, out_ready
   );

   parameter data_width = 32;
   localparam flit_width = data_width+2;

   parameter  fifo_depth = 16;
   localparam size_width = clog2(fifo_depth);
   
   localparam READY = 1'b0, BUSY = 1'b1;
   
   //inputs
   input                   clk, rst;
   input [flit_width-1:0]  in_flit;
   input                   in_valid;
   output                  in_ready;

   output [flit_width-1:0] out_flit;
   output                  out_valid;
   input                   out_ready;

   output reg [size_width-1:0] out_size;
    
   // Signals for fifo
   reg [flit_width-1:0] fifo_data [0:fifo_depth]; //actual fifo
   reg [fifo_depth:0]   fifo_write_ptr;

   reg [fifo_depth:0]   last_flits;
   
   wire                 full_packet;
   wire                 pop;
   wire                 push;

   wire [1:0] in_flit_type;
   assign in_flit_type = in_flit[flit_width-1:flit_width-2];
 
   wire                        in_is_last;
   assign in_is_last = (in_flit_type == `FLIT_TYPE_LAST) || (in_flit_type == `FLIT_TYPE_SINGLE);

   reg [fifo_depth-1:0]        valid_flits;

   always @(*) begin : valid_flits_comb
      integer i;
      // Set first element
      valid_flits[fifo_depth-1] = fifo_write_ptr[fifo_depth];
      for (i=fifo_depth-2;i>=0;i=i-1) begin
         valid_flits[i] = fifo_write_ptr[i+1] | valid_flits[i+1];
      end
   end
   
   assign full_packet = |(last_flits & valid_flits);

   assign pop = out_valid & out_ready;
   assign push = in_valid & in_ready;

   assign out_flit = fifo_data[0];
   assign out_valid = full_packet;

   assign in_ready = !fifo_write_ptr[fifo_depth];

   always @(*) begin : findfirstlast
      integer i;
      integer s;
      reg    found;

      s = 0;
      found = 0;
      
      for (i=0;i<fifo_depth-1;i=i+1) begin
         if (last_flits[i] && !found) begin
            s = i+1;
            found = 1;
         end
      end
      out_size = s;
   end
   
   always @(posedge clk) begin
      if (rst) begin
         fifo_write_ptr <= {{fifo_depth{1'b0}},1'b1};
      end else if (push & !pop) begin
         fifo_write_ptr <= fifo_write_ptr << 1;
      end else if (!push & pop) begin
         fifo_write_ptr <= fifo_write_ptr >> 1;
      end
   end

   always @(posedge clk) begin : shift_register
      if (rst) begin
         last_flits <= {fifo_depth+1{1'b0}};
      end else begin : shift
         integer i;
         for (i=0;i<fifo_depth-1;i=i+1) begin
            if (pop) begin
               if (push & fifo_write_ptr[i+1]) begin
                  fifo_data[i] <= in_flit;
                  last_flits[i] <= in_is_last;
               end else begin
                  fifo_data[i] <= fifo_data[i+1];
                  last_flits[i] <= last_flits[i+1];
               end
            end else if (push & fifo_write_ptr[i]) begin
               fifo_data[i] <= in_flit;
               last_flits[i] <= in_is_last;
            end
         end // for (i=0;i<fifo_depth-1;i=i+1)

         // Handle last element
         if (pop &  push & fifo_write_ptr[i+1]) begin
            fifo_data[i] <= in_flit;
            last_flits[i] <= in_is_last;
         end else if (push & fifo_write_ptr[i]) begin
            fifo_data[i] <= in_flit;
            last_flits[i] <= in_is_last;
         end
      end
   end // block: shift_register

   function integer clog2;
      input integer value;
      begin
         value = value-1;
         for (clog2=0; value>0; clog2=clog2+1)
           value = value>>1;
      end
   endfunction
   
endmodule
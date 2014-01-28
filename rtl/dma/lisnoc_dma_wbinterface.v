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
 * The wishbone slave interface to configure the DMA module.
 * 
 * (c) 2011-2013 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *
 */

`include "lisnoc_dma_def.vh"

module lisnoc_dma_wbinterface(/*AUTOARG*/
   // Outputs
   wb_if_dat_o, wb_if_ack_o, if_write_req, if_write_pos,
   if_write_select, if_write_en, if_valid_pos, if_valid_set,
   if_valid_en, if_validrd_en,
   // Inputs
   clk, rst, wb_if_adr_i, wb_if_dat_i, wb_if_cyc_i, wb_if_stb_i,
   wb_if_we_i, done
   );

   parameter table_entries = 4;
//   localparam table_entries_ptrwidth = $clog2(table_entries);
   localparam table_entries_ptrwidth = 2;

   parameter tileid = 0; // TODO: remove
   
   input clk,rst;
   
   input [31:0]             wb_if_adr_i;
   input [31:0]             wb_if_dat_i;
   input                    wb_if_cyc_i;
   input                    wb_if_stb_i;
   input                    wb_if_we_i;
   output reg [31:0]        wb_if_dat_o;
   output                   wb_if_ack_o;
   
   output [`DMA_REQUEST_WIDTH-1:0]     if_write_req;
   output [table_entries_ptrwidth-1:0] if_write_pos;
   output [`DMA_REQMASK_WIDTH-1:0]     if_write_select;
   output                              if_write_en;
   
   // Interface read (status) interface
   output [table_entries_ptrwidth-1:0]    if_valid_pos;
   output                                 if_valid_set;
   output                                 if_valid_en;
   output                                 if_validrd_en;

   input [table_entries-1:0]              done;

   assign if_write_req = { wb_if_dat_i[`DMA_REQFIELD_LADDR_WIDTH-1:0],
                           wb_if_dat_i[`DMA_REQFIELD_SIZE_WIDTH-1:0],
                           wb_if_dat_i[`DMA_REQFIELD_RTILE_WIDTH-1:0],
                           wb_if_dat_i[`DMA_REQFIELD_RADDR_WIDTH-1:0],
                           wb_if_dat_i[0] };

   assign if_write_pos = wb_if_adr_i[table_entries_ptrwidth+4:5]; // ptrwidth MUST be <= 7 (=128 entries)
   assign if_write_en  = wb_if_cyc_i & wb_if_stb_i & wb_if_we_i;

   assign if_valid_pos = wb_if_adr_i[table_entries_ptrwidth+4:5]; // ptrwidth MUST be <= 7 (=128 entries)
   assign if_valid_en  = wb_if_cyc_i & wb_if_stb_i & (wb_if_adr_i[4:0] == 5'h14) & wb_if_we_i;
   assign if_validrd_en  = wb_if_cyc_i & wb_if_stb_i & (wb_if_adr_i[4:0] == 5'h14) & ~wb_if_we_i;
   assign if_valid_set = wb_if_we_i | (~wb_if_we_i & ~done[if_valid_pos]);

   assign wb_if_ack_o = wb_if_cyc_i & wb_if_stb_i;

   always @(*) begin
      if (wb_if_adr_i[4:0] == 5'h14) begin
         wb_if_dat_o = {31'h0,done[if_valid_pos]};
      end
   end
   
   genvar  i;
   // This assumes, that mask and address match
   generate
      for (i=0;i<`DMA_REQMASK_WIDTH;i=i+1) begin
         assign if_write_select[i] = (wb_if_adr_i[4:2] == i);
      end
   endgenerate
   
endmodule // lisnoc_dma_wbinterface

`include "lisnoc_dma_undef.vh"

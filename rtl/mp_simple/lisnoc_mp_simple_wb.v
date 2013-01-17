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
 * The wishbone slave interface to access the simple message passing.
 * 
 * (c) 2012-2013 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *
 */

module lisnoc_mp_simple_wb(/*AUTOARG*/
   // Outputs
   noc_out_flit, noc_out_valid, noc_in_ready, wb_dat_o, wb_ack_o, irq,
   // Inputs
   clk, rst, noc_out_ready, noc_in_flit, noc_in_valid, wb_adr_i,
   wb_we_i, wb_cyc_i, wb_stb_i, wb_dat_i
   );

   parameter noc_data_width = 32;
   parameter noc_type_width = 2;
   localparam noc_flit_width = noc_data_width + noc_type_width;

   parameter size_width = 4;
   
   input clk;
   input rst;

   // NoC interface
   output [noc_flit_width-1:0] noc_out_flit;
   output                      noc_out_valid;
   input                       noc_out_ready;

   input [noc_flit_width-1:0] noc_in_flit;
   input                      noc_in_valid;
   output                     noc_in_ready;

   input [5:0]                wb_adr_i;
   input                      wb_we_i;
   input                      wb_cyc_i;
   input                      wb_stb_i;
   input [noc_data_width-1:0] wb_dat_i;
   output [noc_data_width-1:0] wb_dat_o;
   output                     wb_ack_o;

   output                     irq;
   
   // Bus side (generic)
   wire [5:0]                  bus_addr;
   wire                        bus_we;
   wire                        bus_en;
   wire [noc_data_width-1:0]   bus_data_in;
   wire [noc_data_width-1:0]   bus_data_out;
   wire                        bus_ack;

   assign bus_addr    = wb_adr_i;
   assign bus_we      = wb_we_i;
   assign bus_en      = wb_cyc_i & wb_stb_i;
   assign bus_data_in = wb_dat_i;
   assign wb_dat_o    = bus_data_out;
   assign wb_ack_o    = bus_ack;

   lisnoc_mp_simple
     #(.noc_data_width(noc_data_width),
       .noc_type_width(noc_type_width),
       .size_width(size_width))
   u_mp_simple(/*AUTOINST*/
               // Outputs
               .noc_out_flit            (noc_out_flit[noc_flit_width-1:0]),
               .noc_out_valid           (noc_out_valid),
               .noc_in_ready            (noc_in_ready),
               .bus_data_out            (bus_data_out[noc_data_width-1:0]),
               .bus_ack                 (bus_ack),
               .irq                     (irq),
               // Inputs
               .clk                     (clk),
               .rst                     (rst),
               .noc_out_ready           (noc_out_ready),
               .noc_in_flit             (noc_in_flit[noc_flit_width-1:0]),
               .noc_in_valid            (noc_in_valid),
               .bus_addr                (bus_addr[5:0]),
               .bus_we                  (bus_we),
               .bus_en                  (bus_en),
               .bus_data_in             (bus_data_in[noc_data_width-1:0]));


endmodule // lisnoc_mp_simple_wb

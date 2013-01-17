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
 * The module behaving as initiator in DMA transfers.
 * 
 * (c) 2011-2013 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *
 */

`include "lisnoc_def.vh"
`include "lisnoc_dma_def.vh"

module lisnoc_dma_initiator (/*AUTOARG*/
   // Outputs
   ctrl_read_pos, ctrl_done_pos, ctrl_done_en, noc_out_flit,
   noc_out_valid, noc_in_ready, wb_req_cyc_o, wb_req_stb_o,
   wb_req_we_o, wb_req_dat_o, wb_req_adr_o, wb_req_cti_o,
   wb_req_bte_o, wb_req_sel_o, wb_resp_cyc_o, wb_resp_stb_o,
   wb_resp_we_o, wb_resp_dat_o, wb_resp_adr_o, wb_resp_cti_o,
   wb_resp_bte_o, wb_resp_sel_o,
   // Inputs
   clk, rst, ctrl_read_req, valid, noc_out_ready, noc_in_flit,
   noc_in_valid, wb_req_ack_i, wb_req_dat_i, wb_resp_ack_i,
   wb_resp_dat_i
   );
  
   //parameters
   parameter table_entries = 4;
//   parameter table_entries_ptrwidth = $clog2(table_entries);
   parameter table_entries_ptrwidth = 2;

   parameter tileid = 0;

   parameter noc_packet_size = 16;
   
   input  clk; 
   input  rst; 

   // Control read (request) interface
   output [table_entries_ptrwidth-1:0] ctrl_read_pos;
   input [`DMA_REQUEST_WIDTH-1:0]      ctrl_read_req;

   output [table_entries_ptrwidth-1:0] ctrl_done_pos;
   output                              ctrl_done_en;

   input [table_entries-1:0]           valid;

   // NOC-Interface
   output [`FLIT_WIDTH-1:0]                noc_out_flit;
   output                                  noc_out_valid;
   input                                   noc_out_ready;

   input [`FLIT_WIDTH-1:0]                 noc_in_flit;
   input                                   noc_in_valid;
   output                                  noc_in_ready;
   
   // Wishbone interface for L2R data fetch
   input                                   wb_req_ack_i;
   output                                  wb_req_cyc_o, wb_req_stb_o;
   output                                  wb_req_we_o; 
   input [31:0]                            wb_req_dat_i;
   output [31:0]                           wb_req_dat_o;
   output [31:0]                           wb_req_adr_o;
   output [2:0]                            wb_req_cti_o;
   output [1:0]                            wb_req_bte_o;
   output [3:0]                            wb_req_sel_o;
   
   // Wishbone interface for L2R data fetch
   input                                   wb_resp_ack_i;
   output                                  wb_resp_cyc_o, wb_resp_stb_o;
   output                                  wb_resp_we_o; 
   input [31:0]                            wb_resp_dat_i;
   output [31:0]                           wb_resp_dat_o;
   output [31:0]                           wb_resp_adr_o;
   output [2:0]                            wb_resp_cti_o;
   output [1:0]                            wb_resp_bte_o;
   output [3:0]                            wb_resp_sel_o;

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire [31:0]          req_data;               // From u_wbreq of lisnoc_dma_initiator_wbreq.v
   wire                 req_data_ready;         // From u_nocreq of lisnoc_dma_initiator_nocreq.v
   wire                 req_data_valid;         // From u_wbreq of lisnoc_dma_initiator_wbreq.v
   wire                 req_is_l2r;             // From u_nocreq of lisnoc_dma_initiator_nocreq.v
   wire [31:0]          req_laddr;              // From u_nocreq of lisnoc_dma_initiator_nocreq.v
   wire [`DMA_REQFIELD_SIZE_WIDTH-3:0] req_size;// From u_nocreq of lisnoc_dma_initiator_nocreq.v
   wire                 req_start;              // From u_nocreq of lisnoc_dma_initiator_nocreq.v
   // End of automatics
   
   lisnoc_dma_initiator_wbreq 
     u_wbreq(/*AUTOINST*/
             // Outputs
             .wb_req_cyc_o              (wb_req_cyc_o),
             .wb_req_stb_o              (wb_req_stb_o),
             .wb_req_we_o               (wb_req_we_o),
             .wb_req_dat_o              (wb_req_dat_o[31:0]),
             .wb_req_adr_o              (wb_req_adr_o[31:0]),
             .wb_req_cti_o              (wb_req_cti_o[2:0]),
             .wb_req_bte_o              (wb_req_bte_o[1:0]),
             .wb_req_sel_o              (wb_req_sel_o[3:0]),
             .req_data_valid            (req_data_valid),
             .req_data                  (req_data[31:0]),
             // Inputs
             .clk                       (clk),
             .rst                       (rst),
             .wb_req_ack_i              (wb_req_ack_i),
             .wb_req_dat_i              (wb_req_dat_i[31:0]),
             .req_start                 (req_start),
             .req_is_l2r                (req_is_l2r),
             .req_size                  (req_size[`DMA_REQFIELD_SIZE_WIDTH-3:0]),
             .req_laddr                 (req_laddr[31:0]),
             .req_data_ready            (req_data_ready));
   

   lisnoc_dma_initiator_nocreq
     #(.tileid(tileid),.noc_packet_size(noc_packet_size))
   u_nocreq(/*AUTOINST*/
            // Outputs
            .noc_out_flit               (noc_out_flit[`FLIT_WIDTH-1:0]),
            .noc_out_valid              (noc_out_valid),
            .ctrl_read_pos              (ctrl_read_pos[table_entries_ptrwidth-1:0]),
            .req_start                  (req_start),
            .req_laddr                  (req_laddr[31:0]),
            .req_data_ready             (req_data_ready),
            .req_is_l2r                 (req_is_l2r),
            .req_size                   (req_size[`DMA_REQFIELD_SIZE_WIDTH-3:0]),
            // Inputs
            .clk                        (clk),
            .rst                        (rst),
            .noc_out_ready              (noc_out_ready),
            .ctrl_read_req              (ctrl_read_req[`DMA_REQUEST_WIDTH-1:0]),
            .valid                      (valid[table_entries-1:0]),
            .ctrl_done_pos              (ctrl_done_pos[table_entries_ptrwidth-1:0]),
            .ctrl_done_en               (ctrl_done_en),
            .req_data_valid             (req_data_valid),
            .req_data                   (req_data[31:0]));

   /* lisnoc_dma_initiator_nocresp AUTO_TEMPLATE(
    .wb_\(.*\) (wb_resp_\1[]),
    ); */
   lisnoc_dma_initiator_nocresp
     #(.noc_packet_size(noc_packet_size))
   u_nocresp(/*AUTOINST*/
             // Outputs
             .noc_in_ready              (noc_in_ready),
             .wb_cyc_o                  (wb_resp_cyc_o),         // Templated
             .wb_stb_o                  (wb_resp_stb_o),         // Templated
             .wb_we_o                   (wb_resp_we_o),          // Templated
             .wb_dat_o                  (wb_resp_dat_o[31:0]),   // Templated
             .wb_adr_o                  (wb_resp_adr_o[31:0]),   // Templated
             .wb_cti_o                  (wb_resp_cti_o[2:0]),    // Templated
             .wb_bte_o                  (wb_resp_bte_o[1:0]),    // Templated
             .wb_sel_o                  (wb_resp_sel_o[3:0]),    // Templated
             .ctrl_done_pos             (ctrl_done_pos[table_entries_ptrwidth-1:0]),
             .ctrl_done_en              (ctrl_done_en),
             // Inputs
             .clk                       (clk),
             .rst                       (rst),
             .noc_in_flit               (noc_in_flit[`FLIT_WIDTH-1:0]),
             .noc_in_valid              (noc_in_valid),
             .wb_ack_i                  (wb_resp_ack_i),         // Templated
             .wb_dat_i                  (wb_resp_dat_i[31:0]));  // Templated
   
endmodule // lisnoc_dma_ctrl_req

`include "lisnoc_undef.vh"
`include "lisnoc_dma_undef.vh"

// Local Variables:
// verilog-library-directories:("." "../" "../infrastructure")
// verilog-auto-inst-param-value: t
// End:

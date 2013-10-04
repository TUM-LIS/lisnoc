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
 * This is the toplevel-module of usb-to-noc and noc-to-usb conversion.
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s): 
 *    Michael Tempelmeier, michael.tempelmeier@tum.de
 */

`include "lisnoc16_def.vh"


module lisnoc16_usb(/*AUTOARG*/
   // Outputs
   fx_rdy, noc_in_ready, noc_out_flit, noc_out_valid,
   // Inouts
   fx_fd,
   // Inputs
   fx_clk, fx_ctl, fpga_clk, rst, noc_in_flit, noc_in_valid,
   noc_out_ready
   );
   
   parameter data_width = 16;

   //USB-Interface
   input fx_clk;
   inout [15:0] fx_fd;
   output [1:0] fx_rdy;
   input [2:0]  fx_ctl;


   input        fpga_clk;
   input        rst;

   //NoC-IN
   input [`FLIT16_WIDTH-1:0] noc_in_flit;
   input                     noc_in_valid;
   output                    noc_in_ready;
   
   //NoC-OUT
   output [`FLIT16_WIDTH-1:0] noc_out_flit;
   output                     noc_out_valid;
   input                      noc_out_ready;

   
   wire [data_width-1:0] in_data;
   wire                  in_ready;
   wire                  in_valid;
   wire [data_width-1:0] out_data;
   wire                  out_ready;
   wire                  out_valid;



   wire [3:0]  fx_rdy_unused;

      /* fx2_usb_comm AUTO_TEMPLATE(
    .fx_rdy ({fx_rdy_unused,fx_rdy}),
    .fx_ctl ({3'b00, fx_ctl}),
    .data_from_usb_clk (fpga_clk),
    .data_to_usb_clk (fpga_clk),
    .out_no_complete_bulk_transfer(),
    .out_transfer(),
    .reset (1'b0),
    ); */


   fx2_usb_comm
     u_comm(/*AUTOINST*/
            // Outputs
            .fx_rdy                     ({fx_rdy_unused,fx_rdy}), // Templated
            .in_data                    (in_data[15:0]),
            .in_valid                   (in_valid),
            .out_ready                  (out_ready),
            .out_transfer               (),                      // Templated
            .out_no_complete_bulk_transfer(),                    // Templated
            // Inouts
            .fx_fd                      (fx_fd[15:0]),
            // Inputs
            .fx_clk                     (fx_clk),
            .fx_ctl                     ({3'b00, fx_ctl}),       // Templated
            .in_ready                   (in_ready),
            .out_data                   (out_data[15:0]),
            .out_valid                  (out_valid),
            .fpga_clk                   (fpga_clk),
            .rst                        (rst));

lisnoc16_usb_to_noc
  usb_to_noc(
             .clk(fpga_clk),
             .rst(rst),
             
   //USB-Interface
             .in_usb_data(in_data),
             .in_usb_valid(in_valid),
             .in_usb_ready(in_ready),

   //NOC-Interface
             .out_noc_data(noc_out_flit),
             .out_noc_valid(noc_out_valid),
             .out_noc_ready(noc_out_ready)
             );

lisnoc16_usb_from_noc  #(.fifo_depth(`MAX_NOC16_PACKET_LENGTH))
  usb_from_noc(
               .clk(fpga_clk),
               .rst(rst),
             
             //USB-Interface  
               .out_usb_data(out_data),
               .out_usb_valid(out_valid),
               .out_usb_ready(out_ready),

             //NoC-Interface
               .in_noc_data(noc_in_flit),
               .in_noc_valid(noc_in_valid),
               .in_noc_ready(noc_in_ready)
               );
   

endmodule // lisnoc16_usb


//Local Variables:
//verilog-library-directories:("~/fx2_inout/rtl/")
//End:
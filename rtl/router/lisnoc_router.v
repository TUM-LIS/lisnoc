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
 * This is the generic router toplevel.
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s):
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 */

`include "lisnoc_def.vh"

module lisnoc_router( /*AUTOARG*/
   // Outputs
   out_flit, out_valid, in_ready,
   // Inputs
   clk, rst, out_ready, in_flit, in_valid
   );

   parameter  flit_data_width = 32;
   parameter  flit_type_width = 2;
   localparam flit_width = flit_data_width+flit_type_width;
   
   parameter  num_dests = 32;
   parameter  ph_dest_width = 5;

   parameter use_prio = 0;
   parameter ph_prio_width = 4;
   
   parameter vchannels = 1;
   
   parameter input_ports = 5;
   parameter output_ports = 5;

   parameter in_fifo_length = 4;
   parameter out_fifo_length = 4;   
   
   parameter [output_ports*num_dests-1:0] lookup = {num_dests*output_ports{1'b0}};

   input clk, rst;

   output [output_ports*flit_width-1:0] out_flit;
   output [output_ports*vchannels-1:0]   out_valid;
   input [output_ports*vchannels-1:0]    out_ready;
   
   input [input_ports*flit_width-1:0]    in_flit;
   input [input_ports*vchannels-1:0]     in_valid;
   output [input_ports*vchannels-1:0]    in_ready;
   
   // Array conversion
   wire [flit_width-1:0] out_flit_array [0:output_ports-1];
   wire [vchannels-1:0]   out_valid_array [0:output_ports-1];
   wire [vchannels-1:0]   out_ready_array [0:output_ports-1];
   
   wire [flit_width-1:0] in_flit_array [0:input_ports-1];
   wire [vchannels-1:0]   in_valid_array [0:input_ports-1];
   wire [vchannels-1:0]   in_ready_array [0:input_ports-1];

   genvar                 p;
   genvar                 op,v,ip;
   generate
      for (p=0;p<output_ports;p=p+1) begin : output_arrays
         assign out_flit[(p+1)*flit_width-1:p*flit_width] = out_flit_array[p];
         assign out_valid[(p+1)*vchannels-1:p*vchannels]    = out_valid_array[p];
         assign out_ready_array[p] = out_ready[(p+1)*vchannels-1:p*vchannels];
      end
   endgenerate

   generate
      for (p=0;p<input_ports;p=p+1) begin : input_arrays
         assign in_flit_array[p]  = in_flit[(p+1)*flit_width-1:p*flit_width];
         assign in_valid_array[p] = in_valid[(p+1)*vchannels-1:p*vchannels];
         assign in_ready[(p+1)*vchannels-1:p*vchannels] = in_ready_array[p];
      end
   endgenerate
     
   // Those are the switching wires
   wire [flit_width*vchannels-1:0] switch_in_flit[0:input_ports-1];
   wire [output_ports*vchannels-1:0]        switch_in_request[0:input_ports-1];
   wire [output_ports*vchannels-1:0]        switch_in_read[0:input_ports-1];
   
   wire [flit_width*vchannels*input_ports-1:0] switch_out_flit[0:output_ports-1];
   wire [input_ports*vchannels-1:0]             switch_out_request[0:output_ports-1];
   wire [input_ports*vchannels-1:0]             switch_out_read[0:output_ports-1];

   // Switch
   wire [flit_width*input_ports*vchannels-1:0] all_flits;

   generate
      for (p=0;p<input_ports;p=p+1) begin : compose_all_flits
         assign all_flits[(p+1)*vchannels*flit_width-1:p*vchannels*flit_width] = switch_in_flit[p];
      end
   endgenerate

   generate
      for (p=0;p<output_ports;p=p+1) begin : assign_all_flits
         assign switch_out_flit[p] = all_flits;
      end
   endgenerate

   generate
      for (op=0;op<output_ports;op=op+1) begin
         for (v=0;v<vchannels;v=v+1) begin
            for (ip=0;ip<input_ports;ip=ip+1) begin
               assign switch_out_request[op][v*input_ports+ip] = switch_in_request[ip][v*output_ports+op];
               assign switch_in_read[ip][v*output_ports+op] = switch_out_read[op][v*input_ports+ip];
            end
         end
      end
   endgenerate
   
   generate
      for (p=0;p<input_ports;p=p+1) begin : inputs
         /* lisnoc_router_input AUTO_TEMPLATE (
         .link_ready     (in_ready_array[p]),
         .link_flit      (in_flit_array[p]),
         .link_valid     (in_valid_array[p]),
         .switch_request (switch_in_request[p]),
         .switch_flit    (switch_in_flit[p]),
         .switch_read    (switch_in_read[p]),
         );*/
         
         lisnoc_router_input
            #(.vchannels(vchannels),.ports(output_ports),
               .num_dests(num_dests),.lookup(lookup),.flit_data_width(flit_data_width),
               .flit_type_width(flit_type_width),.ph_dest_width(ph_dest_width),
               .fifo_length(in_fifo_length))
         inputs(/*AUTOINST*/
                // Outputs
                .link_ready             (in_ready_array[p]),     // Templated
                .switch_request         (switch_in_request[p]),  // Templated
                .switch_flit            (switch_in_flit[p]),     // Templated
                // Inputs
                .clk                    (clk),
                .rst                    (rst),
                .link_flit              (in_flit_array[p]),      // Templated
                .link_valid             (in_valid_array[p]),     // Templated
                .switch_read            (switch_in_read[p]));    // Templated
      end
   endgenerate

   generate
      for (p=0;p<output_ports;p=p+1) begin : outputs
         /* lisnoc_router_output AUTO_TEMPLATE (
         .link_flit      (out_flit_array[p]),
         .link_valid     (out_valid_array[p]),
         .link_ready     (out_ready_array[p]),
         .switch_read    (switch_out_read[p]),
         .switch_request (switch_out_request[p]),
         .switch_flit    (switch_out_flit[p]),
         );*/
         
         lisnoc_router_output

         #(.vchannels(vchannels),.ports(input_ports), .flit_data_width(flit_data_width),.flit_type_width(flit_type_width), .fifo_length(out_fifo_length),
              .use_prio(use_prio),.ph_prio_width(ph_prio_width),.ph_prio_offset(ph_dest_width))

         outputs (/*AUTOINST*/
                  // Outputs
                  .link_flit            (out_flit_array[p]),     // Templated
                  .link_valid           (out_valid_array[p]),    // Templated
                  .switch_read          (switch_out_read[p]),    // Templated
                  // Inputs
                  .clk                  (clk),
                  .rst                  (rst),
                  .link_ready           (out_ready_array[p]),    // Templated
                  .switch_request       (switch_out_request[p]), // Templated
                  .switch_flit          (switch_out_flit[p]));   // Templated
            end // for (p=0;p<output_ports;p=p+1)
   endgenerate
      
endmodule // lisnoc_router

`include "lisnoc_undef.vh"
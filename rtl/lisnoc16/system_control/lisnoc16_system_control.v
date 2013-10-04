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
 * This module can reset the cpus or the whole system.
 * 
 * (c) 2012 by the author(s)
 *
 * Author(s): 
 *    Michael Tempelmeier, michael.tempelmeier@tum.de
 */


`include "lisnoc16_def.vh"
`include "lisnoc16_system_control_def.vh"

module lisnoc16_system_control(/*AUTOARG*/
   // Outputs
   out_flit, out_valid, in_ready, rst_sys_dbg, rst_cpu_dbg,
   clk_sys_off_dbg, clk_sys_on_dbg, stop_cpu_dbg, start_cpu_dbg,
   stop_monitoring_dbg, start_monitoring_dbg,
   // Inputs
   clk, rst, out_ready, in_flit, in_valid
   );


   parameter usb_dest = 0;
 //clk and rst
   input clk;
   input rst;
   
 //noc-output
   output reg [`FLIT16_WIDTH-1:0] out_flit;  // data_out
   output reg                 out_valid; // data available
   input                      out_ready; // read request  

   
 //noc-input
   input [`FLIT16_WIDTH-1:0] in_flit;  // data_out
   input                   in_valid; // data available
   output reg              in_ready; // read request    

//control signals
   output              rst_sys_dbg;
   output              rst_cpu_dbg;
   output              clk_sys_off_dbg;
   output              clk_sys_on_dbg;
   output              stop_cpu_dbg;
   output              start_cpu_dbg;
   output              stop_monitoring_dbg;
   output              start_monitoring_dbg;   


   reg [`FLIT16_WIDTH -1 :0] sampled_flit;     // could be smaler; actually [`FLIT16_CONTENT_MSB:`FLIT16_CONTENT_LSB]
   reg [`FLIT16_WIDTH -1 :0] nxt_sampled_flit; // should be sufficient.


   assign rst_sys_dbg = in_valid & in_flit[`SYSTEM_RESET_BIT];
   assign rst_cpu_dbg = in_valid & in_flit[`CPU_RESET_BIT];
   assign clk_sys_on_dbg = in_valid & in_flit [`CLK_SYS_ON_BIT];
   assign clk_sys_off_dbg = in_valid & in_flit [`CLK_SYS_OFF_BIT];
   assign start_cpu_dbg = in_valid & in_flit[`START_CPU_BIT];
   assign stop_cpu_dbg = in_valid & in_flit[`STOP_CPU_BIT]; //not used atm
   assign start_monitoring_dbg = in_valid & in_flit[`START_MONITORING_BIT];
   assign stop_monitoring_dbg = in_valid & in_flit[`STOP_MONITORING_BIT];

`define STATE_IDLE 1'b0
`define STATE_ACK 1'b1

   reg                 state;
   reg                 nxt_state;


   always @ (*) begin: FSM_comb
      //defaults:

      nxt_state = state;
      nxt_sampled_flit = sampled_flit;
      out_flit = {`FLIT16_WIDTH { 1'bX}};
      
      case (state)
        `STATE_IDLE: begin
           in_ready = 1'b1;   // we can receive one flit
           out_valid = 1'b0;
           if(in_valid) begin
//              nxt_state = `STATE_IDLE; //uncomment, if you don't want any feedback
              nxt_state = `STATE_ACK;    //comment, if you don't want any feedback
              nxt_sampled_flit = in_flit;
           end
         end
        `STATE_ACK: begin
           in_ready = 1'b0;   // we have to send back our ACK-Flit before we can receive new flits
           out_valid = 1'b1;
           out_flit[`FLIT16_TYPE_MSB : `FLIT16_TYPE_LSB] = `FLIT16_TYPE_SINGLE;
           out_flit[`FLIT16_DEST_MSB : `FLIT16_DEST_LSB] = usb_dest;
           out_flit[`PACKET16_CLASS_MSB: `PACKET16_CLASS_LSB] = `PACKET16_CLASS_CONTROL;
           out_flit[`PACKET16_CLASS_LSB-1: 0] = sampled_flit[`PACKET16_CLASS_LSB -1 :0];
           if (out_ready) begin
              nxt_state = `STATE_IDLE;
           end
        end
        default: begin
          //must not happen
        end
      endcase // case (state)
   end // block: FSM_comb

   always @ (posedge clk) begin: FSM_reg
      if (rst) begin
         state = `STATE_IDLE;
         sampled_flit = {`FLIT16_WIDTH {1'bX}};
      end else begin
         sampled_flit = nxt_sampled_flit;
         state = nxt_state;
      end
   end
          
   
endmodule

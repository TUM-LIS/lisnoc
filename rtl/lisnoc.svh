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
 * As SystemVerilog allows for better definition of datatypes than
 * the macros in lisnoc_def.vh this is provided for convenience.
 * You always must assure that the settings correspond to the ones
 * in Verilog.
 *
 * (c) 2011 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *    Andreas Lankes, andreas.lankes@tum.de
 *    Michael Tempelmeier, michael.tempelmeier@tum.de
 */

typedef enum bit[4:0] {SELECT_NONE=0,SELECT_NORTH=1,SELECT_EAST=2,SELECT_SOUTH=4,SELECT_WEST=8,SELECT_LOCAL=16} dir_select_t;

`define NORTH 0
`define EAST 1
`define SOUTH 2
`define WEST 3
`define LOCAL 4

typedef enum bit [1:0] { HEADER=2'b01, SINGLE=2'b11, PAYLOAD=2'b00, LAST=2'b10 } flit_type_t;

class flit_t #(int data_width=32,int type_width=2);
        bit [type_width-1:0] ftype;
        bit [data_width-1:0] content;
endclass

class flit_header_t #(int data_width=32);
        bit [4:0] dest;
        bit [3:0] prio;
        bit [2:0] packet_class;
        bit [data_width-13:0] class_specific;
endclass



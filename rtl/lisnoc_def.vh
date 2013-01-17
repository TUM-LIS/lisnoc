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
 * This is the definition file. All Verilog macros are defined here.
 * Please note, that it is not intended to be used for configuration
 * (which should be done via parameters) but more for specific 
 * constants, that might change over longer time periods.
 *
 * (c) 2011-2012 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *    Andreas Lankes, andreas.lankes@tum.de
 *    Michael Tempelmeier, michael.tempelmeier@tum.de
 */

`define FLIT_TYPE_PAYLOAD 2'b00
`define FLIT_TYPE_HEADER  2'b01
`define FLIT_TYPE_LAST    2'b10
`define FLIT_TYPE_SINGLE  2'b11

// Convenience definitions for mesh
`define SELECT_NONE  5'b00000
`define SELECT_NORTH 5'b00001 
`define SELECT_EAST  5'b00010
`define SELECT_SOUTH 5'b00100
`define SELECT_WEST  5'b01000
`define SELECT_LOCAL 5'b10000

`define NORTH 0
`define EAST  1
`define SOUTH 2
`define WEST  3
`define LOCAL 4


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
 * cosntants, that might change over longer time periods.
 *
 * (c) 2011 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *    Andreas Lankes, andreas.lankes@tum.de
 *    Michael Tempelmeier, michael.tempelmeier@tum.de
 */

`define FLIT16_WIDTH 18

// Type of flit
// The coding is chosen, so that
// type[0] signals that this is the first flit of a packet
// type[1] signals that this is the last flit of a packet

`define FLIT16_TYPE_MSB (`FLIT16_WIDTH - 1)
`define FLIT16_TYPE_WIDTH 2
`define FLIT16_TYPE_LSB (`FLIT16_TYPE_MSB - `FLIT16_TYPE_WIDTH + 1)
`define FLIT16_DATA_WIDTH `FLIT16_WIDTH - `FLIT16_TYPE_WIDTH

// same as FLIT_TYPE_* in lisnoc_def.v
`define FLIT16_TYPE_PAYLOAD 2'b00
`define FLIT16_TYPE_HEADER  2'b01
`define FLIT16_TYPE_LAST    2'b10
`define FLIT16_TYPE_SINGLE  2'b11

// This is the flit content size
`define FLIT16_CONTENT_WIDTH 16
`define FLIT16_CONTENT_MSB   15
`define FLIT16_CONTENT_LSB    0

// The following fields are only valid for header flits
`define FLIT16_DEST_WIDTH 5
// destination address field of header flit
`define FLIT16_DEST_MSB `FLIT16_CONTENT_MSB
`define FLIT16_DEST_LSB `FLIT16_DEST_MSB - `FLIT16_DEST_WIDTH + 1

// packet type field  of header flit
`define PACKET16_CLASS_MSB (`FLIT16_DEST_LSB - 1)
`define PACKET16_CLASS_WIDTH 3
`define PACKET16_CLASS_LSB (`PACKET16_CLASS_MSB - `PACKET16_CLASS_WIDTH + 1)

// class defines
`define PACKET16_CLASS_CONTROL 3'b010
`define PACKET16_CLASS_32 3'b111

//some global defines
`define USB_DEST 5'b00000
`define MAX_NOC16_PACKET_LENGTH 32
`define LD_MAX_NOC16_PACKET_LENGTH 8

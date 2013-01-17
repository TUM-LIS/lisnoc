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
 * This interface is used to integrate the System Verilog router
 * wrapper in your designs.
 *
 * (c) 2011 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 */

`include "lisnoc.svh"

/* The transmission on a link is controlled by the sender.
 * The receiver signals on which virtual channels it is ready
 * to receive a flit. Based on this information and the arbitration
 * policy the sender sets the flit and signals with the selected
 * vchannel's bit in the valid signal that there is valid data
 * for this vchannel on the flit wires.
 */
interface lisnoc_link_if #(data_width=32,type_width=2,vchannels=1) ();
   wire [data_width+type_width-1:0] flit;
   wire [vchannels-1:0] valid;
   wire [vchannels-1:0] ready;
   
   modport out(output flit, valid, input ready);
   modport in(input flit, valid, output ready);

endinterface // noc_link_if

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
 * This module implements the round robin scheme.
 * 
 * (c) 2011 by the author(s)
 * 
 * Author(s): 
 *    Stefan Wallentowitz, stefan.wallentowitz@tum.de
 *    Andreas Lankes, andreas.lankes@tum.de
 *
 */
 
`include "lisnoc_def.vh"

module lisnoc_arb_prio_rr(/*AUTOARG*/
   // Outputs
   nxt_gnt,
   // Inputs
   req, gnt
   );

   // Number of input ports in the design
   parameter N = 2;
  
   // inputs
   input [N-1:0] req;
   input [N-1:0] gnt;
   
   // outputs
   output reg [N-1:0] nxt_gnt;

   // registers
   reg [N-1:0] mask [0:N-1];
   
   
   // wires
   wire [N-1:0] nxt_gnt_tmp;
   wire [N-1:0] msr;
   
   integer i,j;
   
   always @(*) begin
      for (i=0;i<N;i=i+1) begin
	      mask[i] = {N{1'b0}};
	      
	      if(i>0) begin 
	         mask[i][i-1] = ~gnt[i-1];
	      end else begin
	         mask[i][N-1] = ~gnt[N-1];
	      end
	     	      
	      for (j=2;j<N;j=j+1) begin
	        if (i-j>=0) begin
	          mask[i][i-j] = mask[i][i-j+1] & ~gnt[i-j];
	        end else if(i-j+1>=0) begin
	          mask[i][i-j+N] = mask[i][i-j+1] & ~gnt[i-j+N];
	        end else begin
	          mask[i][i-j+N] = mask[i][i-j+N+1] & ~gnt[i-j+N];
	        end  
	      end
      end
   end
   
   always @(*) begin
      if (|nxt_gnt_tmp == 1) begin
         nxt_gnt = nxt_gnt_tmp;
       end else begin
         nxt_gnt = msr;
       end
   end
     
   genvar k;
   generate
      for (k=0;k<N;k=k+1) begin: nxtGnt
	       assign nxt_gnt_tmp[k] = (~|(mask[k] & req) & req[k]); 
      end
   endgenerate
   
   generate
     for (k=0;k<N;k=k+1) begin: mostSignRequest
       if (k==0) begin
         assign msr[k] = req[k];
       end else begin
         assign msr[k] = req[k] & (~|req[k-1:0]);
       end
     end
   endgenerate
   
endmodule // lisnoc_arb_prio_rr

`include "lisnoc_undef.vh"



module lisnoc_arb_rr(/*AUTOARG*/
   // Outputs
   nxt_gnt,
   // Inputs
   req, gnt
   );

   parameter N = 2;
  
   input [N-1:0] req;
   input [N-1:0] gnt;
   output [N-1:0] nxt_gnt;

   reg [N-1:0]      mask [0:N-1];
   
   integer 	      i,j;
   
   always @(*) begin
      for (i=0;i<N;i=i+1) begin
	 mask[i] = {N{1'b0}};
	 if(i>0)
	   mask[i][i-1] = ~gnt[i-1];
	 else
	   mask[i][N-1] = ~gnt[N-1];
	 for (j=2;j<N;j=j+1) begin
	    if (i-j>=0)
	      mask[i][i-j] = mask[i][i-j+1] & ~gnt[i-j];
	    else if(i-j+1>=0)
	      mask[i][i-j+N] = mask[i][i-j+1] & ~gnt[i-j+N];
	    else
	      mask[i][i-j+N] = mask[i][i-j+N+1] & ~gnt[i-j+N];
	 end
      end
   end // always @ (*)

   genvar k;
   generate
      for (k=0;k<N;k=k+1) begin
	 assign nxt_gnt[k] = (~|(mask[k] & req) & req[k]) | (~|req & gnt[k]);
      end
   endgenerate
endmodule // lisnoc_arb_rr

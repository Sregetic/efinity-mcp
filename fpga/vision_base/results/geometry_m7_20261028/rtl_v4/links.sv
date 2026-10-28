module tb;
vision_shape_classifier dut(.clk(1'b0),.rst_n(1'b0),.de(1'b0),.vs(1'b0),.x(12'd0),.y(12'd0),.gray(8'd0),.diff_threshold(8'd32));
integer r[0:254][0:4];integer n=0,a,b,c,d,i,j,k,off,checks=0;reg ll,lr,rl,rr,old_value,new_value;
initial begin
 for(a=0;a<9;a++)for(b=a;b<9;b++)begin r[n][0]=1;r[n][1]=a;r[n][2]=b;r[n][3]=a;r[n][4]=b;n++;end
 for(a=0;a<9;a++)for(b=a;b<9;b++)for(c=b+2;c<9;c++)for(d=c;d<9;d++)begin r[n][0]=2;r[n][1]=a;r[n][2]=b;r[n][3]=c;r[n][4]=d;n++;end
 if(n!=255)$fatal(1,"row enumeration");
 for(k=0;k<2;k++)begin off=k*4087;
 for(i=0;i<n;i++)for(j=0;j<n;j++)begin
  ll=dut.connected(12'(r[i][1]+off),12'(r[i][2]+off),12'(r[j][1]+off),12'(r[j][2]+off));
  lr=r[j][0]==2&&dut.connected(12'(r[i][1]+off),12'(r[i][2]+off),12'(r[j][3]+off),12'(r[j][4]+off));
  rl=r[i][0]==2&&dut.connected(12'(r[i][3]+off),12'(r[i][4]+off),12'(r[j][1]+off),12'(r[j][2]+off));
  rr=r[i][0]==2&&r[j][0]==2&&dut.connected(12'(r[i][3]+off),12'(r[i][4]+off),12'(r[j][3]+off),12'(r[j][4]+off));
  old_value=(ll||lr)&&(r[i][0]!=2||rl||rr)&&(ll||rl)&&(r[j][0]!=2||lr||rr);
  new_value=dut.row_connected(r[i][0]==2,r[j][0]==2,12'(r[i][1]+off),12'(r[i][2]+off),12'(r[i][3]+off),12'(r[i][4]+off),12'(r[j][1]+off),12'(r[j][2]+off),12'(r[j][3]+off),12'(r[j][4]+off));
  if(old_value!==new_value)$fatal(1,"row link mismatch %0d %0d offset%0d",i,j,off);checks++;
 end end
 $display("PASS geometry row-link equivalence %0d pairs including 12-bit limits",checks);$finish;
end
endmodule

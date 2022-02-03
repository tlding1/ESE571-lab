/* TODO: INSERT NAME AND PENNKEY HERE */

`timescale 1ns / 1ps
`default_nettype none

/**
 * @param a first 1-bit input
 * @param b second 1-bit input
 * @param g whether a and b generate a carry
 * @param p whether a and b would propagate an incoming carry
 */
module gp1(input wire a, b,
           output wire g, p);
   assign g = a & b;
   assign p = a | b;
endmodule

/**
 * Computes aggregate generate/propagate signals over a 4-bit window.
 * @param gin incoming generate signals 
 * @param pin incoming propagate signals
 * @param cin the incoming carry
 * @param gout whether these 4 bits collectively generate a carry (ignoring cin)
 * @param pout whether these 4 bits collectively would propagate an incoming carry (ignoring cin)
 * @param cout the carry outs for the low-order 3 bits
 */
module gp4(input wire [3:0] gin, pin,
           input wire cin,
           output wire gout, pout,
           output wire [2:0] cout);
   assign gout = gin[3] | (gin[2] & pin[3]) | (gin[1] & pin[3] & pin[2]) | (gin[0] & pin[3] & pin[2] & pin[1]);
   assign pout = (& pin);
   assign cout[0] = gin[0] | (pin[0] & cin);
   assign cout[1] = gin[1] | (pin[1] & gin[0]) | (pin[1] & pin[0] & cin);
   assign cout[2] = gin[2] | (pin[2] & gin[1]) | (pin[2] & pin[1] & gin[0]) | (pin[2] & pin[1] & pin[0] & cin);
endmodule

/**
 * 16-bit Carry-Lookahead Adder
 * @param a first input
 * @param b second input
 * @param cin carry in
 * @param sum sum of a + b + carry-in
 */
module cla16
  (input wire [15:0]  a, b,
   input wire         cin,
   output wire [15:0] sum);
    wire[15:0] g;
    wire[15:0] p;
    wire[3:0] gout;
    wire[3:0] pout;
    wire[15:0] cout;
    genvar i;
      for(i=0;i<15;i=i+1) begin
            gp1 mygp1 (.a(a[i]),.b(b[i]),.g(g[i]),.p(p[i]));
      end
    gp4 mygp41 (.gin(g[3:0]),.pin(p[3:0]),.cin(cin),.gout(gout[0]),.pout(pout[0]),.cout(cout[2:0]));
    gp4 mygp42 (.gin(g[7:4]),.pin(p[7:4]),.cin(cout[3]),.gout(gout[1]),.pout(pout[1]),.cout(cout[6:4]));
    gp4 mygp43 (.gin(g[11:8]),.pin(p[11:8]),.cin(cout[7]),.gout(gout[2]),.pout(pout[2]),.cout(cout[10:8]));
    gp4 mygp44 (.gin(g[15:12]),.pin(p[15:12]),.cin(cout[11]),.gout(gout[3]),.pout(pout[3]),.cout(cout[14:12]));
    gp4 mygp4top (.gin(gout[3:0]),.pin(pout[3:0]),.cin(cin),.gout(),.pout(),.cout({cout[11],cout[7],cout[3]}));
    assign sum[0] = a[0] ^ b[0] ^ cin;  
    genvar j;
      for(j=1;j<16;j=j+1) begin
            assign sum[j] = a[j] ^ b[j] ^ cout[j-1];
      end
endmodule


/** Lab 2 Extra Credit, see details at
  https://github.com/upenn-acg/cis501/blob/master/lab2-alu/lab2-cla.md#extra-credit
 If you are not doing the extra credit, you should leave this module empty.
 */
module gpn
  #(parameter N = 4)
  (input wire [N-1:0] gin, pin,
   input wire  cin,
   output wire gout, pout,
   output wire [N-2:0] cout);
 
endmodule

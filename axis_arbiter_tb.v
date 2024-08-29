`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.08.2024 14:48:11
// Design Name: 
// Module Name: axis_arbiter_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define clk_period 10;

module axis_arbiter_tb();

   reg axis_clk = 0;
   reg resetn;
   
  // pins of first axis_master 
   reg s_axis_tvalid1;
   wire s_axis_tready1;
   reg [7:0]s_axis_tdata1;
   reg s_axis_tlast1;
   
   
// pins of first axis_master 

   reg s_axis_tvalid2;
   wire s_axis_tready2;
   reg [7:0]s_axis_tdata2;
   reg s_axis_tlast2;
   
   
   // pins for round robin arbiter (master arbiter)
   reg  m_axis_tready;
   wire m_axis_tvalid;   // input 
   wire [7:0]m_axis_tdata;
   wire m_axis_tlast;
   
   //  Instantiation of the ports
   
   axis_arbiter dut (
     .axis_clk (axis_clk),
     .resetn (resetn),
   
  // pins of first axis_master 
    .s_axis_tvalid1(s_axis_tvalid1),
    .s_axis_tready1(s_axis_tready1),
    .s_axis_tdata1(s_axis_tdata1),
    .s_axis_tlast1(s_axis_tlast1),
   
   
// pins of first axis_master 

   .s_axis_tvalid2(s_axis_tvalid2),
   .s_axis_tready2(s_axis_tready2),
   .s_axis_tdata2(s_axis_tdata2),
   .s_axis_tlast2(s_axis_tlast2),
   
   
   // pins for round robin arbiter (master arbiter)
   .m_axis_tready(m_axis_tready),
   .m_axis_tvalid(m_axis_tvalid),   // input 
   .m_axis_tdata(m_axis_tdata),
   . m_axis_tlast(m_axis_tlast)
   );
   
   integer i;
   // logic for clock signal
   
   always #10 axis_clk = ~axis_clk;
   
   initial begin
   resetn = 1'b0;
   repeat(5) @(posedge axis_clk);
   
   resetn = 1'b1;
      // for slave axis_1
   for ( i = 0; i<5 ; i= i+1) begin
    @(posedge axis_clk);
    s_axis_tvalid1 = 1'b1;
    s_axis_tdata1 = $random();
    s_axis_tlast1 = 1'b0;
    
    s_axis_tvalid2 = 1'b0;
    s_axis_tdata2 = $random();
    s_axis_tlast2 = 1'b0;
    m_axis_tready =1'b1;
    
   end
   @(posedge axis_clk);
   
 
    s_axis_tdata1 = $random();
    s_axis_tlast1 = 1'b1;
   @(posedge axis_clk);
   
   s_axis_tlast1 = 1'b0;
   s_axis_tvalid1 = 1'b0;
   @(posedge axis_clk);


      // for slave_axis_2//
   for (i = 0; i<5 ; i= i+1) 
   begin
    @(posedge axis_clk);
    
    s_axis_tvalid1 = 1'b0;
    s_axis_tdata1 = $random();
    s_axis_tlast1 = 1'b0;
    
    s_axis_tvalid2 = 1'b1;
    s_axis_tdata2 = $random();
    s_axis_tlast2 = 1'b0;
    m_axis_tready =1'b1;
   end
    @(posedge axis_clk);
    
    s_axis_tdata2 = $random();
    s_axis_tlast2 = 1'b1;
   @(posedge axis_clk);
   
   
   s_axis_tlast2 = 1'b0;
   s_axis_tvalid2 = 1'b0;
   @(posedge axis_clk);
   
   end
endmodule

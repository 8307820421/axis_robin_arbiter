`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 29.08.2024 12:07:40
// Design Name: 
// Module Name: axis_arbiter
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


module axis_arbiter(
   input wire axis_clk,
   input wire resetn,
   
  // pins of first axis_master 
  
   input wire s_axis_tvalid1,
   output wire s_axis_tready1,
   input wire [7:0]s_axis_tdata1,
   input wire s_axis_tlast1,
   
   
// pins of first axis_master 

   input wire s_axis_tvalid2,
   output wire s_axis_tready2,
   input wire [7:0]s_axis_tdata2,
   input wire s_axis_tlast2,
   
   
   // pins for round robin arbiter (master arbiter)
   input  wire  m_axis_tready,
   output  wire m_axis_tvalid,
   output wire [7:0]m_axis_tdata,
   output wire m_axis_tlast
   
   
   

    );
    
    // this is declared for synchronisation of both s_axis 
    reg [7:0] t_data;
    reg t_last;
    // as per waveform or specification
    assign s_axis_tready1 = 1'b1;
    assign s_axis_tready2 = 1'b1;
    
    localparam idle = 2'b00;
    localparam  s1 = 2'b01;  // store or tx state
    localparam s2 = 2'b10;  // finish state
    reg [1:0] state =idle , next_state = idle;
    
    // always block for reset
    
    always @ (posedge axis_clk)
    begin
     if (resetn == 1'b1)
     state <= idle;
     else 
     state <= next_state;
    end
     
    
    // FSM for request from s_axis1 and s_axis2 management
    // combinational block
always @ (*)begin
case (state)
    // idle state for  request managment w.r.t state 
 idle : begin
       if ((s_axis_tvalid1)&&(s_axis_tready1))
       begin
           next_state = s1;
           t_data = s_axis_tdata1;
           t_last = s_axis_tlast1;
        end   
       else if ((s_axis_tvalid2)&&(s_axis_tready2))
       begin
           next_state = s2;
           t_data = s_axis_tdata1;
           t_last = s_axis_tlast1;
        end 
             
       else 
       next_state = idle;
     end
     
     // s1 state handle by the master arbiter based upon s_axis1 based upon the priority
     
 s1 : begin
    if ( m_axis_tready == 1'b1) begin  // for master arbiter granting the request by s_axis1
       
        if (s_axis_tlast1)
        begin  // first slave axis 
                t_data = s_axis_tdata1;
                t_last = s_axis_tlast1; 
                
           if ((s_axis_tvalid2)&&(s_axis_tready2))
                 next_state = s2 ; // second s_axis2 handled
                 
         else  // t_last1 is deasserted (low) // else not reaches to last byte of data
           
             next_state = idle;
            
       end
       
     else begin   // there is not request (t_valid ) then remain in state 1
       
               next_state = s1;
              t_data = s_axis_tdata1;
              t_last = s_axis_tlast1;
     end
       
  end
       
 else begin   // wait for slave to consume data
       next_state = s1;
    end
        
 end

s2 : begin
  if (m_axis_tready == 1'b1) begin  // m_axis_tready acts as output (grant)  // m_axis_tvalid is as input based upon request from the
    if (s_axis_tlast2)               // slave_axis_s1 and slave_axis_s2
    begin
              t_data = s_axis_tdata2;
              t_last = s_axis_tlast2;
              
          if ((s_axis_tvalid1)&&(s_axis_tready1))
               next_state = s1;
               
   else    // t_last1 is deasserted (low) // else not reaches to last byte of data
               next_state = idle;
   end 
      
      else begin      // m_axis_tvalid high then remain in state 2
         next_state = s2;
         t_data = s_axis_tdata2;
         t_last = s_axis_tlast2;
      end   
  end
  
  else begin  // wait for slave to consume data// if there is not t_valid as request2
    next_state = s2;
  end

end
default : begin
   next_state = idle;
end

endcase  
end

assign m_axis_tdata = ((s_axis_tvalid1 && s_axis_tready1)||(s_axis_tvalid2 && s_axis_tready2)) ? t_data : 8'h00;
assign m_axis_tvalid = ((s_axis_tvalid1 && s_axis_tready1)||(s_axis_tvalid2 && s_axis_tready2)) ? 1'b1 : 1'b0;
assign m_axis_tlast = ((s_axis_tvalid1 && s_axis_tready1)||(s_axis_tvalid2 && s_axis_tready2)) ? t_last : 1'b0;

endmodule

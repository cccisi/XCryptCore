/*  
Copyright 2019 XCrypt Studio                
																	 
Licensed under the Apache License, Version 2.0 (the "License");         
you may not use this file except in compliance with the License.        
You may obtain a copy of the License at                                 
																	 
 http://www.apache.org/licenses/LICENSE-2.0                          
																	 
Unless required by applicable law or agreed to in writing, software    
distributed under the License is distributed on an "AS IS" BASIS,       
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and     
limitations under the License.                                          
*/  

// ------------------------------------------------------------------------------
// File name        :   tb_aes192_core.v
// Function         :   AES-128 Cryptographic Algorithm Core Simulate File 
// ------------------------------------------------------------------------------
// Author           :   Xie
// Version          :   v-1.0
// Date				:   2019-4-19
// Email            :   xcrypt@126.com
// ------------------------------------------------------------------------------

`timescale 1ns / 1ps

module tb_aes192_core();
    
    reg             r_clk;
    reg             r_rst;
    reg             r_flag;
	reg 			r_key_en;
    reg     [191:0] r_key; 
	reg 			r_din_en;
    reg     [127:0] r_din;
	reg 	[31:0]	r_err;
	reg 	[2:0]	r_count;
	reg				r_test;
	wire 			s_dout_en;
    wire    [127:0]  s_dout;
    wire            s_key_ok;
	reg 	[1:0]	r_state;
	
	localparam DLY = 1;
	
	reg [191:0] KEY1 = {32'h0001_0203,32'h0405_0607,32'h0809_0a0b,32'h0c0d_0e0f,32'h1011_1213,32'h1415_1617};
	reg [127:0]	PT1  = {32'h0011_2233,32'h4455_6677,32'h8899_aabb,32'hccdd_eeff};
	reg [127:0]	CT1  = {32'hdda9_7ca4,32'h864c_dfe0,32'h6eaf_70a0,32'hec0d_7191};
						   
	aes192_core uut(
    .i_clk		(r_clk		),
    .i_rst		(r_rst		),
    .i_flag		(r_flag		),  //1-encrypt,0-decrypt
    .i_key		(r_key		),
    .i_key_en	(r_key_en	),
    .i_din		(r_din		),
    .i_din_en	(r_din_en	),
    .o_dout		(s_dout		),
    .o_dout_en	(s_dout_en	),
    .o_key_ok	(s_key_ok	)
    );  
    
    initial begin
        r_clk = 0;
        forever #5 r_clk = ~r_clk;
    end
	
	always@(posedge r_clk or posedge r_rst) begin
		if(r_rst) begin
			r_count <= #DLY 3'd0;
			r_flag <= #DLY 1'b0;
			r_din_en <= #DLY 1'b0;
			r_din <= #DLY 'b0;
			r_key_en <= #DLY 1'b0;
			r_key <= #DLY 'b0;
			r_err <= #DLY 'b0;
			r_state <= #DLY 2'b0;
		end else begin
			case(r_state)
				2'd0: begin
					if(r_test) begin
						r_key_en <= #DLY 1'b1;
						r_key <= #DLY KEY1;
						r_state <= #DLY 2'd1;
					end 
				end
				2'd1: begin
					r_key_en <= #DLY 1'b0;
					if(s_key_ok) begin
						r_din_en <= #DLY 1'b1;
						r_flag <= #DLY 1'b1;
						r_din <= #DLY PT1;
						r_state <= #DLY 2'd2;
					end
				end
				2'd2: begin
					r_din_en <= #DLY 1'b0;
					if(s_dout_en) begin
						if(s_dout!=CT1)
							r_err <= #DLY r_err + 1'b1;
						r_din_en <= #DLY 1'b1;
						r_din <= #DLY CT1;
						r_flag <= #DLY 1'b0;
						r_state <= #DLY 2'd3;
					end
				end
				2'd3: begin
					r_din_en <= #DLY 1'b0;
					if(s_dout_en) begin
						if(s_dout!=PT1)
							r_err <= #DLY r_err + 1'b1;
						r_count <= #DLY r_count + 1'b1;
						if(r_count == 'd7)
							r_state <= #DLY 2'd0;
						else 
							r_state <= #DLY 2'd1;
					end				
				end
			endcase
		end
	
	end
	
	initial begin
		r_rst = 1'b1;
		r_test = 1'b0;
		repeat(50) @(negedge r_clk);
		r_rst = 1'b0;
		repeat(10) @(negedge r_clk);
		r_test = 1'b1;
		repeat(5000) @(negedge r_clk);
		$stop;
	end
    
endmodule

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
// File name        :   sm4_core.v
// Function         :   SM4 Cryptographic Algorithm Core 
// ------------------------------------------------------------------------------
// Author           :   Xie
// Version          ��  v-1.0
// Date				:   2019-2-1
// Email            :   xcrypt@126.com
// ------------------------------------------------------------------------------
`timescale 1ns / 1ps

module sm4_core(
    input           i_clk,
    input           i_rst,
    input           i_flag,  //1-encrypt,0-decrypt
    input  [127:0]  i_key,
    input           i_key_en,
	output 			o_key_ok,
    input  [127:0]  i_din,
    input           i_din_en,
    output [127:0]  o_dout,
    output          o_dout_en
    );
	
	wire 	[31:0]	s_sbox_din_ke;
	wire 	[31:0]	s_sbox_din_dp;
	wire 	[31:0]	s_sbox_din;
	wire 	[31:0]	s_sbox_dout;
	wire  [1023:0] 	s_exkey;
	
	//key expand
	sm4_keyex u_keyex(
	.i_clk		(i_clk			),
	.i_rst		(i_rst			),
	.i_key		(i_key			),
	.i_key_en	(i_key_en		),
	.o_exkey	(s_exkey		),
	.o_key_ok	(o_key_ok		),
	.o_sbox_use (s_sbox_use_ke	),
	.o_sbox_din	(s_sbox_din_ke 	),
	.i_sbox_dout(s_sbox_dout	)
	);

	//data encrypt or decrypt
	sm4_dpc u_dpc(
	.i_clk		(i_clk			),
	.i_rst		(i_rst			),	
	.i_flag		(i_flag			),
	.i_keyex	(s_exkey		),
    .i_din		(i_din			),
    .i_din_en	(i_din_en		),
    .o_dout		(o_dout			),
    .o_dout_en	(o_dout_en		),
	.o_sbox_din	(s_sbox_din_dp 	),
	.i_sbox_dout(s_sbox_dout	)	
	);	

    //s-core subbytes
    assign s_sbox_din = (s_sbox_use_ke == 1'b1) ? s_sbox_din_ke : s_sbox_din_dp;
    
    sm4_sbox u_sm4_sbox0(
    .din        (s_sbox_din[7:0]	),
    .dout       (s_sbox_dout[7:0]	)
    );
    sm4_sbox u_sm4_sbox1(
    .din        (s_sbox_din[15:8]	),
    .dout       (s_sbox_dout[15:8]	)
    );
    sm4_sbox u_sm4_sbox2(
    .din        (s_sbox_din[23:16]	),
    .dout       (s_sbox_dout[23:16]	)
    );      
    sm4_sbox u_sm4_sbox3(
    .din        (s_sbox_din[31:24]	),
    .dout       (s_sbox_dout[31:24]	)
    );    	
	
endmodule

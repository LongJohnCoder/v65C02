`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright (C) 2018 Ryan Clarke

This program is free software (firmware): you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/


/*******************************************************************************
Module Name : SevenSegmentController
Dependences : HexToSSEG
File Name   : sseg_controller.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Release History :

    Version     | Date          | Description
    --------------------------------------------
    0.0         | 08/12/2018    | Initial design
================================================================================
Purpose : Seven-segment display controller for the v65C02 8-bit Computer on the
          Nexys 4 DDR FPGA development board.
          
          The controller has two control registers: DIGITS, and DP. DIGITS
          controls the individual status of each seven-segment display, and DP
          controls the status of each decimal point.
          
                 -----------------------------------------------
                   7  |  6  |  5  |  4  |  3  |  2  |  1  |  0
                 -----------------------------------------------
          DIGITS   D7 |  D6 |  D5 |  D4 |  D3 |  D2 |  D1 |  D0
          DP      DP7 | DP6 | DP5 | DP4 | DP3 | DP2 | DP1 | DP0
          
          There are also four data registers to write two hexadecimal digits at
          a time, aka to write a byte.
*******************************************************************************/


module SevenSegmentController
    (
    input wire        clk_i,            // CPU clock
    
    input wire        en_i,             // controller bus enable
    input wire        we_i,             // write enable
    input wire  [7:0] addr_i,           // 8-bit register address bus
    input wire  [7:0] din_i,            // 8-bit data input bus
    
    output wire [7:0] an_n_o,           // anode (active low)
    output wire [7:0] sseg_n_o          // segments (active low)
    );
    
    
/* CONTROLLER REGISTERS AND RAM ***********************************************/
    
    reg [7:0] digits_reg;               // DIGITS
    reg [7:0] dp_reg;                   // DP
    reg [3:0] data_reg [0:7];           // DATA
    
    // controller registers
    initial digits_reg = 8'd0;          // all digits disabled
    initial dp_reg     = 8'd0;          // all decimal points disabled
    always @(posedge clk_i)
        if(en_i)
            if(we_i)
                case(addr_i)
                    8'h00: digits_reg <= #1 din_i;
                    8'h01: dp_reg     <= #1 din_i;
                endcase
    
    // data registers
    always @(posedge clk_i)
        if(en_i)
            if(we_i)
                case(addr_i)
                    8'h02:
                        begin
                            data_reg[0] <= #1 din_i[3:0];
                            data_reg[1] <= #1 din_i[7:4];
                        end
                
                    8'h03:
                        begin
                            data_reg[2] <= #1 din_i[3:0];
                            data_reg[3] <= #1 din_i[7:4];
                        end
                
                    8'h04:
                        begin
                            data_reg[4] <= #1 din_i[3:0];
                            data_reg[5] <= #1 din_i[7:4];
                        end
                
                    8'h05:
                        begin
                            data_reg[6] <= #1 din_i[3:0];
                            data_reg[7] <= #1 din_i[7:4];
                        end
                    endcase
    
    
/* HEX TO SEVEN-SEGMENT *******************************************************/
    
    wire [7:0] sseg_n [0:7];                 // seven-segment data
    
    generate
        genvar i;
        
        // 8x hexadecimal to seven-segment converters
        for(i = 0; i <= 7; i = i + 1)
            begin : nibbles
                HexToSSEG HexToSSEG
                    (
                    .hex_i   (data_reg[i]),
                    .dp_i    (dp_reg[i]),
                    .sseg_n_o(sseg_n[i])
                    );
            end
    endgenerate
    
    
/* MULTIPLEXER ****************************************************************/
    
    reg  [16:0] refresh_counter_reg;    // display refresh counter
    wire [2:0]  digit;                  // current seven-segment digit
    reg  [7:0]  an_n_reg;               // anode (active low)
    reg  [7:0]  sseg_n_reg;             // seven-segment digit (active low)
    
    // refresh counter
    initial refresh_counter_reg = 17'd0;
    always @(posedge clk_i)
        refresh_counter_reg <= #1 refresh_counter_reg + 17'd1;
    
    // ~432 Hz cycle rate equates to ~54 Hz display refresh rate
    assign digit = refresh_counter_reg[16:14];
    
    // anode - essentially a 3-to-8 multiplexer
    initial an_n_reg = 8'hFF;
    always @(posedge clk_i)
        an_n_reg <= #1 ~(1 << digit);
    
    // seven-segment digit - 3-to-8 multiplexer
    initial sseg_n_reg = 8'hFF;
    always @(posedge clk_i)
        sseg_n_reg <= #1 sseg_n[digit];
    
    
    // output logic
    assign an_n_o   = an_n_reg | ~digits_reg;
    assign sseg_n_o = sseg_n_reg;
    
endmodule

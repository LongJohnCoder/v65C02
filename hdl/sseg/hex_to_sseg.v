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
Module Name : HexToSSEG
Top Module  : SevenSegmentController
File Name   : hex_to_sseg.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Hexadecimal to seven-segment display converter.
          
          The output is ordered from cathode A to G from bit 0 to bit 6, with
          the decimal point DP at bit 7.
          
             _A_
            |   |
            F   B
            |_G_|
            |   |
            E   C
            |_D_| o DP
*******************************************************************************/


module HexToSSEG
    (
    input wire [3:0] hex_i,     // hexadecimal input
    input wire       dp_i,      // decimal point
    
    output reg [7:0] sseg_n_o   // seven-segment display output
    );
    
    
/* ROM TABLE ******************************************************************/
    
    always @*
        begin
            case(hex_i)
                //                        GFEDCBA
                4'h0:    sseg_n_o[6:0] = 7'b1000000;
                4'h1:    sseg_n_o[6:0] = 7'b1111001;
                4'h2:    sseg_n_o[6:0] = 7'b0100100;
                4'h3:    sseg_n_o[6:0] = 7'b0110000;
                4'h4:    sseg_n_o[6:0] = 7'b0011001;
                4'h5:    sseg_n_o[6:0] = 7'b0010010;
                4'h6:    sseg_n_o[6:0] = 7'b0000010;
                4'h7:    sseg_n_o[6:0] = 7'b1111000;
                4'h8:    sseg_n_o[6:0] = 7'b0000000;
                4'h9:    sseg_n_o[6:0] = 7'b0010000;
                4'hA:    sseg_n_o[6:0] = 7'b0001000;
                4'hB:    sseg_n_o[6:0] = 7'b0000011;
                4'hC:    sseg_n_o[6:0] = 7'b1000110;
                4'hD:    sseg_n_o[6:0] = 7'b0100001;
                4'hE:    sseg_n_o[6:0] = 7'b0000110;
                4'hF:    sseg_n_o[6:0] = 7'b0001110;
                default: sseg_n_o[6:0] = 7'b1111111;
            endcase
            
            sseg_n_o[7] = ~dp_i;
        end
    
endmodule

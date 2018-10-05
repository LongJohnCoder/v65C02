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
Module Name : RAM_32K8
Top Module  : v65C02_Top
File Name   : ram_32k8.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : 32K x 8-bit write-first RAM for the v65C02 8-bit Computer.
          
          All outputs are registered for a one clock cycle delay.
*******************************************************************************/


module RAM_32K8
    (
    input wire        clk_i,    // system clock
    
    input wire        en_i,     // RAM enable
    input wire        we_i,     // write enable
    
    input wire [14:0] addr_i,   // 14-bit address
    input wire [7:0]  din_i,    // 8-bit data input
    output reg [7:0]  dout_o    // 8-bit data outut
    );
    
    
/* DECLARATIONS ***************************************************************/
    
    // 32K x 8-bit block RAM
    (* ram_style = "block" *) reg [7:0] ram_reg [0:32767];
    
    
/* RAM REGISTER ***************************************************************/
    
    always @(posedge clk_i)
        if(en_i)
            if(we_i)
                ram_reg[addr_i] <= #1 din_i;
            else
                dout_o <= #1 ram_reg[addr_i];
    
endmodule

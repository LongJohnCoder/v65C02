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
Module Name : ROM_4K8
Top Module  : VGAController
File Name   : rom_4k8.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : 4K x 8-bit synchronous ROM.

          Loads the ROM with an 8-bit binary formatted text file.
          
          All outputs are registered for a one clock cycle delay.
*******************************************************************************/


module ROM_4K8
    (
    input wire        clk_i,    // clock
    input wire        en_i,     // ROM enable
    
    input wire [11:0] addr_i,   // 12-bit address
    output reg [7:0]  dout_o    // 8-bit data
    );
    
    
/* ROM ************************************************************************/
    
    // 4K x 8-bit block RAM
    (* rom_style = "block" *) reg [7:0] rom_reg [0:4095];
    
    // Initialize the ROM with IBM Code Page 437
    initial $readmemb("ibm_cp437.txt", rom_reg, 0, 4095);
    
    initial dout_o = 8'h00;
    always @(posedge clk_i)
        if(en_i)
            dout_o <= #1 rom_reg[addr_i];
    
endmodule

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
Module Name : RAM_4K8_2K16
Top Module  : VGAController
File Name   : ram_4k8_2k16.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Asymmetric, dual-port 32 Kb synchronous RAM with an 8-bit read/write
          (no-change) port A and a 16-bit read-only port B.
          
          All outputs are registered and incur a one clock cycle delay.
*******************************************************************************/


module RAM_4K8_2K16
    (
    // port A
    input wire        clka_i,   // clock
    input wire        ena_i,    // RAM enable
    input wire        wea_i,    // write enable
    input wire [11:0] addra_i,  // address
    input wire [7:0]  dia_i,    // data input
    output reg [7:0]  doa_o,    // data output
    
    // port B
    input wire        clkb_i,   // clock
    input wire        enb_i,    // RAM enable
    input wire [10:0] addrb_i,  // address
    output reg [15:0] dob_o     // data output
    );
    
    
/* RAM ************************************************************************/
    
    // 4K x 8-bit block RAM
    (*rom_style = "block" *) reg [7:0] ram_reg [0:4095];
    
    
/* PORT A - READ/WRITE (NO-CHANGE) ********************************************/
    
    initial doa_o = 8'h00;
    always @(posedge clka_i)
        if(ena_i)
            if(wea_i)
                ram_reg[addra_i] <= #1 dia_i;
            else
                doa_o <= #1 ram_reg[addra_i];
    
    
/* PORT B - READ-ONLY *********************************************************/
    
    // least and most significant byte addresses for 16- to 8-bit conversion
    wire [11:0] addrb_lsb;
    wire [11:0] addrb_msb;
    
    assign addrb_lsb = {addrb_i, 1'b0};     // LSB = addr * 2
    assign addrb_msb = {addrb_i, 1'b1};     // MSB = addr * 2 + 1
    
    initial dob_o = 8'h00;
    always @(posedge clkb_i)
        if(enb_i) begin
            dob_o[7:0]  <= #1 ram_reg[addrb_lsb];
            dob_o[15:8] <= #1 ram_reg[addrb_msb];
        end
    
endmodule

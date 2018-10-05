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
Module Name : ROM_4K8_tb
File Name   : rom_4k8_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module ROM_4K8 associated with the v65C02 8-bit
          Computer.
*******************************************************************************/


module ROM_4K8_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_i;
    reg        en_i;
    reg [11:0] addr_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] dout_o;
    
    
/* MODULES ********************************************************************/
    
    ROM_4K8 ROM_4K8_uut
        (
        .clk_i (clk_i),
        .en_i  (en_i),
        .addr_i(addr_i),
        .dout_o(dout_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    localparam T_clk = 10;      // clock period (ns)
    
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
    
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        en_i   =  1'b0;
        addr_i = 12'h000;
        
        // read two bytes
        #1;
        en_i   =  1'b1;
        addr_i = 12'h012;
        @(posedge clk_i);
        
        #1;
        en_i   =  1'b1;
        addr_i = 12'h013;
        @(posedge clk_i);
        
        // deselect ROM
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule

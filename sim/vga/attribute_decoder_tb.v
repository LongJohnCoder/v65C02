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
Module Name : AttributeDecoder_tb
File Name   : attribute_decoder_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Release History

    Version     | Date          | Description
    --------------------------------------------
    0.0         | 08/05/2018    | Initial design
================================================================================
Purpose : Verilog test bench for module AttributeDecoder associated with the
          v65C02 8-bit Computer.
*******************************************************************************/


module AttributeDecoder_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       en_i;
    reg [7:0] attr_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [11:0] fg_rgb_o;
    wire [11:0] bg_rgb_o;
    
    
/* MODULES ********************************************************************/
    
    AttributeDecoder AttributeDecoder_uut
        (
        .clk_i   (clk_i),
        .en_i    (en_i),
        .attr_i  (attr_i),
        .fg_rgb_o(fg_rgb_o),
        .bg_rgb_o(bg_rgb_o)
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
        en_i   = 1'b0;
        attr_i = 8'h00;
        
        // light gray text on blue background
        #1;
        en_i   = 1'b1;
        attr_i = 8'h17;
        @(posedge clk_i);
        
        // disable
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule

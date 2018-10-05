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
Module Name : CharacterGenerator
Top Module  : VGAController
File Name   : character_generator.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Character generator for the VGA text-mode controller module.
          
          Current character ASCII code is obtained from video RAM.
          
          All outputs are registered. Reading the character ROM incurs a one
          pixel-clock cycle delay. Registering the pixel output incurs a second
          delay. Total delay is two pixel-clock cycles for a valid output.
*******************************************************************************/


module CharacterGenerator
    (
    input wire         clk_i,       // pixel clock
    input wire         en_i,        // enable strobe
    
    input wire  [3:0]  glyph_row_i, // character glyph row		
    input wire  [7:0]  ascii_i,     // ASCII character code
    
    // character ROM signals
    output wire        rd_stb_o,    // read strobe
    output wire [11:0] addr_o,      // 12-bit address 
    input wire  [7:0]  din_i,       // 8-bit data
    
    output wire        pixel_o      // pixel output
    );
    
    
/* CHARACTER ROM SIGNALS ******************************************************/
    
    assign rd_stb_o = en_i;
    assign addr_o   = {ascii_i, glyph_row_i};
    
    
/* PIXEL GENERATOR ************************************************************/
    
    reg        en_p1_ff;            // pipeline delay
    reg  [8:0] glyph_pixels_reg;    // glyph pixels
    wire       bit9;                // bit-9 pixel for character
    
    // enable strobe pipeline
    initial en_p1_ff = 1'b0;
    always @(posedge clk_i)
        en_p1_ff <= #1 en_i;
    
    // extend the drawing characters to keep them continuous
    assign bit9 = ((ascii_i >= 8'd192) & (ascii_i <  8'd223)) ? din_i[0] : 1'b0;
    
    // glyph pixels shift register
    initial glyph_pixels_reg = 9'd0;
    always @(posedge clk_i)
        if(en_p1_ff)
            glyph_pixels_reg <= #1 {din_i, bit9};
        else
            glyph_pixels_reg <= #1 {glyph_pixels_reg[7:0], 1'b0};
    
    assign pixel_o = glyph_pixels_reg[8];
    
endmodule

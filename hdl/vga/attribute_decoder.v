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
Module Name : AttributeDecoder
Top Module  : VGAController
File Name   : attribute_decoder.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Attribute decoder for the VGA text-mode controller module.
          
          Converts each foreground and background value of the current
          attribute stored in video RAM into the appropriate 12-bit RGB444
          value. Attributes are two 4-bit nibbles, representing a coded
          foreground color (lower nibble) and background color (upper nibble).
          
          All outputs are registered for a one pixel clock cycle delay.
*******************************************************************************/


module AttributeDecoder
    (
    input wire        clk_i,        // pixel clock
    input wire        en_i,         // enable
    
    input wire [7:0]  attr_i,       // attribute
    
    output reg [11:0] fg_rgb_o,     // foreground RGB444 value
    output reg [11:0] bg_rgb_o      // background RGB444 value
    );
    
    
/* FOREGROUND ATTRIBUTE *******************************************************/
    
    wire [3:0] fg_attr;
    
    // extract foreground attribute from 8-bit input
    assign fg_attr = attr_i[3:0];
    
    // foreground RGB444 value
    initial fg_rgb_o = 12'h000;
    always @(posedge clk_i)
        if(en_i)
            case(fg_attr)
                4'h0: fg_rgb_o <= #1 {4'd0,  4'd0,  4'd0 };    // black
                4'h1: fg_rgb_o <= #1 {4'd0,  4'd0,  4'd10};    // blue
                4'h2: fg_rgb_o <= #1 {4'd0,  4'd10, 4'd0 };    // green
                4'h3: fg_rgb_o <= #1 {4'd0,  4'd10, 4'd10};    // cyan
                4'h4: fg_rgb_o <= #1 {4'd10, 4'd0,  4'd0 };    // red
                4'h5: fg_rgb_o <= #1 {4'd10, 4'd0,  4'd10};    // magenta
                4'h6: fg_rgb_o <= #1 {4'd10, 4'd5,  4'd0 };    // brown
                4'h7: fg_rgb_o <= #1 {4'd10, 4'd10, 4'd10};    // light gray
                4'h8: fg_rgb_o <= #1 {4'd5,  4'd5,  4'd5 };    // dark gray
                4'h9: fg_rgb_o <= #1 {4'd5,  4'd5,  4'd15};    // light blue
                4'ha: fg_rgb_o <= #1 {4'd5,  4'd15, 4'd5 };    // light green
                4'hb: fg_rgb_o <= #1 {4'd5,  4'd15, 4'd15};    // light cyan
                4'hc: fg_rgb_o <= #1 {4'd15, 4'd5,  4'd5 };    // light red
                4'hd: fg_rgb_o <= #1 {4'd15, 4'd5,  4'd15};    // light magenta
                4'he: fg_rgb_o <= #1 {4'd15, 4'd15, 4'd5 };    // yellow
                4'hf: fg_rgb_o <= #1 {4'd15, 4'd15, 4'd15};    // white
            endcase
    
    
/* BACKGROUND ATTRIBUTE *******************************************************/    
    
    wire [3:0] bg_attr;
    
    // extract background attribute from 8-bit input
    assign bg_attr = attr_i[7:4];
    
    // background RGB444 value
    initial bg_rgb_o = 12'h000;
    always @(posedge clk_i)
        if(en_i)
            case(bg_attr)
                4'h0: bg_rgb_o <= #1 {4'd0,  4'd0,  4'd0 };    // black
                4'h1: bg_rgb_o <= #1 {4'd0,  4'd0,  4'd10};    // blue
                4'h2: bg_rgb_o <= #1 {4'd0,  4'd10, 4'd0 };    // green
                4'h3: bg_rgb_o <= #1 {4'd0,  4'd10, 4'd10};    // cyan
                4'h4: bg_rgb_o <= #1 {4'd10, 4'd0,  4'd0 };    // red
                4'h5: bg_rgb_o <= #1 {4'd10, 4'd0,  4'd10};    // magenta
                4'h6: bg_rgb_o <= #1 {4'd10, 4'd5,  4'd0 };    // brown
                4'h7: bg_rgb_o <= #1 {4'd10, 4'd10, 4'd10};    // light gray
                4'h8: bg_rgb_o <= #1 {4'd5,  4'd5,  4'd5 };    // dark gray
                4'h9: bg_rgb_o <= #1 {4'd5,  4'd5,  4'd15};    // light blue
                4'ha: bg_rgb_o <= #1 {4'd5,  4'd15, 4'd5 };    // light green
                4'hb: bg_rgb_o <= #1 {4'd5,  4'd15, 4'd15};    // light cyan
                4'hc: bg_rgb_o <= #1 {4'd15, 4'd5,  4'd5 };    // light red
                4'hd: bg_rgb_o <= #1 {4'd15, 4'd5,  4'd15};    // light magenta
                4'he: bg_rgb_o <= #1 {4'd15, 4'd15, 4'd5 };    // yellow
                4'hf: bg_rgb_o <= #1 {4'd15, 4'd15, 4'd15};    // white
            endcase
    
endmodule

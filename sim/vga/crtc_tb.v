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
Module Name : CRTC_tb
File Name   : crtc_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module CRTC associated with the v65C02 8-bit
          Computer.
*******************************************************************************/


module CRTC_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire       col_stb_o;
    wire [6:0] col_o;
    wire [8:0] line_o;
    wire       cursor_o;
    wire       hsync_o;
    wire       vsync_o;
    wire       video_on_o;
    
    
/* MODULES ********************************************************************/
    
    CRTC CRTC_uut
        (
        .clk_i     (clk_i),
        .col_stb_o (col_stb_o),
        .col_o     (col_o),
        .line_o    (line_o),
        .cursor_o  (cursor_o),		
        .hsync_o   (hsync_o),
        .vsync_o   (vsync_o),
        .video_on_o(video_on_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    localparam T_clk = 10;          // clock period (ns)
    
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
    
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        @(posedge clk_i);
        
        // observe cursor timing
        @(negedge cursor_o);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule

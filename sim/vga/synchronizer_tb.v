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
Module Name : Synchronizer_tb
File Name   : synchronizer_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module Synchronizer associated with the v65C02
          8-bit Computer.
*******************************************************************************/


module Synchronizer_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_i;
    reg        en_i;
    reg        hsync_i;
    reg        vsync_i;
    reg        video_on_i;
    reg        pixel_i;
    reg        cursor_i;
    reg [11:0] fg_rgb_i;
    reg [11:0] bg_rgb_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [11:0] rgb_o;
    wire        hsync_o;
    wire        vsync_o;
    
    
/* MODULES ********************************************************************/
    
    Synchronizer Synchronizer_uut
        (
        .clk_i     (clk_i),
        .en_i      (en_i),
        .hsync_i   (hsync_i),
        .vsync_i   (vsync_i),
        .video_on_i(video_on_i),
        .pixel_i   (pixel_i),
        .cursor_i  (cursor_i),
        .fg_rgb_i  (fg_rgb_i),
        .bg_rgb_i  (bg_rgb_i),
        .rgb_o     (rgb_o),
        .hsync_o   (hsync_o),
        .vsync_o   (vsync_o)
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
        // T = 1: initial state
        en_i       =  1'b0;
        hsync_i    =  1'b0;
        vsync_i    =  1'b0;
        video_on_i =  1'b0;
        pixel_i    =  1'b0;
        cursor_i   =  1'b0;
        fg_rgb_i   = 12'h000;
        bg_rgb_i   = 12'h000;
        
        // T = 2: valid CRTC
        #1;
        en_i       =  1'b1;
        hsync_i    =  1'b1;
        video_on_i =  1'b1;
        @(posedge clk_i);      
         
        // T = 3: valid video RAM
        @(posedge clk_i);
        
        // T = 4: valid attribute and valid character ROM
        #1;
        fg_rgb_i = 12'hAAA;
        bg_rgb_i = 12'h000;
        @(posedge clk_i);
        
        // T = 5: valid pixel
        #1;
        pixel_i = 1'b1;
        @(posedge clk_i);
        
        // T = 6: valid output
        @(posedge clk_i)
        
        // pixel on, cursor on
        #1;
        cursor_i = 1'b1;
        @(posedge clk_i)
        
        // pixel off, cursor on
        #1;
        pixel_i = 1'b0;
        @(posedge clk_i);
        
        // pixel off, cursor off
        #1;
        cursor_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule

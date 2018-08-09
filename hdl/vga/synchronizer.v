`timescale 1 ns / 1 ps

/*******************************************************************************
Copyright (C) 2017-2018 Ryan Clarke

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
Module Name : Synchronizer
Top Module  : VGAController
File Name   : synchronizer.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Synchronizer for the VGA text-mode controller module.
          
          Synchronizes the horizontal and vertical sync, active video flag, 
          character generator pixel, RGB444, and cursor inputs. The horizontal
          and vertical sync, active video flag, and cursor pixelo are delayed
          three pixel-clock cycles in order to match timing.
          
          The synchronizer is the final end point for the VGA signal and can be
          enabled and disabled to blank the screen.
          
          All outputs are registered and incur a one pixel-clock delay. Total
          delay from start to a valid output is six pixel-clock cycles.
*******************************************************************************/


module Synchronizer
    (
    input wire         clk_i,       // pixel clock
    input wire         en_i,        // output enable
    
    input wire         hsync_i,     // horizontal sync from CRTC
    input wire         vsync_i,     // vertical sync from CRTC
    input wire         video_on_i,  // active video flag from CRTC
    
    input wire         pixel_i,     // character generator pixel 
    input wire         cursor_i,    // cursor pixel
    
    input wire  [11:0] fg_rgb_i,    // foreground RGB444 from attribute decoder
    input wire  [11:0] bg_rgb_i,    // background RGB444 from attribute decoder
    
    output wire [11:0] rgb_o,       // RGB444 output
    output wire        hsync_o,     // horizontal sync output
    output wire        vsync_o      // vertical sync output
    );
    
    
/* PIPELINE SYNC **************************************************************/
    
    // horizontal sync pipeline
    reg hsync_p1_ff;
    reg hsync_p2_ff;
    reg hsync_p3_ff;
    
    // vertical sync pipeline
    reg vsync_p1_ff;
    reg vsync_p2_ff;
    reg vsync_p3_ff;
    
    // active video flag pipeline
    reg video_on_p1_ff;
    reg video_on_p2_ff;
    reg video_on_p3_ff;
    
    // cursor pixel pipeline
    reg cursor_p1_ff;
    reg cursor_p2_ff;
    reg cursor_p3_ff;
    
    // horizontal sync
    initial hsync_p1_ff = 1'b0;
    initial hsync_p2_ff = 1'b0;
    initial hsync_p3_ff = 1'b0;
    always @(posedge clk_i) begin
        hsync_p1_ff <= #1 hsync_i;
        hsync_p2_ff <= #1 hsync_p1_ff;
        hsync_p3_ff <= #1 hsync_p2_ff;
    end
    
    // vertical sync
    initial vsync_p1_ff = 1'b0;
    initial vsync_p2_ff = 1'b0;
    initial vsync_p3_ff = 1'b0;
    always @(posedge clk_i) begin
        vsync_p1_ff <= #1 vsync_i;
        vsync_p2_ff <= #1 vsync_p1_ff;
        vsync_p3_ff <= #1 vsync_p2_ff;
    end
    
    // active video indicator
    initial video_on_p1_ff = 1'b0;
    initial video_on_p2_ff = 1'b0;
    initial video_on_p3_ff = 1'b0;
    always @(posedge clk_i) begin
        video_on_p1_ff <= #1 video_on_i;
        video_on_p2_ff <= #1 video_on_p1_ff;
        video_on_p3_ff <= #1 video_on_p2_ff;
    end
    
    // cursor timing
    initial cursor_p1_ff = 1'b0;
    initial cursor_p2_ff = 1'b0;
    initial cursor_p3_ff = 1'b0;
    always @(posedge clk_i) begin
        cursor_p1_ff <= #1 cursor_i;
        cursor_p2_ff <= #1 cursor_p1_ff;
        cursor_p3_ff <= #1 cursor_p2_ff;
    end
    
    
/* FINAL OUTPUT REGISTERS *****************************************************/
    
    localparam COLOR_BLACK = 12'h000; 
    
    wire [11:0] rgb_mux;        // foreground/background RGB444 multiplexer
    reg  [11:0] rgb_reg;        // multiplexed RGB444 register
    reg         hsync_p4_ff;    // horizontal sync
    reg         vsync_p4_ff;    // vertical sync
    
    // multiplex the character and cursor pixel with the foreground and
    // background RGB444 values    
    assign rgb_mux = (cursor_p3_ff | pixel_i) ? fg_rgb_i
                                              : bg_rgb_i;
    
    // RGB444 output
    initial rgb_reg = 12'h000;
    always @(posedge clk_i)
        if(en_i & video_on_p3_ff)
            rgb_reg <= #1 rgb_mux;
        else
            rgb_reg <= #1 COLOR_BLACK;
    
    // output logic
    assign rgb_o   = rgb_reg;
    
    // horizontal and vertical sync signals
    initial hsync_p4_ff = 1'b0;
    initial vsync_p4_ff = 1'b0;
    always @(posedge clk_i) begin
        hsync_p4_ff <= #1 hsync_p3_ff;
        vsync_p4_ff <= #1 vsync_p3_ff;
    end
    
    // output logic
    assign hsync_o = hsync_p4_ff;
    assign vsync_o = vsync_p4_ff;
    
endmodule

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
Module Name : CRTC
Top Module  : VGAController
File Name   : crtc.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : CRT controller for the VGA text-mode controller module.

          Generates the character column and scan line, horizontal and vertical
          sync signals, cursor timing, and active video flag.
        
          The horizontal and vertical sync are derived from the character column
          and scan line. The column and scan line are pipelined to match the
          sync signals. The cursor timing is based off the frame rate.
          
          Total output delay is two pixel clock cycles.
*******************************************************************************/


module CRTC
    (
    input wire        clk_i,        // pixel clock
    
    output wire       col_stb_o,    // new column strobe
    output wire [6:0] col_o,        // character column
    output wire [8:0] line_o,       // scan line
    
    output wire       cursor_o,     // cursor timing
    
    output wire       hsync_o,      // horizontal sync
    output wire       vsync_o,      // vertical sync
    
    output wire       video_on_o    // active video flag
    );
    
    
/* COMMON DEFINITIONS *********************************************************/
    
    // parameters for CRTC timing: 720 x 400 @ 70 Hz (28.322 MHz pixel clock)
    localparam HS_TOTAL   = 7'd100,     // 100 characters (900 pixels)
               HS_ACTIVE  = 7'd80,      //  80 characters (720 pixels)
               HS_START   = 7'd82,      //  82 characters (738 pixels)
               HS_TIME    = 7'd12,      //  12 characters (108 pixels)
               HS_POL     = 1'b0;       // negative pulse
               
    localparam VS_TOTAL   = 9'd449,     // 449 lines
               VS_ACTIVE  = 9'd400,     // 400 lines
               VS_START   = 9'd413,     // 413 lines
               VS_TIME    = 9'd2,       //   2 lines
               VS_POL     = 1'b1;       // positive pulse
    
    localparam CHAR_WIDTH = 4'd9;       // character glyph width (pixels)
    
    
/* GLYPH PIXEL COUNTER ********************************************************/
    
    reg  [3:0] pixel_reg;       // glyph pixel counter
    wire       char_end;        // character end indicator
    
    assign char_end = (pixel_reg == CHAR_WIDTH - 4'h1);    
    
    initial pixel_reg = 4'h0;
    always @(posedge clk_i)
        if(char_end)
            pixel_reg <= #1 4'h0;
        else
            pixel_reg <= #1 pixel_reg + 4'h1;
    
    
/* CHARACTER COLUMN COUNTER ***************************************************/
    
    wire       col_start;       // column start indicator
    reg        col_stb_ff;      // new column strobe
    reg  [6:0] col_reg;         // character column counter
    reg  [6:0] col_p1_reg;      // pipeline delay
    wire       last_col;        // last column indicator
    
    assign col_start = (pixel_reg == 4'h0);
    
    // new column strobe
    initial col_stb_ff = 1'b0;
    always @(posedge clk_i)
        col_stb_ff <= #1 col_start;
    
    assign last_col = (col_reg   == HS_TOTAL - 7'd1);
    
    // character column counter
    initial col_reg = 7'd0;
    always @(posedge clk_i)
        if(char_end)
            if(last_col)
                col_reg <= #1 7'd0;
            else
                col_reg <= #1 col_reg + 7'd1;
    
    // pipeline delay to match sync timing
    initial col_p1_reg  = 7'd0;
    always @(posedge clk_i)
        col_p1_reg  <= #1 col_reg;
    
    // output logic
    assign col_stb_o = col_stb_ff;
    assign col_o     = col_p1_reg;
    
    
/* SCAN LINE COUNTER **********************************************************/    
    
    reg  [8:0] line_reg;        // scan line counter
    reg  [8:0] line_p1_reg;     // pipeline delay
    wire       last_line;       // last line indicator
    
    assign last_line = (line_reg  == VS_TOTAL - 9'd1);
    
    // scan line counter
    initial line_reg = 9'd0;
    always @(posedge clk_i)
        if(last_col & char_end)
            if(last_line)
                line_reg <= #1 9'd0;
            else
                line_reg <= #1 line_reg + 9'd1;
    
    // pipeline delay to match sync timing
    initial line_p1_reg = 9'd0;
    always @(posedge clk_i)
        line_p1_reg <= #1 line_reg;
    
    // output logic
    assign line_o    = line_p1_reg;
    
    
/* SYNC SIGNALS ***************************************************************/
    
    reg        hsync_ff;        // horizontal sync
    reg        vsync_ff;        // vertical sync
    wire       hsync_on;        // horizontal sync active indicator
    wire       vsync_on;        // vertical sync active indicator
    
    assign hsync_on = (col_reg >= (HS_START)) &
                      (col_reg <  (HS_START + HS_TIME));
    assign vsync_on = (line_reg >= (VS_START)) &
                      (line_reg <  (VS_START + VS_TIME));
    
    // horizontal sync
    initial hsync_ff = 1'b0;
    always @(posedge clk_i)
        if(hsync_on)
            hsync_ff <= #1 HS_POL;
        else
            hsync_ff <= #1 ~HS_POL;
    
    // vertical sync
    initial vsync_ff = 1'b0;
    always @(posedge clk_i)
        if(vsync_on)
            vsync_ff <= #1 VS_POL;
        else
            vsync_ff <= #1 ~VS_POL;
    
    // output logic
    assign hsync_o = hsync_ff;
    assign vsync_o = vsync_ff;
    
    
/* ACTIVE VIDEO FLAG **********************************************************/
    
    reg video_on_ff;            // active video indicator
    
    // active video flag
    initial video_on_ff = 1'b0;
    always @(posedge clk_i)
        video_on_ff <= #1 (col_reg < HS_ACTIVE) & (line_reg < VS_ACTIVE);
    
    // output logic
    assign video_on_o = video_on_ff;
    
    
/* CURSOR TIMING **************************************************************/
    
    wire       frame_end;       // frame end indicator
    reg  [4:0] frame_cnt_reg;   // frame counter
    reg        cursor_ff;       // cursor timing
    
    assign frame_end = char_end & last_col & last_line;
    
    // frame counter
    initial frame_cnt_reg = 4'h0;
    always @(posedge clk_i)
        if(frame_end)
            frame_cnt_reg <= #1 frame_cnt_reg + 4'h1;
    
    // cursor blink rate is tied to frame rate. Blinks at 2.1875 Hz
    // 1/(2 * 16 / 70.09) Hz
    initial cursor_ff = 1'b0;
    always @(posedge clk_i)
        cursor_ff <= #1 frame_cnt_reg[4];
    
    // output logic
    assign cursor_o = cursor_ff;
    
endmodule

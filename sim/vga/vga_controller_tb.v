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
Module Name : VGAController_tb
File Name   : vga_controller_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module VGAController associated with the v65C02
          8-bit Computer.
*******************************************************************************/


module VGAController_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_cpu_i;
    reg        clk_pixel_i;
    reg        ctrl_en_i;
    reg        vram_en_i;
    reg        we_i;
    reg [11:0] addr_i;
    reg [7:0]  din_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0]  dout_o;
    wire [11:0] rgb_o;
    wire        hsync_o;
    wire        vsync_o;
    
    
/* MODULES ********************************************************************/
    
    VGAController VGAController_uut
        (
        .clk_cpu_i  (clk_cpu_i),
        .clk_pixel_i(clk_pixel_i),
        .ctrl_en_i  (ctrl_en_i),
        .vram_en_i  (vram_en_i),
        .we_i       (we_i),
        .addr_i     (addr_i),
        .din_i      (din_i),
        .dout_o     (dout_o),
        .rgb_o      (rgb_o),
        .hsync_o    (hsync_o),
        .vsync_o    (vsync_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    // clock period (ns)
    localparam T_clk_cpu   = 40;
    localparam T_clk_pixel = T_clk_cpu / 4;
    
    // CPU clock
    always begin
        clk_cpu_i = 1'b1;
        #(T_clk_cpu / 2);
    
        clk_cpu_i = 1'b0;
        #(T_clk_cpu / 2);
    end
    
    // pixel clock
    always begin
        clk_pixel_i = 1'b1;
        #(T_clk_pixel / 2);
    
        clk_pixel_i = 1'b0;
        #(T_clk_pixel / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        ctrl_en_i =  1'b0;
        vram_en_i =  1'b0;
        we_i      =  1'b0;
        addr_i    = 12'h000;
        din_i     =  8'd0;
        
        // write NUL character to VRAM address 0x000
        #1;
        vram_en_i =  1'b1;
        we_i      =  1'b1;
        addr_i    = 12'h000;
        din_i     =  8'h00;
        @(posedge clk_cpu_i);
        
        // write light gray on black attribute to VRAM address 0x001
        #1;
        addr_i = 12'h001;
        din_i  =  8'h07;
        @(posedge clk_cpu_i);
        
        // move cursor to (1,1)
        #1;
        vram_en_i =  1'b0;
        ctrl_en_i =  1'b1;
        addr_i    = 12'h001;
        din_i     =  8'h51;
        @(posedge clk_cpu_i);
        
        #1;
        addr_i = 12'h002;
        din_i  =  8'h00;
        @(posedge clk_cpu_i);
        
        // enable VGA output and cursor
        #1;
        addr_i    = 12'h000;
        din_i     = 8'h03;
        @(posedge clk_cpu_i);
        
        // read video RAM address 0x001
        #1;
        ctrl_en_i =  1'b0;
        we_i      =  1'b0;
        vram_en_i =  1'b1;
        addr_i    = 12'h001;
        @(posedge clk_cpu_i);
        
        // read STATUS register
        #1;
        vram_en_i = 1'b0;
        ctrl_en_i = 1'b1;
        addr_i    = 12'h000;
        @(posedge clk_cpu_i);
        
        // read cursor address
        #1;
        addr_i = 12'h001;
        @(posedge clk_cpu_i);
        
        #1;
        addr_i = 12'h002;
        @(posedge clk_cpu_i);
        
        // deselect VGA
        #1;
        ctrl_en_i = 1'b0;
        @(posedge clk_cpu_i);
        
        // run for 33 frames to observe cursor
        //I#(33 * T_clk_pixel * 900 * 449);
        
        // done
        @(posedge clk_cpu_i) $stop;
    end
    
endmodule

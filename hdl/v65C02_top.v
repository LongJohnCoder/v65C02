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
Module Name : v65C02_Top
Dependences : ClockGen, CPUReset, cpu_65c02, RAM_32K8, ROM_16K8, VGAController
File Name   : v65C02_top.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Release History :

    Version     | Date          | Description
    --------------------------------------------
    0.0         | 07/25/2018    | Initial design
================================================================================
Purpose : Top module for the v65C02 8-bit Computer.
*******************************************************************************/


module v65C02_Top
    (
    input  wire       CLK100MHZ,    // 100 MHz Nexys 4 DDR clock
    input  wire       CPU_RESETN,   // active-low asynchronous reset
    
    output wire [3:0] VGA_R,        // red
    output wire [3:0] VGA_G,        // green
    output wire [3:0] VGA_B,        // blue
    output wire       VGA_HS,       // horizontal sync
    output wire       VGA_VS        // vertical sync
    );
    
    
/* CLOCK GENERATOR ************************************************************/
    
    wire clk_pixel;
    wire clk_cpu;
    
    clk_gen ClockGen
        (
        .clk_100M_i  (CLK100MHZ),
        .clk_28_32M_o(clk_pixel),
        .clk_7_08M_o (clk_cpu)
        );
    
    
/* CPU RESET BUTTON ***********************************************************/
    
    reg  rst_async_ff;
    reg  rst_sync_ff;
    wire rst_cpu;
    
    // reset synchronizer
    initial rst_async_ff = 1'b0;
    initial rst_sync_ff  = 1'b0;
    always @(posedge clk_cpu) begin
        rst_async_ff <= #1 ~CPU_RESETN;
        rst_sync_ff  <= #1 rst_async_ff;
    end
    
    CPUReset CPUReset
        (
        .clk_i    (clk_cpu),
        .trigger_i(rst_sync_ff),
        .reset_o  (rst_cpu)
        );
    
    
/* 65C02 CPU ******************************************************************/
    
    wire [15:0] cpu_addr;
    reg  [7:0]  cpu_din;
    wire [7:0]  cpu_dout;
    wire        cpu_we;
    
    cpu_65c02 CPU
        (
        .clk  (clk_cpu),
        .reset(rst_cpu),
        .AB   (cpu_addr),
        .DI   (cpu_din),
        .DO   (cpu_dout),
        .WE   (cpu_we),
        .IRQ  (1'b0),
        .NMI  (1'b0),
        .RDY  (1'b1)
        );
    
    
/* RAM ************************************************************************/
    
    localparam RAM_ADDR = 4'b0XXX;
    
    wire       ram_en;
    wire [7:0] ram_dout;
    
    assign ram_en  = ~cpu_addr[15];
    
    RAM_32K8 RAM
        (
        .clk_i (clk_cpu),
        .en_i  (ram_en),
        .we_i  (cpu_we),
        .addr_i(cpu_addr[14:0]),
        .din_i (cpu_dout),
        .dout_o(ram_dout)
        );
    
    
/* ROM BIOS *******************************************************************/
    
    localparam BIOS_ADDR = 4'b11XX;
    
    wire       bios_en;
    wire [7:0] bios_dout;
    
    assign bios_en = & cpu_addr[15:14];
    
    ROM_16K8 BIOS
        (
        .clk_i (clk_cpu),
        .en_i  (bios_en),
        .addr_i(cpu_addr[13:0]),
        .dout_o(bios_dout)
        );
    
    
/* VGA CONTROLLER *************************************************************/
    
    localparam VRAM_ADDR   = 4'b1000;
    localparam VGA_CONTROL = 4'b1001;
    
    wire        vga_vram_en;
    wire [7:0]  vga_vram_dout;
    wire        vga_ctrl_en;
    wire [7:0]  vga_ctrl_dout;
    wire [11:0] vga_rgb;
    wire        vga_hsync;
    wire        vga_vsync;
    
    assign vga_vram_en = (cpu_addr[15:12] == VRAM_ADDR);
    assign vga_ctrl_en = (cpu_addr[15:12] == VGA_CONTROL);
    
    VGAController VGAController
        (
        .clk_cpu_i  (clk_cpu),
        .clk_pixel_i(clk_pixel),
        .vram_en_i  (vga_vram_en),
        .vram_we_i  (cpu_we),
        .vram_addr_i(cpu_addr[11:0]),
        .vram_din_i (cpu_dout),
        .vram_dout_o(vga_vram_dout),
        .ctrl_en_i  (vga_ctrl_en),
        .ctrl_we_i  (cpu_we),
        .ctrl_addr_i(cpu_addr[1:0]),
        .ctrl_din_i (cpu_dout),
        .ctrl_dout_o(vga_ctrl_dout),
        .rgb_o      (vga_rgb),
        .hsync_o    (vga_hsync),
        .vsync_o    (vga_vsync)
        );
    
    assign {VGA_R, VGA_G, VGA_B} = vga_rgb;
    assign VGA_HS = vga_hsync;
    assign VGA_VS = vga_vsync;
    
    
/* MEMORY DECODING LOGIC ******************************************************/
    
    localparam NOP = 8'hEA;
    
    reg [3:0] cpu_addr_p1_4_reg;
    
    initial cpu_addr_p1_4_reg = 4'h0;
    always @(posedge clk_cpu)
        cpu_addr_p1_4_reg <= #1 cpu_addr[15:12];
    
    always @*
        casex(cpu_addr_p1_4_reg)
            RAM_ADDR:    cpu_din = ram_dout;
            VRAM_ADDR:   cpu_din = vga_vram_dout;
            BIOS_ADDR:   cpu_din = bios_dout;
            VGA_CONTROL: cpu_din = vga_ctrl_dout;
            default:     cpu_din = NOP;
        endcase
    
endmodule

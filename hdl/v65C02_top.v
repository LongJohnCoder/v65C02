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
    input  wire       CLK100MHZ,        // 100 MHz Nexys 4 DDR clock
    input  wire       CPU_RESETN,       // active-low asynchronous reset
    
    // VGA
    output wire [3:0] VGA_R,            // red
    output wire [3:0] VGA_G,            // green
    output wire [3:0] VGA_B,            // blue
    output wire       VGA_HS,           // horizontal sync
    output wire       VGA_VS,           // vertical sync
    
    // seven-segment display
    output wire [7:0] AN,
    output wire       CA,
    output wire       CB,
    output wire       CC,
    output wire       CD,
    output wire       CE,
    output wire       CF,
    output wire       CG,
    output wire       DP
    );
    
    
/* CLOCK GENERATOR ************************************************************/
    
    wire clk_pixel;                     // pixel clock
    wire clk_cpu;                       // CPU clock
    
    ClockGen ClockGen
        (
        .clk_100M_i   (CLK100MHZ),
        .clk_28_322M_o(clk_pixel),
        .clk_50M_o    (clk_cpu)
        );
    
    
/* CPU RESET BUTTON ***********************************************************/
    
    reg  rst_async_ff;                  // reset synchronizer
    reg  rst_sync_ff;
    wire rst_cpu;                       // v65C02 reset signal
    
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
    
    
/* v65C02 CPU *****************************************************************/
    
    wire [15:0] cpu_addr;               // v65C02 16-bit address bus
    reg  [7:0]  cpu_din;                // v65C02 8-bit data input
    wire [7:0]  cpu_dout;               // v65C02 8-bit data output
    wire        cpu_we;                 // v65C02 data write enable
    
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
    
    localparam RAM_ADDR = 8'b0XXX_XXXX; // RAM = $0000 -> $7FFF
    
    wire       ram_en;                  // RAM enable
    wire [7:0] ram_dout;                // RAM 8-bit data out
    
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
    
    localparam BIOS_ADDR = 8'b11XX_XXXX;    // BIOS = $C000 -> $FFFF
    
    wire       bios_en;                     // BIOS enable
    wire [7:0] bios_dout;                   // BIOS 8-bit data out
    
    assign bios_en = & cpu_addr[15:14];
    
    ROM_16K8 BIOS
        (
        .clka (clk_cpu),
        .ena  (bios_en),
        .addra(cpu_addr[13:0]),
        .douta(bios_dout)
        );
    
    
/* VGA CONTROLLER *************************************************************/
    
    localparam VRAM_ADDR   = 8'b1000_XXXX;  // VRAM = $8000 -> $8FFF
    localparam VGA_CONTROL = 8'b1001_0000;  // VGA control bus = $9000 -> $90FF
    
    wire        vga_ctrl_en;            // VGA control bus enable
    wire        vga_vram_en;            // video RAM enable
    wire [7:0]  vga_dout;               // 8-bit data output
    wire [11:0] vga_rgb;                // RGB444 output
    wire        vga_hsync;              // horizontal sync
    wire        vga_vsync;              // vertical sync
    
    assign vga_ctrl_en = (cpu_addr[15:8] == VGA_CONTROL);
    assign vga_vram_en = (cpu_addr[15:12] == VRAM_ADDR[7:4]);
    
    VGAController VGAController
        (
        .clk_cpu_i  (clk_cpu),
        .clk_pixel_i(clk_pixel),
        .ctrl_en_i  (vga_ctrl_en),
        .vram_en_i  (vga_vram_en),
        .we_i       (cpu_we),
        .addr_i     (cpu_addr[11:0]),
        .din_i      (cpu_dout),
        .dout_o     (vga_dout),
        .rgb_o      (vga_rgb),
        .hsync_o    (vga_hsync),
        .vsync_o    (vga_vsync)
        );
    
    // output logic
    assign {VGA_R, VGA_G, VGA_B} = vga_rgb;
    assign VGA_HS = vga_hsync;
    assign VGA_VS = vga_vsync;
    
    
/* SEVEN-SEGMENT CONTROLLER ***************************************************/
    
    localparam SSEG_CONTROL = 8'b1001_0001;     // SSEG ctrl bus = $9100->$91FF
    
    wire sseg_en;                       // SSEG control bus enable
    wire [7:0] sseg_an_n;               // anode (active low)
    wire [7:0] sseg_sseg_n;             // seven-segment digit (active low)
    
    assign sseg_en = (cpu_addr[15:8] == SSEG_CONTROL);
    
    SevenSegmentController SevenSegmentController
        (
        .clk_i   (clk_cpu),
        .en_i    (sseg_en),
        .we_i    (cpu_we),
        .addr_i  (cpu_addr[7:0]),
        .din_i   (cpu_dout),
        .an_n_o  (sseg_an_n),
        .sseg_n_o(sseg_sseg_n)
        );
    
    // output logic
    assign AN = sseg_an_n;
    assign {DP, CG, CF, CE, CD, CC, CB, CA} = sseg_sseg_n;
    
    
/* MEMORY DECODING LOGIC ******************************************************/
    
    localparam NOP = 8'h00;             // 65C02 NOP opcode
    
    reg [7:0] cpu_addr_p1_msb_reg;      // v65C02 address MSB pipeline
    
    // v65C02 expects valid data after one-clock cycle
    initial cpu_addr_p1_msb_reg = 8'h00;
    always @(posedge clk_cpu)
        cpu_addr_p1_msb_reg <= #1 cpu_addr[15:8];
    
    // v65C02 data input multiplexer
    always @*
        casex(cpu_addr_p1_msb_reg)
            RAM_ADDR:    cpu_din = ram_dout;
            VRAM_ADDR:   cpu_din = vga_dout;
            VGA_CONTROL: cpu_din = vga_dout;
            BIOS_ADDR:   cpu_din = bios_dout;
            default:     cpu_din = NOP;
        endcase
    
endmodule

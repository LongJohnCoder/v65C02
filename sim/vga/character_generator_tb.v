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
Module Name : CharacterGenerator_tb
File Name   : character_generator_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module CharacterGenerator associated with the
          v65C02 8-bit Computer.
*******************************************************************************/


module CharacterGenerator_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_i;
    reg        en_i;
    reg  [3:0] glyph_row_i;
    reg  [7:0] ascii_i;
    wire [7:0] rom2gen_data;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire        rd_stb_o;
    wire [11:0] gen2rom_addr;
    wire        pixel_o;
    
    
/* MODULES ********************************************************************/
    
    CharacterGenerator CharacterGenerator_uut
        (
        .clk_i      (clk_i),
        .en_i       (en_i),
        .glyph_row_i(glyph_row_i),
        .ascii_i    (ascii_i),
        .rd_stb_o   (rd_stb_o),
        .addr_o     (gen2rom_addr),
        .din_i      (rom2gen_data),
        .pixel_o    (pixel_o)
        );
    
    ROM_4K8 CharacterROM
        (
        .clk_i (clk_i),
        .en_i  (en_i),
        .addr_i(gen2rom_addr),
        .dout_o(rom2gen_data)
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
        en_i        = 1'b0;
        glyph_row_i = 4'h0;
        ascii_i     = 8'h00;
        
        // ASCII and glyph data (01110111 + 0)
        #1;
        en_i        = 1'b1;
        ascii_i     = 8'd178;
        glyph_row_i = 4'h1;
        @(posedge clk_i);
        
        // valid character ROM
        #1;
        en_i = 1'b0;
        @(posedge clk_i)
        
        // generate 9 pixels
        repeat(9)
            @(posedge clk_i);
        
        // ASCII and glyph data (11111111 + 1)
        #1;
        en_i        = 1'b1;
        ascii_i     = 8'd219;
        glyph_row_i = 4'h0;
        @(posedge clk_i);
        
        // valid character ROM
        #1;
        en_i = 1'b0;
        @(posedge clk_i)
        
        // generate 9 pixels
        repeat(9)
            @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
endmodule

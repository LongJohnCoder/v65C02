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
Module Name : PS2_RX
Parent:     : KeyboardController
File Name   : ps2_rx.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : PS/2 receiver module for the v65C02 8-bit Computer.
          
          The receiver responds to the falling edge of the PS/2 clock signal,
          in accordance with the PS/2 protocol. After capturing all 11 bits of
          the protocol (start bit, 8-bit scan code, parity bit, and stop bit),
          the receiver emits a one system-clock cycle tick to signal that a scan
          code was received.
*******************************************************************************/


module PS2_RX
    (
    input  wire       clk_i,        // system clock
    
    input  wire       ps2_clk_i,    // PS/2 clock input
    input  wire       ps2_din_i,    // PS/2 data input
    
    output wire       rx_stb_o,     // keyboard scan code received strobe
    output wire [7:0] scan_code_o   // keyboard scan code
    );
    
    
/* PS/2 CLOCK FALLING EDGE DETECTOR *******************************************/
    
    reg  ps2_clk_p1_ff;      // PS/2 clock delay
    wire ps2_clk_fe;         // PS/2 clock falling edge
    
    // PS/2 clock delay
    initial ps2_clk_p1_ff = 1'b1;
    always @(posedge clk_i) begin
        ps2_clk_p1_ff <= #1 ps2_clk_i;
    end
    
    // falling edge detector
    assign ps2_clk_fe = ps2_clk_p1_ff & ~ps2_clk_i;
    
    
/* BIT COUNTER ****************************************************************/
    
    // received bits counter
    reg [3:0] bit_count_reg;
    
    initial bit_count_reg = 4'h0;
    always @(posedge clk_i)
        if(ps2_clk_fe) begin
            if(bit_count_reg == 4'h0)
                bit_count_reg <= #1 4'hA;   // reset bit count on first fall
            else
                bit_count_reg <= #1 bit_count_reg - 4'h1;
        end
    
    
/* RECEIVE SHIFT REGISTER *****************************************************/
    
    reg  [10:0] rxsr_reg;           // 11-bit receive shift register
    
    initial rxsr_reg = 11'd0;
    always @(posedge clk_i)
        if(ps2_clk_fe)
            if(bit_count_reg > 4'h0)    // only capture 11 bits
                rxsr_reg <= #1 {ps2_din_i, rxsr_reg[10:1]}; // right shift
                
    // output logic
    assign scan_code_o = rxsr_reg[8:1];
    
    
/* RECEIVE STROBE *************************************************************/
    
    reg  [3:0] bit_count_p1_reg;    // bit counter delay
    wire       rx_stb;              // received strobe (really a falling edge)
    
    initial bit_count_p1_reg = 4'h0;
    always @(posedge clk_i)
        bit_count_p1_reg <= #1 bit_count_reg;
    
    // output logic (detects when bit_count goes to 0)
    assign rx_stb_o = (| bit_count_p1_reg) & (bit_count_reg == 4'h0);
    
endmodule

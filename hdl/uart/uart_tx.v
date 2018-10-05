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
Module Name : UART_TX
Parent      : UARTController
File Name   : uart_tx.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : UART Transmitter module for the v65C02 8-bit Computer.

          Preset for 8-N-1. Baud rate is determined by Fosc / [16 * (BRG + 1)].
          Transmission starts after 8-bit data is written to the transmit shift
          register. The busy flag is high while the module is shifting the data
          out. 
*******************************************************************************/


module UART_TX
    (
    input wire        clk_i,        // system clock
    
    input wire        brg_stb_i,    // baud rate generator strobe
    input wire        we_i,         // write enable
    
    input  wire [7:0] din_i,        // 8-bit data input
    output wire       dout_o,       // 1-bit serial output
    
    output wire       busy_o        // busy flag
    );
    
    
/* BAUD RATE GENERATOR DIV 16 *************************************************/
    
    reg  [3:0] brg_16_reg;          // baud rate generator divide-by-16 register
    wire       brg_16_stb;          // baud rate generator divide-by-16 strobe
    
    initial brg_16_reg = 4'h0;
    always @(posedge clk_i)
        if(brg_stb_i)
            brg_16_reg <= #1 brg_16_reg + 4'h1;
    
    // one clock-cycle strobe at a baud rate generator divide-by-16 rate
    assign brg_16_stb = (brg_16_reg == 4'hF) & (brg_stb_i);
    
    
/* TRANSMIT SHIFT REGISTER ****************************************************/
    
    // transmit bit values
    localparam B_IDLE  = 1'b1,
               B_START = 1'b0,
               B_STOP  = 1'b1;
    
    reg [9:0] txsr_reg;                 // 10-bit transmit shift register
    
    initial txsr_reg = {10{B_IDLE}};
    always @(posedge clk_i)
        if(we_i)
            txsr_reg <= #1 {B_STOP, din_i, B_START};        // load
        else
            if(brg_16_stb)
                txsr_reg <= #1 {B_IDLE, txsr_reg[9:1]};     // right shift
    
    
/* SERIAL OUTPUT **************************************************************/
    
    reg dout_ff;                        // 1-bit serial data
    
    initial dout_ff = B_IDLE;
    always @(posedge clk_i)
        if(brg_16_stb)
            dout_ff <= #1 txsr_reg[0];  // LSb of transmit shift register
    
    // output logic
    assign dout_o = dout_ff;
    
    
/* BUSY FLAG ******************************************************************/
    
    reg [3:0] bit_count_reg;            // transmitted bit counter
    
    initial bit_count_reg = 4'hF;       // empty
    always @(posedge clk_i) begin
        if(we_i)
            bit_count_reg <= #1 4'd10;  // 10 bits to transmit
        else
            if(brg_16_stb)              // sync with baud rate generator/16
                if(bit_count_reg != 4'hF)
                    bit_count_reg <= #1 bit_count_reg - 4'h1;
    end
    
    // output logic
    assign busy_o = (bit_count_reg != 4'hF);    // rolls through 0
    
endmodule

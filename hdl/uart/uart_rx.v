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
Module Name : UART_RX
Parent      : UARTController
File Name   : uart_tx.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : UART Receiver module for the v65C02 8-bit Computer.

          Preset for 8-N-1. Baud rate is determined by Fosc / [16 * (BRG + 1)].
*******************************************************************************/


module UART_RX
    (
    input  wire       clk_i,            // CPU clock
    
    input  wire       brg_stb_i,        // baud rate generator strobe
    
    input  wire       din_i,            // 1-bit serial data input
    output wire [7:0] dout_o,           // 8-bit data output
    
    output wire       done_stb_o        // new received byte strobe
    );
    
    
/* BAUD RATE GENERATOR COUNTER ************************************************/
    
    reg [3:0] brg_count_reg;
    reg [3:0] brg_count_ns;
    
    initial brg_count_reg = 4'h0;
    always @(posedge clk_i)
        brg_count_reg <= #1 brg_count_ns;
    
    
/* BIT COUNTER ****************************************************************/
    
    reg [3:0] bit_count_reg;
    reg [3:0] bit_count_ns;
    
    initial bit_count_reg = 4'h0;
    always @(posedge clk_i)
        bit_count_reg <= #1 bit_count_ns;
    
    
/* STATE MACHINE **************************************************************/
    
    localparam S_IDLE = 2'b00,
               S_SYNC = 2'b01,
               S_DATA = 2'b10,
               S_DONE = 2'b11;
    
    localparam B_START = 1'b0;
    
    reg [1:0] state_reg;
    reg [1:0] state_ns;
    
    initial state_reg = S_IDLE;
    always @(posedge clk_i)
        state_reg <= #1 state_ns;
    
    always @* begin
        brg_count_ns = brg_count_reg;
        bit_count_ns = bit_count_reg;
        state_ns     = state_reg;
        
        case(state_reg)
            S_IDLE:
                if(din_i == B_START) begin
                    brg_count_ns = 4'h0;
                    state_ns     = S_SYNC;
                end
            
            S_SYNC:
                if(brg_stb_i) begin
                    if(brg_count_reg == 4'h7) begin
                        brg_count_ns = 4'h0;
                        bit_count_ns = 4'h0;
                        state_ns     = S_DATA;
                    end
                    else begin
                        brg_count_ns = brg_count_reg + 4'h1;
                    end
                end
            
            S_DATA:
                if(brg_stb_i)
                    if(brg_count_reg == 4'hF) begin
                        brg_count_ns = 4'h0;
                        
                        if(bit_count_reg == 4'h7)
                            state_ns = S_DONE;
                        else
                            bit_count_ns = bit_count_reg + 4'h1;
                    end
                    else begin
                        brg_count_ns = brg_count_reg + 4'h1;
                    end
            
            S_DONE:
                state_ns = S_IDLE;
            
            default:
                state_ns = S_IDLE;
            
        endcase
    end
    
    
/* RECEIVE SHIFT REGISTER *****************************************************/
    
    localparam B_IDLE = 1'b1;
    
    wire       rxsr_en;
    reg  [7:0] rxsr_reg;
    
    assign rxsr_en = (brg_stb_i) &
                     (state_reg == S_DATA) &
                     (brg_count_reg == 4'hF);
    
    initial rxsr_reg = {8{B_IDLE}};
    always @(posedge clk_i)
        if(rxsr_en)
            rxsr_reg <= #1 {din_i, rxsr_reg[7:1]};
    
    // output logic
    assign dout_o = rxsr_reg;
    

/* NEW RECEIVED BYTE **********************************************************/
    
    reg done_stb_ff;
    
    initial done_stb_ff = 1'b0;
    always @(posedge clk_i)
        if(state_reg == S_DONE)
            done_stb_ff <= #1 1'b1;
        else
            done_stb_ff <= #1 1'b0;
    
    // output logic
    assign done_stb_o = done_stb_ff;
    
endmodule

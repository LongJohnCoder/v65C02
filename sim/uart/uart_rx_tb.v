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
Module Name : UART_TX_tb
File Name   : uart_tx_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module UART_RX associated with the v65C02 8-bit
          Computer's UART.
*******************************************************************************/


module UART_RX_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_i;
    wire       brg_stb_i;
    
    reg        we_i;            // transmitter write enable
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] dout_o;
    wire       done_stb_o;
    
    wire       tx2rx_dout;      // transmitter serial data output
    wire       busy_o;          // transmitter busy flag
    
    
/* MODULES ********************************************************************/
    
    UART_RX UART_RX_uut
        (
        .clk_i     (clk_i),
        .brg_stb_i (brg_stb_i),
        .din_i     (tx2rx_dout),
        .dout_o    (dout_o),
        .done_stb_o(done_stb_o)
        );
    
    // use transmitter to send data to the receiver
    UART_TX UART_TX
        (
        .clk_i    (clk_i),
        .brg_stb_i(brg_stb_i),
        .we_i     (we_i),
        .din_i    (8'h75),
        .dout_o   (tx2rx_dout),
        .busy_o   (busy_o)        
        );
    
    
/* CLOCK **********************************************************************/
    
    // clock period (ns)
    localparam T_clk = 10;
    
    // system clock
    always begin
        clk_i = 1'b1;
        #(T_clk / 2);
    
        clk_i = 1'b0;
        #(T_clk / 2);
    end
    
    
/* BAUD RATE GENERATOR ********************************************************/
    
    reg [1:0] brg_reg;
    
    initial brg_reg = 2'b00;
    always @(posedge clk_i)
        brg_reg <= #1 brg_reg + 2'b01;
    
    assign brg_stb_i = (brg_reg == 2'b11); // BRG = 100e6 / (16 * 4)
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        we_i = 1'b0;
                
        // transmit 0x75
        #1;
        we_i  = 1'b1;
        @(posedge clk_i);
        
        #1;
        we_i = 1'b0;
        @(posedge clk_i);
        
        // wait for complete reception
        wait(done_stb_o);
        @(posedge clk_i);
        
        // done
        @(posedge clk_i);
        $stop;
    end
        
endmodule

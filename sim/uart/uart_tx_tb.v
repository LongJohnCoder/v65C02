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
Purpose : Verilog test bench for module UART_TX associated with the v65C02 8-bit
          Computer's UART.
*******************************************************************************/


module UART_TX_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg       clk_i;
    wire      brg_stb_i;
    reg       we_i;
    reg [7:0] din_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire      dout_o;
    wire      busy_o;
    
    
/* MODULES ********************************************************************/
    
    UART_TX UART_TX_uut
        (
        .clk_i    (clk_i),
        .brg_stb_i(brg_stb_i),
        .we_i     (we_i),
        .din_i    (din_i),
        .dout_o   (dout_o),
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
        we_i  = 1'b0;
        din_i = 8'd0;
        
        // transmit 0x75
        #1;
        we_i  = 1'b1;
        din_i = 8'h75;
        @(posedge clk_i);
        
        #1;
        we_i = 1'b0;
        @(posedge clk_i);
        
        // wait for complete transmission
        wait(~busy_o);
        @(posedge clk_i);
        
        // transmit 0x53
        #1;
        we_i  = 1'b1;
        din_i = 8'h53;
        @(posedge clk_i);
        
        #1;
        we_i = 1'b0;
        @(posedge clk_i);
        
        // wait for complete transmission
        wait(~busy_o);
        @(posedge clk_i);
        
        $stop;
    end
        
endmodule

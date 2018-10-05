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
Module Name : UARTController_tb
File Name   : uart_controller_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module UARTController associated with the
          v65C02 8-bit Computer.
*******************************************************************************/


module UARTController_tb;


/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       en_i;
    reg       we_i;
    reg [7:0] addr_i;
    reg [7:0] din_i;
    
    reg       tx_we_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] dout_o;
    wire       tx_o;
    
    wire       tx_dout;
    
    
/* MODULES ********************************************************************/
    
        reg delay;
    
    UARTController UARTController_uut
        (
        .clk_i (clk_i),
        .en_i  (en_i),
        .we_i  (we_i),
        .addr_i(addr_i),
        .din_i (din_i),
        .dout_o(dout_o),
        .tx_o  (tx_o),
        .rx_i  (tx_dout)
        );
    
    // use transmitter to send data to the receiver
    UART_TX UART_TX
        (
        .clk_i    (clk_i),
        .brg_stb_i(UARTController_uut.brg_stb),
        .we_i     (tx_we_i),
        .din_i    (8'h75),
        .dout_o   (tx_dout),
        .busy_o   ()        
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
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        en_i   = 1'b0;
        we_i   = 1'b0;
        addr_i = 8'h00;
        din_i  = 8'h00;
        
        // set BRG = 0x0001
        #1;
        en_i   = 1'b1;
        we_i   = 1'b1;
        addr_i = 8'h01;
        din_i  = 8'h01;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        we_i = 1'b0;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b1;
        we_i = 1'b1;
        addr_i = 8'h02;
        din_i  = 8'h00;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        we_i = 1'b0;
        @(posedge clk_i);
        
        // transmit 0x75
        #1;
        en_i   = 1'b1;
        we_i   = 1'b1;
        addr_i = 8'h03;
        din_i  = 8'h75;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        we_i = 1'b0;
        @(posedge clk_i);
        
        // receive 0x75
        #1;
        tx_we_i = 1'b1;
        @(posedge clk_i);
        
        #1;
        tx_we_i = 1'b0;
        @(posedge clk_i);
        
        // wait for complete transmission
        #1;
        en_i   = 1'b1;
        addr_i = 8'h00;
        @(posedge clk_i);
        
        // delay for read
        @(posedge clk_i);
        
        // check TXBUSY bit
        while(dout_o[0])
            @(posedge clk_i);
        
        // wait for complete reception ... check RXFULL bit
        while(!dout_o[1])
            @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        //read received byte        
        #1;
        en_i = 1'b1;
        addr_i = 8'h04;
        @(posedge clk_i);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // done
        @(posedge clk_i);
        $stop;
    end
        
endmodule

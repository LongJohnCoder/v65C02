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
Module Name : UARTController
Dependences : UART_TX, UART_RX
File Name   : uart_controller.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : UART controller for the v65C02 8-bit Computer on the Nexys 4 DDR FPGA
          development board.
          
          The controller has four registers: STATUS, BRGL, BRGH, TXREG, RXREG.
          The STATUS register contains the status and control bits for the UART.
          BRGL and BRGH make up the 16-bit Baud Rate Generator. TXREG is the
          data register for transmitted data and RXREG is the received data.
          
                 ---------------------------------------------------------------
                    7   |   6   |   5   |   4   |   3   |   2   |   1   |   0
                 ---------------------------------------------------------------
          STATUS    X   |   X   |   X   |   X   |   X   |   X   | RXFULL| TXBUSY
          BRGL    BRG7  | BRG6  | BRG5  | BRG4  | BRG3  | BRG2  | BRG1  |  BRG0
          BRGH    BRG15 | BRG14 | BRG13 | BRG12 | BRG11 | BRG10 | BRG9  |  BRG8
          TXREG     D7  |   D6  |   D5  |   D4  |   D3  |   D2  |  D1   |   D0
          
          Baud rate is determine by the following equation:
          
            Baud Rate = Fosc / [16 * (BRG + 1)]            
*******************************************************************************/


module UARTController
    (
    input  wire       clk_i,        // CPU clock
    
    input  wire       en_i,         // control bus select
    input  wire       we_i,         // write enable
    
    input  wire [7:0] addr_i,       // 8-bit register address
    input  wire [7:0] din_i,        // 8-bit register data input
    output wire [7:0] dout_o,       // 8-bit register data output
    
    input  wire       rx_i,         // serial input
    output wire       tx_o          // serial output
    );
    
    
/* SERIAL INPUT SYNCHRONIZER **************************************************/
    
    reg        rx_async_ff;         // serial input synchronizer
    reg        rx_sync_ff;
    
    // synchronize serial input to CPU clock
    initial rx_async_ff = B_IDLE;
    initial rx_sync_ff  = B_IDLE;
    always @(posedge clk_i) begin
        rx_async_ff <= #1 rx_i;
        rx_sync_ff  <= #1 rx_async_ff;
    end
    
    
/* CONTROLLER REGISTERS *******************************************************/
    
    localparam STATUS = 8'h00,
               BRGL   = 8'h01,
               BRGH   = 8'h02,
               TXREG  = 8'h03,
               RXREG  = 8'h04;
    
    reg [7:0] brgl_reg;             // baud rate generator (LSB)
    reg [7:0] brgh_reg;             // baud rate generator (MSB)
    reg [7:0] rxdata_reg;           // received data
    reg [7:0] dout_reg;             // register data output
    
    // input registers
    initial brgl_reg   = 8'h00;
    initial brgh_reg   = 8'h00;
    always @(posedge clk_i)
        if(en_i)
            if(we_i)
                case(addr_i)
                    BRGL:   brgl_reg <= #1 din_i;
                    BRGH:   brgh_reg <= #1 din_i;
                endcase
    
    // output registers
    initial dout_reg = 8'h00;
    always @(posedge clk_i)
        if(en_i)
            case(addr_i)
                STATUS:  dout_reg <= #1 {6'b0000_00, rx_full_ff, tx_busy};
                RXREG:   dout_reg <= #1 rxdata_reg;
                default: dout_reg <= #1 8'h00;
            endcase
    
    // output logic
    assign dout_o = dout_reg;
    
    
/* BAUD RATE GENERATOR ********************************************************/
    
    reg  [15:0] brg_count_reg;      // baud rate generator counter
    wire        brg_stb;            // baud rate generator strobe
    
    initial brg_count_reg = 16'h0000;
    always @(posedge clk_i) begin
        if(brg_count_reg == {brgh_reg, brgl_reg})
            brg_count_reg <= #1 16'h0000;
        else
            brg_count_reg <= #1 brg_count_reg + 16'h0001;
    end
    
    assign brg_stb = (brg_count_reg == {brgh_reg, brgl_reg});
    
    
/* TRANSMITTER ****************************************************************/
    
    wire tx_we;                     // transmit enable
    wire tx_dout;                   // serial data output
    wire tx_busy;                   // transmit busy
    
    assign tx_we = en_i & we_i & (addr_i == TXREG);
    
    UART_TX UART_TX
        (
        .clk_i    (clk_i),
        .brg_stb_i(brg_stb),
        .we_i     (tx_we),
        .din_i    (din_i),
        .dout_o   (tx_dout),
        .busy_o   (tx_busy)
        );
    
    // output logic
    assign tx_o = tx_dout;
    
    
/* RECEIVER *******************************************************************/
    
    localparam B_IDLE = 1'b1;       // idle high
    
    wire [7:0] rx_dout;             // 8-bit received data (non-persistent)
    wire       rx_done_stb;         // new data
    reg        rx_full_ff;          // receiver full
    
    UART_RX UART_RX
        (
        .clk_i     (clk_i),
        .brg_stb_i (brg_stb),
        .din_i     (rx_sync_ff),
        .dout_o    (rx_dout),
        .done_stb_o(rx_done_stb)
        );
    
    // received data register (RXDATA)
    initial rxdata_reg = 8'h00;
    always @(posedge clk_i)
        if(rx_done_stb)
            rxdata_reg <= #1 rx_dout;           // stores read data
    
    // receiver full flag
    initial rx_full_ff = 1'b0;
    always @(posedge clk_i) begin
        if(rx_done_stb)
            rx_full_ff <= #1 1'b1;
        else
            if(en_i)
                if(addr_i == RXREG)
                    rx_full_ff <= #1 1'b0;      // reset on read
    end
    
endmodule

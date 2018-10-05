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
Module Name : SevenSegmentController_tb
File Name   : sseg_controller_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module SevenSegmentController associated with
          the v65C02 8-bit Computer.
*******************************************************************************/


module SevenSegmentController_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clk_i;
    reg        en_i;
    reg        we_i;
    reg [11:0] addr_i;
    reg [7:0]  din_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] an_n_o;
    wire [7:0] sseg_n_o;
    
    
/* MODULES ********************************************************************/
    
    SevenSegmentController SevenSegmentController_uut
        (
        .clk_i   (clk_i),
        .en_i    (en_i),
        .we_i    (we_i),
        .addr_i  (addr_i),
        .din_i   (din_i),
        .an_n_o  (an_n_o),
        .sseg_n_o(sseg_n_o)
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
        en_i   =  1'b0;
        we_i   =  1'b0;
        addr_i = 12'h000;
        din_i  =  8'd0;
        
        // write 76543210 to the seven-segment display
        for(integer i = 2; i < 10; i = i + 1) begin
            #1;
            en_i   = 1'b1;
            we_i   = 1'b1;
            addr_i = i;
            din_i  = i - 2;
            @(posedge clk_i);
        end
        
        // enable all digits
        #1;
        addr_i = 12'h000;
        din_i  =  8'hFF;
        @(posedge clk_i);
        
        // deselect controller bus
        #1;
        en_i = 1'b0;
        we_i = 1'b0;
        @(posedge clk_i);
        
        wait(ascii == "7");
        wait(ascii == "0");
        
        // disable first 4 digits
        #1;
        en_i   = 1'b1;
        we_i   = 1'b1;
        addr_i = 12'h000;
        din_i  =  8'hF0;
        @(posedge clk_i);
        
        // deselect controller bus
        #1;
        en_i = 1'b0;
        we_i = 1'b0;
        @(posedge clk_i);
        
        wait(ascii == "7");
        
        // done
        @(posedge clk_i) $stop;
    end
    
    
/* SSEG TO ASCII **************************************************************/
    
    reg [7:0] ascii;
    
    task sseg_to_ascii;
        input [7:0] sseg_n;
        begin
            case(sseg_n[6:0])
                7'b1000000: ascii = "0";
                7'b1111001: ascii = "1";
                7'b0100100: ascii = "2";
                7'b0110000: ascii = "3";
                7'b0011001: ascii = "4";
                7'b0010010: ascii = "5";
                7'b0000010: ascii = "6";
                7'b1111000: ascii = "7";
                7'b0000000: ascii = "8";
                7'b0010000: ascii = "9";
                7'b0001000: ascii = "A";
                7'b0000011: ascii = "B";
                7'b1000110: ascii = "C";
                7'b0100001: ascii = "D";
                7'b0000110: ascii = "E";
                7'b0001110: ascii = "F";
                default:    ascii = "X";
            endcase
        end
    endtask
       
    always begin
        @(posedge clk_i);
        sseg_to_ascii(sseg_n_o);
    end
    
endmodule

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
Module Name : PS2_RX_tb
File Name   : ps2_rx_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Release History

    Version     | Date          | Description
    --------------------------------------------
    0.1         | 05/04/2018    | Initial design
================================================================================
Purpose : Verilog test bench for module PS2_RX associated with the v65C02 8-bit
          Computer.
*******************************************************************************/

module PS2_RX_tb;


/* INPUTS *********************************************************************/
    
    reg clk_i;
    reg ps2_clk_i;
    reg ps2_din_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire       rx_stb_o;
    wire [7:0] scan_code_o;
    
    
/* MODULES ********************************************************************/
    
    // unit under test
    PS2_RX PS2_RX_uut
        (
        .clk_i      (clk_i),
        .ps2_clk_i  (ps2_clk_i),
        .ps2_din_i  (ps2_din_i),
        .rx_stb_o   (rx_stb_o),
        .scan_code_o(scan_code_o)
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
    
    // scan codes
    localparam KEY_A = 8'h1c;
    localparam KEY_Q = 8'h15;
    
    initial begin
        ps2_clk_i = 1'b1;
        ps2_din_i = 1'b1;
        
        $write("Pressing A... ");
        #1;
        press_key(KEY_A);
        @(posedge clk_i);
        
        $write("Pressing Q... ");
        #1;
        press_key(KEY_Q);
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
    // display scan code when received
    always @(posedge clk_i)
        if(rx_stb_o)
            $display("Scan code: %h", scan_code_o);
    
    
/* KEY PRESS ******************************************************************/
    
    // PS/2 protocol bits
    localparam PS2_START_BIT = 1'b0;
    localparam PS2_STOP_BIT  = 1'b1;
    
    // Simulate pressing a key
    task press_key;
        input    [7:0] scan_code;
        reg     [10:0] data;
        reg            odd_parity;
        integer        i;
        begin
            odd_parity = ~(^scan_code);     // set if even number of ones
            data       = {PS2_STOP_BIT, odd_parity, scan_code, PS2_START_BIT};
            
            // 10kHz PS/2 clock
            for(i = 0; i < 11; i = i + 1)
                begin
                    ps2_din_i = data[i];
                    
                    // 50 us half-period
                    #(50000);
                    ps2_clk_i = 0;
                    
                    // 50 us half-period
                    #(50000);
                    ps2_clk_i = 1;
                end
        end    
    endtask
    
endmodule

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
Module Name : KeyboardController_tb
File Name   : kbd_controller_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module KeyboardController associated with the
          v65C02 8-bit Computer.
*******************************************************************************/

module KeyboardController_tb;


/* INPUTS *********************************************************************/
    
    reg       clk_i;
    reg       en_i;
    reg [7:0] addr_i;
    reg       ps2_clk_i;
    reg       ps2_din_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0] dout_o;
    
    
/* MODULES ********************************************************************/
    
    // unit under test
    KeyboardController KeyboardController_uut
        (
        .clk_i    (clk_i),
        .en_i     (en_i),
        .addr_i   (addr_i),
        .dout_o   (dout_o),
        .ps2_clk_i(ps2_clk_i),
        .ps2_din_i(ps2_din_i)
        );
    
    
/* CLOCKS *********************************************************************/
    
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
    localparam KEY_A   = 8'h1c;
    localparam KEY_B   = 8'h32;
    localparam L_SHIFT = 8'h12;
    localparam BREAK   = 8'hf0;
    
    // controller registers
    localparam STATUS   = 8'h00,
               SCANCODE = 8'h01;
    
    initial begin
        en_i      = 1'b0;
        addr_i    = 8'h00;
        ps2_clk_i = 1'b1;
        ps2_din_i = 1'b1;
        
        // press and release "a"
        #1;
        press_key(KEY_A);
        press_key(BREAK);
        press_key(KEY_A);
        @(posedge clk_i);
        
        // read the STATUS register and wait until there is a scan code avail.
        #1;
        en_i   = 1'b1;
        addr_i = STATUS;
        @(posedge clk_i);
        
        while(~dout_o[0])
            @(posedge clk_i);
        
        // read the scan code
        #1;
        en_i = 1'b1;
        addr_i = SCANCODE;
        @(posedge clk_i);
        
        // display the scan code
        @(posedge clk_i);
        $display("Scan code: %h", dout_o);
        
        #1;
        en_i = 1'b0;
        @(posedge clk_i);
        
        // press and release shift + "b"
        #1;
        press_key(L_SHIFT);
        press_key(KEY_B);
        press_key(BREAK);
        press_key(KEY_B);
        press_key(BREAK);
        press_key(L_SHIFT);
        @(posedge clk_i);
        
        // done
        @(posedge clk_i) $stop;
    end
    
    
/* TASKS **********************************************************************/
    
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

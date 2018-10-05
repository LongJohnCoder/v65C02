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
Module Name : CPUReset
Top Module  : v65C02_Top
File Name   : cpu_reset.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Reset circuit for the v65C02 8-bit Computer.
          
          Generates an active-high reset signal, triggered on startup or by the
          rising-edge sensitive trigger input. The reset signal lasts four clock
          cycles to meet the minimum 2 clock cycle specification of the 65C02.
*******************************************************************************/


module CPUReset
    (
    input  wire clk_i,              // system clock
    
    input  wire trigger_i,          // trigger (rising edge sensitive)
    output wire reset_o             // reset signal
    );
    
    
/* RISING EDGE DETECTOR *******************************************************/
    
    reg        trigger_prev_ff;     // previous trigger input
    wire       trigger_edge;        // rising-edge detector
    
    initial trigger_prev_ff = 1'b0;
    always @(posedge clk_i)
        trigger_prev_ff <= #1 trigger_i;
    
    assign trigger_edge = ~trigger_prev_ff & trigger_i;
    
    
/* RESET SIGNAL ***************************************************************/
    
    reg  [2:0] counter_reg;         // clock cycle counter
    
    initial counter_reg = 3'd0;
    always @(posedge clk_i)
        if(trigger_edge)
            counter_reg <= #1 3'd0;
        else if(~counter_reg[2])
            counter_reg <= #1 counter_reg + 3'd1;
    
    assign reset_o = ~counter_reg[2];
    
endmodule

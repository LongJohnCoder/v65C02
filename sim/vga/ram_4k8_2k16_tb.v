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
Module Name : RAM_4K8_2K16_tb
File Name   : ram_4k8_2k16_tb.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Purpose : Verilog test bench for module RAM_4K8_2K16 associated with the v65C02
          8-bit Computer.
*******************************************************************************/


module RAM_4K8_2K16_tb;
    
    
/* INPUTS *********************************************************************/
    
    reg        clka_i;
    reg        clkb_i;
    reg        ena_i;
    reg        enb_i;
    reg        wea_i;
    reg [11:0] addra_i;
    reg [10:0] addrb_i;
    reg [7:0]  dia_i;
    
    
/* OUTPUTS  *******************************************************************/
    
    wire [7:0]  doa_o;
    wire [15:0] dob_o;
    
    
/* CONSTANTS ******************************************************************/
    
    // clock period (ns)
    localparam T_clka = 10;
    localparam T_clkb = T_clka * 4;
    
    
/* MODULES ********************************************************************/
    
    RAM_4K8_2K16 RAM_4K8_2K16_uut
        (
        .clka_i (clka_i),
        .ena_i  (ena_i),
        .wea_i  (wea_i),
        .addra_i(addra_i),
        .dia_i  (dia_i),
        .doa_o  (doa_o),
        .clkb_i (clkb_i),
        .enb_i  (enb_i),
        .addrb_i(addrb_i),
        .dob_o  (dob_o)
        );
    
    
/* CLOCK **********************************************************************/
    
    // clock A
    always begin
        clka_i = 1'b1;
        #(T_clka / 2);
    
        clka_i = 1'b0;
        #(T_clka / 2);
    end
    
    // clock B
    always begin
        clkb_i = 1'b1;
        #(T_clkb / 2);
        
        clkb_i = 1'b0;
        #(T_clkb / 2);
    end
    
    
/* MAIN ***********************************************************************/
    
    initial begin
        ena_i   =  1'b0;
        wea_i   =  1'b0;
        addra_i = 12'h000;
        enb_i   =  1'b0;
        addrb_i = 11'h000;
        dia_i   =  8'h00;
        
        // write two bytes to port A
        #1;
        ena_i   =  1'b1;
        wea_i   =  1'b1;
        addra_i = 12'h000;
        dia_i   =  8'h01;
        @(posedge clka_i);
        
        #1;
        ena_i   =  1'b1;
        wea_i   =  1'b1;
        addra_i = 12'h001;
        dia_i   =  8'h02;
        @(posedge clka_i);
        
        // read two bytes from port A
        #1;
        ena_i   =  1'b1;
        wea_i   =  1'b0;
        addra_i = 12'h000;
        @(posedge clka_i);
        
        #1;
        ena_i   =  1'b1;
        wea_i   =  1'b0;
        addra_i = 12'h001;
        @(posedge clka_i);
        
        // deselect port A
        #1;
        ena_i = 1'b0;
        @(posedge clka_i);
        
        // read one byte from port B
        #1;
        enb_i   =  1'b1;
        addrb_i = 12'h000;
        @(posedge clkb_i);
        
        // deselect port B
        #1;
        enb_i = 1'b0;
        @(posedge clkb_i);
        
        // done
        @(posedge clkb_i) $stop;
    end
    
endmodule

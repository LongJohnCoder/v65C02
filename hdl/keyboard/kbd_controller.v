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
Module Name : KeyboardController
File Name   : kbd_controller.v
Project     : v65C02 8-bit Computer
Author      : Ryan Clarke
E-mail      : kj6msg@icloud.com
================================================================================
Release History :

    Version     | Date          | Description
    --------------------------------------------
    0.1         | 05/06/2018    | Initial design
================================================================================
Purpose : PS/2 keyboard controller for the v65C02 8-bit Computer.
*******************************************************************************/

module KeyboardController
    (
    input  wire       clk_i,        // CPU clock
    
    input  wire       en_i,         // controller bus select
    
    input  wire [7:0] addr_i,       // 8-bit register address
    output wire [7:0] dout_o,       // 8-bit register data output
    
    input  wire       ps2_clk_i,    // PS/2 clock input
    input  wire       ps2_din_i     // PS/2 data input
    );
    
    
/* INPUT SYNCHRONIZER *********************************************************/
    
    reg ps2_clk_async_ff;               // PS/2 clock synchronizer
    reg ps2_clk_sync_ff;                // PS/2 clock synchronizer
    
    reg ps2_din_async_ff;               // PS/2 data synchronizer
    reg ps2_din_sync_ff;                // PS/2 data synchronizer
    
    // PS/2 clock synchronizer
    initial ps2_clk_async_ff = 1'b1;
    initial ps2_clk_sync_ff  = 1'b1;
    always @(posedge clk_i) begin
        ps2_clk_async_ff <= #1 ps2_clk_i;
        ps2_clk_sync_ff  <= #1 ps2_clk_async_ff;
    end
    
    // PS/2 data synchronizer
    initial ps2_din_async_ff = 1'b1;
    initial ps2_din_sync_ff  = 1'b1;
    always @(posedge clk_i) begin
        ps2_din_async_ff <= #1 ps2_din_i;
        ps2_din_sync_ff  <= #1 ps2_din_async_ff;
    end
    
    
/* CONTROLLER REGISTERS *******************************************************/
    
    localparam STATUS   = 8'h00,
               SCANCODE = 8'h01;
    
    reg  [7:0] dout_reg;                // register data output
    
    initial dout_reg = 8'h00;
    always @(posedge clk_i)
        if(en_i)
            case(addr_i)
                STATUS:   dout_reg <= #1 {3'b000, alt_ff, ctrl_ff, rshift_ff,
                                          lshift_ff, data_rdy_ff};
                SCANCODE: dout_reg <= #1 scan_code_reg;
                default:  dout_reg <= #1 8'h00;
            endcase
    
    // output logic
    assign dout_o = dout_reg;
    
    
/* STATUS REGISTERS ***********************************************************/
    
    reg alt_ff;
    reg alt_ns;
    reg ctrl_ff;
    reg ctrl_ns;
    reg lshift_ff;
    reg lshift_ns;
    reg rshift_ff;
    reg rshift_ns;
    
    wire data_rd;
    reg  data_rdy_ff;
    reg  data_rdy_ns;
    
    initial alt_ff    = 1'b0;
    initial ctrl_ff   = 1'b0;
    initial lshift_ff = 1'b0;
    initial rshift_ff = 1'b0;
    always @(posedge clk_i) begin
        alt_ff    <= #1 alt_ns;
        ctrl_ff   <= #1 ctrl_ns;
        lshift_ff <= #1 lshift_ns;
        rshift_ff <= #1 rshift_ns;
    end
    
    assign data_rd = (en_i) & (addr_i == SCANCODE);     // scan code read?
    
    initial data_rdy_ff = 1'b0;
    always @(posedge clk_i) begin
        if(data_rd)
            data_rdy_ff <= #1 1'b0;
        else
            data_rdy_ff <= #1 data_rdy_ns;
    end
    
    
/* SCAN CODE REGISTER *********************************************************/
    
    reg [7:0] scan_code_reg;
    reg [7:0] scan_code_ns;
    
    initial scan_code_reg = 8'h00;
    always @(posedge clk_i)
        scan_code_reg <= #1 scan_code_ns;
    
    
/* RECEIVER *******************************************************************/
    
    wire       rx_stb;                  // new scan code flag
    wire [7:0] rx_scan_code;            // received keyboard scan code
    
    PS2_RX PS2_RX
        (
        .clk_i      (clk_i),
        .ps2_clk_i  (ps2_clk_sync_ff),
        .ps2_din_i  (ps2_din_sync_ff),
        .rx_stb_o   (rx_stb),
        .scan_code_o(rx_scan_code)
        );
    
    
/* STATE MACHINE **************************************************************/
    
    localparam S_IDLE  = 2'b00,
               S_BREAK = 2'b01,
               S_MAKE  = 2'b10;
    
    localparam C_EXTEND = 8'hE0,
               C_BREAK  = 8'hF0;
    
    localparam C_ALT    = 8'h11,
               C_LSHIFT = 8'h12,
               C_CTRL   = 8'h14,
               C_RSHIFT = 8'h59;
    
    reg  [1:0] state_reg;
    reg  [1:0] state_ns;
    
    initial state_reg = S_IDLE;
    always @(posedge clk_i)
        state_reg <= #1 state_ns;
    
    // next state logic
    always @* begin
        state_ns = state_reg;
        
        alt_ns    = alt_ff;
        ctrl_ns   = ctrl_ff;
        lshift_ns = lshift_ff;
        rshift_ns = rshift_ff;

        data_rdy_ns = data_rdy_ff;
        
        scan_code_ns = scan_code_reg;
        
        case(state_reg)
            S_IDLE:     // wait for a key press/release
                begin
                    if(rx_stb)
                        case(rx_scan_code)
                            C_EXTEND: state_ns = S_IDLE;
                            C_BREAK:  state_ns = S_BREAK;
                            default:  state_ns = S_MAKE;
                        endcase
                end
            
            S_BREAK:    // break code (F0)
                begin
                    if(rx_stb) begin
                        case(rx_scan_code)
                            C_ALT:    alt_ns    = 1'b0;
                            C_CTRL:   ctrl_ns   = 1'b0;
                            C_LSHIFT: lshift_ns = 1'b0;
                            C_RSHIFT: rshift_ns = 1'b0;
                        endcase
                        
                        state_ns = S_IDLE;
                    end
                end
            
            S_MAKE:     // make code
                begin
                    case(rx_scan_code)
                        C_ALT:    alt_ns    = 1'b1;
                        C_CTRL:   ctrl_ns   = 1'b1;
                        C_LSHIFT: lshift_ns = 1'b1;
                        C_RSHIFT: rshift_ns = 1'b1;
                        default:
                            begin
                                data_rdy_ns  = 1'b1;
                                scan_code_ns = rx_scan_code;
                            end
                    endcase
                    
                    state_ns = S_IDLE;
                end
            
            default:
                begin
                    state_ns = S_IDLE;
                end
        endcase        
    end
    
endmodule

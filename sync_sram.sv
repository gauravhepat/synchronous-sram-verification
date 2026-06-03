`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.12.2025 12:58:13
// Design Name: 
// Module Name: sync_sram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// ============================================================
// Synchronous Single-Port SRAM
// 16 x 8 bit memory
// Ports:
//   clk  : clock signal
//   en   : enable memory access
//   we   : write enable (1 = write, 0 = read)
//   addr : 4-bit memory address (0 to 15)
//   din  : 8-bit input data (for write)
//   dout : 8-bit output data (for read)
// ============================================================

module sync_sram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4,
    parameter DEPTH      = (1 << ADDR_WIDTH)
)(
    input  logic                   clk,
    input  logic                   rst,
    input  logic                   en,
    input  logic                   we,
    input  logic                   re,
    input  logic [ADDR_WIDTH-1:0]  addr,
    input  logic [DATA_WIDTH-1:0]  din,
    output logic [DATA_WIDTH-1:0]  dout
);

    // Memory array
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // FSM state definition
    typedef enum logic [1:0] {IDLE, WRITE, READ, HOLD} state_t;
    state_t curr_state, next_state;

    // State register
    always_ff @(posedge clk) begin
        if (rst)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // Next-state logic
    always_comb begin
        next_state = curr_state;
        case (curr_state)
            IDLE: begin
                if (en && we && !re)
                    next_state = WRITE;
                else if (en && re && !we)
                    next_state = READ;
                else if (en && !we && !re)
                    next_state = HOLD;
            end

            WRITE: begin
                next_state = HOLD;
            end

            READ: begin
                next_state = HOLD;
            end

            HOLD: begin
                if (!en)
                    next_state = IDLE;
                else if (we && !re)
                    next_state = WRITE;
                else if (re && !we)
                    next_state = READ;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Output and memory operations
    always_ff @(posedge clk) begin
        if (rst) begin
            dout <= {DATA_WIDTH{1'b0}};
        end
        else begin
            case (curr_state)
                WRITE: mem[addr] <= din;
                READ:  dout <= mem[addr];
                HOLD:  dout <= dout;
                default: dout <= dout;
            endcase
        end
    end

endmodule


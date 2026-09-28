module sync_fifo #(

    parameter DATA_WIDTH = 8,
    parameter DEPTH = 8

)   (

    input logic  [DATA_WIDTH-1:0] data_in,
    input logic                   write,
    input logic                   read,
    input logic                   clk,
    input logic                   reset,
    
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  full,
    output logic                  empty
);

    timeunit 1ns;
    timeprecision 1ps;
    // Derived constants
    localparam PTR_WIDTH   = $clog2(DEPTH);
    localparam COUNT_WIDTH = $clog2(DEPTH + 1);

    localparam logic [PTR_WIDTH-1:0] LAST_ADDR = PTR_WIDTH'(DEPTH -1);
    // Internal storage and state
    
    logic [DATA_WIDTH-1:0] memory [0:DEPTH-1];

    logic [PTR_WIDTH-1:0] read_ptr;
    logic [PTR_WIDTH-1:0] write_ptr;
    logic [COUNT_WIDTH-1:0] count;

    
    assign empty = (count == 0);
    assign full = (count == DEPTH);
    
    always_ff @(posedge clk) begin

        if (reset) begin
            read_ptr  <= '0;
            write_ptr <= '0;
            count     <= '0;
            data_out  <= '0;
        end
        else begin
            // Write
            if (write && !full) begin
                memory[write_ptr] <= data_in;

                if (write_ptr == LAST_ADDR)
                    write_ptr <= '0;
                else
                    write_ptr <= write_ptr + 1;
            end

            // Read
            if (read && !empty) begin
                data_out <= memory[read_ptr];

                if (read_ptr == LAST_ADDR) begin
                    read_ptr <= '0;
                end
                else begin
                    read_ptr <= read_ptr + 1;
                end
            end

            // Update count
            if ((write && !full) && !(read && !empty)) begin
                count <= count + 1;
            end
            else if (!(write && !full) && (read && !empty)) begin
                count <= count - 1;
            end
        end
            
    end
    
    


endmodule


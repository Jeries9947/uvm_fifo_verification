module fifo_tb;

    localparam DATA_WIDTH = 8;
    localparam DEPTH      = 8;

    timeunit 1ns;
    timeprecision 1ps;

    logic                  clk;
    logic                  reset;
    logic                  write;
    logic                  read;
    logic [DATA_WIDTH-1:0] data_in;

    logic [DATA_WIDTH-1:0] data_out;
    logic                  full;
    logic                  empty;

sync_fifo #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
) dut (
    .data_in(data_in),
    .write(write),
    .read(read),
    .clk(clk),
    .reset(reset),
    .data_out(data_out),
    .full(full),
    .empty(empty)
);
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    // Initial values
    reset = 1;
    write = 0;
    read = 0;
    data_in = '0;

    // Hold reset for two clock edges
    repeat (2) @(posedge clk);

    // Release reset
    reset = 0;

    if (!empty) begin
        $error("FIFO should be empty after reset");
    end

    if (full) begin
        $error("FIFO should not be full after reset");
    end

    $display("Reset test passed");

    // Write 0xAA
    @(negedge clk);
    data_in = 8'hAA;
    write = 1;

    @(posedge clk);

    // Write 0xBB
    @(negedge clk);
    data_in = 8'hBB;

    @(posedge clk);

    // Write -CC
    @(negedge clk);
    data_in = 8'hCC;

    @(posedge clk);

    // Stop writing
    @(negedge clk);
    write = 0;

    // Read first value

    read = 1;

    @(posedge clk);
    #1;

    if (data_out != 8'hAA) begin
        $error("Expected 0xAA, got 0x%h", data_out);
    end
    else begin
        $display("read 1 passed: data_out = 0x%h", data_out);
    end

    @(posedge clk);
    #1;

    if (data_out != 8'hBB) begin
        $error("Expected 0xBB, got 0x%h", data_out);
    end
    else begin
        $display("read 2 passed: data_out = 0x%h", data_out);
    end

    @(posedge clk);
    #1;

    if (data_out != 8'hCC) begin
        $error("Expected 0xCC, got 0x%h", data_out);
    end
    else begin
        $display("read 3 passed: data_out = 0x%h", data_out);
    end

    if (!empty) begin
        $error ("FIFO should be empty after reading all entries");
    end
    else begin
        $display("FIFO empty check passed");
    end



    $finish;

end


endmodule


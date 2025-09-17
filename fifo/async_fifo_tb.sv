`timescale 1ns/1ps
`include "../config.v"
// `include "./async_fifo.v"
module async_fifo_tb;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;
    parameter ADDR_WIDTH = $clog2(DEPTH);

    // Signals
    logic clk_wr, clk_rd;
    logic rst_n_wr, rst_n_rd;
    logic wr_en, rd_en;
    logic [DATA_WIDTH-1:0] wr_din, rd_dout;
    logic fifo_full, fifo_empty;

    // Clock Generation
    initial begin
        clk_wr = 0;
        forever #5 clk_wr = ~clk_wr; // 100MHz write clock
    end

    initial begin
        clk_rd = 0;
        forever #6 clk_rd = ~clk_rd; // ~83.33MHz read clock
    end

    // DUT Instantiation
    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk_wr(clk_wr),
        .rst_n_wr(rst_n_wr),
        .wr_en(wr_en),
        .wr_din(wr_din),
        .fifo_full(fifo_full),

        .clk_rd(clk_rd),
        .rst_n_rd(rst_n_rd),
        .rd_en(rd_en),
        .rd_dout(rd_dout),
        .fifo_empty(fifo_empty)
    );

    // Reset Control
    initial begin
        rst_n_wr = 0;
        rst_n_rd = 0;
        wr_en = 0;
        rd_en = 0;
        #20; // Wait for clocks to stabilize
        rst_n_wr <= 1;
        rst_n_rd <= 1;
    end

    // Write Data Queue and Read Data Queue
    int write_data_q[$];
    int read_data_q[$];

    // Write Process
    task automatic write_data(int data);
        wr_din = data;
        wr_en = 1;
        @(posedge clk_wr);
        wr_en = 0;
        write_data_q.push_back(data);
    endtask

    // Read Process
    task automatic read_data(output int data);
        rd_en = 1;
        @(posedge clk_rd);
        data = rd_dout;
        rd_en = 0;
        read_data_q.push_back(data);
    endtask

    // Monitor and Compare
    always @(posedge clk_wr) begin
        $display("Time %0t: Write Addr: %0d | FIFO Full: %0b", $time, write_data_q.size(), fifo_full);
    end

    always @(posedge clk_rd) begin
        $display("Time %0t: Read Addr: %0d | FIFO Empty: %0b", $time, read_data_q.size(), fifo_empty);
    end

    // Test Scenario
    initial begin
        int data;
        int expected_data;

        // Initial Reset
        rst_n_wr = 0;
        rst_n_rd = 0;
        #20;
        rst_n_wr = 1;
        rst_n_rd = 1;

        // Write until FIFO is full
        for (int i = 0; i < DEPTH + 2; i++) begin
            if (!fifo_full) begin
                write_data(i);
            end else begin
                $display("FIFO is full at write index %0d", i);
                break;
            end
        end

        // Read until FIFO is empty
        for (int i = 0; i < DEPTH + 2; i++) begin
            if (!fifo_empty) begin
                read_data(expected_data);
                assert (expected_data == read_data_q[0]) else $error("Data mismatch! Expected %0d, got %0d", read_data_q[0], expected_data);
                read_data_q.pop_front();
            end else begin
                $display("FIFO is empty at read index %0d", i);
                break;
            end
        end

        // Mixed Read/Write
        for (int i = 0; i < DEPTH/2; i++) begin
            if (!fifo_full) write_data(i + DEPTH);
            if (!fifo_empty) read_data(expected_data);
            if (!fifo_empty) read_data(expected_data);
            #10;
        end

        // Final Check
        if (write_data_q.size() == read_data_q.size()) begin
            $display("All data matched! Test passed.");
        end else begin
            $error("Data mismatch detected! Test failed.");
        end

        #100;
        $finish;
    end

    initial begin
        $fsdbDumpfile("async_fifo_tb.fsdb");
        $fsdbDumpvars(0, async_fifo_tb);
    end
endmodule
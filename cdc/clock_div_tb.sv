`timescale 1ns / 1ps

module tb_div_3;
    // Inputs
    reg clk;
    reg rst_n;
    
    // Outputs
    wire clk_q;
    
    // Instantiate the Unit Under Test (UUT)
    div_3 uut (
        .clk(clk),
        .rst_n(rst_n),
        .clk_q(clk_q)
    );

    // Generate clock (100 MHz, period = 10 ns)
    always #5 clk = ~clk;  // 5 ns high, 5 ns low -> 100 MHz

    initial begin
        // Initialize inputs
        clk = 0;
        rst_n = 0;  // Active low reset
        
        // Apply reset for 20 ns (2 clock cycles)
        #20 rst_n = 1;
        
        // Run simulation for 100 ns (10 clock cycles, 3.33 periods of 30 ns output)
        #100 $finish;
    end

    // Monitor outputs
    initial begin
        $fsdbDumpfile("tb_div_3.fsdb");
        $fsdbDumpvars(0, tb_div_3);
    end
endmodule
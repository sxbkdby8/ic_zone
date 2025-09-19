`timescale 1ns / 1ps

// Glitch-free clock switch
module sync_clk_switch(
    input clk_a,
    input clk_b,
    input sel,
    output clk_out
);
    reg out_a;
    reg out_b;

    always @(negedge clk_a) begin
        out_a <= sel && (~out_b);
    end

    always @(negedge clk_b) begin
        out_b <= ~sel && (~out_a);
    end

    assign clk_out = (clk_a && out_a) || (clk_b && out_b);

endmodule

module async_clk_switch(  // TODO : verify
    input clk_a,
    input clk_b,
    input sel,
    input rst_n, 

    output clk_out
); 
    reg out_a_dly1, out_a_dly2;
    reg out_b_dly1, out_b_dly2;

    wire clk_a_sel = sel && !out_b_dly2;
    wire clk_b_sel = sel && !out_a_dly2;
    gnrl_dffr #(1) (clk_a_sel, out_a_dly1, clk_a, rst_n);
    gnrl_dffr #(1) (out_a_dly1, out_a_dly2, clk_a, rst_n);

    gnrl_dffr #(1) (clk_b_sel, out_b_dly1, clk_b, rst_n);
    gnrl_dffr #(1) (out_b_dly1, out_b_dly2, clk_b, rst_n);

    assign clk_out = (out_a_dly2 && clk_a) || (out_b_dly2 && clk_b);
endmodule
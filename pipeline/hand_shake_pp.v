`timescale 1ns/1ps

module hand_shake_pp #(  // NOT verified
    parameter WIDTH=8
) (
    input clk, 
    input rst_n,

    input [WIDTH-1:0] din,
    input din_vld,
    output rdy_o,

    output [WIDTH-1:0] dout,
    input rdy_i,
    output vld_o
);
    reg [WIDTH-1:0] dout_r;
    reg vld_r;

    assign rdy_o = rdy_i;
    assign dout = dout_r;
    assign vld_o = vld_r;

    always @(posedge clk) begin
        if(rdy_i && rdy_o) dout_r <= din;
    end

    always @(posedge clk) begin
        if(!rst_n) begin
            vld_r <= 1'b0;
        end else begin
            vld_r <= din_vld;
        end
    end
    
endmodule

// module
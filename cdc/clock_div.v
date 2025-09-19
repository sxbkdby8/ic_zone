`timescale 1ns / 1ps


module div_3 (
    input clk,
    input rst_n,
    output clk_q
);
    reg [1:0] cnt1, cnt2;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt1 <= 2'b0;
        end else begin
            if (cnt1 == 2'b10) begin
                cnt1 <= 2'b0;
            end else begin
                cnt1 <= cnt1 + 1;
            end
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt2 <= 2'b0;
        end else begin
            if (cnt2 == 2'b10) begin
                cnt2 <= 2'b0;
            end else begin
                cnt2 <= cnt2 + 1;
            end
        end
    end

    wire clk_out_1 = (cnt1 == 2'b00);
    wire clk_out_2 = (cnt2 == 2'b00);
    assign clk_q = clk_out_1 | clk_out_2;
endmodule
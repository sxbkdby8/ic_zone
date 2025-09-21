`timescale 1ns / 1ps
module strobe_cdc_1bit (
    input clk_src,
    input rst_n,
    input clk_dst,
    input din,
    output dout 
);  // 支持任意时钟域转换
    reg src_en, src_dly1, src_dly2, src_dly3;
    reg dst_dly1, dst_dly2;

    always@ (posedge clk_src) begin
        if(!rst_n) begin
            src_en <= 1'b0;
        end else begin
            if(din) begin
                src_en <= 1'b1;
            end else if(dst_dly2) begin
                src_en <= 1'b0;
            end
        end
    end

    always@ (posedge clk_src or negedge rst_n) begin
        if(!rst_n) begin
            src_dly1 <= 1'b0;
            src_dly2 <= 1'b0;
            src_dly3 <= 1'b0;
        end else begin
            src_dly1 <= src_en;
            src_dly2 <= src_dly1;
            src_dly3 <= src_dly2;
        end
    end

    assign dout = src_dly2 && (!src_dly3); // 

    always@ (posedge clk_dst) begin
        if(!rst_n) begin
            dst_dly1 <= 1'b0;
            dst_dly2 <= 1'b0;
        end else begin
            dst_dly1 <= src_en;
            dst_dly2 <= dst_dly1;
        end
    end
    
endmodule
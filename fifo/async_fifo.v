`timescale 1ns/1ps
// `include "../utils/gnrl_dffs.v"
// `include "../utils/gnrl_ram.v"
`include "../config.v"

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = $clog2(DEPTH),
    parameter InitFile = ""
) (
    input clk_wr,
    input rst_n_wr,
    input wr_en,
    input [DATA_WIDTH-1:0] wr_din,
    output fifo_full, 

    input clk_rd,
    input rst_n_rd,
    input rd_en,
    output [DATA_WIDTH-1:0] rd_dout,
    output fifo_empty
);
    function [ADDR_WIDTH:0] bin2gray;
        input [ADDR_WIDTH:0] bin;
        bin2gray = {bin[ADDR_WIDTH], bin[ADDR_WIDTH:1] ^ bin[ADDR_WIDTH-1:0]};
    endfunction


    /************************************** Write side variables ***************************************/
    reg [ADDR_WIDTH:0] wr_addr, wr_addr_dly1;
    reg [ADDR_WIDTH:0] wr_addr_gray, wr_addr_gray_dly1;
    wire [ADDR_WIDTH:0] wr_addr_gray_sync;
    reg fifo_full_d;

    wire wr_en_not_full = (wr_en == 1'b1) & (fifo_full == 1'b0);

    /************************************** Read side variables ***************************************/
    reg [ADDR_WIDTH:0] rd_addr, rd_addr_dly1;
    reg [ADDR_WIDTH:0] rd_addr_gray, rd_addr_gray_dly1;
    wire [ADDR_WIDTH:0] rd_addr_gray_sync;
    reg fifo_empty_d;

    wire rd_en_not_empty = (rd_en == 1'b1) & (fifo_empty == 1'b0);

    async_tpram #(
        .depth(DEPTH),
        .width(DATA_WIDTH)
    ) mem (
        .wr_clk(clk_wr),
        .wr_ena(wr_en_not_full),
        .addra(wr_addr[ADDR_WIDTH-1:0]),
        .data_in_a(wr_din),
        .rd_clk(clk_rd),
        .rd_enb(rd_en_not_empty),
        .addrb(rd_addr[ADDR_WIDTH-1:0]),
        .data_out_b(rd_dout)
    );

    /************************************** Clocks Region Crossing ***************************************/
    gnrl_dffr #(ADDR_WIDTH) rd_addr_gray_cdc_dffr_inst1(rd_addr_gray, rd_addr_gray_dly1, clk_wr, rst_n_wr);  // rd_addr : RD_CLK -> WR_CLK
    gnrl_dffr #(ADDR_WIDTH) rd_addr_gray_cdc_dffr_inst2(rd_addr_gray_dly1, rd_addr_gray_sync, clk_wr, rst_n_wr);  // rd_addr : RD_CLK -> WR_CLK

    gnrl_dffr #(ADDR_WIDTH) wr_addr_gray_cdc_dffr_inst1(wr_addr_gray, wr_addr_gray_dly1, clk_rd, rst_n_rd);
    gnrl_dffr #(ADDR_WIDTH) wr_addr_gray_cdc_dffr_inst2(wr_addr_gray_dly1, wr_addr_gray_sync, clk_rd, rst_n_rd);

    always @(posedge clk_wr or negedge rst_n_wr) begin
        if (!rst_n_wr) 
            wr_addr <= 0;
        else if (wr_en_not_full) 
            wr_addr <= wr_addr + 1;
    end
    
    always @(posedge clk_rd or negedge rst_n_rd) begin
        if (!rst_n_rd) 
            rd_addr <= 0;
        else if (rd_en_not_empty) 
            rd_addr <= rd_addr + 1;
    end

    always@(*) begin
        rd_addr_gray = bin2gray(rd_addr);
        wr_addr_gray = bin2gray(wr_addr);
        fifo_full_d = (wr_addr_gray == {~rd_addr_gray_sync[ADDR_WIDTH],
            rd_addr_gray_sync[ADDR_WIDTH-1:0]});

        fifo_empty_d = (rd_addr_gray == wr_addr_gray_sync);  // empty in read region
    end
    gnrl_dffr #(1) fifo_full_dffr_inst(fifo_full_d, fifo_full, clk_wr, rst_n_wr);
    gnrl_dffr #(1) fifo_empty_dffr_inst(fifo_empty_d, fifo_empty, clk_rd, rst_n_rd);

endmodule
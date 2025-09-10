`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/02/22 16:42:44
// Design Name: 
// Module Name: gnrl_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// this module is designed for Synchronize ram/rom usage
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// `include "config.v"
// define default mem style as distributed , which can be defined as 
// block, reg, uram and so on for different platform or optimization direction
`ifndef GNRL_RAM_STYLE
    `define GNRL_RAM_STYLE "distributed"
`endif

`ifndef GNRL_ROM_STYLE
    `define GNRL_ROM_STYLE "distributed"
`endif


module sync_spram#(
    parameter depth = 512,
    parameter width = 8,
    localparam addr_w = $clog2(depth)
    )(
    input clk,

    input ram_en,
    input wr_en,
    input [addr_w-1:0] addr,
    input [width-1:0] data_in,
    output reg [width-1:0] data_out
    );

    //on chip memory define 
    (*RAM_STYLE = `GNRL_RAM_STYLE*) reg [width-1:0] ram [depth-1:0];
    integer i; initial for (i=0; i<depth; i=i+1) ram[i] = 0;//zero value initial instead of adding reset ping
    //when adding reset ping this module will be systhesized as register file instead of distributed ram

    //write first
    always @(posedge clk) begin
        if (ram_en) begin
            if (wr_en) begin
                ram[addr] <= data_in;
                data_out <= data_in;
            end else 
                data_out <= ram[addr];
        end
    end

endmodule


module sync_tpram#(
    parameter depth = 512,
    parameter width = 8,
    localparam addr_w = $clog2(depth)
    )(
    input clk,

    input wr_ena,
    input rd_enb,
    input [addr_w-1:0] addra,
    input [addr_w-1:0] addrb,
    input [width-1:0] data_in_a,
    output [width-1:0] data_out_b
    );

    //on chip memory define 
    (* RAM_STYLE=`GNRL_RAM_STYLE *) reg [width-1:0] ram [depth-1:0];
    integer i; initial for (i=0; i<depth; i=i+1) ram[i] = 0;//zero value initial instead of adding reset ping
    //when adding reset ping this module will be systhesized as register file instead of distributed ram

    //write first
    always @(posedge clk) begin
        if (wr_ena) begin
            ram[addra] <= data_in_a;
        end
        //if (rd_enb) begin
        //    data_out_b <= ram[addrb];
        //end
    end
    assign data_out_b = ram[addrb];

endmodule

module sync_dpram#(
    parameter depth = 512,
    parameter width = 8,
    localparam addr_w = $clog2(depth)
    )(
    input clk,

    input ena,
    input enb,
    input wr_ena,
    input wr_enb,
    input [addr_w-1:0] addra,
    input [addr_w-1:0] addrb,
    input [width-1:0] data_in_a,
    input [width-1:0] data_in_b,
    output reg [width-1:0] data_out_a,
    output reg [width-1:0] data_out_b
    );

    //on chip memory define 
    (*RAM_STYLE = `GNRL_RAM_STYLE*) reg [width-1:0] ram [depth-1:0];
    integer i; initial for (i=0; i<depth; i=i+1) ram[i] = 0;//zero value initial instead of adding reset ping
    //when adding reset ping this module will be systhesized as register file instead of distributed ram

    //write first
    always @(posedge clk) begin
        if (ena) begin
            if (wr_ena) begin
                ram[addra] <= data_in_a;
                data_out_a <= data_in_a;
            end else data_out_a <= ram[addra];
        end           
        if (enb) begin
            if (wr_enb) begin
                ram[addrb] <= data_in_b;
                data_out_b <= data_in_b;
            end else data_out_b <= ram[addrb];
        end
    end

endmodule

//RAM仿真初始化
    //reg [DATA_WIDTH-1:0] ram [DEPTH-1:0];
    //integer i;
    //initial for (i=0; i < DEPTH; i=i+1) ram[i] = 0;
//
    ////读取二进制形式存储文件
    //reg [31:0] ram [0:3];
    //initial begin
    //    $readmemb("ram.data", ram, 0, 3);
    //end
//
    ////读取16进制形式存储文件
    //reg [31:0] ram [0:3];
    //initial begin
    //    $readmemh("ram.data", ram, 0, 3);
    //end
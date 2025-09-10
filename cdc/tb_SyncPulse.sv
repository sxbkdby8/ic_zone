// tb_SyncPulse.sv
`timescale 1ns/1ps

module tb_SyncPulse;

    // 时钟和复位信号
    reg clk_src;      // 快时钟 (e.g., 100MHz)
    reg clk_dst;      // 慢时钟 (e.g., 50MHz)
    reg rst_n;
    reg din;
    wire dout_signal;
    wire dout_pulse;

    // 实例化被测模块
    SyncPulse uut (
        .clk_src(clk_src),
        .clk_dst(clk_dst),
        .rst_n(rst_n),
        .din(din),
        .dout_signal(dout_signal),
        .dout_pulse(dout_pulse)
    );

    // 时钟生成
    initial begin
        clk_src = 0;
        forever #5 clk_src = ~clk_src; // 100MHz (5ns周期)
    end

    initial begin
        clk_dst = 0;
        forever #10 clk_dst = ~clk_dst; // 50MHz (10ns周期)
    end

    // 初始复位和测试序列
    initial begin
        rst_n = 0;
        din = 0;
        #20 rst_n = 1;

        // 测试单周期脉冲
        #95 din = 1;
        #5 din = 0;
        #5

        // 测试多周期脉冲
        #200 din = 1;
        #20 din = 0;

        // 测试连续脉冲
        #200 din = 1;
        #5 din = 0;
        #10 din = 1;
        #5 din = 0;

        // 仿真结束
        #200 $finish;
    end

    // 波形输出
    initial begin
        $fsdbDumpfile("tb_SyncPulse.fsdb");
        $fsdbDumpvars(0, tb_SyncPulse);
    end

endmodule
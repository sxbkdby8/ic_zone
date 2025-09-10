`include "../utils/gnrl_dffs.v"
`include "../utils/gnrl_ram.v"

module two_cycle_delay (  // Slow 2 Fast region
    input clk_src,
    input clk_dst, 
    input rst_n_src,
    input rst_n_dst,
    input din,
    output dout
);

    wire data_sync1, data_sync2;

    gnrl_dffr #(1) src_sync_dffr1(din, data_sync1, clk_src, rst_n_src);
    gnrl_dffr #(1) dsr_sync_dffr1(data_sync1, data_sync2, clk_dst, rst_n_dst);
    gnrl_dffr #(1) dsr_sync_dffr2(data_sync2, dout, clk_dst, rst_n_dst);

endmodule 

// Pulse Synchronization, from fast to slow clock region
module SyncPulse(  
    input clk_src,  // fast
    input clk_dst,  // slow
    input rst_n,
    input din,
    output dout_signal, 
    output dout_pulse
);
    reg signal_src, signal_dst;

    reg dst_sync1, dst_sync2;
    reg dst2src_fb_dly1, dst2src_fb_dly2;
    always @(posedge clk_src or negedge rst_n) begin
        if(!rst_n) begin
            signal_src <= 1'b0;
        end else if (din) begin
            signal_src <= 1'b1;
        end else if (dst2src_fb_dly2) begin
            signal_src <= 1'b0;
        end
    end

    always@(posedge clk_dst or negedge rst_n) begin
        if(!rst_n) begin
            signal_dst <= 1'b0;
            dst_sync1 <= 1'b0;
        end else begin
            signal_dst <= signal_src;
            dst_sync1 <= signal_dst;
        end
    end

    // always@(posedge clk_dst or negedge rst_n) begin
    //     if(!rst_n) begin
    //         {dst_sync2, dst_sync1} <= 2'b00;
    //     end else begin
    //         {dst_sync2, dst_sync1} <= {dst_sync1, signal_dst};
    //     end
    // end

    always @(posedge clk_src or negedge rst_n) begin  // Generate feedback signal
        if (!rst_n) begin
            {dst2src_fb_dly2, dst2src_fb_dly1} <= 2'b00;
        end else begin
           {dst2src_fb_dly2, dst2src_fb_dly1} <= {dst2src_fb_dly1, dst_sync1};
        end
    end
    assign dout_signal = dst_sync1;
    assign dout_pulse = !dst_sync1 & signal_dst;
endmodule

// module two_cycle_delay
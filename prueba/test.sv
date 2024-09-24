`timescale 1ns/1ps

`include "Driver.sv"
`include "monitor.sv"
`include "Library.sv"
`include "packs_mbx.sv"

module testbench;
    tst_drv_mbx tst_drv_mbx = new();
    parameter drvrs = 4;
    parameter pckg_sz = 16; 
    parameter fifo_size = 8;
    parameter bits = 1;
    parameter broadcast = {8{1'b1}};

    reg clk_tb;
    reg reset_tb;

    bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) _if (.clk(clk_tb));
    Driver #(.drvrs(drvrs), .pckg_sz(pckg_sz), .fifo_sz(fifo_size));

    always #5 clk_tb = ~clk_tb; 

    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) uut (
        .clk(_if.clk), 
        .reset(_if.rst), 
        .pndng(_if.pndng), 
        .push(_if.push), 
        .pop(_if.pop), 
        .D_pop(_if.D_pop), 
        .D_push(_if.D_push)
    );

    inital begin
        clk_tb = 0;
        uut = new();
        uut._if = _if;
        fork
            uut.run();
        join_none
    end

    always @(posedge clk_tb) begin
        if ($time > 100000) begin
            $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
            $finish;
        end
    end

endmodule
`timescale 1ns/1ps
`include "Driver_Monitor.sv"
`include "Interface_Transactions.sv"
`include "Libary.sv"

module Test_Driver;

    // Parámetros de prueba
    parameter drvrs = 4;
    parameter pckg_sz = 16;
    parameter num_pckg = 8;
    parameter bits = 1;
    parameter broadcast = {8{1'b1}};


    // Instancia del Driver_Monitor
    Driver_Monitor #(.drvrs(drvrs), .pckg_sz(pckg_sz), .num_pckg(num_pckg)) driver_monitor_inst;

    bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf_inst (.clk(clk));

    bs_gntrt_n_rbtr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) bs_gntrt_n_rbtr_inst (
        .clk(clk),
        .reset(reset),
        .pndng(bus_intf_inst.pndng),
        .push(bus_intf_inst.push),
        .pop(bus_intf_inst.pop),
        .D_pop(bus_intf_inst.D_pop),
        .D_push(bus_intf_inst.D_push)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        driver_monitor_inst.bus_intf = bus_intf_inst;
        fork
            driver_monitor_inst.run();
        join_none
    end

    always @(posedge clk) begin
        if ($time > 100000) begin
            $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
            $finish;
        end
    end

endmodule

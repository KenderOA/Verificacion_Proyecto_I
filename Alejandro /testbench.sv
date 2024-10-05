`timescale 1ns/1ps

`include "intf_pkc_mbx.sv"
//`include "dv_mn.sv"
`include "Driver.sv"
`include "Monitor.sv"
`include "Agente.sv"
`include "Generador.sv"
`include "Checker_Scoreboard.sv"
`include "Ambiente.sv"
`include "Test.sv"

module testbench;

    tst_gen_mbx tst_gen_mbx = new();

    parameter drvrs = 4;
    parameter pckg_sz = 16;
    parameter bits = 1;
    parameter broadcast = {8{1'b1}};

    reg clk_tb;
    reg reset_tb;

    initial begin
        $dumpfile("test_bus.vcd");
        $dumpvars(0,testbench);
    end 

    bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) bus_intf (.clk(clk_tb));
    bs_gnrtr_n_rbtr  #(.bits(bits),.drvrs(drvrs), .pckg_sz(pckg_sz),.broadcast(broadcast)) DUT_0 (
        .clk(bus_intf.clk),
        .reset(bus_intf.rst), 
        .pndng(bus_intf.pndng), 
        .push(bus_intf.push), 
        .pop(bus_intf.pop), 
        .D_pop(bus_intf.D_pop), 
        .D_push(bus_intf.D_push)
    );

    Ambiente #(.drvrs(drvrs), .pckg_sz(pckg_sz)) ambiente_0;
    Test #(.drvrs(drvrs), .pckg_sz(pckg_sz)) t_0, t_1;

    initial begin
        clk_tb = 0;
        reset_tb = 1;
        bus_intf.rst = reset_tb;
        #50
        reset_tb = 0;
        bus_intf.rst = reset_tb;
    end

    initial begin
        forever begin
            #5
            clk_tb = ~clk_tb;
        end
    end

    initial begin

      t_0 = new(normal);
        t_0.tst_gen_mbx = tst_gen_mbx;
        t_0.dis_src = 0;
        t_0.id = 2;
        ambiente_0 = new();
        //ambiente_0.display(); como no tenemos ningun task display en ambiente, no se puede llamar
        ambiente_0.generador_inst.tst_gen_mbx = tst_gen_mbx;  //no sé si es .generador

        for (int i = 0; i < drvrs; i++) begin

            automatic int k = i;
          ambiente_0.driver_inst[k].bus_intf = bus_intf;
            ambiente_0.monitor_inst[k].bus_intf = bus_intf;
            
        end

        fork
            t_0.run();
            ambiente_0.run();
        join_none

        #200000

        disable fork;
          end 

    initial begin
        #1000000
        $finish;
    end

endmodule

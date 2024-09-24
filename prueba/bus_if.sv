interface bus_if #(parameter drvrs = 4, parameter pckg_sz = 16, parameter bits = 1)
(input clk);
    logic rst;
    logic pndng [bits-1:0][drvrs-1:0];
    logic push [bits-1:0][drvrs-1:0];
    logic pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push [bits-1:0][drvrs-1:0];
endinterface
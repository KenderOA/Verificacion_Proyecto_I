interface bus_intf #(parameter drvrs = 4, parameter pckg_sz = 16, parameter bits = 1, parameter broadcast = {8{1'b1}}) (
    input clk
);

    logic reset;
    logic pndng [bits-1:0][drvrs-1:0];
    logic push [bits-1:0][drvrs-1:0];
    logic pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push [bits-1:0][drvrs-1:0];

endinterface

class agnt_drvr #(parameter drvrs = 4, parameter pckg_sz = 16);
    rand bit [pckg_sz-9:0] data;
    rand bit [pckg_sz : pckg_sz-10] id;
    rand int source;
    
    int variability;

    function new ();
        variability = pckg_sz - 9;
    endfunction;

endclass

typedef mailbox #(agnt_drvr) agnt_drvr_mbx;
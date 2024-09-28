interface bus_intf #(parameter drvrs = 4, parameter pckg_sz = 16, parameter bits = 1) (

    input clk
);

    logic reset;
    logic pndng [bits-1:0][drvrs-1:0];
    logic push [bits-1:0][drvrs-1:0];
    logic pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push [bits-1:0][drvrs-1:0];

endinterface

class rand_values_generate;

	rand int drvrs;
    rand int pckg_sz;
    rand int fifo_size;
    constraint valid_drvrs {drvrs < 15 ; drvrs >= 4;};
    constraint valid_fifo_size {fifo_size > 0; fifo_size < 20;};
    constraint valid_pckg_sz {pckg_sz >= 8; pckg_sz < 64;};

endclass

class agnt_drvr #(parameter drrs = 4, parameter pckg_sz = 16);
    rand bit [pckg_sz-9:0] data;
    rand bit [7:0] id;
    rand int source;
    
    int variability;

    function new ();
        variability = pckg_sz - 9;
    endfunction;

endclass

typedef mailbox #(agnt_drvr) agnt_drvr_mbx;
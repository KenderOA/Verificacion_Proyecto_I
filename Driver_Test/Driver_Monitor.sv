`include "Interface_Transactions.sv"

class Driver_Monitor #(parameter drvrs = 4, parameter pckg_sz = 16, parameter num_pckg = 8);

    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz))   bus_intf;

    agnt_drvr_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))       agnt_drvr_mbx;
    agnt_drvr #(.drvrs(drvrs), .pckg_sz(pckg_sz))           agnt_drvr_transaction;

    bit [pckg_sz-1:0]                                        fifo_in[$];               //fifo de entrada
    int                                                      drvr_num;

    function new (int drvr_num);
        this.drvr_num = drvr_num;
        $display("Driver %d inicializado", this.drvr_num);
        this.agnt_drvr_transaction = new();
        this.agnt_drvr_mbx = new();
        fifo_in = {};
    endfunction

    virtual task run ();
        this.agnt_drvr_mbx.get(agnt_drvr_transaction);
        $display("Driver %d: Trasancción recibida", this.drvr_num);
        this.fifo_in.push_back({this.agnt_drvr_transaction.id, this.agnt_drvr_transaction.data});
        fork
            $display("Fifo %d entrada corriendo", this.drvr_num);
            forever begin
                if(this.fifo_in.size == 0) begin
                    this.bus_intf.pndng[0][this.drvr_num] = 0;
                    this.bus_intf.D_pop[0][this.drvr_num] = 0;
                end
                else begin
                    this.bus_intf.pndng[0][this.drvr_num] = 1;
                    this.bus_intf.D_pop[0][this.drvr_num] = this.fifo_in[0];
                end
            end
        join_none
    endtask
endclass
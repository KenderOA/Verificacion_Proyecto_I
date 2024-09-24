`include "packs_mbx.sv"
`include "fifo.sv"
`include "bus_if.sv"

class Driver #(parameter drvrs = 4, parameter pckg_sz = 16, parameter fifo_sz = 10);

    fifo #(.pckg_sz(pckg_sz), .drvrs(drvrs), .fifo_sz(fifo_sz)) fifo;

    agnt_drv #(.drvr(drvr), .pckg_sz(pckg_sz))      agnt_drvr_transaction;
    agnt_chk_sb #(.pckg_sz(pckg_sz))                    agnt_chk_sb_transaction;

    agnt_drv_mbx #(.drvr(drvr), .pckg_sz(pckg_sz))  agnt_drv_mbx;
    agnt_chk_sb_mbx #(.pckg_sz(pckg_sz))                agnt_chk_sb_mbx;
    
    int drv_num;

    function new(int drv_num);
        this.drv_num = drv_num;
        $display("Driver %d iniciado",this.drv_num);
        this.agnt_drvr_transaction = new();
        this.agnt_drv_mbx = new();
        this.fifo = new(drv_num);
    endfunction

    virtual task run();
        fork
            fifo.if_signal();
        join_none
        forever begin
            this.agnt_drv_mbx.get(agnt_drvr_transaction);
            $display("DRIVER %d: Transaction recivida", this.drv_num);
            while(this.fifo.d_q.size >= fifo_sz) #5;
            this.fifo.fifo_push({this.agnt_drvr_transaction.id, this.agnt_drvr_transaction.dato});
            this.agnt_sb_transaction = new(this.agnt_drvr_transaction.dato, this.agnt_drvr_transaction.id, $time, this.agnt_drvr_transaction.source);
            this.agnt_sb_mbx.put(agnt_sb_transaction);
        end
    endtask
endclass


include fifo.sv
class driver #(parameter drvrs = 4, parameter pckg_sz = 16, parameter fifo_size=8);

    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz)) v_if;
    int drv_num;
    fifo #(.packagesize(pckg_sz), .drvrs(drvrs), .fifo_size(fifo_size)) fifo;//instancia de la FIFO que se comunica al DUT
    //mailbox
    agnt_drv_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drv_mbx;			
    //agnt_chk_sb_mbx #(.pckg_sz(pckg_sz)) agnt_chk_sb_mbx;
    //transactor
    agnt_drv #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drv_transaction; 
    //agnt_chk_sb #(.pckg_sz(pckg_sz)) agnt_chk_sb_transaction;

    
    function new(virtual bus_if v_if);
        this.drv_num = drv_num;							//Identificador único para cada Driver
        $display("Driver %d a iniciado",this.drv_num);     
        this.agnt_drv_transaction = new();                  
        this.agnt_drv_mbx = new(); 
        this.fifo = new(drv_num);  
    endfunction

    task run();
        $display("Driver %d a iniciado",this.drv_num); 
        fork
        fifo_gen.pop_();
        fifo_gen.d_pop();
        join_none
    endtask

    

endclass

class Checker_Scoreboard #(parameter drvrs = 4, parameter pckg_sz = 16);

    bus_mbx mnt_chkr_sb_mbx;  // Mailbox from monitor to checker scoreboard
    bus_mbx drvr_chkr_sb_mbx;

    bus_transaction mnt_chkr_sb_transaction;  // Transaction from monitor to checker scoreboard
    bus_transaction drvr_chkr_sb_transaction;

    logic [pckg_sz-1:0] resultados [$];
    logic [pckg_sz-1:0] instrucciones [$];

    string file_name;
    int fa;


    // Constructor
    function new();

        this.mnt_chkr_sb_mbx = new();
        this.drvr_chkr_sb_mbx = new();
        this.mnt_chkr_sb_transaction = new();
        this.drvr_chkr_sb_transaction = new();

        this.resultados = {};
        this.instrucciones = {};

    endfunction
    // Task to run the checker
    task run_drvr();
    forever begin
        this.drvr_chkr_sb_mbx.try_get(this.drvr_chkr_sb_transaction);
        this.instrucciones.push_back(this.drvr_chkr_sb_transaction);

    end
    endtask

    task run_mnt();
    forever begin
        this.mnt_chkr_sb_mbx.try_get(this.mnt_chkr_sb_transaction);
        this.resultados.push_back(this.mnt_chkr_sb_transaction);
    end
    endtask

    function report_sb();
        $display("Report");
        this.file_name = $sformatf("Reporte: %0dDrivers_%0dPckg_Sz.csv",this.mnt_chkr_sb_transaction.drvrs, this.mnt_chkr_sb_transaction.pckg_sz);
        this.fa = $fopen(this.file_name,"w");
        $fdisplay(fa,"++++++++++++++++++");
        $fdisplay(fa,"REPORTE SCOREBOARD");
        $fdisplay(fa,"++++++++++++++++++\n");

        $fdisplay(fa,"RESULTADOS");
        $fdisplay(fa,"TRANSACCIONES ENVIADAS: %d",this.instrucciones.size())
        foreach (this.instrucciones[i]) $fdisplay(fa,"Posición %d de la cola, dato = %d , id = %d, instante [%g], salió del dispositivo: %g",i,this.instrucciones[i].dato,this.instrucciones[i].id, this.instrucciones[i].tiempo,this.instrucciones[i].dis_src);
        $fdisplay(fa,"TRANSACCIONES RECIBIDAS: %d",this.resultados.size());
        foreach (this.resultados[i]) $fdisplay(fa,"Posición %d de la cola, dato = %d , id = %d, instante [%g], llegó al dispositivo: %g",i,this.resultados[i].dato, this.resultados[i].id, this.resultados[i].tiempo, this.resultados[i].id);
        if(this.instrucciones.size() - this.resultados.size() > 0) $fdisplay(fa,"TRANSACCIONES PERDIDAS: %d",this.instrucciones.size() - this.resultados.size());
        $fclose(fa);
    endfunction

endclass

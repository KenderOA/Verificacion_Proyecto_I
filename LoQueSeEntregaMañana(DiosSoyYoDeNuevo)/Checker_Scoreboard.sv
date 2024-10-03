class Checker_Scoreboard #(parameter drvrs = 4, parameter pckg_sz = 16);
  
    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mnt_chkr_sb_mbx[drvrs]; // Arreglo de mailboxes para monitor a checker
    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_sb_mbx[drvrs]; // Arreglo de mailboxes para driver a checker

    bus_transaction mnt_chkr_sb_transaction;  // Transacción desde el monitor al scoreboard
    bus_transaction drvr_chkr_sb_transaction;

    bus_transaction resultados[$];  // Array dinámico para transacciones recibidas
    bus_transaction instrucciones[$];  // Array dinámico para transacciones enviadas

    string file_name;
    int fa;

    // Constructor
    function new();
        for (int i = 0; i < drvrs; i++) begin
            this.mnt_chkr_sb_mbx[i] = new(); // Instanciar cada mailbox
            this.drvr_chkr_sb_mbx[i] = new(); // Instanciar cada mailbox
        end

        this.resultados = {};
        this.instrucciones = {};
    endfunction

    // Tarea para ejecutar el checker de drivers
    task run_drvr();
        forever begin
            for (int i = 0; i < drvrs; i++) begin
                if (this.drvr_chkr_sb_mbx[i].try_get(this.drvr_chkr_sb_transaction)) begin
                    this.instrucciones.push_back(this.drvr_chkr_sb_transaction);
                end
            end
        end
    endtask

    // Tarea para ejecutar el checker de monitores
    task run_mnt();
        forever begin
            for (int i = 0; i < drvrs; i++) begin
                if (this.mnt_chkr_sb_mbx[i].try_get(this.mnt_chkr_sb_transaction)) begin
                    this.resultados.push_back(this.mnt_chkr_sb_transaction);
                end
            end
        end
    endtask

    // Función para generar el reporte
    function report_sb();
        $display("Report");
        this.file_name = $sformatf("Reporte: %0dDrivers_%0dPckg_Sz.csv", drvrs, pckg_sz);
        this.fa = $fopen(this.file_name, "w");
        $fdisplay(fa, "++++++++++++++++++");
        $fdisplay(fa, "REPORTE SCOREBOARD");
        $fdisplay(fa, "++++++++++++++++++\n");

        $fdisplay(fa, "RESULTADOS");
        $fdisplay(fa, "TRANSACCIONES ENVIADAS: %d", this.instrucciones.size());
        foreach (this.instrucciones[i]) begin
            $fdisplay(fa, "Posición %d de la cola, dato = %d , id = %d, instante [%g], salió del dispositivo: %g",
                      i, this.instrucciones[i].dato, this.instrucciones[i].id, 
                      this.instrucciones[i].tiempo, this.instrucciones[i].dis_src);
        end
        $fdisplay(fa, "TRANSACCIONES RECIBIDAS: %d", this.resultados.size());
        foreach (this.resultados[i]) begin
            $fdisplay(fa, "Posición %d de la cola, dato = %d , id = %d, instante [%g], llegó al dispositivo: %g",
                      i, this.resultados[i].dato, this.resultados[i].id, 
                      this.resultados[i].tiempo, this.resultados[i].id);
        end
        if (this.instrucciones.size() - this.resultados.size() > 0) 
            $fdisplay(fa, "TRANSACCIONES PERDIDAS: %d", this.instrucciones.size() - this.resultados.size());
        $fclose(fa);
    endfunction

endclass

class Ambiente #(parameter drvrs = 4, parameter pckg_sz = 16);
  
  // Declaración de los componentes del ambiente
  
  virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz))        bus_intf;
  
  Driver#(.drvrs(drvrs), .pckg_sz(pckg_sz))                   driver_inst[drvrs];
  Monitor #(.drvrs(drvrs), .pckg_sz(pckg_sz))                 monitor_inst[drvrs];
  Agente #(.drvrs(drvrs), .pckg_sz(pckg_sz))                  agente_inst;
  Generador #(.drvrs(drvrs), .pckg_sz(pckg_sz))               generador_inst;
  Checker_Scoreboard #(.drvrs(drvrs), .pckg_sz(pckg_sz))      checker_inst;
  

  // Declaración de los mailboxes
  
  bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))                 agnt_drvr_mbx [drvrs]; 
  //bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))                 mnt_chkr_sb_mbx [drvrs];
  //bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))                 drvr_chkr_sb_mbx [drvrs];

  gen_agnt_mbx                                                gen_agnt_mbx;
  tst_gen_mbx                                                 tst_gen_mbx;

  function new();                            
    gen_agnt_mbx = new();
    tst_gen_mbx = new();
    for (int i = 0; i < drvrs; i++) begin
      automatic int k       = i;
      this.agnt_drvr_mbx[k] = new();
      //this.mnt_chkr_sb_mbx[k] = new();    
      //this.drvr_chkr_sb_mbx[k] = new();
    end

    //checker_inst = new(); // Descomentar si es necesario
    generador_inst  = new();
    agente_inst     = new();

    
    agente_inst.gen_agnt_mbx      = gen_agnt_mbx;
    generador_inst.gen_agnt_mbx   = gen_agnt_mbx;
    generador_inst.tst_gen_mbx    = tst_gen_mbx;
    //checker_inst.mnt_chkr_sb_mbx = mnt_chkr_sb_mbx; 
    //checker_inst.drvr_chkr_sb_mbx = drvr_chkr_sb_mbx;
    
    for (int i = 0; i < drvrs; i++) begin
      automatic int k = i;
      $display("[%g] Instanciando driver %0d", $time, k);
      this.driver_inst[k]                   = new(k, bus_intf);
      this.monitor_inst[k]                  = new(k, bus_intf);
      this.agente_inst.bus_mbx_array[k]     = agnt_drvr_mbx[k];
      this.driver_inst[k].agnt_drvr_mbx     = agnt_drvr_mbx[k];
      //this.monitor_inst[k].mnt_chkr_sb_mbx = mnt_chkr_sb_mbx[k]; 
      //this.driver_inst[k].drvr_chkr_sb_mbx = drvr_chkr_sb_mbx[k];
  
    end
  endfunction

  virtual task run();
    $display("[%g] EL AMBIENTE FUE INICIALIZADO", $time);
    fork
      generador_inst.run();
      agente_inst.run();
      for (int i = 0; i < drvrs; i++) begin
        fork
          automatic int k = i;
          $display("[%g] Iniciando driver %0d", $time, k);
          this.driver_inst[k].run_driver();
          this.monitor_inst[k].run_monitor();
        join_none
      end
    join;
  endtask
endclass

class Ambiente #(parameter drvrs = 4, parameter pckg_sz = 16);
  
  // Declaración de los componentes del ambiente
  
  virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf;
  
  Driver_Monitor #(.drvrs(drvrs), .pckg_sz(pckg_sz)) driver_inst[drvrs];
  Agente #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agente_inst;
  Generador #(.drvrs(drvrs), .pckg_sz(pckg_sz)) generador_inst;
  Checker_Scoreboard #(.drvrs(drvrs), .pckg_sz(pckg_sz)) checker_inst;
  

  // Declaración de los mailboxes
  
  bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx [drvrs]; 
  bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mnt_chkr_sb_mbx [drvrs];
  bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_sb_mbx [drvrs];
  gen_agnt_mbx gen_agnt_mbx;
  tst_gen_mbx tst_gen_mbx; // mailbox del driver al checker

  function new();
    // Instanciación de los mailboxes
    gen_agnt_mbx = new();
    tst_gen_mbx = new();
    for (int i = 0; i < drvrs; i++) begin
      automatic int k = i;
      this.agnt_drvr_mbx[k] = new();
      this.mnt_chkr_sb_mbx[k] = new(); // Descomentar si es necesario
      this.drvr_chkr_sb_mbx[k] = new();
    end

    // Instanciación de los componentes del ambiente
    checker_inst = new(); // Descomentar si es necesario
    generador_inst = new();
    agente_inst = new();

    // Conexión de las interfaces y mailboxes en el ambiente
    agente_inst.gen_agnt_mbx = gen_agnt_mbx;
    generador_inst.gen_agnt_mbx = gen_agnt_mbx;
    generador_inst.tst_gen_mbx = tst_gen_mbx;
    checker_inst.mnt_chkr_sb_mbx = mnt_chkr_sb_mbx; // Descomentar si es necesario
    checker_inst.drvr_chkr_sb_mbx = drvr_chkr_sb_mbx;
    
    for (int i = 0; i < drvrs; i++) begin
      automatic int k = i;
      this.driver_inst[k] = new(k, bus_intf, k); // Instanciación del driver
      this.agente_inst.bus_mbx_array[k] = agnt_drvr_mbx[k];
      this.driver_inst[k].agnt_drvr_mbx = agnt_drvr_mbx[k];
      this.driver_inst[k].mnt_chkr_sb_mbx = mnt_chkr_sb_mbx[k]; // Descomentar si es necesario
      this.driver_inst[k].drvr_chkr_sb_mbx = drvr_chkr_sb_mbx[k];
  
    end
  endfunction

  virtual task run();
    $display("[%g] El ambiente fue inicializado", $time);
    fork
      generador_inst.run();
      agente_inst.run();
      for (int i = 0; i < drvrs; i++) begin
        automatic int k = i;
        
        this.driver_inst[k].run_driver();
        void'(checker_inst.report_sb());
        checker_inst.run_drvr();
        this.driver_inst[k].run_monitor();
        
      end
      checker_inst.run_mnt();
      
    join_none;
  endtask
endclass

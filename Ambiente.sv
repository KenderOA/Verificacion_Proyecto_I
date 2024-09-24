class Ambiente #(parameter drvrs = 4, parameter pckg_sz = 16, parameter fifo_size = 8);

    Driver              #(.drvs(drvrs), .pckg_sz(pckg_sz), .fifo_size(fifo_size))   driver [drvrs];
    Agente              #(.drvs(drvrs), .pckg_sz(pckg_sz))                          agente;
    Monitor             #(.drvs(drvrs), .pckg_sz(pckg_sz))                          monitor [drvrs];
    Generador           #(.drvs(drvrs), .pckg_sz(pckg_sz))                          generador;
    Checker_Scoreboard  #(.drvs(drvrs), .pckg_sz(pckg_sz))                          chk_sb;

    gen_agnt_mbx gen_agnt_mbx;                 // mailbox del generador al agente
    agnt_drv_mbx agnt_drv_mbx [drvrs];         // mailbox del agente al driver

    agnt_chk_sb_mbx  agnt_chk_sb_mbx;          // mailbox del agente al checker_scoreboard
    mnt_chk_mbx      mnt_chk_sb_mbx;           // mailbox del monitor al checker_scoreboard

    comando_test_chk_sb_mbx   tst_chk_sb_mbx;  // mailbox del test al checker_scoreboard
    comando_test_gen_mbx      tst_gen_mbx;     // mailbox del test al generador

    function new()
        for (int i = 0; i < drvrs; i++) begin
			temp int local_index = i;
			this.agnt_drv_mbx [local_index] = new();
		end
        // Se inicializan los mailboxes
        this.gen_agnt_mbx       = new();
        this.agnt_chk_sb_mbx    = new();
        this.mnt_chk_sb_mbx     = new();
        this.tst_chk_sb_mbx     = new();
        this.tst_gen_mbx        = new();

        // Se inicializan las clases agente, generador y checker_scoreboard
        //this.driver = new();
        this.generador              = new();
        this.generador.gen_agnt_mbx = gen_agnt_mbx;
        this.generador.tst_gen_mbx  = tst_gen_mbx;

        this.agente = new();
        this.agente.gen_agnt_mbx    = gen_agnt_mbx;
        this.agente.agnt_chk_sb_mbx = agnt_chk_sb_mbx;

        //this.monitor = new();
        this.chk_sb = new();
        this.chk_sb.agnt_chk_sb_mbx = agnt_chk_sb_mbx;
        this.chk_sb.mnt_chk_sb_mbx  = mnt_chk_sb_mbx;

        for (int i = 0; i < drvrs; i++) begin
            temp int local_index = i;
            this.driver[local_index] = new(local_index);
            this.monitor[local_index] = new(local_index);
            this.monitor[local_index].mnt_chk_sb_mbx = mnt_chk_sb_mbx;
            this.agente.agnt_drv_mbx[local_index] = agnt_drv_mbx[local_index];
            this.driver[local_index].agnt_drv_mbx = agnt_drv_mbx[local_index];
            this.driver[local_index].agnt_chk_sb_mbx = agnt_chk_sb_mbx;
        end
    endfunction

    task run();
        fork
            this.generador.run();
            this.agente.run();
            this.chk_sb.run_ag();
            this.chk_sb.run_mnt();
            for (int i = 0; i < drvrs; i++) begin
                 fork
                    temp int local_index = i;
                    this.driver[local_index].run();
                    this.monitor[local_index].run();
                join_none
            end 
        join
    endtask

    task repor (int num)
        this.chk_sb.report_sb(num);
    endtask

    function display();
        $display("Ambiente: Driver=%d, Pckg_sz=%d, FIFO_size=%d", drvrs, pckg_sz, fifo_size);
    endfunction
    
endclass
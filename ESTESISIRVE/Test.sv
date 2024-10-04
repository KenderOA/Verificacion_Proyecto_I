class Test #(parameter drvrs = 4, parameter pckg_sz = 16);

    //Mailboxes
    tst_gen         tst_gen_transaction; //Envia la instruccion al agente
    tst_gen_mbx     tst_gen_mbx; //Envia la instruccion al checker

    int test;
    int dis_src;
    int id;

    function new(int test);

        tst_gen_transaction   = new();
      	this.test             = test;

    endfunction

    task run();
        
        $display("[%g] EL TEST FUE INICIALIZADO", $time);

        tst_gen_transaction.id          = this.id;
        tst_gen_transaction.dis_src     = this.dis_src;
        tst_gen_transaction.tipo_gen    = this.test;
        tst_gen_mbx.put(tst_gen_transaction);

        $display("TRANSACCIÓN ENVIADA TEST => GENERADOR: %h",tst_gen_transaction);
    endtask



endclass

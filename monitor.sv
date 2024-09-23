class monitor #(parameter pckg_sz = 16, parameter drvrs = 4);

	virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz)) v_if;
    bit [pckg_sz-1:0] d_q[$];
	int mnt_num;

    mnt_chk_sb_mbx mnt_chk_sb_mbx;
	mnt_chk_sb mnt_chk_sb_transaction;
	
	// Constructor con print
	function new(int mnt_num);
		this.d_q = {};
        this.mnt_num = mnt_num;
        this.mnt_chk_sb_transaction = new(this.mnt_num);
        this.mnt_chk_sb_mbx = new();
		$display("Monitor %d iniciado", this.mnt_num); // Print al iniciar el monitor
	endfunction
    
	// Task run con prints para ver cómo funciona
	task run();
      forever begin
        @(posedge this.v_if.push[0][this.mnt_num]);
        
        // Print cuando se detecta el flanco positivo
        $display("[%0t] Flanco positivo detectado en push[%0d]", $time, this.mnt_num);
        
        this.d_q.push_back(this.v_if.D_push[0][this.mnt_num]);
        
        // Print del valor del dato en el bus
        $display("[%0t] Dato en D_push[%0d]: 0x%h", $time, this.mnt_num, this.v_if.D_push[0][this.mnt_num]);
        
		this.mnt_chk_sb_transaction = new(this.mnt_num);
        
        // Asignar y mostrar ID y dato del paquete
        this.mnt_chk_sb_transaction.id = this.v_if.D_push[0][this.mnt_num][pckg_sz-1:pckg_sz-8];
        this.mnt_chk_sb_transaction.dato = this.v_if.D_push[0][this.mnt_num][pckg_sz-9:0];
        
        $display("[%0t] ID: 0x%h, Dato: 0x%h", $time, this.mnt_chk_sb_transaction.id, this.mnt_chk_sb_transaction.dato);
        
        // Colocar la transacción en el mailbox
        this.mnt_chk_sb_mbx.put(mnt_chk_sb_transaction);
        
        // Print cuando la transacción es colocada en el mailbox
        $display("[%0t] Transacción colocada en el mailbox", $time);
      end
	endtask

endclass

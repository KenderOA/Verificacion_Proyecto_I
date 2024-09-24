class monitor #(parameter pckg_sz = 16, parameter drvrs = 4);

	virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz)) v_if;
    bit [pckg_sz-1:0] d_q[$];
	int mnt_num;

    mnt_chk_sb_mbx mnt_chk_sb_mbx;
	mnt_chk_sb mnt_chk_sb_transaction;
	
	function new(int mnt_num);
		this.d_q = {};
        this.mnt_num = mnt_num;
        this.mnt_chk_sb_transaction = new(this.mnt_num);//Inicia la trasaccion con el numero especifico del monitor 
        this.mnt_chk_sb_mbx = new();
		$display("Monitor %d iniciado", this.mnt_num); 
	endfunction
    
	task run();
      forever begin
        @(posedge this.v_if.push[0][this.mnt_num]);
        
        this.d_q.push_back(this.v_if.D_push[0][this.mnt_num]);
        $display("[%0t] Dato en D_push[%0d]: 0x%h", $time, this.mnt_num, this.v_if.D_push[0][this.mnt_num]);
        
		this.mnt_chk_sb_transaction = new(this.mnt_num);//Tener una nueva transaccion cada vez que se repita el ciclo.
        this.mnt_chk_sb_transaction.id = this.v_if.D_push[0][this.mnt_num][pckg_sz-1:pckg_sz-8];
        this.mnt_chk_sb_transaction.dato = this.v_if.D_push[0][this.mnt_num][pckg_sz-9:0];
        
        $display("[%0t] ID: 0x%h, Dato: 0x%h", $time, this.mnt_chk_sb_transaction.id, this.mnt_chk_sb_transaction.dato);
        
       if (this.mnt_chk_sb_transaction.id >= drvrs || this.mnt_chk_sb_transaction.dato === 'x) begin //Verifica que la id sea menor al numero de dispositivos/Que le dato este definido
            $display("[%0t] ERROR: Fallo en Monitor %d - ID inválido o dato no esta correcto", $time, this.mnt_num);
        end else begin
            this.mnt_chk_sb_mbx.put(mnt_chk_sb_transaction); //Lo que va al checker
            $display("[%0t] Transacción colocada en el mailbox", $time);
        end
      end
	endtask

endclass

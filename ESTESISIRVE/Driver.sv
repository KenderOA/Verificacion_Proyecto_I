class Driver #(parameter drvrs = 4, parameter pckg_sz = 16);

    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf; 

    bus_transaction #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaction;

    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx; 

    //bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_sb_mbx; 

    int drvr_num;  
    int espera;    
    
    logic [pckg_sz-1:0] fifo_in[$];

    function new(int num, virtual bus_intf bus);
        this.drvr_num = num;
        this.bus_intf = bus; 
        fifo_in = {};
        espera = 0;
        this.agnt_drvr_mbx = new(); 
        //this.drvr_chkr_sb_mbx = new();
      	transaction = new(); /
      	 $display("[%g] Driver %0d: Constructor inicializado", $time,
                  drvr_num);
      $display("[%g] Driver num %0d: agnt_drvr_mbx:%0d", $time,
                  drvr_num, agnt_drvr_mbx );
    endfunction

    // Task para ejecutar el comportamiento del Driver

  virtual task run_driver();

    $display("[%g] ++++++++++++++ EL DRIVER %d FUE INICIALIZADO ++++++++++++++",$time, this.drvr_num);

    fork
        forever begin
            if( fifo_in.size() == 0) begin
                this.bus_if.pndng[0][this.drvr_num] = 0;

                $display("[%g] ESTADO DE PENDING EN %d", $time, this.bus_if.pndng[0][this.drvr_num]);
                $display("[%g] NO HAY DATOS EN EL FIFO", $time);
            end else begin
                this.bus_if.pndng[0][this.drvr_num] = 1;
                this.bus_if.D_pop[0][this.drvr_num] = fifo_in[0];

                $display("[%g] HAY %d DATOS EN EL FIFO", $time, fifo_in.size());
                $display("[%g] TRANSACCIÓN ENVIADA DRIVER => BUS: %h", $time, fifo_in[0]);
                $display("[%g] ESTADO DE PENDING EN %d", $time, this.bus_if.pndng[0][this.drvr_num]);
            end
        end
    join_none

    fork    
        forever begin
            @(posedge this.bus_if.pop[0][this.drvr_num]);
            $display("[%g] SE RECIBIO UN POP", $time);
            fifo_in.delete(0);
        end
    join_none

    forever begin

        this.agnt_drvr_mbx.get(transaction);
        $display("[%g] TRANSACCIÓN RECIBIDA AGENTE => DRIVER: %h", $time, this.transaction);
        fifo_in.push_back({this.transaction.id, this.transaction.data});
        $display("[%g] PAQUETE A ENVIAR:    %d",this.bus_transaction.paquete); 
        $display("[%g] DATO EN PAQUETE:  %d",this.bus_transaction.dato);
        $display("[%G] ID EN PAQUETE: %d",this.bus_transaction.id);

    end
endtask



endclass

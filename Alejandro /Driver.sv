class Driver #(parameter drvrs = 4, parameter pckg_sz = 16);

    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf;  // Interfaz del bus
    int drvr_num;  // Número de driver
    int espera;    // Tiempo de espera o retardo
    
    bus_transaction #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaction;
    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx;    // Mailbox agnt_drvr
    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_sb_mbx; // Mailbox para enviar al checker
    
    logic [pckg_sz-1:0] fifo_in[$];  // FIFO para los datos de entrada del driver
    
    // Constructor de la clase
    function new(int num, virtual bus_intf bus);
        this.drvr_num = num;
        this.bus_intf = bus; // Asignar la interfaz del bus
        fifo_in = {};
        espera = 0;
        transaction = new();
        this.agnt_drvr_mbx = new();  // Inicializar mailboxes
        this.drvr_chkr_sb_mbx = new();
      	 $display("[%g] Driver %0d: Constructor inicializado", $time,
                  drvr_num);
    endfunction

    // Task para ejecutar el comportamiento del Driver
    virtual task run_driver();
        $display("[%g] El driver fue inicializado", $time);
        forever begin
            // Esperar por una transacción en el mailbox
            if (agnt_drvr_mbx.num() > 0) begin
                agnt_drvr_mbx.get(transaction);
              	transaction.dis_src = this.drvr_num;
               $display("Driver:%0d Transacción recibida: ID=%0d,Paquete=%0d", transaction.dis_src, transaction.id, transaction.paquete);
    $display("Transacciones pendientes en el mbx agnt_drv %d = %g", drvr_num, agnt_drvr_mbx.num());

                // Manejar el retardo (si lo hay)
                espera = transaction.retardo;
                if (espera > 0) begin
                    $display("[%g] Driver %d: Aplicando retardo de %d ciclos", $time, drvr_num, espera);
                    repeat (espera) @(posedge bus_intf.clk);  // Esperar el número de ciclos especificados
                end

                // Agregar el dato a la FIFO
                this.fifo_in.push_back(transaction.paquete);
                this.drvr_chkr_sb_mbx.put(transaction);
                $display("[%g] Driver %d: Dato agregado a FIFO: %d", $time, drvr_num, transaction.paquete);

                // Enviar el dato al bus
                if (fifo_in.size() > 0) begin
                    bus_intf.D_pop[0][this.drvr_num] = fifo_in[0]; // Enviar el primer dato de la FIFO
                    bus_intf.pndng[0][this.drvr_num] = 1; // Marcar como pendiente
                    $display("[%g] Driver %d: Paquete enviado a D_pop: %d", $time, drvr_num, fifo_in[0]);

                    // Esperar el flanco positivo de la señal pop
                    @(posedge this.bus_intf.pop[0][this.drvr_num]);
                    $display("[%g] Driver %d: Señal pop recibida, dato procesado", $time, drvr_num);

                    // Eliminar el dato de la FIFO después de enviarlo
                    @(posedge this.bus_intf.clk);
                    if(this.fifo_in.size() > 0) begin 
                        this.fifo_in.delete(0); // Eliminar el primer dato
                        $display("[%g] Driver %d: Dato eliminado de FIFO", $time, drvr_num);
                    end
                end else begin
                    $display("[%g] Driver %d: FIFO vacío, no se puede enviar", $time, drvr_num);
                end
            end
        end
    endtask
endclass

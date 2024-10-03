
class Driver_Monitor #(parameter drvrs = 4, parameter pckg_sz = 16);
    
    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf;  // Interfaz del bus compartida
    int drvr_num;  // Número de driver
    int mnt_num;
    int espera;    // Tiempo de espera o retardo

  	bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx;    // Mailbox agnt_drvr
  	bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mnt_chkr_sb_mbx;  // Mailbox drvr_mnt a chkr_sb
    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_sb_mbx;
    
    logic [pckg_sz-1:0] fifo_in[$];  // FIFO para los datos de entrada del driver
    logic [pckg_sz-1:0] fifo_out[$]; // FIFO para los datos de salida del monitor
	
  	bus_transaction #(.pckg_sz(pckg_sz), .drvrs(drvrs)) transaction;
    // Constructor de la clase
    function new(int num, virtual bus_intf bus, int mnum);
        
      	this.drvr_num = num;
        this.mnt_num = mnum;
        this.bus_intf = bus; // Asignar la interfaz del bus
        fifo_in = {};
        fifo_out = {};
        espera = 0;
        this.agnt_drvr_mbx = new();  // Inicializar mailboxes
        this.mnt_chkr_sb_mbx = new();
        this.drvr_chkr_sb_mbx=new();
    endfunction

    // Task para ejecutar el comportamiento combinado de Driver y Monitor

    // Lógica del driver
   virtual task run_driver();
        $display("[%g] El driver fue inicializado", $time);
        forever begin
            bus_transaction #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaction; // Asegúrate de que esto se inicialice aquí
            transaction = new(); // Inicializar el objeto
            transaction.dis_src = this.drvr_num;

            $display("[%g] El driver espera por una transacción", $time);

            // Esperar por una transacción en el mailbox
            if (agnt_drvr_mbx.num() > 0) begin
                agnt_drvr_mbx.get(transaction);
                transaction.print("Driver: Transacción recibida");
                $display("Transacciones pendientes en el mbx agnt_drv %d= %g", drvr_num,
                         agnt_drvr_mbx.num());

                // Manejar el retardo
                espera = transaction.retardo;
                if (espera > 0) begin
                    $display("[%g] Driver %d: Aplicando retardo de %d ciclos", $time, drvr_num, espera);
                   // while (espera > 0) begin
                       // @(posedge bus_intf.clk);
                       // espera--;
                   // end
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
                    
                    // Eliminar el dato de la FIFO después de enviarlo
                    @(posedge this.bus_intf.pop[0][this.drvr_num]); 
                    fifo_in.pop_front();
                  	
                end else begin
                    $display("[%g] Driver %d: FIFO vacío, no se puede enviar", $time, drvr_num);
                end
            end else begin
                $display("[%g] Driver %d: No hay transacciones en el mailbox", $time, drvr_num);
            end
        end
    endtask

    // Lógica del monitor
   virtual task run_monitor();
        $display("[%g] Monitor inicializado", $time);
        @(posedge bus_intf.clk); // Esperar al primer flanco de reloj
        
        forever begin
            bus_transaction#(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaction_mnt; // Inicializar aquí también
            transaction_mnt = new();
            transaction_mnt.id = this.mnt_num;
            
            // Esperar señal de push
            @(posedge this.bus_intf.push[0][this.mnt_num]);
            // Agregar el dato a la cola
            this.fifo_out.push_back(this.bus_intf.D_push[0][this.mnt_num]);
            bus_intf.push[0][mnt_num] = 1;
            // Crear nueva transacción de verificación
            transaction_mnt.id = this.bus_intf.D_push[0][this.mnt_num][pckg_sz-1:pckg_sz-8];
            transaction_mnt.dato = this.bus_intf.D_push[0][this.mnt_num][(pckg_sz-9):0];
            
            // Enviar la transacción al mailbox
            this.mnt_chkr_sb_mbx.put(transaction_mnt);
            $display("[%g] Monitor %d: Transacción enviada al mailbox (ID: %h, Payload: %h)", 
                     $time, this.mnt_num, transaction_mnt.id, transaction_mnt.dato);
        end
    endtask
endclass

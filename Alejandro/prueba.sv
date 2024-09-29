`include "interfaz.sv"
class Driver_Monitor #(parameter drvrs = 4, parameter pckg_sz = 16);
    
    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf;  // Interfaz del bus compartida
    int drvr_num;  // Número de driver
    int mnt_num;
    int espera;    // Tiempo de espera o retardo

    mnt_chk_sb #(.pckg_sz(pckg_sz), .drvrs(drvrs)) mnt_chkr_sb_transaction;
    bus_mbx agnt_drvr_mbx;    // Mailbox agnt_drvr
    mnt_chk_sb_mbx mnt_chkr_sb_mbx;  // Mailbox drvr_mnt a chkr_sb
    
    bit [pckg_sz-1:0] fifo_in[$];  // FIFO para los datos de entrada del driver
    bit [pckg_sz-1:0] fifo_out[$]; // FIFO para los datos de salida del monitor


    // Constructor de la clase
    function new(int num, virtual bus_intf bus);
        this.drvr_num = num;
        int mnt_num= mnum;
        this.bus_intf = bus; // Asignar la interfaz del bus
        fifo_in = {};
        fifo_out = {};
        espera = 0;
        this.agnt_drvr_mbx = new();  // Inicializar mailboxes
        this.mnt_chkr_sb_mbx = new("chkr_sb_mbx");
    endfunction

    // Task para ejecutar el comportamiento combinado de Driver y Monitor
    task run();
        fork
            run_driver();   // Ejecutar la lógica del driver en paralelo
            run_monitor();  // Ejecutar la lógica del monitor en paralelo
        join
    endtask

    // Lógica del driver
    task run_driver();
        $display("[%g] El driver fue inicializado", $time);
        @(posedge bus_intf.clk);
        bus_intf.rst = 1;
        @(posedge bus_intf.clk);
        
        forever begin
            bus_transaction #(.pckg_sz(pckg_sz), .drvrs(drvrs)) transaction;
            $display("[%g] El driver espera por una transacción", $time);
            transaction = new();
            transaction.dis_src = this.drvr_num;

            // Esperar por una transacción en el mailbox
            agnt_drvr_mbx.get(transaction);
            transaction.print("Driver: Transacción recibida");
            $display("Transacciones pendientes en el mbx agnt_drv %d= %g", drvr_num, agnt_drvr_mbx.num());

            // Manejar el retardo
            espera = transaction.retardo;
            while (espera > 0) begin
                @(posedge bus_intf.clk);
                espera--;
            end
            
            // Agregar el dato a la FIFO
            this.fifo_in.push_back(transaction.paquete);
            $display("[%g] Driver %d: Dato agregado a FIFO: 0x%h", $time, drvr_num, transaction.paquete);

            // Enviar el dato al bus
            if (fifo_in.size() > 0) begin
                bus_intf.D_pop[0][this.drvr_num] = fifo_in[0]; // Enviar el primer dato de la FIFO
                bus_intf.pndng[0][this.drvr_num] = 1; // Marcar como pendiente
                $display("[%g] Driver %d: Paquete enviado a D_pop: 0x%h", $time, drvr_num, fifo_in[0]);
                
                // Eliminar el dato de la FIFO después de enviarlo
                @(posedge this.bus_intf.pop[0][this.drvr_num]); 
                fifo_in.pop_front();
            end else begin
                $display("[%g] Driver %d: FIFO vacío, no se puede enviar", $time, drvr_num);
            end
        end
    endtask

    // Lógica del monitor
    task run_monitor();
        $display("[%g] Monitor inicializado", $time);
        @(posedge bus_intf.clk); // Esperar al primer flanco de reloj
        
        forever begin
        // Esperar señal de push
        @(posedge this.bus_intf.push[0][this.mnt_num]);
        
        // Agregar el dato a la cola
        this.fifo_out.push_back(this.bus_intf.D_push[0][this.mnt_num]);
        
        // Crear nueva transacción de verificación
        this.mnt_chkr_sb_transaction = new();
        this.mnt_chkr_sb_transaction.id = this.bus_intf_push[0][this.mnt_num][pckg_sz-1:pckg_sz-8];
        this.mnt_chkr_sb_transaction.payload = this.bus_intf.D_push[0][this.mnt_num][pckg_sz-9:0];
        
        // Enviar la transacción al mailbox
        this.mnt_chkr_sb_mbx.put(this.mon_chk_sb_transaction);
        $display("[%g] Monitor %d: Transacción enviada al mailbox (ID: %h, Payload: %h)", 
                 $time, this.mnt_num, mnt_chkr_sb_transaction.id, mnt_chkr_sb_transaction.payload);
    end
    endtask
endclass

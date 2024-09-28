
class Driver #(parameter drvrs = 4, parameter pckg_sz = 16);
    
    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf;
    int drvr_num;
    int espera;
    bus_mbx  agnt_drvr_mbx;            //mailbox del agente del driver

    bit [pckg_sz-1:0]  fifo_in[$];

    function new(int num);
        this.drvr_num = num;
        fifo_in = {};
        espera=0; 
    endfunction

    task run();
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
endclass

class Monitor #(parameter drvrs = 4, parameter pckg_sz = 16);
    
    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf;
    bus_mbx mnt_chkr_sb_mbx; 
    bit [pckg_sz-1:0] fifo_out[$];

    function new(virtual bus_intf bus);
        this.bus_intf = bus; // Asignar la interfaz del bus
        fifo_out = {};
        this.mnt_chkr_sb_mbx = new("chkr_sb_mbx"); // Inicializar el mailbox
    endfunction

    task run();
        $display("[%g] Monitor inicializado", $time);
        @(posedge bus_intf.clk); // Esperar al primer flanco de reloj
        
        forever begin
            // Esperar señal de push
            @(posedge bus_intf.push[0]); // Esperar señal de push
            
            // Leer el paquete de la señal D_push
            bit [pckg_sz-1:0] paquete = bus_intf.D_push[0]; // Suponiendo que D_push es un arreglo

            // Crear nueva transacción
            bus_transaction #(.pckg_sz(pckg_sz)) mnt_transaction;
            mnt_transaction = new(paquete[pckg_sz-1:pckg_sz-8], paquete[pckg_sz-9:0]); // Crear transacción

            // Asignar mnt_num basado en el ID del paquete
            int mnt_num = mnt_transaction.id; // Usar el ID como número de monitor
            
            // Verificar si el ID es válido antes de almacenarlo en FIFO
            if (mnt_num >= 0 && mnt_num < drvrs) begin
                fifo_out.push_back(paquete); // Almacenar en FIFO
                // Enviar transacción al mailbox
                mnt_chkr_sb_mbx.put(mnt_transaction);
                $display("[%g] Monitor %d: Paquete recibido (ID: %h, Payload: %h)", 
                         $time, mnt_num, mnt_transaction.id, mnt_transaction.payload);
            end else begin
                $display("[%g] Monitor: ID no válido (ID: %d)", $time, mnt_num);
            end
        end
    endtask
endclass

class Driver_Monitor #(parameter drvrs = 4, parameter pckg_sz = 16);
    
    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf;
    Driver #(.drvrs(drvrs), .pckg_sz(pckg_sz)) driver;
    Monitor #(.drvrs(drvrs), .pckg_sz(pckg_sz)) monitor;

    // Mailboxes
    bus_mbx agnt_drvr_mbx;
    bus_mbx mnt_chkr_sb_mbx;

    function new(virtual bus_intf bus, int drvr_num, int mnt_num);
        this.bus_intf = bus;
        this.driver = new(drvr_num);
        this.monitor = new(mnt_num, bus);
        
        // Inicialización de mailboxes
        agnt_drvr_mbx; = new();
        mnt_chkr_sb_mbx = new();
        
        // Conexión de mailboxes
        driver.agnt_drvr_mbx = agnt_drvr_mbx;
        monitor.mnt_chkr_sb_mbx = mnt_chkr_sb_mbx;
    endfunction

    task run();
        $display("[%g] Driver_Monitor fue inicializado", $time);
        
        // Ejecutar las tareas del driver y monitor en paralelo
        fork
            driver.run();
            monitor.run();
        join
    endtask
endclass

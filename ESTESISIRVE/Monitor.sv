class Monitor #(parameter drvrs = 4, parameter pckg_sz = 16);

    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_intf;  // Interfaz del bus

    bus_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mnt_chkr_sb_mbx; // Mailbox para enviar al checker
    bus_transaction#(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaction_mnt; 
    
    logic [pckg_sz-1:0] fifo_out[$]; // FIFO para los datos de salida del monitor

    int mnt_num;  // Número de monitor

    // Constructor de la clase
    function new(int num, virtual bus_intf bus);
        this.mnt_num = num;
        this.bus_intf = bus; // Asignar la interfaz del bus
        fifo_out = {};
        this.mnt_chkr_sb_mbx = new();
        transaction_mnt = new(mnt_num);
    endfunction

    // Task para ejecutar el comportamiento del Monitor
    task run_monitor();
        $display("[%g] Monitor inicializado", $time);
        @(posedge bus_intf.clk); // Esperar al primer flanco de reloj
        
        forever begin
                      
            
            // Esperar señal de push
            @(posedge this.bus_intf.push[0][this.mnt_num]);
            
            // Agregar el dato a la FIFO
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

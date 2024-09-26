class Driver_Monitor #(parameter drvrs = 4, parameter pck_sz = 16);

    virtual bus_intf #(.drvrs(drvrs), .pckg_sz(pck_sz))   bus_intf;                 //interfaz virtual del bus 
    agnt_drvr_transaction #(.pck_sz(pck_sz), .drvr(drvr)) agnt_drvr_transaction;    //transacción del agente del driver
    agnt_drvr_mbx                                         agnt_drvr_mbx;            //mailbox del agente del driver

    int                                                   drvr_num;                 //número del driver

    bit [pck_sz-1:0]                                      fifo_in[$];               //fifo de entrada
    bit [pck_sz-1:0]                                      fifo_out[$];              //fifo de salida
    bit [pck_sz-1:0]                                      dato;                     //dato

    function new (int drvr_num);                                                    //constructor
        fifo_in = {};                                                               //se inicializa la fifo de entrada vacía
        fifo_out = {};                                                              //se inicializa la fifo de salida vacía
        this.drvr_num = drvr_num;                                                   //se asigna el número del driver   
    endfunction

    task run ()
        forever begin
            agnt_drvr_mbx.get(agnt_drvr_transaction);
            @(posedge bus_intf.clk);
            agnt_drvr_mbx.get(signal);
            case(agnt_drvr_transaction.tipo)
                enviar_dato: begin
                    this.fifo_in.push_back(dato);                                           //se agrega un dato al final de la fifo de entrada
                    this.bus_intf.D_pop[0][this.drvr_num] = fifo_in[0];                     //se actualiza el valor de D_pop con el primer dato de la fifo de entrada
                    this.bus_intf.pndng[0][this.drvr_num] = 1;                              //se actualiza el valor de pndng a 1
                end
                recibir_dato: begin
                    @(posedge this.bus_intf.push[0][this.drvr_num]);                        //se espera a que se active la señal push del bus
                    this.fifo_out.push_back(this.bus_intf.D_push[0][this.drvr_num]);        //se agrega un dato al final de la fifo de salida
                    @(posedge this.bus_intf.clk);                                           //se espera a que se active el flanco de subida del reloj
                    this.fifo_out.pop_front(); //this.fifo_out.delete(0);                   //se elimina el primer dato de la fifo de salida
                end
                eliminar_dato: begin                                                        
                    @(posedge this.bus_intf.pop[0][this.drvr_num]);                         //se espera a que se active la señal pop del bus
                    this.fifo_in.pop_front(); //this.fifo_in.delete(0);                     //se elimina el primer dato de la fifo de entrada
                end
            endcase
        end
    endtask
endclass
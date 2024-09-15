class fifo_gen #(parameter fifo_size = 8, parameter drvrs = 4, parameter pckg_sz = 16);

    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz)) v_if;
    int fifo_num;
    bit [pckg_sz-1:0] d_q[$];

    function new(virtual bus_if v_if, int fifo_num);
        d_q= {};
        this.fifo_num=fifo_num;
        this.v_if= v_if;
        
    endfunction 

    function void fifo_push (bit [pckg_sz-1:0] data);
        if (d_q.size() < fifo_size) begin
            d_q.push_back(data); // Inserta el dato en la cola si no está llena
			this.v_if.pndng[0][this.fifo_num] = 1;         
        end else begin
            $display("Error: FIFO %0d overflow!", fifo_num);
        end
    endfunction

    //function bit [pckg_sz-1:0] fifo_pop();
   //bit [pckg_sz-1:0] data;
    
    //if (!d_q.empty()) begin
        // Extrae el dato más antiguo (primero en la cola)
        //data = d_q.pop_front();

        // Actualiza la interfaz con el nuevo primer dato de la cola, si hay más datos
        //if (!d_q.empty()) begin
            //this.v_if.D_pop[0][this.fifo_num] = d_q[0];
        //end else begin
            // Si la FIFO está vacía después del pop, marca que no hay datos pendientes
            //this.v_if.pndng[0][this.fifo_num] = 0;
        //end
    //end else begin

        //$display("Error: FIFO %0d underflow!", fifo_num);
        //data = '0;
    //end
    
    //return data;

//endfunction

 // Tarea para manejar las señales de la interfaz virtual
    task if_signal();
        $display("FIFO%d: if_signal running", this.fifo_num);
        this.v_if.pndng[0][this.fifo_num] = 0; // Inicializa sin datos pendientes
        forever begin
            // Revisa si la FIFO está vacía o tiene datos
            if (this.d_q.size() == 0) begin
                this.v_if.pndng[0][this.fifo_num] = 0;
                this.v_if.D_pop[0][this.fifo_num] = 0;
            end else begin
                this.v_if.pndng[0][this.fifo_num] = 1;
                this.v_if.D_pop[0][this.fifo_num] = d_q[0]; // Asigna el dato más antiguo
            end

            // Espera a que ocurra un pop
            @(posedge this.v_if.pop[0][this.fifo_num]);

            // Actualiza el valor de D_pop y sincroniza con el reloj
            this.v_if.D_pop[0][this.fifo_num] = d_q[0];
            @(posedge this.v_if.clk);

            // Elimina el dato si la FIFO tiene datos
            if (this.d_q.size() > 0) this.d_q.delete(0);
        end
    endtask

endclass 
class fifo_gen #(parameter fifo_size = 8, parameter drvrs = 4, parameter pckg_sz = 16);

    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz)) v_if;
    int fifo_num;
    bit [pckg_sz-1:0] d_q[$];

    // Constructor de la clase
    function new(virtual bus_if v_if, int fifo_num);
        d_q = {}; // Inicializa la cola FIFO vacía
        this.fifo_num = fifo_num;
        this.v_if = v_if;
    endfunction

    // Función para insertar datos en la FIFO
    function void fifo_push(bit [pckg_sz-1:0] data);
        if (d_q.size() < fifo_size) begin
            d_q.push_back(data); // Inserta el dato en la cola si no está llena
            this.v_if.pndng[0][this.fifo_num] = 1; // Marca datos pendientes
        end else begin
            $display("Error: FIFO %0d overflow!", fifo_num);
        end
    endfunction

    // Función para extraer datos de la FIFO
    function bit [pckg_sz-1:0] fifo_pop();
        bit [pckg_sz-1:0] data;

        if (!d_q.empty()) begin
            data = d_q.pop_front(); // Extrae el dato más antiguo
            this.v_if.pndng[0][this.fifo_num] = (d_q.size() > 0); // Actualiza el estado pendiente
        end else begin
            $display("Error: FIFO %0d underflow!", fifo_num);
            data = '0; // Retorna 0 si la FIFO está vacía
        end

        return data;
    endfunction

    // Task para manejar el pop (eliminar datos de la FIFO)
    task pop();
        $display("FIFO%d: pop running", this.fifo_num);
        forever begin
            // Espera a que ocurra un pop en la interfaz
            @(posedge this.v_if.pop[0][this.fifo_num]);

            if (!d_q.empty()) begin
                d_q.delete(0); // Elimina el dato más antiguo
            end else begin
                $display("Error: FIFO %0d underflow!", fifo_num);
            end
        end
    endtask

    // Task para manejar el d_pop (actualizar la interfaz con el dato actual)
    task d_pop();
        $display("FIFO%d: d_pop running", this.fifo_num);
        forever begin
            // Si la FIFO está vacía
            if (this.d_q.size() == 0) begin
                this.v_if.pndng[0][this.fifo_num] = 0; // No hay datos pendientes
                this.v_if.D_pop[0][this.fifo_num] = 0; // No hay dato a poppear
            end else begin
                // Si hay datos pendientes
                this.v_if.pndng[0][this.fifo_num] = 1;
                this.v_if.D_pop[0][this.fifo_num] = d_q[0]; // Asigna el dato más antiguo
            end

            // Espera a un ciclo de reloj para actualizar la interfaz
            @(posedge this.v_if.clk);
        end
    endtask

    // Proceso principal para ejecutar las tareas pop y d_pop en paralelo
    initial begin
        fork
            pop();  // Tarea que maneja la extracción de datos
            d_pop(); // Tarea que maneja la actualización de la interfaz
        join
    end

endclass

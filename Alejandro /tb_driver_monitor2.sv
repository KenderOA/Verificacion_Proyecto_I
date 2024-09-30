`timescale 1ns/1ps

module top();

  parameter      P_SYS  = 10;           // 100MHz
  reg            clk_tb;                // Global CLK
  parameter drvrs = 4;
  parameter pckg_sz = 16;
  parameter bits = 1;

  // Set Clk for SDRAM to 0
  initial clk_tb = 0;

  // Generate CLK for SDRAM
  always #(P_SYS/2) clk_tb = !clk_tb;

  // Declaraciones de módulos
  Driver_Monitor #(.drvrs(drvrs), .pckg_sz(pckg_sz)) driver [0:drvrs-1];
  bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) _if(.clk(clk_tb));

  bus_mbx agnt_drvr_mbx;    // Mailbox agnt_drvr
  bus_mbx mnt_chkr_sb_mbx;

  // Declaración de un arreglo de punteros de transacciones
  bus_transaction #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaction[0:drvrs-1];

  // Inicialización de los drivers y el monitor
  initial begin
    $dumpfile("verilog.vcd");
    $dumpvars(0);

    // Inicializar los mailboxes
    agnt_drvr_mbx = new();  // Asegúrate de inicializar el mailbox
    mnt_chkr_sb_mbx = new();  // Inicializar el segundo mailbox

    // Crear instancias de Driver_Monitor y transacciones
    for (int i = 0; i < drvrs; i++) begin
      driver[i] = new(i, _if, i);
      transaction[i] = new();  // Inicializar cada transacción
      driver[i].agnt_drvr_mbx = agnt_drvr_mbx;  // Asignar mailbox al driver
    end

    // Randomización de las transacciones en el testbench antes de ejecutar run()
    for (int i = 0; i < drvrs; i++) begin
      if (!transaction[i].randomize()) begin
        $display("Error en la randomización de la transacción %0d", i);
      end else begin
        transaction[i].id = $urandom_range(1, 4);
        transaction[i].dato = $random;
        transaction[i].dis_src = $urandom_range(1, 4);
        transaction[i].retardo = $urandom_range(1, 5);

        transaction[i].paquete = {transaction[i].id, transaction[i].dato};

        transaction[i].print("Testbench: Transacción randomizada");
        agnt_drvr_mbx.put(transaction[i]);  // Asegurarse de que el objeto esté inicializado
      end
    end

    // Iniciar el funcionamiento del driver después de la randomización
    fork
      begin
        // Asegúrate de que las señales también estén correctamente inicializadas aquí
        // (Agregar lógica de señales si fuera necesario)
        
        // Ejecutar run() para cada driver
        for (int i = 0; i < drvrs; i++) begin
          fork
            driver[i].run();  // Ejecutar la función run() de cada driver en paralelo
          join_none
        end
      end
    join
  end

  // Lógica para simular el comportamiento del bus
  initial begin
    integer count = 0;  // Contador para controlar las impresiones

    forever begin
      @(posedge clk_tb);

      // Manejo de D_pop
      for (int i = 0; i < drvrs; i++) begin
        if (driver[i].fifo_in.size() > 0) begin
          _if.D_pop[0][i] = driver[i].fifo_out[0];  // Leer de FIFO del driver
          _if.pop[0][i] = 1;  // Activar la señal de pop
          #1;
          _if.pop[0][i] = 0;  // Desactivar la señal de pop
        end
      end

      // Manejo de D_push
      for (int j = 0; j < drvrs; j++) begin
        if (_if.D_push[0][j] !== 0) begin
          driver[j].fifo_out.push_back(_if.D_push[0][j]);
          count = count + 1;  // Incrementar contador

          // Imprimir cada 10 ciclos
          if (count % 10 == 0) begin
            $display("[%g] Monitor: Dato recibido de D_push: 0x%h", $time, _if.D_push[0][j]);
          end
        end
      end
    end
  end

  // Finalización del test al pasar el tiempo límite
  always @(posedge clk_tb) begin
    if ($time > 100000) begin
      $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
      $finish;
    end
  end

endmodule

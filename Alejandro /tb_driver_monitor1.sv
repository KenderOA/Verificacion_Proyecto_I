timescale 1ns/1ps

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
  
  
  
  Driver_Monitor #(.drvrs(drvrs), .pckg_sz(pckg_sz)) driver [drvrs];
 
  bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz), .bits(bits)) _if(.clk(clk_tb));
  
  bus_mbx agnt_drvr_mbx;    // Mailbox agnt_drvr
  bus_mbx mnt_chkr_sb_mbx;

  // Declaración de un arreglo de punteros de transacciones
  bus_transaction #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaction[drvrs];
  
  // Inicialización de los drivers y el monitor
  initial begin
    $dumpfile("verilog.vcd");
    $dumpvars(0);
    agnt_drvr_mbx = new();
    mnt_chkr_sb_mbx= new ();
    
    // Crear instancias de Driver_Monitor
    for (int i = 0; i < drvrs; i++) begin
      driver[i] = new(i, _if, i); 
      transaction[i] = new(); 
      driver[i].agnt_drvr_mbx = agnt_drvr_mbx;
    end
    
    fork
      begin
        // Llamar al método run() para cada instancia del driver
        for (int i = 0; i < drvrs; i++) begin
          // Randomización de la transacción en el testbench
          if (!transaction[i].randomize()) begin
              $display("Error en la randomización de la transacción %0d", i);
          end else begin
              transaction[i].id = i;  
              transaction[i].dato = $random; 
              transaction[i].dis_src = i;
              transaction[i].retardo = $urandom_range(1, 5);  
            
              transaction[i].paquete = {transaction[i].id, transaction[i].dato}; 

              transaction[i].print("Testbench: Transacción randomizada");
              agnt_drvr_mbx.put(transaction[i]);
           end
          driver[i].run();
        end
    join
  end

  // Finalización del test al pasar el tiempo límite
  always @(posedge clk_tb) begin
        if ($time > 100000) begin
            $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
            $finish;
        end
    end
endmodule

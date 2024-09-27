`timescale 1ns/1ps
`include "Driver_Monitor.sv"
module test_driver_monitor;
    reg clk;
    parameter pckg_sz=16;
    parameter drvrs=4;

    //senales
    Driver_Monitor #( .drvrs(drvrs), .pckg_sz(pckg_sz)) dm;
    always #5 clk = ~clk;

    initial begin
        clk=0;
        dm = new(0); 
        clk = 0;
        fork
            dm.run();  
        join_none

        for (int i = 0; i < 10; i++) begin  // Envía 10 transacciones aleatorias
            dm.transaction = new();
            dm.transaction.tipo = $urandom_range(0, 2);
            dm.transaction.paquete= $urandom_range(0, 255);  
            dm.agnt_drvr_mbx.put(dm.transaction);

            $display("[%g] Agente envió transacción: Tipo=%0d, Paquete=0x%h", $time, dm.transaction.tipo, dm.transaction.paquete);
            #10;
        end
        #50;
        for (int j = 0; j < 10; j++) begin
            if (dm.drv_chkr_mbx.get(dm.transaction)) begin // Intenta obtener una transacción del mailbox del checker
                // Imprime la transacción recibida en el checker
                $display("[%g] Checker recibió transacción: Tipo=%0d, Paquete=0x%h", $time, transaction.tipo, transaction.paquete);
            end else begin
                $display("[%g] Checker no recibió transacción en el mailbox", $time);
            end
        end
        // Finaliza la simulación
        always @(posedge clk) begin
            if ($time > 100000) begin
                $display("Test_bench: Tiempo límite de prueba en el test_bench alcanzado");
                $finish;
            end
        end
    end

endmodule

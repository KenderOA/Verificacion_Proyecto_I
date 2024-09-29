`timescale 1ns/1ps
`include "prueba.sv"

module tb_Driver_Monitor;

    // Definir parámetros de la interfaz y el número de drivers
    parameter drvrs = 4;
    parameter pckg_sz = 16;

    // Instancia de la interfaz del bus
    bus_intf #(.drvrs(drvrs), .pckg_sz(pckg_sz)) bus_ifc();

    // Instancias de Driver_Monitor
    Driver_Monitor #(.drvrs(drvrs), .pckg_sz(pckg_sz)) dm[drvrs];

    // Clock y reset
    logic clk;
    logic rst;

    // Generador de clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Periodo de 10 unidades de tiempo
    end

    // Reset inicial
    initial begin
        rst = 1;
        #20 rst = 0;
    end

    // Inicialización de las instancias de Driver_Monitor
    initial begin
        for (int i = 0; i < drvrs; i++) begin
            dm[i] = new(i, bus_ifc);
        end
    end

    // Testbench para enviar múltiples mensajes
    initial begin
        // Esperar al reset
        @(negedge rst);
        
        // Crear transacciones para cada driver
        foreach (dm[i]) begin
            fork
                // Enviar mensajes desde el driver `i`
                send_multiple_messages(dm[i], i);
            join_none
        end

        // Esperar suficiente tiempo para procesar todas las transacciones
        #500;
        $stop; // Detener la simulación
    end

    // Task para enviar múltiples mensajes desde un driver
    task send_multiple_messages(Driver_Monitor dm_instance, int driver_num);
        bus_transaction transaction;

        // Enviar 10 mensajes desde este driver
        for (int j = 0; j < 10; j++) begin
            // Crear una nueva transacción con datos aleatorios
            transaction = new($urandom_range(0, 255), 10, $urandom_range(0, drvrs-1), driver_num);

            // Colocar la transacción en el mailbox del driver
            dm_instance.agnt_drvr_mbx.put(transaction);

            $display("[%g] Testbench: Mensaje %0d enviado desde driver %0d a destino %0d", 
                     $time, j, driver_num, transaction.id);

            #20;  // Esperar un tiempo antes de enviar el siguiente mensaje
        end
    endtask

endmodule

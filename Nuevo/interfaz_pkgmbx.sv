interface bus_intf #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16) //parameter del broadcast no se si va aqui
(input clk);
    logic rst;
    logic pndng [bits-1:0][drvrs-1:0];
    logic push [bits-1:0][drvrs-1:0];
    logic pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push [bits-1:0][drvrs-1:0];
endinterface
//Instrucciones 
typedef enum { enviar_dato, recibir_dato, eliminar_dato} inst_drv_mnt;
//Paquetes

class agnt_drvr_transaction#(parameter pckg_sz = 16, parameter drvrs=4);
    //rand int retardo; // tiempo de retardo en ciclos de reloj que se debe esperar antes de ejecutar la transacción
    //rand bit [pckg_sz-1:0] dato; // este es el dato de la transacción
    //rand bit [7:0] id; //identificador del dispositivo destino
    //rand int dis_src; //dispositivo de envio
    //int tiempo; // Representa el tiempo de simulación en el que se ejecutó la transacción
    inst_drv_mnt tipo; // enviar dato, recibir dato, eliminar dato
    //int max_retardo;

    //constraint const_retardo { retardo < max_retardo; retardo > 0; }
    //constraint dispositivo_valido{dis_src >= 0;};  
    //constraint fuente_valida {dis_src< drvrs;};  
    //constraint id_valida {id < drvrs;};       
    //constraint fuente_destino {id != dis_src;};        
    //constraint dato_valido {dato inside {{(pckg_sz-8){1'b1}},{(pckg_sz-8){1'b0}}};};

    function new (bit [pckg_sz-9:0] dto=0, int ret=0, bit [7:0] ide=0, int src=0, int tmp=0, int mxrto=10, inst_drv_mnt inst=enviar_dato );
        
        //this.dato=dto;
        //this.retardo=ret;
        //this.id=ide;
        //this.dis_src=src;
        //this.tiempo=tmp;
        //this.max_retardo=mxrto;
        this.tipo=inst;
        
    endfunction;

    function clean;
        //this.retardo = 0;
        //this.dato = 0;
        //this.dis_src=0;
        //this.id=0;
       // this.tiempo = 0;
        this.inst = enviar_dato;
    endfunction

    //function void print(string tag = "");
    //$display("[%g] %s Tiempo=%g Tipo=%s Retardo=%g Dato=0x%h Dis_src=%0d ID=%0d Inst=%s", 
            // $time, tag, this.tiempo, this.tipo, this.retardo, this.dato, this.dis_src, this.id, this.inst.name());
    //endfunction

endclass

class bus_transactions #(parameter drvrs = 4, parameter pck_sz = 16);


endclass

class agnt_instruction

//Mailbox
typedef mailbox #(agnt_driv) agnt_drvr_mbx;

typedef mailbox #(bus_transactions) bus_transactions_mbx;

typedef mailbox #(agnt_instruction) comando_tst_agnt_mbx;
typedef enum data_type { normal_transactions,  } name;



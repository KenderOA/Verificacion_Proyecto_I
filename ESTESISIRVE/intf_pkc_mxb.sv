////Instrucciones 
typedef enum {max_variabilidad, max_aleatoriedad} modo_agnt_data; //gen_ag_data_modo
typedef enum {self_id, any_id, invalid_id, fix_source ,normal_id} modo_agnt_id;//gen_ag_id_modo
typedef enum {normal, broadcast, one_to_all, all_to_one} Generador_modo;
//Interface
interface bus_intf #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16) //parameter del broadcast no se si va aqui
(input clk);
    logic rst;
    logic pndng [bits-1:0][drvrs-1:0];
    logic push [bits-1:0][drvrs-1:0];
    logic pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop [bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push [bits-1:0][drvrs-1:0];
endinterface


class bus_transaction #(parameter pckg_sz = 16, parameter drvrs=4);
    rand int retardo; // tiempo de retardo en ciclos de reloj que se debe esperar antes de ejecutar la transacción
    rand logic [pckg_sz-1:0] paquete; // este es el dato de la transacción
  rand logic [pckg_sz-1:pckg_sz-8] id; //identificador del dispositivo destino
    rand logic [pckg_sz-9:0] dato ; //Payload del paquete
    rand int dis_src; //dispositivo de envio
    int max_retardo;
    int tiempo;

    constraint const_retardo { retardo < max_retardo; retardo > 0; }
    constraint dispositivo_valido{dis_src >= 0;};  
    constraint fuente_valida {dis_src< drvrs;};  
    constraint id_valida {id < drvrs;};       
    constraint fuente_destino {id != dis_src;};        
    constraint dato_valido {dato inside {{(pckg_sz-8){1'b1}},{(pckg_sz-8){1'b0}}};};
  function new (logic [pckg_sz-9:0] dto='0, int ret=0, logic [7:0] ide='0, int src=0, int mxrto=10, int tmp=0);
        this.dato=dto;
        this.retardo=ret;
        this.id=ide;
        this.dis_src=src;
        //this.tiempo=tmp;
        this.max_retardo=mxrto;
        //this.tipo=inst;
        this.paquete={id, dato};
        this.tiempo=tmp;
    endfunction;

    function clean;
        this.retardo = 0;
        this.dato = '0;
        this.dis_src=0;
        this.id='0;
        this.tiempo = 0;
        //this.tipo= enviar_dato;
        this.paquete='0;
    endfunction

    function void print(string tag = "");
    $display("[%g] %s Retardo=%g Dato=0x%h Dis_src=%0d ID=%0d", 
             $time, tag, this.retardo, this.dato, this.dis_src, this.id);
    endfunction
  

endclass

class gen_agnt; //gen_ag
  int cant_datos; //cant_datos
  rand modo_agnt_data tipo_data; //data_modo       
  rand modo_agnt_id tipo_id; //id_modo
  int id_rand; //id_rand
  int id; //id
  int dis_src_rand; //source_rand
  int dis_src; // source
 
// Constructor
  function new (int cnt_dato=0, modo_agnt_id id_modo=normal_id, modo_agnt_data data_modo=max_aleatoriedad, int id_rand=0, int id=0, int dis_src_rand=0, int dis_src=0);
    this.cant_datos = cnt_dato;
    this.tipo_data = data_modo;
    this.tipo_id = id_modo;
    this.id_rand = id_rand;
    this.id = id;
    this.dis_src_rand = dis_src_rand;
    this.dis_src = dis_src;
  endfunction;
endclass

class tst_gen;

  Generador_modo tipo_gen; //caso
  int id; 
  int dis_src; //source

  function new (Generador_modo tpo_gen=normal, int id=0, dis_src=0);

    this.tipo_gen=tpo_gen;
    this.id=id;
    this.dis_src=dis_src;

  endfunction;

endclass

//Mailbox

typedef mailbox #(bus_transaction) bus_mbx;
typedef mailbox #(gen_agnt) gen_agnt_mbx;
typedef mailbox #(tst_gen) tst_gen_mbx;

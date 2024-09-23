//Enumerado de instrucciones pruebas 
typedef enum {max_variabilidad, max_aleatoriedad} Intrucciones_dato_modo; ///generador-agente modo el dato 
typedef enum {self_id, any_id, invalid_id,normal_id} instrucciones_agente;// generador afente modo del id
typedef enum {bus_push, bus_pop} instrucciones_monitor; // odo del monitor
typedef enum {normal, broadcast, one_to_all, all_to_one} instrucciones_genenerador; //modo del generador

class agnt_drv #(parameter pckg_sz=16, parameter drvrs=4);

    rand bit [pckg_sz-9:0] dato;
    rand bit [7:0]         id;
    rand int               dis_src;
    rand int               retardo;
    int                    tiempo;
    int                    max_retardo;

    //Respecto al Source
    constraint pos_source_addrs {dis_src >= 0;};  //**Restriccion necesaria
    constraint source_addrs {dis_src< drvrs;};  //**Restriccion para asegurar que el paquete se dirige a un driver existente (necesaria)
    //Respecto al ID
    constraint valid_addrs {id < drvrs;};       //Restriccion asegura que la direccion pertenece a un driver
    constraint self_addrs {id != dis_src;};        //Restriccion que no permite a un id igual al del dispositivo
    //Respecto al DATO
    constraint data_variablility {dato inside {{(pckg_sz-8){1'b1}},{(pckg_sz-8){1'b0}}};};
    //Respecto al retardo
    constraint const_retardo {retardo <= max_retardo; retardo>0;}

  
    function new (bit [pckg_sz-9:0] dto=0, int ret=0, bit [7:0] ide=0, int src=0, int tmp=0, int mxrto=10 );
        
        this.dato=dto;
        this.retardo=ret;
        this.id=ide;
        this.dis_src=src;
        this.tiempo=tmp;
        this.max_retardo=mxrto;
        
    endfunction;

    function void print(string tag = "");
    $display("[%g] %s Tiempo de envio=%g Retardo=%g Fuente=0x%h dato=0x%h ",
             $time,
             tag,
             tiempo,
             this.retardo,
             this.dis_src,
             this.dato,
             )
  endfunction
endclass

class agnt_sb_chk #(parameter pckg_sz = 16);

  bit [pckg_sz-9:0] dato;
  bit [7:0] id ;
  int tiempo_trc;
  int dis_src;
  
  function new(bit [pckg_sz-1:0] info,bit [7:0] destino,int tiempo,int source);
    this.dato= info;
    this.id = destino;
    this.tiempo_trc = tiempo;
    this.dis_src = source;
  endfunction
  
  function void display();
    $display("El dato: %b se envió, en el tiempo %g", this.dato, this.tiempo_trc);
  endfunction

endclass

class mnt_chk_sb ;
  int id;
  int dato
  int dato_rec;
  int tiempo;
  function new (int dto_rdo);
	  this.dato_rec = dto_rdo;
	  this.tiempo = $time;
  endfunction;
endclass

class gen_agnt;
  int cant_datos;
  int dato_modo;        
  int id_modo;
  int id;
  int dis_src;
  function new ();
  endfunction;
endclass

class tst_chk_sb;
  int test;
  int drvrs;
  int pckg_sz;
  int fifo_size;
  function new ();
  endfunction;
endclass

class gen_chk_sb;
  int cant_datos;
  function new ();
  endfunction;
endclass


class tst_gen;
  int caso;
  int id;
  int dis_src;
  function new ();
  endfunction;
endclass


//Mailboxes
typedef mailbox #(agnt_chk_sb) agnt_chk_sb_mbx ;
typedef mailbox #(agnt_drv) agnt_drv_mbx ;
typedef mailbox #(gen_agnt) gen_agnt_mbx ;
typedef mailbox #(mnt_chk_sb) mnt_chk_sb_mbx;
typedef mailbox #(tst_gen) tst_gen_mbx;
typedef mailbox #(tst_chk_sb) tst_chk_sb_mbx;
typedef mailbox #(gen_chk_sb) gen_chk_sb_mbx;

class Generador #(parameter drvrs = 4, parameter pckg_sz = 16);

    tst_gen_mbx          tst_gen_mbx;
    tst_gen             tst_gen_transaction;

    gen_agnt_mbx        gen_agnt_mbx;
    gen_agnt            gen_agnt_transaction;

    function new();
    
        this.gen_agnt_transaction = new();
        this.tst_gen_transaction = new();

    endfunction

    task run();
        forever begin
            tst_gen_mbx.get(tst_gen_transaction);
            $display("Generador: Transaccion recibida de TEST recibida en %d", $time);
            case(this.tst_gen_transaction.tipo_gen)
                normal:begin
                    this.gen_agnt_transaction.tipo_data         = max_aleatoriedad;
                    this.gen_agnt_transaction.cant_datos         = 35;
                    this.gen_agnt_transaction.tipo_id           = normal_id;
                    this.gen_agnt_transaction.id_rand           = 1;
                    this.gen_agnt_transaction.id                = tst_gen_transaction.id;
                    this.gen_agnt_transaction.dis_src_rand       = 1;
                    this.gen_agnt_transaction.dis_src            = tst_gen_transaction.dis_src;
                    gen_agnt_mbx.put(gen_agnt_transaction);
                    
                end
               broadcast:begin
                    this.gen_agnt_transaction.tipo_data         = max_aleatoriedad;
                    this.gen_agnt_transaction.cant_datos         = 5;
                    this.gen_agnt_transaction.tipo_id           = normal_id;
                    this.gen_agnt_transaction.id_rand           = 0;
                    this.gen_agnt_transaction.id                = {8{1'b1}};
                    this.gen_agnt_transaction.dis_src_rand       = 1;
                    this.gen_agnt_transaction.dis_src            = tst_gen_transaction.dis_src;
                    gen_agnt_mbx.put(gen_agnt_transaction);
                    
                end
                one_to_all:begin
                    this.gen_agnt_transaction.tipo_data         = max_aleatoriedad;
                    this.gen_agnt_transaction.cant_datos         = 40;
                    this.gen_agnt_transaction.tipo_id           = fix_source;
                    this.gen_agnt_transaction.id_rand           = 1;
                    this.gen_agnt_transaction.id                = tst_gen_transaction.id;
                    this.gen_agnt_transaction.dis_src_rand       = 0;
                    this.gen_agnt_transaction.dis_src            = tst_gen_transaction.dis_src;
                    gen_agnt_mbx.put(gen_agnt_transaction);
                    
                end
                all_to_one:begin
                    this.gen_agnt_transaction.tipo_data         = max_aleatoriedad;
                    this.gen_agnt_transaction.cant_datos         = 30;
                    this.gen_agnt_transaction.tipo_id           = fix_source;
                    this.gen_agnt_transaction.id_rand           = 0;
                    this.gen_agnt_transaction.id                = tst_gen_transaction.id;
                    this.gen_agnt_transaction.dis_src_rand       = 1;
                    this.gen_agnt_transaction.dis_src            = tst_gen_transaction.dis_src;
                    gen_agnt_mbx.put(gen_agnt_transaction);
                    
                end
                
                default:begin
                    this.gen_agnt_transaction.cant_datos         = 10;;
                end
            endcase
        end
    endtask
endclass

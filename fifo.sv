class fifo_gen #(parameter fifo_size = 8, parameter drvrs = 4, parameter pckg_sz = 16);

    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz)) v_if;
    int fifo_num;
    bit [packagesize-1:0] d_q[$];

    function new(int fifo_num);
        d_q= {}
        this.fifo_num=fifo_num;
        
    endfunction 

endclass 
class Driver_Monitor #(parameter drvrs = 4, parameter pckg_sz = 16, parameter num_pckg = 8);

    virtual bus_if #(.drvrs(drvrs), .pckg_sz(pckg_sz))   bus_intf;

    agnt_drvr_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz))       agnt_drvr_mbx;
    agnt_drvr_transaction #(.pckg_sz(pckg_sz), .drvrs(drvrs)) agnt_drvr_transaction;

    bit [pckg_sz-1:0]                                        fifo_in[$];               //fifo de entrada
    int                                                      drvr_num;

    function new (int drvr_num);
        this.drvr_num = drvr_num;
        $display("Driver %d inicializado", this.drvr_num);
        this.agnt_drvr_transaction = new();
        this.agnt_drvr_mbx = new();
        fifo_in = {};
    endfunction

    virtual task run ();
        fork
            $display("Fifo %d entrada corriendo", this.drvr_num);
            forever begin
                if(this.fifo_in.size == 0) begin
                    this.bus_intf.pndng[0][this.drvr_num] = 0;
                    this.bus_intf.D_in[0][this.drvr_num] = 0;
                end
                else begin
                    this.bus_intf.pndng[0][this.drvr_num] = 1;
                    this.bus_intf.D_in[0][this.drvr_num] = this.fifo_in[0];
                end

                @(posedge this.bus_intf.pop[0][this.drvr_num]);
                this.fifo_in.delete(0);
            end
        join_none

        forever begin
            this.agnt_drvr_mbx.get(agnt_drvr_transaction);
            $display("Driver %d: Trasancción recibida", this.drvr_num);
            while(this.fifo_in.size >= num_pckg) #5;
            this.fifo_in.push_back({this.agnt_drvr_transaction.id, this.agnt_drvr_transaction.data});
            this.bus_intf.D_in[0][this.drvr_num] = this.fifo_in[0];
            this.bus_intf.pndng[0][this.drvr_num] = 1;
        end
    endtask
endclass
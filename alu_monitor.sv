class alu_monitor;
/*monitor do the following 
    1.Read DUT/Inteface signals
    2.Store them in transaction
    3.Send transaction to scoreboard
*/
    virtual alu_if vif; //handle for real interface
    //monitor has a reference to the real alu_if instance created in tb_top


    mailbox #(alu_transaction) mon2scb; //monitor to scoreboard mailbox
    //monitor put inside observed transactions

    //constructor new  
    //called from enviroment when it makes mon=new(vif,mon2scb);
    //it takes 2 values 1.virtual interface handle, 2.mailbox connected to scoreboard 
    function new(virtual alu_if vif, mailbox #(alu_transaction) mon2scb);

        this.vif     = vif; //store virtual interface inside monitor (so monitor can read signals using vif.A,..etc)
        this.mon2scb = mon2scb;//store mailbox inside monitor so monitor can send trans. to scoreboard

    endfunction


    task run(int count); //takes parameter count, no.of transactions that monitor will observe

        alu_transaction tr;  //transaction variables
        //new transaction based on readings from interface
        
        repeat (count) begin

            //wait on +ve edge because the design output happens at posedge clk 
            //normally, we will monitor @posedge to see new output
            @(posedge vif.clk);
            #1ps;//delay after positive edge to avoid race condition
             //at same positive edge DUT updates C output using non-blocking assignment
             //so if monitor read the C at same clock, may read the old value
             //so we will wait for 1 picosecond after clock edge and then read

            tr = new(); //new object of alu_transaction
            //read the signal from interface and put it inside the transaction
            tr.A      = vif.A;
            tr.B      = vif.B;
            tr.ALU_en = vif.ALU_en;
            tr.a_en   = vif.a_en;
            tr.a_op   = vif.a_op;
            tr.b_en   = vif.b_en;
            tr.b_op   = vif.b_op;
            
            // read output from DUT and store it inside actual
            //actual = real value output from DUT
            //scoreboard compares actual vs expected
            tr.actual = vif.C;

            //send the transactions to scoreboard
            mon2scb.put(tr);

        end

    endtask

endclass
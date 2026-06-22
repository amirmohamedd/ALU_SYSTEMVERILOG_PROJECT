class alu_driver;
//takes transactions from generator and drive transactions values to the interface

   
    //real interface on alu_if and it is made in tb_top (alu_if alu_vif(clk));

    //virtual interface as driver class is not module and thus we can't instantiate from interface  
    virtual alu_if vif; //vif inside driver points to alu_vif  which is inside top
    //and from this we can write vif.A <= tr.A;

    //mailbox between generator to driver 
    mailbox #(alu_transaction) gen2drv;
    //generator makes gen2drv.put(tr); while driver makes gen2drv.get(tr);


    //constructor is called when env makes -> drv=new(vif, ge2drv);
    //gives driver 2 things 1.virtual interface handle, mailbox connected with generator
    function new(virtual alu_if vif, mailbox #(alu_transaction) gen2drv);
        //this.sth means argument inside the constructor
        this.vif     = vif; //store virtual interface which comes from env inside driver
        this.gen2drv = gen2drv;

    endfunction


    //task for making reset for DUT from the beggining of the simulation
    //driver is resposible for it bec driver is responsible for driving signals to DUT
    
    task reset();

        vif.A      <= '0;
        vif.B      <= '0;
        vif.a_en   <= 1'b0;
        vif.a_op   <= '0;
        vif.b_en   <= 1'b0;
        vif.b_op   <= '0;
        vif.ALU_en <= 1'b0;

        vif.rst_n  <= 1'b1; //initially inactive
        
        @(posedge vif.clk); //wait till one rising edge of clock

        vif.rst_n  <= 1'b0; //reset active means design C<=0
        repeat (3) @(posedge vif.clk); //make  reset active for 3 cycles
        // not specifed no. as 3, but to make sure that design is in reset mode and assertions and coverage see reset asserted
        
        vif.rst_n  <= 1'b1;// then release reset
        
        @(posedge vif.clk);//wait one clock cylce after releasing reset 
        //bec to give the design opportunity to be stable before driving transactions

    endtask


    task run(int count); //task run of driver, takes input count
    //count is the number of transactions that driver receives 
        /*in enviroment 
          test_count= directed_count + random_count;
          and then drv.run (test_count); 
          driver will know what he will receive exactly  */
        
        alu_transaction tr; //transaction handle

        repeat (count) begin

            gen2drv.get(tr); //receive transactions from generator
            //this means, take transactions from gen2drv mailbox and put it in tr
           
           //we will use negative edge because DUT reads and output happens @posedge
           
           /*this means:
           1.driver drives at negedge
           2.DUT samples/calculates @posedge
           3.monitor samples after posedge
           */
            @(negedge vif.clk);
            //put the value of tr on real signal that is inside interface
            vif.A      <= tr.A;
            vif.B      <= tr.B;
            vif.ALU_en <= tr.ALU_en;
            vif.a_en   <= tr.a_en;
            vif.a_op   <= tr.a_op;
            vif.b_en   <= tr.b_en;
            vif.b_op   <= tr.b_op;

        end

    endtask

endclass
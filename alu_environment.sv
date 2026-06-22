class alu_environment;
    /*enviroment do these things:
    1.Build components 
    2.connect components
    3.Run components
    */

    //so it created generator, driver, monitor and scoreboard and connect them by mailboxes and vif
    //then run them all with each other
    
    virtual alu_if vif; //handle for real interface
    //it need to handle reference to send it to driver and monitor
    //so it receive interface from tb_top and then gives it to the components that need it

    mailbox #(alu_transaction) gen2drv; //mailbox between generator to driver
    mailbox #(alu_transaction) mon2scb; //mailbox between monitor to scoreboard

    //component handles
    alu_generator  gen;
    alu_driver     drv;
    alu_monitor    mon;
    alu_scoreboard scb;

    //counters
    int random_count; //generator will make 100 random tests
    int directed_count; //generator will ake 18 directed tests
    int test_count; //total = random + directed


    //constructor
    //almost called from tb_top as env=new(alu_vif,100);

    function new(virtual alu_if vif, int random_count = 100);

        this.vif          = vif; //store interface hand inside env
        this.random_count = random_count; //store random tests inside env


        directed_count = 18; //same as send_directed() in generator
        test_count     = random_count + directed_count;

        gen2drv = new(); //mailbox object
        mon2scb = new(); //mailbox object

        gen = new(gen2drv, random_count); 
        drv = new(vif, gen2drv);
        mon = new(vif, mon2scb);
        scb = new(mon2scb);

    endfunction


    task run();
        //firstly, call reset task of driver
        //bec before start test, DUT must be in a known state
        drv.reset();

        fork
            gen.run();
            drv.run(test_count);
            mon.run(test_count);
            scb.run(test_count);
        join
        
        //after finished all components
        //env take a look on no.of failures in scoreboard
        if (scb.fail_count != 0) begin
            $fatal(1, "ALU test failed, fail_count = %0d", scb.fail_count);
        end

    endtask

endclass
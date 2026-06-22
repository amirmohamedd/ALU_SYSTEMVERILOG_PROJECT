class alu_generator;
    // we will create ALU transaction 
    // Send them to the driver 

    //mailbox generator to driver
    //generator will put inside the transaction
    //& the driver will take the transaction from this mailbox
    mailbox #(alu_transaction) gen2drv;


    int random_count;// integer to calculate the nu,ber of random trans.


    //constructor new (called whenever we make object from generator)
    function new(mailbox #(alu_transaction) gen2drv, int random_count = 100);
    //constructor take 2 i/p which are mailbox gen2dr and random_count
        this.gen2drv      = gen2drv;
        //store mailbox that comes from env inside generator
        this.random_count = random_count;

    endfunction


    //task for specific test cases manually
    task send_directed(
        logic signed [4:0] A,
        logic signed [4:0] B,
        logic              ALU_en,
        logic              a_en,
        logic        [2:0] a_op,
        logic              b_en,
        logic        [1:0] b_op
    );

        alu_transaction tr;  // handle tr

        tr = new(); // transaction object

        //put argument A in field A inside transaction
        tr.A      = A;
        //same as previous one
        tr.B      = B;
        tr.ALU_en = ALU_en;
        tr.a_en   = a_en;
        tr.a_op   = a_op;
        tr.b_en   = b_en;
        tr.b_op   = b_op;

        //put this transaction into gen2drv mailbox
        gen2drv.put(tr);
        //after this the driver will take this transaction (gen2drv.get(tr))
        //take same transaction and start to drive signals
    endtask


    //when enviroment makes gen.run() then generator starts 
    //run will make 2 things, 1.send directed test, 2.send random test
    task run();

        alu_transaction tr;//transaction handle will use it in random_tests

        // A enable only
        //ALU_en=1, a_en=1, b_en=0
        send_directed(5'sd7,     5'sd3,     1'b1, 1'b1, 3'd0, 1'b0, 2'd0);
        send_directed(5'sd7,     5'sd3,     1'b1, 1'b1, 3'd1, 1'b0, 2'd0);
        send_directed(5'sd10,    5'sd5,     1'b1, 1'b1, 3'd2, 1'b0, 2'd0);
        send_directed(-5'sd4,    5'sd6,     1'b1, 1'b1, 3'd3, 1'b0, 2'd0);
        send_directed(-5'sd4,    5'sd6,     1'b1, 1'b1, 3'd4, 1'b0, 2'd0);
        send_directed(5'sd8,     5'sd2,     1'b1, 1'b1, 3'd5, 1'b0, 2'd0);
        send_directed(5'sd8,     5'sd2,     1'b1, 1'b1, 3'd6, 1'b0, 2'd0);

        // signed boundaries
        send_directed(5'sb10000, 5'sd0,     1'b1, 1'b1, 3'd0, 1'b0, 2'd0);//-16+0=-16 expected
        send_directed(5'sd0,     5'sb10000, 1'b1, 1'b1, 3'd0, 1'b0, 2'd0);


        // B enable only
        //ALU_en=1, a_en=0, b_en=1
        send_directed(5'sd7,     5'sd3,     1'b1, 1'b0, 3'd0, 1'b1, 2'd0);
        send_directed(5'sd7,     5'sd3,     1'b1, 1'b0, 3'd0, 1'b1, 2'd1);
        send_directed(-5'sd5,    5'sd4,     1'b1, 1'b0, 3'd0, 1'b1, 2'd2);


        // both enables
        //ALU_en=1, a_en=1, b_en=1
        send_directed(5'sd10,    5'sd5,     1'b1, 1'b1, 3'd0, 1'b1, 2'd0);
        send_directed(5'sd10,    5'sd5,     1'b1, 1'b1, 3'd0, 1'b1, 2'd1);
        send_directed(-5'sd8,    5'sd0,     1'b1, 1'b1, 3'd0, 1'b1, 2'd2);
        send_directed(5'sd0,    -5'sd3,     1'b1, 1'b1, 3'd0, 1'b1, 2'd3);


        // disabled and no operation
        //ALU disabled  
        send_directed(5'sd7,     5'sd3,     1'b0, 1'b1, 3'd0, 1'b0, 2'd0);
        // No operation is selected
        send_directed(5'sd7,     5'sd3,     1'b1, 1'b0, 3'd0, 1'b0, 2'd0);


        //Random testing
        repeat (random_count) begin

            tr = new(); //new transaction

            //randomization for field of rand in alu_transactions but with respect to constraints
            if (!tr.randomize()) begin
                $fatal(1, "Randomization failed"); //if randomization failed simulation stops
                //$fatal is stronger than error means simulation has a big problem so stop it
            end
            // if randomization successed then send this transaction to driver
            gen2drv.put(tr);

        end

    endtask

endclass
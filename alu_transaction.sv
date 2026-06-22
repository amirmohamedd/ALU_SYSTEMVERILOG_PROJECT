class alu_transaction;
    //transaction is the data transfered between blocks
    //rand variable to use randomization 
    rand logic signed [4:0] A;
    rand logic signed [4:0] B;

    rand logic              ALU_en;
    rand logic              a_en;
    rand logic        [2:0] a_op;
    rand logic              b_en;
    rand logic        [1:0] b_op;

    //store actual output from DUT 
    //monitor will fill it as (tr.actual = vif.C)
    logic signed [5:0] actual;
    //Store  expected from specs from Scoreboard Calculation
    //tr.expected = golden_model (tr);
    logic signed [5:0] expected;
    //then make comparison between actual and expected 


    //constraint for inputs A and B ranges  
    constraint input_range_c {
        A inside {[-16:15]};
        B inside {[-16:15]};
    }

    //constraint on ALU_en 
    constraint enable_c {
        ALU_en dist {1 := 9, 0 := 1}; //distribution 
        //ALU_en =1 weight 9, 90% enabled
        //ALU_en =0 weight 1, 10% disabled
    }

    //constraint for prevernting illegal opcodes in random tests
    constraint legal_opcode_c {

        if (ALU_en && a_en && !b_en)
        //if ALU enabled and a_en=1 and b_en=0 (A-only mode)
            a_op inside {[3'd0:3'd6]}; //a_op inside from 0 to 6 and prevent 7

        if (ALU_en && !a_en && b_en)
        //if ALU enabled and a_en=0 and b_en=1 (B-only mode)
            b_op inside {[2'd0:2'd2]}; //a_op inside from 0 to 2 and prevent 3

    }

    //Constructor new
    function new();

        A        = 0;
        B        = 0;
        ALU_en   = 0;
        a_en     = 0;
        a_op     = 0;
        b_en     = 0;
        b_op     = 0;
        actual   = 0;
        expected = 0;

    endfunction


    //function to return string 
    //we will use it for debugging and display
    function string to_string();

        return $sformatf("A=%0d B=%0d ALU_en=%0b a_en=%0b a_op=%0d b_en=%0b b_op=%0d expected=%0d actual=%0d",
                         A, B, ALU_en, a_en, a_op, b_en, b_op, expected, actual);

    endfunction

endclass
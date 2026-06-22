`timescale 1ns/1ps

interface alu_if(input logic clk);

    //signals
    logic signed [4:0] A;
    logic signed [4:0] B;
    logic              a_en;
    logic        [2:0] a_op;
    logic              b_en;
    logic        [1:0] b_op;
    logic              rst_n;
    logic              ALU_en;
    logic signed [5:0] C;

    //dut modport
    
    modport dut (
        input  A,
        input  B,
        input  a_en,
        input  a_op,
        input  b_en,
        input  b_op,
        input  rst_n,
        input  clk,
        input  ALU_en,
        output C
    );

     
      
//==============================Assertions==============================
    
    property reset_p;
        @(posedge clk)
        //if reset(Asynchronous) is active then C must equal to zero @(+vedge)
        (!rst_n) |-> (C == '0); //using overlapped implication (happens at same time)
    endproperty


    assert property (reset_p)
    else $error("ASSERT FAIL: Reset active but C != 0");


    //property for ALU disable
    property alu_disable_p;
        @(posedge clk)
        //if reset is active, stop checking this property
        disable iff (!rst_n)
        //non-overlapped implication
        (!ALU_en) |=> (C == '0); //if ALU_en=0, next cycle C=0
    endproperty

    assert property (alu_disable_p)
    else $error("ASSERT FAIL: ALU_en is low but C did not become 0");


    //illegal property for a_op
    property illegal_aop_p;
        @(posedge clk)
        disable iff (!rst_n)
        //if ALU_en is 1 (enabled) and mode is a only then a_op can't be 7
        //because specs says that a_op = 7 is Null/illegal in a_op mode
        (ALU_en && a_en && !b_en) |-> (a_op != 3'd7);
    endproperty

    assert property (illegal_aop_p)
    else $error("ASSERT FAIL: Illegal a_op = 7 detected in A-only mode");


    //illegal property for b_op
    property illegal_bop_p;
        @(posedge clk)
        disable iff (!rst_n)
        //if ALU_en is 1 (enabled) and mode is b only then b_op can't be 3
        //because specs says that b_op = 3 is Null/illegal in b_op set 1 mode
        (ALU_en && !a_en && b_en) |-> (b_op != 2'd3);
    endproperty

    assert property (illegal_bop_p)
    else $error("ASSERT FAIL: Illegal b_op = 3 detected in B-only mode");


    //Output Range Property
    property range_p;
        @(posedge clk)
        disable iff (!rst_n)
        //output should be between -32 to +31 (signed 6-bits)
        (C inside {[-32:31]});
    endproperty
    //since this is signed 6-bits output 
    //normally the output is between the specified range
    //this is calll sanity check more than functionality check
    assert property (range_p)
    else $error("ASSERT FAIL: Output out of signed 6-bit range");


    //==============================Functional Coverage==============================
    //functional coverage, to ask whether the tests has covered the specified cases or not
    //@each clock cycle, see the signals and decide that the bins is covered or not
    covergroup alu_functional_cg @(posedge clk);

        option.per_instance = 1; //calculate coverage for each instance from covergroup
        //in our project we have one instance ( alu_cg )
       
       //coverpoint on reset
        cp_rst_n: coverpoint rst_n {
            bins asserted = {0}; //rst_n = 0 -> reset asserted
            bins released = {1}; //rst_n = 1 -> reset released
        }

       //coverpoint on ALU_en
       //do not take sample unless reset is not active
        cp_ALU_en: coverpoint ALU_en iff (rst_n) {
            bins disabled = {0}; //ALU_en = 0 -> disabled
            bins enabled  = {1}; //ALU_en = 1 -> enabled
        }

        //coverpoint on enable modes
        //concatenation between {a_en, b_en}
        cp_enable_mode: coverpoint {a_en, b_en} iff (rst_n && ALU_en) {
            bins none   = {2'b00};//a_en = 0, b_en = 0 -> 2'b00 (none)
            bins a_only = {2'b10};//a_en = 1, b_en = 0 -> 2'b00 (use a_op table)
            bins b_only = {2'b01};//a_en = 0, b_en = 1 -> 2'b00 (use b_op set1 table)
            bins both   = {2'b11};//a_en = 1, b_en = 1 -> 2'b00 (use b_op set2 table)
        }

        //coverpoint on a_op 
        //sample a_op only when -> rst_n=1, ALU_en=1, a_en=1, b_en=0
        cp_a_op_a_only: coverpoint a_op iff (rst_n && ALU_en && a_en && !b_en) {
            bins op0 = {3'd0};
            bins op1 = {3'd1};
            bins op2 = {3'd2};
            bins op3 = {3'd3};
            bins op4 = {3'd4};
            bins op5 = {3'd5};
            bins op6 = {3'd6};
            illegal_bins illegal_op7 = {3'd7};//illegal bin
        }

        //coverpoint on b_op 
        //sample a_op only when -> rst_n=1, ALU_en=1, a_en=0, b_en=1
        cp_b_op_b_only: coverpoint b_op iff (rst_n && ALU_en && !a_en && b_en) {
            bins op0 = {2'd0};
            bins op1 = {2'd1};
            bins op2 = {2'd2};
            illegal_bins illegal_op3 = {2'd3};//illegal bin
        }

        //coverpoint on b_op in both modes when (a_en=1, b_en=1)
        cp_b_op_both: coverpoint b_op iff (rst_n && ALU_en && a_en && b_en) {
            bins op0 = {2'd0};
            bins op1 = {2'd1};
            bins op2 = {2'd2};
            bins op3 = {2'd3};
        }

        //coverpoint for A if reset is released and ALU enabled
        cp_A_values: coverpoint A iff (rst_n && ALU_en) {
            bins min      = {-16}; //cover least   
            bins zero     = {0};   //cover zero
            bins max      = {15};  //cover max positive 
            bins negative = {[-15:-1]}; //cover negative value
            bins positive = {[1:14]};   //cover positive value
        }

        //coverpoint for B if reset is released and ALU enabled
        cp_B_values: coverpoint B iff (rst_n && ALU_en) {
            bins min      = {-16};
            bins zero     = {0};
            bins max      = {15};
            bins negative = {[-15:-1]};
            bins positive = {[1:14]};
        }

    endgroup

    //make instance from covergroup called alu_cg
    alu_functional_cg alu_cg = new();

endinterface
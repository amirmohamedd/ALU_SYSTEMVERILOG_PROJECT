//firstly, time_unit = 1ns, time_precision = 1ps
`timescale 1ns/1ps

module alu (
    //5-bits signed input A,B  [-16 to +15]
    input  logic signed [4:0] A,
    input  logic signed [4:0] B,
    //Enable signals for a_op operations
    input  logic              a_en,
    //3 bits defining a set of operations to be performed
    input  logic        [2:0] a_op,
    //Enable signals for a_op operations
    input  logic              b_en,
    //2 bits defining a set of operations to be performed
    input  logic        [1:0] b_op,
    //Asynchronous Active Low reset signal ( reset=0 -> reset active, reset=1 -> normal operation )
    input  logic              rst_n,
    //System input Clock Signal
    input  logic              clk,
    //The overall system Enable signal
    input  logic              ALU_en,
    //6-bits Signed output data [15+15=30, -16+ (-16)=-32] 
    output logic signed [5:0] C
);

    /*automatic function for extension 5-bit to 6-bits
    it takes 5-bits and retured signed 6-bits 
    We need this function because operations like 
    in_a ^ in_b,in_a & in_b,in_a | in_b ===> their output is 5bits 
    while the C output is signed 6-bits
    so we need signed extension
    */
    function automatic logic signed [5:0] ext5(input logic [4:0] value);
       //concatenations takes signed bit [4] and put it firstly
       //if value is +ve like value=5'b00101 (+5)
       //value[4]=0, {value[4],value} = 6'b000101

       //if value is -ve like value=5'b11100 (-4)
       //value[4]=1, {value[4],value}=6'b111100
 
        ext5 = $signed({value[4], value});
    endfunction


    //automatic function for calculation the result
    
   
    function automatic logic signed [5:0] calc_result(
       //inputs of the functions
        input logic signed [4:0] in_a,
        input logic signed [4:0] in_b,
        input logic              in_a_en,
        input logic        [2:0] in_a_op,
        input logic              in_b_en,
        input logic        [1:0] in_b_op,
        input logic              in_alu_en
    );

        //if ALU_en=0 then output=0
        if (!in_alu_en) begin
            calc_result = '0; //all bits are filled with zero
        end
        //Case1
        //if (a_en=1, b_en=0)
        //in this case we use a_op 
        else if (in_a_en && !in_b_en) begin
            case (in_a_op)
                3'd0: calc_result = in_a + in_b;
                3'd1: calc_result = in_a - in_b;
                3'd2: calc_result = ext5(in_a ^ in_b);//XOR     
                3'd3: calc_result = ext5(in_a & in_b);//AND
                3'd4: calc_result = ext5(in_a & in_b);//AND 
                3'd5: calc_result = ext5(in_a | in_b); //OR
                3'd6: calc_result = ext5(~(in_a ^ in_b)); //XNOR
                default: calc_result = '0; //Null,illegal (a_op)
            endcase
        end

        //Case2
        //if (a_en=0, b_en=1)
        //in this case we use b_op set 1
        else if (!in_a_en && in_b_en) begin
            case (in_b_op)
                2'd0: calc_result = ext5(~(in_a & in_b)); //Compilent of the input which is AND
                2'd1: calc_result = in_a + in_b;//addition
                2'd2: calc_result = in_a + in_b;//addition
                default: calc_result = '0;
            endcase
        end
        //Case3
        //if (a_en=1, b_en=1)
        //in this case we use b_op set 2
        else if (in_a_en && in_b_en) begin
            case (in_b_op)
                2'd0: calc_result = ext5(in_a ^ in_b);//XOR
                2'd1: calc_result = ext5(~(in_a ^ in_b));//XNOR
                2'd2: calc_result = in_a - 6'sd1;//A-(signed decimal 1)  
                2'd3: calc_result = in_b + 6'sd2;//B+2
             endcase
        end
        //Case4 
        //if (a_en=0, b_en=0)
        //expected output is 0
        else begin
            calc_result = '0;
        end
    endfunction

    //Sequential Block
    always_ff @(posedge clk or negedge rst_n) begin
        //Active-Low
        if (!rst_n) begin
            C <= '0;
        end
        else begin
            C <= calc_result(A, B, a_en, a_op, b_en, b_op, ALU_en);
        end
    end

endmodule

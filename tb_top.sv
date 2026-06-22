`timescale 1ns/1ps

module tb_top;

    /*combine 3 main things
    1.Clock 
    2.Interface 
    3.DUT + Enviroment
    */
    import alu_pkg::*; 

    logic clk;

    alu_if alu_vif(clk); //interface instance alu_vif and send clock to it 

   
    alu_environment env; //enviroment handle


    //DUT instantiation 
    alu dut (
        .A      (alu_vif.A), //port A in Dut is connect to Signal A inside interface
        .B      (alu_vif.B),
        .a_en   (alu_vif.a_en),
        .a_op   (alu_vif.a_op),
        .b_en   (alu_vif.b_en),
        .b_op   (alu_vif.b_op),
        .rst_n  (alu_vif.rst_n),
        .clk    (alu_vif.clk),
        .ALU_en (alu_vif.ALU_en),
        .C      (alu_vif.C)
    );


    //clock generator
    initial begin

        clk = 1'b0;
        forever #5 clk = ~clk;

    end


    initial begin

        env = new(alu_vif, 100); //create object from alu_enviroment
        //send 2 things 1.alu.vif which real interface instance 
        //this instance goes to env and env send it to driver and monitor as virtual interface
        //2.random counts =100
        $display("=======================================");
        $display("Starting ALU test");
        $display("=======================================");

        env.run();//start real test 
        /*inside enviroment 
        1.drv.reset()
        2.for generator,driver,monitor,scoreboard
        3.wait until all finish
        4.check fail_count*/

        $display("=======================================");
        $display("ALU test completed");
        $display("=======================================");

        $finish;

    end

endmodule
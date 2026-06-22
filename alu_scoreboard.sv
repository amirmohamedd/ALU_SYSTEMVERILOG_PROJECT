class alu_scoreboard;
 
     /*it does the following 
    1.Calculate expected output 
    2.Compare expected with actual DUT output
    3.Print Pass or Fail*/
    
    mailbox #(alu_transaction) mon2scb; //mailbox from monitor to scoreboard

    int pass_count; //count passed transactions
    int fail_count; //count failed transactions


    //constructor new
    // when enviroment call scoreboard, scb=new(mon2scb);
    //means that scoreboard will take mailbox that received from monitor
    function new(mailbox #(alu_transaction) mon2scb);

        this.mon2scb = mon2scb;//store mailbox inside scoreboard
        pass_count   = 0;
        fail_count   = 0;

    endfunction

    //function extension 5-bits to 6-bits signed value
    function automatic logic signed [5:0] ext5(input logic [4:0] value);

        ext5 = $signed({value[4], value});

    endfunction

    //function golden_model 
    //calculate output C as expected from specs
    //takes transactions tr
    //can see tr.A,tr.B,...till tr.b_op
    function automatic logic signed [5:0] golden_model(alu_transaction tr);

        if (!tr.ALU_en) begin
            //if ALU_en = 0 then expected output = 0
            golden_model = '0; 

        end
        else begin

            case ({tr.a_en, tr.b_en}) //Concatenation

                2'b10: begin
                    case (tr.a_op)
                        3'd0:    golden_model = tr.A + tr.B;
                        3'd1:    golden_model = tr.A - tr.B;
                        3'd2:    golden_model = ext5(tr.A ^ tr.B);
                        3'd3:    golden_model = ext5(tr.A & tr.B);
                        3'd4:    golden_model = ext5(tr.A & tr.B);
                        3'd5:    golden_model = ext5(tr.A | tr.B);
                        3'd6:    golden_model = ext5(~(tr.A ^ tr.B));
                        default: golden_model = '0;
                    endcase
                end

                2'b01: begin
                    case (tr.b_op)
                        2'd0:    golden_model = ext5(~(tr.A & tr.B));
                        2'd1:    golden_model = tr.A + tr.B;
                        2'd2:    golden_model = tr.A + tr.B;
                        default: golden_model = '0;
                    endcase
                end

                2'b11: begin
                    case (tr.b_op)
                        2'd0:    golden_model = ext5(tr.A ^ tr.B);
                        2'd1:    golden_model = ext5(~(tr.A ^ tr.B));
                        2'd2:    golden_model = tr.A - 6'sd1;
                        2'd3:    golden_model = tr.B + 6'sd2;
                        default: golden_model = '0;
                    endcase
                end
                //default enable mode if a_en=0, b_en=0 -> No operations selected
                //Mo operations selected
                default: begin
                    golden_model = '0;
                end

            endcase

        end

    endfunction


    task run(int count);
    //takes count, means no.of transactions from scoreboard is same test cases generator send and monitor observed 

        alu_transaction tr;  //transaction variable

        repeat (count) begin

            mon2scb.get(tr); //get observed transaction from monitor

            tr.expected = golden_model(tr); //calculate expected output
            // so here takes same transcation input/control signals
            // & send it to the golden_model

            if (tr.actual === tr.expected)  //comparison between expected and actual
            begin 
                pass_count++;
                $display("[SCB] PASS : %s", tr.to_string());
            end
            else begin
                fail_count++;
                $display("[SCB] FAIL : %s", tr.to_string());
            end

        end
        //after finishing call function report to print summary of results
        report();

    endtask


    function void report();

        $display("=======================================");
        $display("ALU SCOREBOARD REPORT");
        $display("PASS  : %0d", pass_count);
        $display("FAIL  : %0d", fail_count);
        $display("TOTAL : %0d", pass_count + fail_count);
        $display("=======================================");

    endfunction

endclass
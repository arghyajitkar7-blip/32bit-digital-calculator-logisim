`timescale 1ns/1ps

module tb_calculator_perfect_corrected;
    reg CLK;

    reg N0,N1,N2,N3,N4,N5,N6,N7,N8,N9;
    reg ADD,SUB,MUL,DIV,EQUAL,CLEAR;

    wire [3:0] D7,D6,D5,D4,D3,D2,D1,D0;

    CALCULATOR dut (
        .CLK(CLK),
        .N0(N0), .N1(N1), .N2(N2), .N3(N3), .N4(N4),
        .N5(N5), .N6(N6), .N7(N7), .N8(N8), .N9(N9),
        .ADD(ADD), .SUB(SUB), .MUL(MUL), .DIV(DIV),
        .EQUAL(EQUAL), .CLEAR(CLEAR),
        .D7(D7), .D6(D6), .D5(D5), .D4(D4),
        .D3(D3), .D2(D2), .D1(D1), .D0(D0)
    );

    always #5 CLK = ~CLK;

    task press_digit(input integer d);
        begin
            case (d)
                0: N0 = 1'b1;
                1: N1 = 1'b1;
                2: N2 = 1'b1;
                3: N3 = 1'b1;
                4: N4 = 1'b1;
                5: N5 = 1'b1;
                6: N6 = 1'b1;
                7: N7 = 1'b1;
                8: N8 = 1'b1;
                9: N9 = 1'b1;
            endcase
            @(posedge CLK);
            #1;
            N0=0; N1=0; N2=0; N3=0; N4=0;
            N5=0; N6=0; N7=0; N8=0; N9=0;
            @(posedge CLK);
        end
    endtask

    task press_add;
        begin
            ADD = 1'b1;
            @(posedge CLK);
            #1 ADD = 1'b0;
            @(posedge CLK);
        end
    endtask

    task press_sub;
        begin
            SUB = 1'b1;
            @(posedge CLK);
            #1 SUB = 1'b0;
            @(posedge CLK);
        end
    endtask

    task press_mul;
        begin
            MUL = 1'b1;
            @(posedge CLK);
            #1 MUL = 1'b0;
            @(posedge CLK);
        end
    endtask

    task press_div;
        begin
            DIV = 1'b1;
            @(posedge CLK);
            #1 DIV = 1'b0;
            @(posedge CLK);
        end
    endtask

    task press_equal;
        begin
            EQUAL = 1'b1;
            @(posedge CLK);
            #1 EQUAL = 1'b0;
            @(posedge CLK);
        end
    endtask

    task press_clear;
        begin
            CLEAR = 1'b1;
            @(posedge CLK);
            #1 CLEAR = 1'b0;
            @(posedge CLK);
        end
    endtask

    task show_display;
        begin
            $display("DISPLAY = %0d%0d%0d%0d%0d%0d%0d%0d",
                     D7,D6,D5,D4,D3,D2,D1,D0);
        end
    endtask

    initial begin
        CLK=0;
        N0=0; N1=0; N2=0; N3=0; N4=0;
        N5=0; N6=0; N7=0; N8=0; N9=0;
        ADD=0; SUB=0; MUL=0; DIV=0; EQUAL=0; CLEAR=0;

        // Reset.
        press_clear;

        // 123 + 456 = 579
        press_digit(1);
        press_digit(2);
        press_digit(3);
        press_add;
        press_digit(4);
        press_digit(5);
        press_digit(6);
        press_equal;
        #1 show_display;

        // 20 - 7 = 13
        press_clear;
        press_digit(2);
        press_digit(0);
        press_sub;
        press_digit(7);
        press_equal;
        #1 show_display;

        // 12 * 3 = 36
        press_clear;
        press_digit(1);
        press_digit(2);
        press_mul;
        press_digit(3);
        press_equal;
        #1 show_display;

        // 20 / 4 = 5
        press_clear;
        press_digit(2);
        press_digit(0);
        press_div;
        press_digit(4);
        press_equal;
        #1 show_display;

        $finish;
    end
endmodule

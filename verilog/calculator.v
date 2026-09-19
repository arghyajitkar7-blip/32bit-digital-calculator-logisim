`timescale 1ns/1ps

module DABLE (
    input  B_3, B_2, B_1, B_0,
    output O_3, O_2, O_1, O_0
);
    wire [3:0] b;
    wire [3:0] o;

    assign b = {B_3, B_2, B_1, B_0};
    assign o = (b >= 4'd5) ? (b + 4'd3) : b;
    assign {O_3, O_2, O_1, O_0} = o;
endmodule

module BCD_to_Binary (
    input  [3:0] D7, D6, D5, D4, D3, D2, D1, D0,
    output [31:0] BINARY_OUT_PUT
);
    assign BINARY_OUT_PUT =
          D7 * 32'd10000000
        + D6 * 32'd1000000
        + D5 * 32'd100000
        + D4 * 32'd10000
        + D3 * 32'd1000
        + D2 * 32'd100
        + D1 * 32'd10
        + D0;
endmodule


module digit_input (
    input CLK,
    input clear,
    input n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,
    output reg [3:0] D7,D6,D5,D4,D3,D2,D1,D0
);
    reg [9:0] previous_buttons;
    reg [3:0] digit;
    reg [3:0] digit_count;
    wire [9:0] buttons;

    assign buttons = {n9,n8,n7,n6,n5,n4,n3,n2,n1,n0};

    always @(*) begin
        digit = 4'd0;


        if      (n0) digit = 4'd0;
        else if (n1) digit = 4'd1;
        else if (n2) digit = 4'd2;
        else if (n3) digit = 4'd3;
        else if (n4) digit = 4'd4;
        else if (n5) digit = 4'd5;
        else if (n6) digit = 4'd6;
        else if (n7) digit = 4'd7;
        else if (n8) digit = 4'd8;
        else if (n9) digit = 4'd9;
    end

    always @(posedge CLK) begin
        if (clear) begin
            D7 <= 4'd0;
            D6 <= 4'd0;
            D5 <= 4'd0;
            D4 <= 4'd0;
            D3 <= 4'd0;
            D2 <= 4'd0;
            D1 <= 4'd0;
            D0 <= 4'd0;
            previous_buttons <= 10'd0;
            digit_count <= 4'd0;
        end
        else begin

            if ((buttons != 10'd0) && (previous_buttons == 10'd0)) begin
                if (digit_count < 4'd8) begin
                    D7 <= D6;
                    D6 <= D5;
                    D5 <= D4;
                    D4 <= D3;
                    D3 <= D2;
                    D2 <= D1;
                    D1 <= D0;
                    D0 <= digit;
                    digit_count <= digit_count + 4'd1;
                end
            end

            previous_buttons <= buttons;
        end
    end
endmodule


module DIGIT_BINARY_OUtput (
    input CLK,
    input n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,
    input clear,
    output [3:0] D7,D6,D5,D4,D3,D2,D1,D0,
    output [31:0] Binary_Out
);
    digit_input DIGITS (
        .CLK(CLK),
        .clear(clear),
        .n0(n0), .n1(n1), .n2(n2), .n3(n3), .n4(n4),
        .n5(n5), .n6(n6), .n7(n7), .n8(n8), .n9(n9),
        .D7(D7), .D6(D6), .D5(D5), .D4(D4),
        .D3(D3), .D2(D2), .D1(D1), .D0(D0)
    );

    BCD_to_Binary BCD_INPUT (
        .D7(D7), .D6(D6), .D5(D5), .D4(D4),
        .D3(D3), .D2(D2), .D1(D1), .D0(D0),
        .BINARY_OUT_PUT(Binary_Out)
    );
endmodule


module A_register (
    input CLK,
    input CLEAR_A,
    input LOAD_A,
    input [31:0] DATA_IN,
    output reg [31:0] A_OUT
);
    always @(posedge CLK) begin
        if (CLEAR_A)
            A_OUT <= 32'd0;
        else if (LOAD_A)
            A_OUT <= DATA_IN;
    end
endmodule


module B_register (
    input CLK,
    input CLEAR_B,
    input LOAD_B,
    input [31:0] DATA_IN,
    output reg [31:0] B_OUT
);
    always @(posedge CLK) begin
        if (CLEAR_B)
            B_OUT <= 32'd0;
        else if (LOAD_B)
            B_OUT <= DATA_IN;
    end
endmodule

module ALU_OP_COMMAND (
    input CLK,
    input ADD, SUB, MUL, DIV,
    input CLEAR,
    output reg [1:0] OP_OUTPUT
);
    always @(posedge CLK) begin
        if (CLEAR)
            OP_OUTPUT <= 2'b00;
        else if (ADD)
            OP_OUTPUT <= 2'b00;
        else if (SUB)
            OP_OUTPUT <= 2'b01;
        else if (MUL)
            OP_OUTPUT <= 2'b10;
        else if (DIV)
            OP_OUTPUT <= 2'b11;
    end
endmodule


module ALU (
    input  [31:0] A_input,
    input  [31:0] B_input,
    input  [1:0]  ALU_OP,
    output reg [31:0] RESULT,
    output reg CARRY,
    output reg OVERFLOW
);
    reg [32:0] temp;

    always @(*) begin
        RESULT   = 32'd0;
        CARRY    = 1'b0;
        OVERFLOW = 1'b0;
        temp     = 33'd0;

        case (ALU_OP)
            2'b00: begin // ADD
                temp = {1'b0, A_input} + {1'b0, B_input};
                RESULT = temp[31:0];
                CARRY = temp[32];
                OVERFLOW =
                    (~(A_input[31] ^ B_input[31])) &
                    (RESULT[31] ^ A_input[31]);
            end

            2'b01: begin // SUB
                RESULT = A_input - B_input;
                
                CARRY = (A_input >= B_input);
                OVERFLOW =
                    (A_input[31] ^ B_input[31]) &
                    (RESULT[31] ^ A_input[31]);
            end

            2'b10: begin 

                RESULT = A_input * B_input;
            end

            2'b11: begin // DIV
                if (B_input != 32'd0)
                    RESULT = A_input / B_input;
                else
                    RESULT = 32'd0;
            end

            default: begin
                RESULT = 32'd0;
            end
        endcase
    end
endmodule


module RESULT_REGISTER (
    input CLK,
    input LOAD_RESULT,
    input CLEAR_RESULT,
    input [31:0] DATA_IN,
    output reg [31:0] RESULT_OUT
);
    always @(posedge CLK) begin
        if (CLEAR_RESULT)
            RESULT_OUT <= 32'd0;
        else if (LOAD_RESULT)
            RESULT_OUT <= DATA_IN;
    end
endmodule


module DOUBLE_DABLE_BCD_TO_BINARY (
    input  [31:0] BINARY_IN,
    output [3:0] DIGIT_7,
    output [3:0] DIGIT_6,
    output [3:0] DIGIT_5,
    output [3:0] DIGIT_4,
    output [3:0] DIGIT_3,
    output [3:0] DIGIT_2,
    output [3:0] DIGIT_1,
    output [3:0] DIGIT_0
);
    wire [63:0] stage [0:32];

    assign stage[0] = {32'd0, BINARY_IN};

    genvar s;
    genvar d;

    generate
        for (s = 0; s < 32; s = s + 1) begin : DD_STAGE
            wire [63:0] corrected;

            
            assign corrected[31:0] = stage[s][31:0];

            for (d = 0; d < 8; d = d + 1) begin : DD_DABLE
                DABLE CORRECT_DIGIT (
                    .B_3(stage[s][32 + d*4 + 3]),
                    .B_2(stage[s][32 + d*4 + 2]),
                    .B_1(stage[s][32 + d*4 + 1]),
                    .B_0(stage[s][32 + d*4 + 0]),
                    .O_3(corrected[32 + d*4 + 3]),
                    .O_2(corrected[32 + d*4 + 2]),
                    .O_1(corrected[32 + d*4 + 1]),
                    .O_0(corrected[32 + d*4 + 0])
                );
            end

            assign stage[s + 1] = corrected << 1;
        end
    endgenerate

    assign DIGIT_7 = stage[32][63:60];
    assign DIGIT_6 = stage[32][59:56];
    assign DIGIT_5 = stage[32][55:52];
    assign DIGIT_4 = stage[32][51:48];
    assign DIGIT_3 = stage[32][47:44];
    assign DIGIT_2 = stage[32][43:40];
    assign DIGIT_1 = stage[32][39:36];
    assign DIGIT_0 = stage[32][35:32];
endmodule

module calculator_body (
    input CLK,

    input N_0,N_1,N_2,N_3,N_4,N_5,N_6,N_7,N_8,N_9,
    input ADD,SUB,MUL,DIV,EQUAL,clear,

    output [3:0] D_7,D_6,D_5,D_4,D_3,D_2,D_1,D_0
);
    localparam ST_IDLE    = 2'd0;
    localparam ST_ENTER_A = 2'd1;
    localparam ST_ENTER_B = 2'd2;
    localparam ST_DISPLAY = 2'd3;

    reg [1:0] state;
    reg [1:0] next_state;

    reg [9:0] previous_digits;
    reg [4:0] previous_controls;
    reg number_entered;

    wire [9:0] digit_buttons;
    wire [4:0] control_buttons;
    wire digit_pulse;
    wire op_pulse;
    wire equal_pulse;
    wire any_op;

    wire [31:0] input_value;
    wire [3:0] inD7,inD6,inD5,inD4,inD3,inD2,inD1,inD0;

    wire [31:0] A_OUT;
    wire [31:0] B_OUT;
    wire [31:0] ALU_RESULT;
    wire [31:0] RESULT_OUT;
    wire [1:0] OP_OUTPUT;

    wire [31:0] alu_B_input;
    wire input_clear;

    wire load_A;
    wire load_B;
    wire load_RESULT;

    wire clear_A;
    wire clear_B;
    wire clear_RESULT;

    wire [31:0] display_value;

    assign digit_buttons = {N_9,N_8,N_7,N_6,N_5,N_4,N_3,N_2,N_1,N_0};
    assign control_buttons = {EQUAL,DIV,MUL,SUB,ADD};
    assign any_op = ADD | SUB | MUL | DIV;

    // One-clock event pulses for calculator controls.
    assign digit_pulse = (digit_buttons != 10'd0) &&
                         (previous_digits == 10'd0);
    assign op_pulse    = any_op && (previous_controls[3:0] == 4'd0);
    assign equal_pulse = EQUAL && !previous_controls[4];

    assign input_clear = clear |
                         ((state == ST_ENTER_A) && op_pulse && number_entered) |
                         ((state == ST_ENTER_B) && equal_pulse && number_entered);

    assign load_A = (state == ST_ENTER_A) && op_pulse && number_entered;
    assign load_B = (state == ST_ENTER_B) && equal_pulse && number_entered;

    assign alu_B_input = ((state == ST_ENTER_B) && equal_pulse && number_entered)
                       ? input_value
                       : B_OUT;

    assign load_RESULT = (state == ST_ENTER_B) && equal_pulse && number_entered;

    assign clear_A      = clear;
    assign clear_B      = clear;
    assign clear_RESULT = clear;

    assign display_value = (state == ST_DISPLAY) ? RESULT_OUT : input_value;

    always @(posedge CLK) begin
        if (clear) begin
            previous_digits <= 10'd0;
            previous_controls <= 5'd0;
            number_entered <= 1'b0;
        end
        else begin
            previous_digits <= digit_buttons;
            previous_controls <= control_buttons;

            case (state)
                ST_IDLE: begin
                    if (digit_pulse)
                        number_entered <= 1'b1;
                end

                ST_ENTER_A: begin
                    if (digit_pulse)
                        number_entered <= 1'b1;
                    else if (op_pulse && number_entered)
                        number_entered <= 1'b0;
                end

                ST_ENTER_B: begin
                    if (digit_pulse)
                        number_entered <= 1'b1;
                    else if (equal_pulse && number_entered)
                        number_entered <= 1'b0;
                end

                ST_DISPLAY: begin
                    if (digit_pulse)
                        number_entered <= 1'b1;
                end

                default:
                    number_entered <= 1'b0;
            endcase
        end
    end

    always @(*) begin
        next_state = state;

        case (state)
            ST_IDLE: begin
                if (digit_pulse)
                    next_state = ST_ENTER_A;
            end

            ST_ENTER_A: begin
                if (op_pulse && number_entered)
                    next_state = ST_ENTER_B;
            end

            ST_ENTER_B: begin
                if (equal_pulse && number_entered)
                    next_state = ST_DISPLAY;
            end

            ST_DISPLAY: begin
                if (digit_pulse)
                    next_state = ST_ENTER_A;
            end

            default:
                next_state = ST_IDLE;
        endcase
    end

    always @(posedge CLK) begin
        if (clear)
            state <= ST_IDLE;
        else
            state <= next_state;
    end

    DIGIT_BINARY_OUtput INPUT_STAGE (
        .CLK(CLK),
        .n0(N_0), .n1(N_1), .n2(N_2), .n3(N_3), .n4(N_4),
        .n5(N_5), .n6(N_6), .n7(N_7), .n8(N_8), .n9(N_9),
        .clear(input_clear),
        .D7(inD7), .D6(inD6), .D5(inD5), .D4(inD4),
        .D3(inD3), .D2(inD2), .D1(inD1), .D0(inD0),
        .Binary_Out(input_value)
    );

    ALU_OP_COMMAND OP_COMMAND (
        .CLK(CLK),
        .ADD(ADD), .SUB(SUB), .MUL(MUL), .DIV(DIV),
        .CLEAR(clear),
        .OP_OUTPUT(OP_OUTPUT)
    );
    A_register A_REG (
        .CLK(CLK),
        .CLEAR_A(clear_A),
        .LOAD_A(load_A),
        .DATA_IN(input_value),
        .A_OUT(A_OUT)
    );

    B_register B_REG (
        .CLK(CLK),
        .CLEAR_B(clear_B),
        .LOAD_B(load_B),
        .DATA_IN(input_value),
        .B_OUT(B_OUT)
    );

    ALU ARITHMETIC_UNIT (
        .A_input(A_OUT),
        .B_input(alu_B_input),
        .ALU_OP(OP_OUTPUT),
        .RESULT(ALU_RESULT),
        .CARRY(),
        .OVERFLOW()
    );

    RESULT_REGISTER RESULT_REG (
        .CLK(CLK),
        .LOAD_RESULT(load_RESULT),
        .CLEAR_RESULT(clear_RESULT),
        .DATA_IN(ALU_RESULT),
        .RESULT_OUT(RESULT_OUT)
    );

    DOUBLE_DABLE_BCD_TO_BINARY DISPLAY_CONVERTER (
        .BINARY_IN(display_value),
        .DIGIT_7(D_7), .DIGIT_6(D_6), .DIGIT_5(D_5), .DIGIT_4(D_4),
        .DIGIT_3(D_3), .DIGIT_2(D_2), .DIGIT_1(D_1), .DIGIT_0(D_0)
    );
endmodule


module CALCULATOR (
    input CLK,

    input N0,N1,N2,N3,N4,N5,N6,N7,N8,N9,
    input ADD,SUB,MUL,DIV,EQUAL,CLEAR,

    output [3:0] D7,D6,D5,D4,D3,D2,D1,D0
);
    calculator_body BODY (
        .CLK(CLK),

        .N_0(N0), .N_1(N1), .N_2(N2), .N_3(N3), .N_4(N4),
        .N_5(N5), .N_6(N6), .N_7(N7), .N_8(N8), .N_9(N9),

        .ADD(ADD), .SUB(SUB), .MUL(MUL), .DIV(DIV),
        .EQUAL(EQUAL), .clear(CLEAR),

        .D_7(D7), .D_6(D6), .D_5(D5), .D_4(D4),
        .D_3(D3), .D_2(D2), .D_1(D1), .D_0(D0)
    );
endmodule

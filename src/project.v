`default_nettype none

module tt_um_bjarke_micro_mac (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    /* verilator lint_off UNUSEDSIGNAL */
    input  wire [7:0] uio_in,
    /* verilator lint_on UNUSEDSIGNAL */
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    localparam LOAD_A = 3'd0;
    localparam LOAD_B = 3'd1;
    localparam EXEC   = 3'd2;
    localparam OUT    = 3'd3;

    reg [2:0] state;
    reg [2:0] index;
    reg [2:0] product_index;
    reg signed [7:0] a0, a1, a2, a3;
    reg signed [7:0] b0, b1, b2, b3;
    reg signed [17:0] acc0, acc1, acc2, acc3;
    reg signed [7:0] c0, c1, c2, c3;
    reg signed [7:0] multiply_a, multiply_b;
    reg [7:0] output_value;
    reg signed [15:0] product;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    assign uo_out  = output_value;

    // Select one of the eight products so synthesis can share one multiplier.
    always @* begin
        multiply_a = 8'sd0;
        multiply_b = 8'sd0;
        case (product_index)
            3'd0: begin multiply_a = a0; multiply_b = b0; end
            3'd1: begin multiply_a = a1; multiply_b = b2; end
            3'd2: begin multiply_a = a0; multiply_b = b1; end
            3'd3: begin multiply_a = a1; multiply_b = b3; end
            3'd4: begin multiply_a = a2; multiply_b = b0; end
            3'd5: begin multiply_a = a3; multiply_b = b2; end
            3'd6: begin multiply_a = a2; multiply_b = b1; end
            3'd7: begin multiply_a = a3; multiply_b = b3; end
            default: begin end
        endcase
        product = multiply_a * multiply_b;
    end

    always @* begin
        output_value = 8'b0;
        if (state == OUT) begin
            case (index)
                3'd0: output_value = c0;
                3'd1: output_value = c1;
                3'd2: output_value = c2;
                3'd3: output_value = c3;
                default: output_value = 8'b0;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= LOAD_A;
            index <= 3'd0;
            product_index <= 3'd0;
            a0 <= 0; a1 <= 0; a2 <= 0; a3 <= 0;
            b0 <= 0; b1 <= 0; b2 <= 0; b3 <= 0;
            acc0 <= 0; acc1 <= 0; acc2 <= 0; acc3 <= 0;
            c0 <= 0; c1 <= 0; c2 <= 0; c3 <= 0;
        end else if (ena) begin
            case (state)
                LOAD_A: begin
                    case (index)
                        3'd0: a0 <= $signed(ui_in);
                        3'd1: a1 <= $signed(ui_in);
                        3'd2: a2 <= $signed(ui_in);
                        3'd3: a3 <= $signed(ui_in);
                        default: begin state <= LOAD_A; index <= 3'd0; end
                    endcase
                    if (index == 3'd3) begin
                        state <= LOAD_B;
                        index <= 3'd0;
                    end else if (index < 3'd3) begin
                        index <= index + 1'b1;
                    end
                end
                LOAD_B: begin
                    case (index)
                        3'd0: b0 <= $signed(ui_in);
                        3'd1: b1 <= $signed(ui_in);
                        3'd2: b2 <= $signed(ui_in);
                        3'd3: b3 <= $signed(ui_in);
                        default: begin state <= LOAD_A; index <= 3'd0; end
                    endcase
                    if (index == 3'd3) begin
                        state <= EXEC;
                        product_index <= 3'd0;
                        acc0 <= 0; acc1 <= 0; acc2 <= 0; acc3 <= 0;
                        index <= 3'd0;
                    end else if (index < 3'd3) begin
                        index <= index + 1'b1;
                    end
                end
                EXEC: begin
                    case (product_index)
                        3'd0: acc0 <= {{2{product[15]}}, product};
                        3'd1: c0 <= clamp(acc0 + {{2{product[15]}}, product});
                        3'd2: acc1 <= {{2{product[15]}}, product};
                        3'd3: c1 <= clamp(acc1 + {{2{product[15]}}, product});
                        3'd4: acc2 <= {{2{product[15]}}, product};
                        3'd5: c2 <= clamp(acc2 + {{2{product[15]}}, product});
                        3'd6: acc3 <= {{2{product[15]}}, product};
                        3'd7: begin
                            c3 <= clamp(acc3 + {{2{product[15]}}, product});
                            state <= OUT;
                            index <= 3'd0;
                        end
                        default: begin state <= LOAD_A; index <= 3'd0; end
                    endcase
                    if (product_index < 3'd7)
                        product_index <= product_index + 1'b1;
                end
                OUT: begin
                    if (index == 3'd3) begin
                        state <= LOAD_A;
                        index <= 3'd0;
                    end else if (index < 3'd3) begin
                        index <= index + 1'b1;
                    end
                end
                default: begin
                    state <= LOAD_A;
                    index <= 3'd0;
                end
            endcase
        end
    end

    function signed [7:0] clamp(input signed [17:0] value);
        begin
            if (value > 18'sd127)
                clamp = 8'sd127;
            else if (value < -18'sd128)
                clamp = -8'sd128;
            else
                clamp = value[7:0];
        end
    endfunction

endmodule

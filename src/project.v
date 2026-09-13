`default_nettype none

module tt_um_bjarke_micro_mac (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
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
    reg signed [7:0] a0, a1, a2, a3;
    reg signed [7:0] b0, b1, b2, b3;
    reg signed [7:0] c0, c1, c2, c3;
    reg [7:0] output_value;

    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;
    assign uo_out  = output_value;

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
            a0 <= 0; a1 <= 0; a2 <= 0; a3 <= 0;
            b0 <= 0; b1 <= 0; b2 <= 0; b3 <= 0;
            c0 <= 0; c1 <= 0; c2 <= 0; c3 <= 0;
        end else if (ena) begin
            case (state)
                LOAD_A: begin
                    case (index)
                        3'd0: a0 <= $signed(ui_in);
                        3'd1: a1 <= $signed(ui_in);
                        3'd2: a2 <= $signed(ui_in);
                        3'd3: a3 <= $signed(ui_in);
                    endcase
                    if (index == 3'd3) begin
                        state <= LOAD_B;
                        index <= 3'd0;
                    end else begin
                        index <= index + 1'b1;
                    end
                end
                LOAD_B: begin
                    case (index)
                        3'd0: b0 <= $signed(ui_in);
                        3'd1: b1 <= $signed(ui_in);
                        3'd2: b2 <= $signed(ui_in);
                        3'd3: b3 <= $signed(ui_in);
                    endcase
                    if (index == 3'd3) begin
                        state <= EXEC;
                        index <= 3'd0;
                    end else begin
                        index <= index + 1'b1;
                    end
                end
                EXEC: begin
                    c0 <= clamp(multiply(a0, b0) + multiply(a1, b2));
                    c1 <= clamp(multiply(a0, b1) + multiply(a1, b3));
                    c2 <= clamp(multiply(a2, b0) + multiply(a3, b2));
                    c3 <= clamp(multiply(a2, b1) + multiply(a3, b3));
                    state <= OUT;
                    index <= 3'd0;
                end
                OUT: begin
                    if (index == 3'd3) begin
                        state <= LOAD_A;
                        index <= 3'd0;
                    end else begin
                        index <= index + 1'b1;
                    end
                end
            endcase
        end
    end

    function signed [17:0] multiply(input signed [7:0] a, input signed [7:0] b);
        reg signed [15:0] product;
        begin
            product = a * b;
            multiply = {{2{product[15]}}, product};
        end
    endfunction

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

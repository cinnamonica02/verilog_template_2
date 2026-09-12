`default_nettype none

module tt_um_bjarke_micro_mac (
    input  wire [7:0] ui_in,    // Input sample stream
    output wire [7:0] uo_out,   // Saturating INT8 computed alert/output
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    assign uio_oe  = 8'b0;
    assign uio_out = 8'b0;

    // Static Weight Registers
    wire signed [7:0] W [0:3];
    assign W[0] = 8'sd12;
    assign W[1] = -8'sd45;
    assign W[2] = 8'sd88;
    assign W[3] = -8'sd20;

    // Execution Pipeline Registers
    reg [1:0]        step;
    reg signed [7:0] shift_reg [0:3];
    reg signed [7:0] acc;

    assign uo_out = acc;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            step         <= 2'd0;
            acc          <= 8'sd0;
            shift_reg[0] <= 8'sd0; shift_reg[1] <= 8'sd0;
            shift_reg[2] <= 8'sd0; shift_reg[3] <= 8'sd0;
        end else if (ena) begin
            shift_reg[0] <= $signed(ui_in);
            shift_reg[1] <= shift_reg[0];
            shift_reg[2] <= shift_reg[1];
            shift_reg[3] <= shift_reg[2];

            case (step)
                2'd0: begin
                    acc  <= clamp($signed(ui_in) * W[0]);
                    step <= 2'd1;
                end
                2'd1: begin
                    acc  <= clamp(acc + (shift_reg[1] * W[1]));
                    step <= 2'd2;
                end
                2'd2: begin
                    acc  <= clamp(acc + (shift_reg[2] * W[2]));
                    step <= 2'd3;
                end
                2'd3: begin
                    acc  <= clamp(acc + (shift_reg[3] * W[3]));
                    step <= 2'd0;
                end
            endcase
        end
    end

    // Saturation Logic Function
    function signed [7:0] clamp(input signed [15:0] val);
        begin
            if (val > 16'sd127)
                clamp = 8'sd127;
            else if (val < -16'sd128)
                clamp = -8'sd128;
            else
                clamp = val[7:0];
        end
    endfunction

endmodule

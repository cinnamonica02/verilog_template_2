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

    // One four-sample frame is accumulated over four enabled clock cycles.
    reg [1:0]         step;
    reg signed [17:0] acc;

    assign uo_out = acc[7:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            step         <= 2'd0;
            acc          <= 18'sd0;
        end else if (ena) begin
            case (step)
                2'd0: begin
                    acc  <= multiply($signed(ui_in), W[0]);
                    step <= 2'd1;
                end
                2'd1: begin
                    acc  <= acc + multiply($signed(ui_in), W[1]);
                    step <= 2'd2;
                end
                2'd2: begin
                    acc  <= acc + multiply($signed(ui_in), W[2]);
                    step <= 2'd3;
                end
                2'd3: begin
                    acc  <= clamp(acc + multiply($signed(ui_in), W[3]));
                    step <= 2'd0;
                end
            endcase
        end
    end

    function signed [17:0] multiply(input signed [7:0] a, input signed [7:0] b);
        reg signed [15:0] product;
        begin
            product = a * b;
            multiply = product;
        end
    endfunction

    // Saturation Logic Function
    function signed [17:0] clamp(input signed [17:0] val);
        begin
            if (val > 18'sd127)
                clamp = 18'sd127;
            else if (val < -18'sd128)
                clamp = -18'sd128;
            else
                clamp = val;
        end
    endfunction

endmodule

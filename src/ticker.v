module ticker#(
    parameter COUNT_MAX = 12500000
) (
    input wire  clk,
    input wire  rst_n,
    output reg tick
);
    localparam WIDTH = $clog2(COUNT_MAX);
    reg [WIDTH-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            count <= {WIDTH{1'b0}};
            tick <= 1'b0;
        end else if (count >= COUNT_MAX - 1) begin
            count <= {WIDTH{1'b0}};
            tick <= 1'b1;
        end else begin
            count <= count + 1;
            tick <= 1'b0;
        end
    end
endmodule
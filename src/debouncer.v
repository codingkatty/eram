module debouncer #(
    parameter CLK_FREQ = 25_000_000,    // Clock frequency in Hz
    parameter DEBOUNCE_TIME_MS = 20     // Debounce time in milliseconds
)(
    input wire clk,           // System clock
    input wire rst_n,         // Active low reset
    input wire [4:0] button_in,     // Raw button input (noisy)
    output wire [4:0] btn_released   // Debounced button output
);

    // Calculate counter value for debounce time
    localparam integer COUNTER_MAX_INT = (CLK_FREQ / 1000) * DEBOUNCE_TIME_MS;
    localparam COUNTER_WIDTH = $clog2(COUNTER_MAX_INT + 1);
    localparam [COUNTER_WIDTH-1:0] COUNTER_MAX = COUNTER_MAX_INT[COUNTER_WIDTH-1:0];

    // Internal registers
    reg [COUNTER_WIDTH-1:0] counter;
    reg [4:0] button_sync_0, button_sync_1;
    reg [4:0] button_debounced;

    // Double-flop synchronizer to avoid metastability
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            button_sync_0 <= 5'b11111;
            button_sync_1 <= 5'b11111;
        end else begin
            button_sync_0 <= button_in;
            button_sync_1 <= button_sync_0;
        end
    end

    // Debounce logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 0;
            button_debounced <= 5'b11111;
        end else begin
            if (button_sync_1 != button_debounced) begin
                // Input differs from output, start/continue counting
                counter <= counter + 1'b1;
                if (counter >= COUNTER_MAX) begin
                    button_debounced <= button_sync_1;
                    counter <= 0;
                end
            end else begin
                // Input matches output, reset counter
                counter <= 0;
            end
        end
    end

    reg [4:0] btn_prev;

    always @(posedge clk or negedge rst_n) begin
      if (!rst_n) begin
        btn_prev <= 5'b11111;
      end else begin
        btn_prev <= button_debounced;
      end
    end

    assign btn_released = button_debounced & ~btn_prev;
endmodule
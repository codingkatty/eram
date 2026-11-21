module sprite_renderer(
  input wire in_screen,
  input wire [3:0] grid_x,
  input wire [2:0] grid_y,
  input wire [2:0] local_x,
  input wire [2:0] local_y,
  input wire [3:0] sprite_x, 
  input wire [2:0] sprite_y, 
  input wire is_friend, 
  output wire [2:0] color
);
  reg [0:23] current_line;

  wire in_bounds = in_screen && (grid_x == sprite_x) && (grid_y == sprite_y);

  always @(*) begin
    if (!is_friend) begin
      case (local_y)
        3'd0: current_line = 24'b000_001_001_001_001_001_001_000;
        3'd1: current_line = 24'b001_001_001_001_001_001_001_001;
        3'd2: current_line = 24'b001_001_010_010_001_001_001_001;
        3'd3: current_line = 24'b001_011_011_011_011_001_011_001;
        3'd4: current_line = 24'b001_011_011_011_011_011_011_001;
        3'd5: current_line = 24'b010_010_010_100_100_100_100_010;
        3'd6: current_line = 24'b011_011_010_010_010_010_011_011;
        3'd7: current_line = 24'b000_001_001_001_010_001_001_000;
      endcase
    end else begin
      case (local_y)
        3'd0: current_line = 24'b001_001_010_010_010_010_001_001;
        3'd1: current_line = 24'b001_001_001_001_001_001_001_001;
        3'd2: current_line = 24'b001_100_100_001_011_011_001_001;
        3'd3: current_line = 24'b001_100_001_001_011_001_001_001;
        3'd4: current_line = 24'b010_001_001_001_001_001_001_010;
        3'd5: current_line = 24'b001_010_010_001_010_010_010_001;
        3'd6: current_line = 24'b001_001_010_001_010_010_001_001;
        3'd7: current_line = 24'b001_001_001_001_001_001_001_001;
      endcase
    end
  end

  reg [2:0] pixel_color;
  always @(*) begin
    case (local_x)
      3'd0: pixel_color = current_line[0:2];
      3'd1: pixel_color = current_line[3:5];
      3'd2: pixel_color = current_line[6:8];
      3'd3: pixel_color = current_line[9:11];
      3'd4: pixel_color = current_line[12:14];
      3'd5: pixel_color = current_line[15:17];
      3'd6: pixel_color = current_line[18:20];
      3'd7: pixel_color = current_line[21:23];
    endcase
  end
  assign color = in_bounds ? pixel_color : 3'b000;
endmodule
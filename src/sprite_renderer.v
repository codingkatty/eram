module sprite_renderer(input wire [9:0] pix_x, input wire [9:0] pix_y, input wire [3:0] sprite_x, input wire [2:0] sprite_y, input wire is_friend, output wire [2:0] color);
  reg [0:23] current_line;

  wire [9:0] act_x;
  wire [9:0] act_y;
  
  assign act_x = {1'b0, sprite_x, 5'b0} + 10'd128;
  assign act_y = {2'b0, sprite_y, 5'b0} + 10'd112;

  wire in_bounds = (pix_x >= act_x) && (pix_x < act_x + 10'd32) && (pix_y >= act_y) && (pix_y < act_y + 10'd32);

  wire [9:0] diff_x = pix_x - act_x;
  wire [9:0] diff_y = pix_y - act_y;
  wire [2:0] local_x = diff_x[4:2];
  wire [2:0] local_y = diff_y[4:2];

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
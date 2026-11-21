module is_tile(
  input wire [3:0] col, 
  input wire [2:0] row, 
  input in_screen, 
  output reg has_tile
);
  localparam [0:11] line_1 = 12'b111111111111;
  localparam [0:11] line_2 = 12'b110000000001;
  localparam [0:11] line_3 = 12'b100101010101;
  localparam [0:11] line_4 = 12'b101000010001;
  localparam [0:11] line_5 = 12'b100010000101;
  localparam [0:11] line_6 = 12'b101010101001;
  localparam [0:11] line_7 = 12'b100000000011;
  localparam [0:11] line_8 = 12'b111111111111;

  always @(*) begin
    if (!in_screen) begin
      has_tile = 0;
    end else begin
      case (row)
        3'd0: has_tile = line_1[col];
        3'd1: has_tile = line_2[col];
        3'd2: has_tile = line_3[col];
        3'd3: has_tile = line_4[col];
        3'd4: has_tile = line_5[col];
        3'd5: has_tile = line_6[col];
        3'd6: has_tile = line_7[col];
        3'd7: has_tile = line_8[col];
      endcase
    end
  end
endmodule

//module check_tile(input wire [3:0] in_x, input wire [2:0] in_y, output reg has_wall);
//  always @(*) begin
//    if (!((in_x >= 1) && (in_x < 11) && (in_y >= 1) && (in_y <= 6))) begin
//      has_wall = 1'b1;
//    end else begin
//      case ({in_x, in_y})
//        {4'd1, 3'd1}: has_wall = 1'b1;
//        {4'd3, 3'd2}: has_wall = 1'b1;
//        {4'd5, 3'd2}: has_wall = 1'b1;
//        {4'd7, 3'd2}: has_wall = 1'b1;
//        {4'd9, 3'd2}: has_wall = 1'b1;
//        {4'd2, 3'd3}: has_wall = 1'b1;
//        {4'd7, 3'd3}: has_wall = 1'b1;
//        {4'd4, 3'd4}: has_wall = 1'b1;
//        {4'd9, 3'd4}: has_wall = 1'b1;
//        {4'd2, 3'd5}: has_wall = 1'b1;
//        {4'd4, 3'd5}: has_wall = 1'b1;
//        {4'd6, 3'd5}: has_wall = 1'b1;
//        {4'd8, 3'd5}: has_wall = 1'b1;
//        {4'd10, 3'd6}: has_wall = 1'b1;
//        default: has_wall = 1'b0;
//      endcase
//    end
//  end
//endmodule
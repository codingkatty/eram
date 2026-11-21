/*
 * Copyright (c) 2024 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_codingkatty_eram(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  //wire [1:0] R;
  //wire [1:0] G;
  //wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  //assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  //wire up;
  //wire down;
  //wire left;
  //wire right;
  //wire x;

  //debouncer up_arrow (clk, rst_n, ui_in[0], up);
  //debouncer down_arrow (clk, rst_n, ui_in[1], down);
  //debouncer left_arrow (clk, rst_n, ui_in[2], left);
  //debouncer right_arrow (clk, rst_n, ui_in[3], right);
  //debouncer action (clk, rst_n, ui_in[4], x);

  wire [4:0] btns;
  debouncer all (clk, rst_n, ui_in[4:0], btns);

  wire up = btns[0];
  wire down = btns[1];
  wire left = btns[2];
  wire right = btns[3];
  wire x = btns[4];

  reg [3:0] kris_x;
  reg [2:0] kris_y;

  reg [3:0] next_x;
  reg [2:0] next_y;

  reg [1:0] last_dir;
  reg [1:0] next_dir;

  reg [3:0] slct_x;
  reg [2:0] slct_y;

  reg [3:0] friend_x_1;
  reg [2:0] friend_y_1;
  reg [1:0] friend_dir_1;

  reg [3:0] fn_x_1;
  reg [2:0] fn_y_1;

  reg [3:0] friend_x_2;
  reg [2:0] friend_y_2;
  reg [1:0] friend_dir_2;

  reg [3:0] fn_x_2;
  reg [2:0] fn_y_2;

  reg [3:0] friend_x_3;
  reg [2:0] friend_y_3;
  reg [1:0] friend_dir_3;

  reg [3:0] fn_x_3;
  reg [2:0] fn_y_3;
  
  always @(*) begin
    next_x = kris_x;
    next_y = kris_y;
    next_dir = last_dir;

    if (up) begin
      next_y = kris_y + 3'd1;
      next_dir = 2'b00;
    end else if (down) begin
      next_y = kris_y - 3'd1;
      next_dir = 2'b01;
    end else if (left) begin
      next_x = kris_x - 4'd1;
      next_dir = 2'b10;
    end else if (right) begin
      next_x = kris_x + 4'd1;
      next_dir = 2'b11;
    end
  end

  reg [3:0] target_x;
  reg [2:0] target_y;

  wire [3:0] after_x = (!is_wall) ? next_x : kris_x;
  wire [2:0] after_y = (!is_wall) ? next_y : kris_y;

  wire is_wall;
  is_tile tilecheck (next_x, next_y, 1'b1, is_wall);

  wire hit_f1 = (x && (target_x == friend_x_1) && (target_y == friend_y_1)) || (show_slct && (slct_x == friend_x_1) && (slct_y == friend_y_1));
  wire hit_f2 = (x && (target_x == friend_x_2) && (target_y == friend_y_2)) || (show_slct && (slct_x == friend_x_2) && (slct_y == friend_y_2));
  wire hit_f3 = (x && (target_x == friend_x_3) && (target_y == friend_y_3)) || (show_slct && (slct_x == friend_x_3) && (slct_y == friend_y_3));

  always @(*) begin
    target_x = after_x;
    target_y = after_y;
    case (next_dir)
      2'b00: target_y = after_y + 3'd1;
      2'b01: target_y = after_y - 3'd1;
      2'b10: target_x = after_x - 4'd1;
      2'b11: target_x = after_x + 4'd1;
    endcase
  end

  reg slash_timer;
  wire show_slct = (slash_timer != 1'd0);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      kris_x <= 4'd5;
      kris_y <= 3'd6;
      slct_x <= 4'd5;
      slct_y <= 3'd5;
      last_dir <= 2'b00;
      slash_timer <= 1'd0;
    end else begin
      if (!is_wall) begin
        kris_x <= next_x;
        kris_y <= next_y;
        last_dir <= next_dir;
      end

      if (up || down || left || right || x) begin
        slct_x <= target_x;
        slct_y <= target_y;
      end
      
      if (up)
        last_dir <= 2'b00;
      else if (down)
        last_dir <= 2'b01;
      else if (left)
        last_dir <= 2'b10;
      else if (right)
        last_dir <= 2'b11;

      if (x) begin
        slash_timer <= 1'd1;
      end else if (tickki && (slash_timer != 1'd0)) begin
        slash_timer <= 1'd0;
      end
    end
  end

  wire tickki;
  ticker tick1 (clk, rst_n, tickki);

  always @(*) begin
    fn_x_1 = friend_x_1;
    fn_y_1 = friend_y_1;

    fn_x_2 = friend_x_2;
    fn_y_2 = friend_y_2;

    fn_x_3 = friend_x_3;
    fn_y_3 = friend_y_3;

    case (friend_dir_1)
      2'b00: fn_y_1 = friend_y_1 + 3'd1;
      2'b01: fn_y_1 = friend_y_1 - 3'd1;
      2'b10: fn_x_1 = friend_x_1 - 4'd1;
      2'b11: fn_x_1 = friend_x_1 + 4'd1;
    endcase

    case (friend_dir_2)
      2'b00: fn_y_2 = friend_y_2 + 3'd1;
      2'b01: fn_y_2 = friend_y_2 - 3'd1;
      2'b10: fn_x_2 = friend_x_2 - 4'd1;
      2'b11: fn_x_2 = friend_x_2 + 4'd1;
    endcase

    case (friend_dir_3)
      2'b00: fn_x_3 = friend_x_3 + 4'd1;
      2'b01: fn_y_3 = friend_y_3 + 3'd1;
      2'b10: fn_x_3 = friend_x_3 - 4'd1;
      2'b11: fn_y_3 = friend_y_3 - 3'd1;
    endcase
  end

  reg [1:0] turn;

  wire [3:0] check_x = (turn == 2'd1) ? fn_x_1 : (turn == 2'd2) ? fn_x_2 : fn_x_3;
  wire [2:0] check_y = (turn == 2'd1) ? fn_y_1 : (turn == 2'd2) ? fn_y_2 : fn_y_3;

  wire is_wall_f;
  is_tile shared_tile (check_x, check_y, 1'b1, is_wall_f);

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      turn <= 2'd0;

      friend_x_1 <= 4'd5;
      friend_y_1 <= 3'd3;
      friend_dir_1 <= 2'b01;

      friend_x_2 <= 4'd9;
      friend_y_2 <= 3'd5;
      friend_dir_2 <= 2'b10;

      friend_x_3 <= 4'd8;
      friend_y_3 <= 3'd4;
      friend_dir_3 <= 2'b00;
    end else begin
      if (tickki) begin
        turn <= 2'd1;
      end else if (turn != 2'd0) begin
        if (turn == 2'd3)
          turn <= 2'd0;
        else
          turn <= turn + 2'd1;
      end

      if (hit_f1) begin
        friend_x_1 <= 4'd5;
        friend_y_1 <= 3'd3;
      end else if (turn == 2'd1) begin
        if (!is_wall_f) begin
          friend_x_1 <= fn_x_1;
          friend_y_1 <= fn_y_1;
        end else begin
          friend_dir_1 <= friend_dir_1 + 2'b01;
        end
      end

      if (hit_f2) begin
        friend_x_2 <= 4'd9;
        friend_y_2 <= 3'd5;
      end else if (turn == 2'd2) begin
        if (!is_wall_f) begin
          friend_x_2 <= fn_x_2;
          friend_y_2 <= fn_y_2;
        end else begin
          friend_dir_2 <= friend_dir_2 - 2'b01;
        end
      end

      if (hit_f3) begin
        friend_x_3 <= 4'd8;
        friend_y_3 <= 3'd4;
      end else if (turn == 2'd3) begin
        if (!is_wall_f) begin
          friend_x_3 <= fn_x_3;
          friend_y_3 <= fn_y_3;
        end else begin
          friend_dir_3 <= friend_dir_3 + 2'b10;
        end
      end
    end
  end

  //wire [9:0] slct_act_x;
  //wire [9:0] slct_act_y;
  
  //assign slct_act_x = {1'b0, slct_x, 5'b0} + 10'd128;
  //assign slct_act_y = {2'b0, slct_y, 5'b0} + 10'd112;

  wire [9:0] rel_x = pix_x - 10'd128;
  wire [9:0] rel_y = pix_y - 10'd112;
  wire [3:0] grid_x = rel_x[8:5];
  wire [2:0] grid_y = rel_y[7:5];

  wire in_slct = in_screen && (grid_x == slct_x) && (grid_y == slct_y);
  wire in_f1   = in_screen && (grid_x == friend_x_1) && (grid_y == friend_y_1);
  wire in_f2   = in_screen && (grid_x == friend_x_2) && (grid_y == friend_y_2);
  wire in_f3   = in_screen && (grid_x == friend_x_3) && (grid_y == friend_y_3);

  //wire in_slct = (pix_x >= slct_act_x) && (pix_x < slct_act_x + 10'd32) && (pix_y >= slct_act_y) && (pix_y < slct_act_y + 10'd32);

  wire in_screen = (pix_x >= 10'd128) && (pix_x < 10'd512) && (pix_y >= 10'd112) && (pix_y < 10'd368);

  wire has_tile;
  is_tile map_instance (grid_x, grid_y, in_screen, has_tile);

  //wire [2:0] kris_color;
  //sprite_renderer hero_sword (pix_x, pix_y, kris_x, kris_y, 0, kris_color);
  //hero_sword kris (pix_x, pix_y, kris_x, kris_y, kris_color);

  //wire [2:0] freedom_color_1;
  //wire [2:0] freedom_color_2;
  //wire [2:0] freedom_color_3;

  //sprite_renderer image_friend1 (pix_x, pix_y, friend_x_1, friend_y_1, 1, freedom_color_1);
  //sprite_renderer image_friend2 (pix_x, pix_y, friend_x_2, friend_y_2, 1, freedom_color_2);
  //sprite_renderer image_friend3 (pix_x, pix_y, friend_x_3, friend_y_3, 1, freedom_color_3);
  //image_friend friend (pix_x, pix_y, 4'd5, 3'd3, freedom_color);

  //wire [9:0] f1_px = {1'b0, friend_x_1, 5'b0} + 10'd128;
  //wire [9:0] f1_py = {2'b0, friend_y_1, 5'b0} + 10'd112;
  //wire in_f1 = (pix_x >= f1_px) && (pix_x < f1_px + 10'd32) && (pix_y >= f1_py) && (pix_y < f1_py + 10'd32);

  //wire [9:0] f2_px = {1'b0, friend_x_2, 5'b0} + 10'd128;
  //wire [9:0] f2_py = {2'b0, friend_y_2, 5'b0} + 10'd112;
  //wire in_f2 = (pix_x >= f2_px) && (pix_x < f2_px + 10'd32) && (pix_y >= f2_py) && (pix_y < f2_py + 10'd32);

  //wire [9:0] f3_px = {1'b0, friend_x_3, 5'b0} + 10'd128;
  //wire [9:0] f3_py = {2'b0, friend_y_3, 5'b0} + 10'd112;
  //wire in_f3 = (pix_x >= f3_px) && (pix_x < f3_px + 10'd32) && (pix_y >= f3_py) && (pix_y < f3_py + 10'd32);

  reg [3:0] active_spr_x;
  reg [2:0] active_spr_y;
  reg       active_is_friend;

  always @(*) begin
    if (in_f1) begin
      active_spr_x = friend_x_1;
      active_spr_y = friend_y_1;
      active_is_friend = 1'b1;
    end else if (in_f2) begin
      active_spr_x = friend_x_2;
      active_spr_y = friend_y_2;
      active_is_friend = 1'b1;
    end else if (in_f3) begin
      active_spr_x = friend_x_3;
      active_spr_y = friend_y_3;
      active_is_friend = 1'b1;
    end else begin
      active_spr_x = kris_x;
      active_spr_y = kris_y;
      active_is_friend = 1'b0;
    end
  end

  wire [2:0] spr_color;
  sprite_renderer shared_sprite (in_screen, grid_x, grid_y, rel_x[4:2], rel_y[4:2], active_spr_x, active_spr_y, active_is_friend, spr_color);

  wire [2:0] freedom_color = active_is_friend ? spr_color : 3'b000;
  wire [2:0] kris_color    = !active_is_friend ? spr_color : 3'b000;

  //wire [2:0] freedom_color = freedom_color_1 | freedom_color_2 | freedom_color_3;
  
  reg [2:0] kris_color_r;
  reg [2:0] freedom_color_r;
  reg       has_tile_r;
  reg       in_slct_r;
  reg       show_slct_r;
  reg       hit_any_r;
  reg       in_screen_r;
  reg       video_active_r;
  reg       hsync_r;
  reg       vsync_r;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      kris_color_r    <= 3'b000;
      freedom_color_r <= 3'b000;
      has_tile_r      <= 1'b0;
      in_slct_r       <= 1'b0;
      show_slct_r     <= 1'b0;
      hit_any_r       <= 1'b0;
      in_screen_r     <= 1'b0;
      video_active_r  <= 1'b0;
      hsync_r         <= 1'b0;
      vsync_r         <= 1'b0;
    end else begin
      kris_color_r    <= kris_color;
      freedom_color_r <= freedom_color;
      has_tile_r      <= has_tile;
      in_slct_r       <= in_slct;
      show_slct_r     <= show_slct;
      hit_any_r       <= hit_f1 | hit_f2 | hit_f3;
      in_screen_r     <= in_screen;
      video_active_r  <= video_active;
      hsync_r         <= hsync;
      vsync_r         <= vsync;
    end
  end

  reg [5:0] pixel_color;

  always @(*) begin
    if (!video_active_r)
      pixel_color = 6'b00_00_00;
    else if (freedom_color_r != 3'b000)
      case (freedom_color_r)
        3'b001: pixel_color = 6'b00_00_00;
        3'b010: pixel_color = 6'b11_11_11;
        3'b011: pixel_color = 6'b11_10_11;
        3'b100: pixel_color = 6'b11_11_00;
        default: pixel_color = 6'b00_00_00;
      endcase
    else if (kris_color_r != 3'b000)
      case (kris_color_r)
        3'b001: pixel_color = 6'b01_00_11;
        3'b010: pixel_color = 6'b10_10_11;
        3'b011: pixel_color = 6'b00_11_11;
        3'b100: pixel_color = 6'b11_00_01;
        default: pixel_color = 6'b00_00_00;
      endcase
    else if (has_tile_r)
      pixel_color = 6'b01_00_01;
    else if ((show_slct_r & in_slct_r) & hit_any_r)
      pixel_color = 6'b11_00_00;
    else if (show_slct_r & in_slct_r)
      pixel_color = 6'b11_01_01;
    else if (in_slct_r)
      pixel_color = 6'b10_01_10;
    else if (in_screen_r)
      pixel_color = 6'b01_00_10;
    else
      pixel_color = 6'b00_00_00;
  end

  wire [1:0] R = pixel_color[5:4];
  wire [1:0] G = pixel_color[3:2];
  wire [1:0] B = pixel_color[1:0];

  reg [7:0] uo_out_r;
  assign uo_out = uo_out_r;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      uo_out_r <= 8'b0;
    end else begin
      uo_out_r <= {hsync_r, B[0], G[0], R[0], vsync_r, B[1], G[1], R[1]};
    end
  end
endmodule
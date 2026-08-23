#include <stdint.h>
#define GD_DRAW_RECT
#include "framework.c"

typedef int32_t i32;
typedef int32_t bool32;
typedef int32_t char32;
typedef int32_t short32;

#define BW 10
#define BH 20
#define CELL 2
#define OX 30
#define OY 2
#define GRAVITY_FRAMES 20

static void draw_cell(i32 bx, i32 by, i32 color){
    /* screen origin is bottom-left, so board row 0 (top of stack) must map
       to the largest screen Y; flip by here, keep all game logic in
       normal top-down array space */
    gd_draw_rect(OX + bx * CELL, OY + (BH - 1 - by) * CELL, CELL, CELL, color);
}

static i32 cell_dx(const i32 *piece_dx, i32 type, i32 rot, i32 cell){
    i32 t1 = type * 16;
    i32 t2 = rot * 4;
    return piece_dx[t1 + t2 + cell];
}
static i32 cell_dy(const i32 *piece_dy, i32 type, i32 rot, i32 cell){
    i32 t1 = type * 16;
    i32 t2 = rot * 4;
    return piece_dy[t1 + t2 + cell];
}

/* does placing `type` at rotation `rot`, box origin (bx,by) collide with walls/floor/locked cells? */
static bool32 collides(const i32 *piece_dx, const i32 *piece_dy, const i32 *board,
                        i32 type, i32 rot, i32 bx, i32 by){
    for (i32 c = 0; c < 4; c++){
        i32 x = bx + cell_dx(piece_dx, type, rot, c);
        i32 y = by + cell_dy(piece_dy, type, rot, c);
        if (x < 0 || x >= BW || y >= BH)
            return 1;
        if (y >= 0 && board[y * BW + x] != 0)
            return 1;
    }
    return 0;
}

static void draw_piece(const i32 *piece_dx, const i32 *piece_dy,
                        i32 type, i32 rot, i32 px, i32 py, i32 color){
    for (i32 c = 0; c < 4; c++){
        i32 x = px + cell_dx(piece_dx, type, rot, c);
        i32 y = py + cell_dy(piece_dy, type, rot, c);
        if (y >= 0)
            draw_cell(x, y, color);
    }
}

static i32 color_for_type(i32 type){
    /* I,O,T,S,Z,J,L -> 2..8 */
    return type + 2;
}

static void spawn_piece(i32 *piece_type, i32 *piece_rot, i32 *piece_x, i32 *piece_y, i32 *piece_color){
    *piece_type = gd_randint(7);
    *piece_rot = 0;
    *piece_x = 3;
    *piece_y = -1;
    *piece_color = color_for_type(*piece_type);
}

static void redraw_board(const i32 *board){
    for (i32 y = 0; y < BH; y++){
        for (i32 x = 0; x < BW; x++){
            draw_cell(x, y, board[y * BW + x]);
        }
    }
}

/* lock current piece into board, clear full lines, respawn */
static void lock_piece(const i32 *piece_dx, const i32 *piece_dy, i32 *board,
                        i32 piece_type, i32 piece_rot, i32 piece_x, i32 piece_y, i32 piece_color,
                        i32 *out_type, i32 *out_rot, i32 *out_x, i32 *out_y, i32 *out_color){
    for (i32 c = 0; c < 4; c++){
        i32 x = piece_x + cell_dx(piece_dx, piece_type, piece_rot, c);
        i32 y = piece_y + cell_dy(piece_dy, piece_type, piece_rot, c);
        if (y >= 0 && y < BH && x >= 0 && x < BW)
            board[y * BW + x] = piece_color;
    }

    /* scan for full lines, compact board downward */
    i32 write_y = BH - 1;
    for (i32 y = BH - 1; y >= 0; y--){
        bool32 full = 1;
        for (i32 x = 0; x < BW; x++){
            if (board[y * BW + x] == 0){
                full = 0;
            }
        }
        if (!full){
            if (write_y != y){
                for (i32 x = 0; x < BW; x++){
                    board[write_y * BW + x] = board[y * BW + x];
                }
            }
            write_y--;
        }
    }
    for (i32 y = write_y; y >= 0; y--){
        for (i32 x = 0; x < BW; x++){
            board[y * BW + x] = 0;
        }
    }

    redraw_board(board);
    spawn_piece(out_type, out_rot, out_x, out_y, out_color);
}

i32 main(){
    /* rotation tables: 7 pieces x 4 rotations x 4 cells, offsets inside a 4x4 box.
       Stack-local (not file-scope globals), and populated via individual element
       assignments rather than a brace initializer list: GCC emits a .rodata blob
       + rep movsl bulk-copy for local array initializers past 16 elements, which
       this ISA cannot express. Plain per-element movl stores always work. */
    i32 piece_dx[112];
    i32 piece_dy[112];
    piece_dx[0] = 0; piece_dy[0] = 1;
    piece_dx[1] = 1; piece_dy[1] = 1;
    piece_dx[2] = 2; piece_dy[2] = 1;
    piece_dx[3] = 3; piece_dy[3] = 1;
    piece_dx[4] = 2; piece_dy[4] = 0;
    piece_dx[5] = 2; piece_dy[5] = 1;
    piece_dx[6] = 2; piece_dy[6] = 2;
    piece_dx[7] = 2; piece_dy[7] = 3;
    piece_dx[8] = 0; piece_dy[8] = 2;
    piece_dx[9] = 1; piece_dy[9] = 2;
    piece_dx[10] = 2; piece_dy[10] = 2;
    piece_dx[11] = 3; piece_dy[11] = 2;
    piece_dx[12] = 1; piece_dy[12] = 0;
    piece_dx[13] = 1; piece_dy[13] = 1;
    piece_dx[14] = 1; piece_dy[14] = 2;
    piece_dx[15] = 1; piece_dy[15] = 3;
    piece_dx[16] = 1; piece_dy[16] = 0;
    piece_dx[17] = 2; piece_dy[17] = 0;
    piece_dx[18] = 1; piece_dy[18] = 1;
    piece_dx[19] = 2; piece_dy[19] = 1;
    piece_dx[20] = 1; piece_dy[20] = 0;
    piece_dx[21] = 2; piece_dy[21] = 0;
    piece_dx[22] = 1; piece_dy[22] = 1;
    piece_dx[23] = 2; piece_dy[23] = 1;
    piece_dx[24] = 1; piece_dy[24] = 0;
    piece_dx[25] = 2; piece_dy[25] = 0;
    piece_dx[26] = 1; piece_dy[26] = 1;
    piece_dx[27] = 2; piece_dy[27] = 1;
    piece_dx[28] = 1; piece_dy[28] = 0;
    piece_dx[29] = 2; piece_dy[29] = 0;
    piece_dx[30] = 1; piece_dy[30] = 1;
    piece_dx[31] = 2; piece_dy[31] = 1;
    piece_dx[32] = 1; piece_dy[32] = 0;
    piece_dx[33] = 0; piece_dy[33] = 1;
    piece_dx[34] = 1; piece_dy[34] = 1;
    piece_dx[35] = 2; piece_dy[35] = 1;
    piece_dx[36] = 1; piece_dy[36] = 0;
    piece_dx[37] = 1; piece_dy[37] = 1;
    piece_dx[38] = 2; piece_dy[38] = 1;
    piece_dx[39] = 1; piece_dy[39] = 2;
    piece_dx[40] = 0; piece_dy[40] = 1;
    piece_dx[41] = 1; piece_dy[41] = 1;
    piece_dx[42] = 2; piece_dy[42] = 1;
    piece_dx[43] = 1; piece_dy[43] = 2;
    piece_dx[44] = 1; piece_dy[44] = 0;
    piece_dx[45] = 0; piece_dy[45] = 1;
    piece_dx[46] = 1; piece_dy[46] = 1;
    piece_dx[47] = 1; piece_dy[47] = 2;
    piece_dx[48] = 1; piece_dy[48] = 0;
    piece_dx[49] = 2; piece_dy[49] = 0;
    piece_dx[50] = 0; piece_dy[50] = 1;
    piece_dx[51] = 1; piece_dy[51] = 1;
    piece_dx[52] = 1; piece_dy[52] = 0;
    piece_dx[53] = 1; piece_dy[53] = 1;
    piece_dx[54] = 2; piece_dy[54] = 1;
    piece_dx[55] = 2; piece_dy[55] = 2;
    piece_dx[56] = 1; piece_dy[56] = 1;
    piece_dx[57] = 2; piece_dy[57] = 1;
    piece_dx[58] = 0; piece_dy[58] = 2;
    piece_dx[59] = 1; piece_dy[59] = 2;
    piece_dx[60] = 0; piece_dy[60] = 0;
    piece_dx[61] = 0; piece_dy[61] = 1;
    piece_dx[62] = 1; piece_dy[62] = 1;
    piece_dx[63] = 1; piece_dy[63] = 2;
    piece_dx[64] = 0; piece_dy[64] = 0;
    piece_dx[65] = 1; piece_dy[65] = 0;
    piece_dx[66] = 1; piece_dy[66] = 1;
    piece_dx[67] = 2; piece_dy[67] = 1;
    piece_dx[68] = 2; piece_dy[68] = 0;
    piece_dx[69] = 1; piece_dy[69] = 1;
    piece_dx[70] = 2; piece_dy[70] = 1;
    piece_dx[71] = 1; piece_dy[71] = 2;
    piece_dx[72] = 0; piece_dy[72] = 1;
    piece_dx[73] = 1; piece_dy[73] = 1;
    piece_dx[74] = 1; piece_dy[74] = 2;
    piece_dx[75] = 2; piece_dy[75] = 2;
    piece_dx[76] = 1; piece_dy[76] = 0;
    piece_dx[77] = 0; piece_dy[77] = 1;
    piece_dx[78] = 1; piece_dy[78] = 1;
    piece_dx[79] = 0; piece_dy[79] = 2;
    piece_dx[80] = 0; piece_dy[80] = 0;
    piece_dx[81] = 0; piece_dy[81] = 1;
    piece_dx[82] = 1; piece_dy[82] = 1;
    piece_dx[83] = 2; piece_dy[83] = 1;
    piece_dx[84] = 1; piece_dy[84] = 0;
    piece_dx[85] = 2; piece_dy[85] = 0;
    piece_dx[86] = 1; piece_dy[86] = 1;
    piece_dx[87] = 1; piece_dy[87] = 2;
    piece_dx[88] = 0; piece_dy[88] = 1;
    piece_dx[89] = 1; piece_dy[89] = 1;
    piece_dx[90] = 2; piece_dy[90] = 1;
    piece_dx[91] = 2; piece_dy[91] = 2;
    piece_dx[92] = 1; piece_dy[92] = 0;
    piece_dx[93] = 1; piece_dy[93] = 1;
    piece_dx[94] = 0; piece_dy[94] = 2;
    piece_dx[95] = 1; piece_dy[95] = 2;
    piece_dx[96] = 2; piece_dy[96] = 0;
    piece_dx[97] = 0; piece_dy[97] = 1;
    piece_dx[98] = 1; piece_dy[98] = 1;
    piece_dx[99] = 2; piece_dy[99] = 1;
    piece_dx[100] = 1; piece_dy[100] = 0;
    piece_dx[101] = 1; piece_dy[101] = 1;
    piece_dx[102] = 1; piece_dy[102] = 2;
    piece_dx[103] = 2; piece_dy[103] = 2;
    piece_dx[104] = 0; piece_dy[104] = 1;
    piece_dx[105] = 1; piece_dy[105] = 1;
    piece_dx[106] = 2; piece_dy[106] = 1;
    piece_dx[107] = 0; piece_dy[107] = 2;
    piece_dx[108] = 0; piece_dy[108] = 0;
    piece_dx[109] = 1; piece_dy[109] = 0;
    piece_dx[110] = 1; piece_dy[110] = 1;
    piece_dx[111] = 1; piece_dy[111] = 2;

    /* board[y*BW+x] = 0 empty, else color index (2..8 = tetromino colors) */
    i32 board[BW * BH];
    for (i32 i = 0; i < BW * BH; i++)
        board[i] = 0;

    i32 piece_type, piece_rot, piece_x, piece_y, piece_color;

    gd_draw_rect(OX - 1, OY - 1, BW * CELL + 2, BH * CELL + 2, 1);
    gd_draw_rect(OX, OY, BW * CELL, BH * CELL, 0);

    spawn_piece(&piece_type, &piece_rot, &piece_x, &piece_y, &piece_color);
    draw_piece(piece_dx, piece_dy, piece_type, piece_rot, piece_x, piece_y, piece_color);

    i32 gravity_timer = 0;
    i32 prev_a = 0, prev_d = 0, prev_left = 0, prev_right = 0, prev_up = 0, prev_w = 0;

    while (1){
        i32 cur_a = gd_a_pressed();
        i32 cur_d = gd_d_pressed();
        i32 cur_left = gd_left_pressed();
        i32 cur_right = gd_right_pressed();
        i32 cur_up = gd_up_pressed();
        i32 cur_w = gd_w_pressed();

        bool32 moved = 0;
        i32 old_x = piece_x, old_y = piece_y, old_rot = piece_rot;

        /* hard drop takes priority and is edge-triggered: handle it and skip
           every other action this frame so we never double-move/double-lock */
        if (cur_w && !prev_w){
            i32 t = piece_y + 1;
            while (!collides(piece_dx, piece_dy, board, piece_type, piece_rot, piece_x, t)){
                t = t + 1;
            }
            lock_piece(piece_dx, piece_dy, board,
                       piece_type, piece_rot, piece_x, piece_y, piece_color,
                       &piece_type, &piece_rot, &piece_x, &piece_y, &piece_color);
            draw_piece(piece_dx, piece_dy, piece_type, piece_rot, piece_x, piece_y, piece_color);
            gravity_timer = 0;
        } else {
            /* rotate: a = CCW (rot-1), d = CW (rot+1), edge-triggered */
            if (cur_a && !prev_a){
                i32 new_rot = (piece_rot + 3) % 4;
                if (!collides(piece_dx, piece_dy, board, piece_type, new_rot, piece_x, piece_y)){
                    piece_rot = new_rot;
                    moved = 1;
                }
            }
            if (cur_d && !prev_d){
                i32 new_rot = (piece_rot + 1) % 4;
                if (!collides(piece_dx, piece_dy, board, piece_type, new_rot, piece_x, piece_y)){
                    piece_rot = new_rot;
                    moved = 1;
                }
            }

            /* move left/right, edge-triggered */
            if (cur_left && !prev_left){
                i32 t = piece_x - 1;
                if (!collides(piece_dx, piece_dy, board, piece_type, piece_rot, t, piece_y)){
                    piece_x = piece_x - 1;
                    moved = 1;
                }
            }
            if (cur_right && !prev_right){
                i32 t = piece_x + 1;
                if (!collides(piece_dx, piece_dy, board, piece_type, piece_rot, t, piece_y)){
                    piece_x = piece_x + 1;
                    moved = 1;
                }
            }

            /* soft drop one row, edge-triggered */
            if (cur_up && !prev_up){
                i32 t = piece_y + 1;
                if (!collides(piece_dx, piece_dy, board, piece_type, piece_rot, piece_x, t)){
                    piece_y = piece_y + 1;
                    moved = 1;
                    gravity_timer = 0;
                }
            }

            if (moved){
                draw_piece(piece_dx, piece_dy, piece_type, old_rot, old_x, old_y, 0);
                draw_piece(piece_dx, piece_dy, piece_type, piece_rot, piece_x, piece_y, piece_color);
            }

            /* gravity */
            gravity_timer = gravity_timer + 1;
            if (gravity_timer >= GRAVITY_FRAMES){
                gravity_timer = 0;
                i32 t = piece_y + 1;
                if (!collides(piece_dx, piece_dy, board, piece_type, piece_rot, piece_x, t)){
                    draw_piece(piece_dx, piece_dy, piece_type, piece_rot, piece_x, piece_y, 0);
                    piece_y = piece_y + 1;
                    draw_piece(piece_dx, piece_dy, piece_type, piece_rot, piece_x, piece_y, piece_color);
                } else {
                    lock_piece(piece_dx, piece_dy, board,
                               piece_type, piece_rot, piece_x, piece_y, piece_color,
                               &piece_type, &piece_rot, &piece_x, &piece_y, &piece_color);
                    draw_piece(piece_dx, piece_dy, piece_type, piece_rot, piece_x, piece_y, piece_color);
                }
            }
        }

        prev_a = cur_a;
        prev_d = cur_d;
        prev_left = cur_left;
        prev_right = cur_right;
        prev_up = cur_up;
        prev_w = cur_w;

        gd_waitnextframe();
    }

    return 0;
}
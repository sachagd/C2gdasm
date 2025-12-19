// tetris.c
#define GD_DRAW_PIXEL
#define GD_DRAW_RECT
#include "framework.c"

typedef int32_t i32;
typedef int32_t bool32;

void piece_block(i32 t, i32 r, i32 k, i32 *dx, i32 *dy){
    // t: 0=I 1=O 2=T 3=S 4=Z 5=J 6=L
    // r: 0..3, k: 0..3
    if(t == 0){ // I
        if(r == 0 || r == 2){ *dy = 1; *dx = k; }
        else                { *dx = 1; *dy = k; }
        return;
    }
    if(t == 1){ // O
        if(k == 0){ *dx = 1; *dy = 0; }
        else if(k == 1){ *dx = 2; *dy = 0; }
        else if(k == 2){ *dx = 1; *dy = 1; }
        else { *dx = 2; *dy = 1; }
        return;
    }
    if(t == 2){ // T
        if(r == 0){
            if(k == 0){ *dx = 1; *dy = 0; }
            else if(k == 1){ *dx = 0; *dy = 1; }
            else if(k == 2){ *dx = 1; *dy = 1; }
            else { *dx = 2; *dy = 1; }
        } else if(r == 1){
            if(k == 0){ *dx = 1; *dy = 0; }
            else if(k == 1){ *dx = 1; *dy = 1; }
            else if(k == 2){ *dx = 2; *dy = 1; }
            else { *dx = 1; *dy = 2; }
        } else if(r == 2){
            if(k == 0){ *dx = 0; *dy = 1; }
            else if(k == 1){ *dx = 1; *dy = 1; }
            else if(k == 2){ *dx = 2; *dy = 1; }
            else { *dx = 1; *dy = 2; }
        } else {
            if(k == 0){ *dx = 1; *dy = 0; }
            else if(k == 1){ *dx = 0; *dy = 1; }
            else if(k == 2){ *dx = 1; *dy = 1; }
            else { *dx = 1; *dy = 2; }
        }
        return;
    }
    if(t == 3){ // S
        if(r == 0 || r == 2){
            if(k == 0){ *dx = 1; *dy = 0; }
            else if(k == 1){ *dx = 2; *dy = 0; }
            else if(k == 2){ *dx = 0; *dy = 1; }
            else { *dx = 1; *dy = 1; }
        } else {
            if(k == 0){ *dx = 1; *dy = 0; }
            else if(k == 1){ *dx = 1; *dy = 1; }
            else if(k == 2){ *dx = 2; *dy = 1; }
            else { *dx = 2; *dy = 2; }
        }
        return;
    }
    if(t == 4){ // Z
        if(r == 0 || r == 2){
            if(k == 0){ *dx = 0; *dy = 0; }
            else if(k == 1){ *dx = 1; *dy = 0; }
            else if(k == 2){ *dx = 1; *dy = 1; }
            else { *dx = 2; *dy = 1; }
        } else {
            if(k == 0){ *dx = 2; *dy = 0; }
            else if(k == 1){ *dx = 1; *dy = 1; }
            else if(k == 2){ *dx = 2; *dy = 1; }
            else { *dx = 1; *dy = 2; }
        }
        return;
    }
    if(t == 5){ // J
        if(r == 0){
            if(k == 0){ *dx = 0; *dy = 0; }
            else if(k == 1){ *dx = 0; *dy = 1; }
            else if(k == 2){ *dx = 1; *dy = 1; }
            else { *dx = 2; *dy = 1; }
        } else if(r == 1){
            if(k == 0){ *dx = 1; *dy = 0; }
            else if(k == 1){ *dx = 2; *dy = 0; }
            else if(k == 2){ *dx = 1; *dy = 1; }
            else { *dx = 1; *dy = 2; }
        } else if(r == 2){
            if(k == 0){ *dx = 0; *dy = 1; }
            else if(k == 1){ *dx = 1; *dy = 1; }
            else if(k == 2){ *dx = 2; *dy = 1; }
            else { *dx = 2; *dy = 2; }
        } else {
            if(k == 0){ *dx = 1; *dy = 0; }
            else if(k == 1){ *dx = 1; *dy = 1; }
            else if(k == 2){ *dx = 0; *dy = 2; }
            else { *dx = 1; *dy = 2; }
        }
        return;
    }
    // L
    if(r == 0){
        if(k == 0){ *dx = 2; *dy = 0; }
        else if(k == 1){ *dx = 0; *dy = 1; }
        else if(k == 2){ *dx = 1; *dy = 1; }
        else { *dx = 2; *dy = 1; }
    } else if(r == 1){
        if(k == 0){ *dx = 1; *dy = 0; }
        else if(k == 1){ *dx = 1; *dy = 1; }
        else if(k == 2){ *dx = 1; *dy = 2; }
        else { *dx = 2; *dy = 2; }
    } else if(r == 2){
        if(k == 0){ *dx = 0; *dy = 1; }
        else if(k == 1){ *dx = 1; *dy = 1; }
        else if(k == 2){ *dx = 2; *dy = 1; }
        else { *dx = 0; *dy = 2; }
    } else {
        if(k == 0){ *dx = 0; *dy = 0; }
        else if(k == 1){ *dx = 1; *dy = 0; }
        else if(k == 2){ *dx = 1; *dy = 1; }
        else { *dx = 1; *dy = 2; }
    }
}

bool32 can_place(i32 board[20][10], i32 t, i32 r, i32 px, i32 py){
    for(i32 k = 0; k < 4; ++k){
        i32 dx, dy;
        piece_block(t, r, k, &dx, &dy);
        i32 gx = px + dx;
        i32 gy = py + dy;
        if(gx < 0 || gx >= 10 || gy < 0 || gy >= 20) return 0;
        if(board[gy][gx]) return 0;
    }
    return 1;
}

void lock_piece(i32 board[20][10], i32 t, i32 r, i32 px, i32 py){
    for(i32 k = 0; k < 4; ++k){
        i32 dx, dy;
        piece_block(t, r, k, &dx, &dy);
        board[py + dy][px + dx] = 1;
    }
}

void clear_full_lines(i32 board[20][10]){
    for(i32 y = 19; y >= 0; --y){
        bool32 full = 1;
        for(i32 x = 0; x < 10; ++x){
            if(board[y][x] == 0){ full = 0; break; }
        }
        if(full){
            for(i32 yy = y; yy > 0; --yy){
                for(i32 x = 0; x < 10; ++x) board[yy][x] = board[yy - 1][x];
            }
            for(i32 x = 0; x < 10; ++x) board[0][x] = 0;
            ++y;
        }
    }
}

void draw_locked(i32 board[20][10], i32 sx, i32 sy){
    for(i32 y = 0; y < 20; ++y){
        for(i32 x = 0; x < 10; ++x){
            if(board[y][x]) gd_draw_pixel(sx + x, sy + y, 2);
        }
    }
}

void draw_piece(i32 t, i32 r, i32 px, i32 py, i32 sx, i32 sy){
    for(i32 k = 0; k < 4; ++k){
        i32 dx, dy;
        piece_block(t, r, k, &dx, &dy);
        i32 gx = px + dx;
        i32 gy = py + dy;
        if(gx >= 0 && gx < 10 && gy >= 0 && gy < 20){
            gd_draw_pixel(sx + gx, sy + gy, 2);
        }
    }
}

i32 main(){
    const i32 BW = 10, BH = 20;
    const i32 OUT_W = BW + 2, OUT_H = BH + 2;
    const i32 OUT_X = (80 - OUT_W) / 2;
    const i32 OUT_Y = (50 - OUT_H) / 2;
    const i32 IN_X  = OUT_X + 1;
    const i32 IN_Y  = OUT_Y + 1;

    i32 board[20][10];
    for(i32 y = 0; y < 20; ++y) for(i32 x = 0; x < 10; ++x) board[y][x] = 0;

    // border once: white outer, black inner
    gd_draw_rect(OUT_X, OUT_Y, OUT_W, OUT_H, 1);
    gd_draw_rect(IN_X,  IN_Y,  BW,    BH,    0);

    i32 cur_t = gd_randint(7);
    i32 cur_r = 0;
    i32 cur_x = 3;
    i32 cur_y = 0;

    // 5 keys: A (rot CCW), D (rot CW), LEFT/RIGHT move, W hard drop
    i32 prev_a = 0, prev_d = 0, prev_l = 0, prev_r = 0, prev_w = 0;

    i32 drop_counter = 0;
    const i32 DROP_DELAY = 20;

    while(1){
        i32 a  = gd_a_pressed();
        i32 d  = gd_d_pressed();
        i32 l  = gd_left_pressed();
        i32 rr = gd_right_pressed();
        i32 w  = gd_w_pressed();

        if(a && !prev_a){
            i32 nr = (cur_r == 0) ? 3 : (cur_r - 1);
            if(can_place(board, cur_t, nr, cur_x, cur_y)) cur_r = nr;
        }
        if(d && !prev_d){
            i32 nr = (cur_r == 3) ? 0 : (cur_r + 1);
            if(can_place(board, cur_t, nr, cur_x, cur_y)) cur_r = nr;
        }
        if(l && !prev_l){
            if(can_place(board, cur_t, cur_r, cur_x - 1, cur_y)) cur_x -= 1;
        }
        if(rr && !prev_r){
            if(can_place(board, cur_t, cur_r, cur_x + 1, cur_y)) cur_x += 1;
        }

        if(w && !prev_w){
            while(can_place(board, cur_t, cur_r, cur_x, cur_y + 1)) cur_y += 1;
            lock_piece(board, cur_t, cur_r, cur_x, cur_y);
            clear_full_lines(board);

            cur_t = gd_randint(7);
            cur_r = 0;
            cur_x = 3;
            cur_y = 0;

            if(!can_place(board, cur_t, cur_r, cur_x, cur_y)){
                break;
            }
            drop_counter = 0;
        } else {
            drop_counter += 1;
            if(drop_counter >= DROP_DELAY){
                drop_counter = 0;
                if(can_place(board, cur_t, cur_r, cur_x, cur_y + 1)){
                    cur_y += 1;
                } else {
                    lock_piece(board, cur_t, cur_r, cur_x, cur_y);
                    clear_full_lines(board);

                    cur_t = gd_randint(7);
                    cur_r = 0;
                    cur_x = 3;
                    cur_y = 0;

                    if(!can_place(board, cur_t, cur_r, cur_x, cur_y)){
                        for(i32 y = 0; y < 20; ++y) for(i32 x = 0; x < 10; ++x) board[y][x] = 0;
                    }
                }
            }
        }

        prev_a = a; prev_d = d; prev_l = l; prev_r = rr; prev_w = w;

        // render
        gd_draw_rect(IN_X, IN_Y, BW, BH, 0);
        draw_locked(board, IN_X, IN_Y);
        draw_piece(cur_t, cur_r, cur_x, cur_y, IN_X, IN_Y);

        gd_waitnextframe();
    }

    return 0;
}

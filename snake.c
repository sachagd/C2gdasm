#include <stdint.h>
#define GD_DRAW_TEXT
#define GD_DRAW_PIXEL
#include "framework.c"

typedef int32_t i32;
typedef int32_t bool32;
typedef int32_t char32;
typedef int32_t short32;

#define WIDTH 80
#define HEIGHT 50
#define MAX_LEN 512

typedef struct { i32 x, y; } Point;

static bool32 on_snake_circ(const Point *snake, i32 head, i32 len, i32 x, i32 y){
    for (i32 k = 0; k < len; ++k){
        i32 idx = (head - k + MAX_LEN) % MAX_LEN;
        if (snake[idx].x == x && snake[idx].y == y)
            return 1;
    }
    return 0;
}

static void spawn_apple(const Point *snake, i32 head, i32 len, i32 *apple_x, i32 *apple_y){
    do {
        *apple_x = gd_randint(WIDTH);
        *apple_y = gd_randint(HEIGHT);
    } while (on_snake_circ(snake, head, len, *apple_x, *apple_y));
}

i32 main(){
    gd_font_init();

    int32_t hello_world[] = {
    7, 4, 11, 11, 14,
    22, 14, 17, 11, 3
    };
    gd_draw_text(10, 10, hello_world, 10, 1);



    Point snake[MAX_LEN];
    i32 head = 2;
    i32 len = 3;
    i32 dx = 1, dy = 0;
    
    snake[0].x = WIDTH/2 - 2;
    snake[0].y = HEIGHT/2;
    snake[1].x = WIDTH/2 - 1;
    snake[1].y = HEIGHT/2;
    snake[2].x = WIDTH/2;
    snake[2].y = HEIGHT/2;

    i32 apple_x, apple_y;
    spawn_apple(snake, head, len, &apple_x, &apple_y);

    // draw initial body
    for (i32 i = 0; i < len; ++i)
        gd_draw_pixel(snake[i].x, snake[i].y, 1);
    gd_draw_pixel(apple_x, apple_y, 2);

    while (1) {
        if (gd_up_pressed() && dy == 0) { dx = 0; dy = 1; }
        else if (gd_w_pressed() && dy == 0) { dx = 0; dy = -1; }
        else if (gd_left_pressed() && dx == 0) { dx = -1; dy = 0; }
        else if (gd_right_pressed() && dx == 0) { dx = 1; dy = 0; }

        i32 new_x = snake[head].x + dx;
        i32 new_y = snake[head].y + dy;

        if (new_x < 0 || new_x >= WIDTH || new_y < 0 || new_y >= HEIGHT)
            break;
        if (on_snake_circ(snake, head, len, new_x, new_y))
            break;

        bool32 ate = (new_x == apple_x && new_y == apple_y);

        if (!ate) {
            i32 temp = len - 1;
            i32 tail = (head - temp + MAX_LEN) % MAX_LEN;
            gd_draw_pixel(snake[tail].x, snake[tail].y, 0); // erase tail
        } else {
            if (len >= MAX_LEN)
                break;
            len++;
        }

        head = (head + 1) % MAX_LEN;
        snake[head].x = new_x;
        snake[head].y = new_y;
        gd_draw_pixel(new_x, new_y, 1); // draw head

        if (ate) {
            spawn_apple(snake, head, len, &apple_x, &apple_y);
            gd_draw_pixel(apple_x, apple_y, 2);
        }

        gd_waitnextframe();
    }

    return 0;
}

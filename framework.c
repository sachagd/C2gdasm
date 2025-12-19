#include <stdint.h>

#define BASE_COLOR_GROUP 205

// subtick ops

__attribute__((noinline, regparm(2))) void gd_draw_pixel_simplified(int32_t p, int32_t color);
__attribute__((noinline, regparm(1))) int32_t gd_get_pixel_simplified(int32_t p);

__attribute__((noinline)) int32_t gd_a_pressed();
__attribute__((noinline)) int32_t gd_w_pressed();
__attribute__((noinline)) int32_t gd_d_pressed();
__attribute__((noinline)) int32_t gd_left_pressed();
__attribute__((noinline)) int32_t gd_up_pressed();
__attribute__((noinline)) int32_t gd_right_pressed();

__attribute__((noinline)) void gd_waitnextframe();

__attribute__((noinline, regparm(1))) int32_t gd_randint(int32_t max);

// ...

#ifdef GD_GET_PIXEL
int32_t gd_get_pixel(int32_t x, int32_t y){
    return gd_get_pixel_simplified(x + 80 * y);
} 
#endif


#ifdef GD_DRAW_TEXT
#include "gd_font_meta.inc"
#include "gd_font_points.inc"

#define gd_font_init();                             \
    __asm__ __volatile__(                                 \
        GD_FONT_META_PUSHES                               \
        "movl %esp, %esi\n"                               \
        GD_FONT_POINTS_PUSHES                             \
        "movl %esp, %edi\n"                               \
    );

void gd_draw_text(int32_t x, int32_t y, int32_t *s, int32_t len, int32_t c){
    int32_t *meta_base;
    int32_t *points_base;

    __asm__ __volatile__(
        "movl %%esi, %0\n"
        "movl %%edi, %1\n"
        : "=r"(meta_base), "=r"(points_base)
    );

    int32_t (*meta)[2]   = (int32_t (*)[2])meta_base;
    int32_t (*points)[2] = (int32_t (*)[2])points_base;

    int32_t color  = c + BASE_COLOR_GROUP;
    int32_t base_x = x;

    for (int32_t i = 0; i < len; ++i) {
        int32_t code = s[i];
        int32_t start = meta[code][0];
        int32_t count = meta[code][1];

        for (int32_t k = 0; k < count; ++k) {
            int32_t dx = points[start + k][0];
            int32_t dy = points[start + k][1];
            gd_draw_pixel_simplified(base_x + dx + 80 * (y + dy), color);
        }

        base_x += 3 + 1;
    }
}
#endif 


#ifdef GD_DRAW_PIXEL
void gd_draw_pixel(int32_t x, int32_t y, int32_t c){
    int32_t color = c + BASE_COLOR_GROUP;
    gd_draw_pixel_simplified(x + 80 * y, color);
} 
#endif


#ifdef GD_DRAW_RECT
void gd_draw_rect(int32_t x, int32_t y, int32_t w, int32_t h, int32_t c){
    int32_t color = c + BASE_COLOR_GROUP;
    for (int i = 0; i < w; i++){
        for (int j = 0; j < h; j++){
            gd_draw_pixel_simplified(x + i + 80 * (y + j), color);
        }
    }
}
#endif


#ifdef GD_DRAW_SCREEN
void gd_draw_screen(int32_t c){
    int32_t color = c + BASE_COLOR_GROUP;
    for (int i = 0; i < 80; i++){
        for (int j = 0; j < 50; j++){
            gd_draw_pixel_simplified(i + 80 * j, color);
        }
    }
}
#endif
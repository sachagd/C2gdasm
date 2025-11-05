#include <stdint.h>

// subtick ops

__attribute__((noinline, regparm(2))) void gd_putpixel_simplified(int32_t p, int32_t color);

__attribute__((noinline)) int32_t gd_a_pressed();
__attribute__((noinline)) int32_t gd_w_pressed();
__attribute__((noinline)) int32_t gd_d_pressed();
__attribute__((noinline)) int32_t gd_left_pressed();
__attribute__((noinline)) int32_t gd_up_pressed();
__attribute__((noinline)) int32_t gd_right_pressed();

__attribute__((noinline)) void gd_waitnextframe();

__attribute__((noinline, regparm(1))) int32_t gd_randint(int32_t max);

// ...

void gd_putpixel(int32_t x, int32_t y, int32_t c){
    gd_putpixel_simplified(x + 80 * y, c);
}  

void gd_rect(int32_t x, int32_t y, int32_t w, int32_t h, int32_t c){
    for (int i = 0; i < h; i++){
        for (int j = 0; j < w; j++){
            gd_putpixel(x + i, y + j, c);
        }
    }
}


// __attribute__((noinline, regparm(3))) void gd_setmode(int32_t mode);
// __attribute__((noinline, regparm(3))) void gd_setviewport(int32_t x, int32_t y, int32_t wh);
// __attribute__((noinline, regparm(3))) void gd_setorigin(int32_t ox, int32_t oy, int32_t _); 
// __attribute__((noinline, regparm(3))) void gd_setpalb(int32_t idx, int32_t b, int32_t _);
// __attribute__((noinline, regparm(3))) void gd_settarget(int32_t id, int32_t _, int32_t __); 
// __attribute__((noinline, regparm(3))) void gd_swapbuffers(int32_t which, int32_t _, int32_t __);
// __attribute__((noinline, regparm(3))) int32_t gd_getpixel(int32_t x, int32_t y, int32_t _);
// __attribute__((noinline)) int sys_pollkeys();


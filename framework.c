#include <stdint.h>

// subtick ops

__attribute__((noinline, regparm(3))) void gd_setmode(uint32_t mode);
__attribute__((noinline, regparm(3))) void gd_setviewport(uint32_t x, uint32_t y, uint32_t wh);
__attribute__((noinline, regparm(3))) void gd_setorigin(uint32_t ox, uint32_t oy, uint32_t _); 

__attribute__((noinline, regparm(3))) void gd_setpalb(uint32_t idx, uint32_t b, uint32_t _);

__attribute__((noinline, regparm(3))) void gd_putpixel(uint32_t x, uint32_t y, uint32_t color);

__attribute__((noinline, regparm(3))) void gd_settarget(uint32_t id, uint32_t _, uint32_t __); 
__attribute__((noinline, regparm(3))) void gd_swapbuffers(uint32_t which, uint32_t _, uint32_t __);

__attribute__((noinline, regparm(3))) uint32_t gd_getpixel(uint32_t x, uint32_t y, uint32_t _);

__attribute__((noinline)) int sys_pollkeys();

// ...

void gd_rect(uint32_t x, uint32_t y, uint32_t w, uint32_t h, uint32_t c){
    for (int i = 0; i < h; i++){
        for (int j = 0; j < w; j++){
            gd_putpixel(x + i, y + j, c);
        }
    }
}
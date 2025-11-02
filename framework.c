#include <stdint.h>

// one-time init / context switches
__attribute__((noinline, regparm(3))) void gd_setmode(uint32_t mode);         // e.g., choose buffer/space
__attribute__((noinline, regparm(3))) void gd_setviewport(uint32_t x, uint32_t y, uint32_t wh); // pack w|h if needed
__attribute__((noinline, regparm(3))) void gd_setorigin(uint32_t ox, uint32_t oy, uint32_t _);  // logical origin

// palette / colors (indexed or direct, as you implement)
__attribute__((noinline, regparm(3))) void gd_setpalette(uint32_t idx, uint32_t r, uint32_t g);    // (b from next op or packed)
__attribute__((noinline, regparm(3))) void gd_setpalb(uint32_t idx, uint32_t b, uint32_t _);

// drawing atomics
__attribute__((noinline, regparm(3))) void gd_putpixel(uint32_t x, uint32_t y, uint32_t color);

// buffer control (only if you can do them with constant sub-tick footprint)
__attribute__((noinline, regparm(3))) void gd_settarget(uint32_t id, uint32_t _, uint32_t __);  // select buffer/layer
__attribute__((noinline, regparm(3))) void gd_swapbuffers(uint32_t which, uint32_t _, uint32_t __);

// optional readback (only if trivial for you)
__attribute__((noinline, regparm(3))) uint32_t gd_getpixel(uint32_t x, uint32_t y, uint32_t _);

__attribute__((noinline)) int sys_pollkeys();

void gd_rect(uint32_t x, uint32_t y, uint32_t w, uint32_t h, uint32_t c){
    for (int i = 0; i < h; i++){
        for (int j = 0; j < w; j++){
            gd_putpixel(x + i, y + j, c);
        }
    }
}
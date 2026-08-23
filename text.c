#include <stdint.h>
#define GD_DRAW_TEXT
#include "framework.c"

typedef int32_t i32;
typedef int32_t bool32;
typedef int32_t char32;
typedef int32_t short32;


i32 main(){
    gd_font_init();

    int32_t hello_world[] = {
    7, 4, 11, 11, 14,
    22, 14, 17, 11, 3
    };
    gd_draw_text(10, 10, hello_world, 10, 1);

    while (1){
        
    }

    return 0;
}

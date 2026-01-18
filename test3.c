#include <stdint.h>
#include <stdio.h>

void print_binary_int32(int32_t x) {
    uint32_t u = (uint32_t)x;          // reinterpret bits
    for (int i = 31; i >= 0; --i) {
        putchar((u >> i) & 1u ? '1' : '0');
        if (i % 4 == 0 && i != 0) putchar(' '); // optional nibble grouping
    }
    putchar('\n');
}

int main(){
    int32_t a = (1 << 28) + (1 << 29) + (1 << 26);
    int32_t b = a + a;
    int32_t c = b + b;
    int32_t d = c + c;
    int32_t e = d + d;
    int32_t f = e + e;
    int32_t g = f + f;
    printf("%i, %i, %i, %i, %i, %i, %i\n", a, b, c, d, e, f, g);
    print_binary_int32(a);
    print_binary_int32(b);
    print_binary_int32(c);
    print_binary_int32(d);
    print_binary_int32(e);
    print_binary_int32(f);
    print_binary_int32(g);
    return 0;
}
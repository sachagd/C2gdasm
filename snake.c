// #include <stdint.h>
// #include <stdbool.h>

// typedef int32_t  i32;
// typedef uint32_t u32;
// typedef int32_t  bool32;
// typedef int32_t  char32;
// typedef int32_t  short32;

// #define BOOL_TRUE  ((bool32)1)
// #define BOOL_FALSE ((bool32)0)

// i32 global_a = 1234;
// u32 global_b = 0xCAFEBABE;

// static inline i32 addmul(i32 a, i32 b, i32 c) {
//     return (a + b) * c;
// }

// i32 mix_arith(i32 x, i32 y) {
//     i32 z = x - y;
//     z += (x ^ y) & 0xFF00FF00;
//     z |= (x & 0xF0F0F0F0) ^ (y | 0x0F0F0F0F);
//     z = (z << 3) | (z >> 5);
//     z ^= (z << 7);
//     z += addmul(x, y, z);
//     return z;
// }

// bool32 bool_logic(i32 a, i32 b) {
//     bool32 eq  = (a == b);
//     bool32 neq = (a != b);
//     bool32 lt  = (a <  b);
//     bool32 le  = (a <= b);
//     bool32 gt  = (a >  b);
//     bool32 ge  = (a >= b);
//     bool32 result = (eq | gt) & ~(lt ^ ge) | neq;
//     return result;
// }

// i32 loop_bits(i32 val) {
//     i32 count = 0;
//     while (val) {
//         count += val & 1;
//         val >>= 1;
//     }
//     return count;
// }

// i32 cond_branch(i32 x) {
//     i32 out = 0;
//     if (x & 1) out += x * 3;
//     else       out -= x * 2;
//     if ((x & 0xF0F0F0F0) == 0xA0A0A0A0)
//         out ^= 0xAAAAAAAA;
//     return out;
// }

// struct Pair { i32 x; i32 y; };

// i32 struct_ops(struct Pair *p) {
//     i32 s = p->x + p->y;
//     p->x = (p->x << 1) ^ p->y;
//     p->y = (p->y >> 1) + s;
//     return s ^ (p->x | p->y);
// }

// i32 arrays_and_pointers(i32 *arr, i32 n) {
//     i32 sum = 0;
//     for (i32 i = 0; i < n; ++i)
//         sum += (arr[i] ^ (i << 2)) & 0xFFFF;
//     return sum;
// }

// i32 recursion_test(i32 x) {
//     if (x <= 1) return 1;
//     return x * recursion_test(x - 1);
// }

// i32 all_together_now(i32 seed) {
//     struct Pair p = { seed, seed ^ 0x55555555 };
//     i32 arr[8];
//     for (i32 i = 0; i < 8; ++i)
//         arr[i] = mix_arith(i, seed) ^ global_b;

//     i32 result = 0;
//     result += mix_arith(global_a, seed);
//     result += loop_bits(seed);
//     result ^= cond_branch(seed);
//     result ^= struct_ops(&p);
//     result += arrays_and_pointers(arr, 8);
//     result ^= recursion_test((seed & 7) + 3);
//     result ^= bool_logic(seed, result);
//     return result;
// }

// int main(void) {
//     i32 total = 0;
//     for (i32 i = 1; i <= 100; ++i)
//         total ^= all_together_now(i);
//     return (int)total;
// }

// int main(void){
//     bool c = true;
//     int keys=sys_pollkeys();
//     gd_rect(5,6,10,12,4);
// }

#include <stdbool.h>
#include <stdint.h>

int main(void){
    uint32_t a = 256;
    uint32_t b = 342;
    uint32_t c = a * b;
}


int lt(uint32_t a, uint32_t b) {
    int x = a * b;
    if (x < 0){
        return 0;
    }
}
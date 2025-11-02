#include <stdlib.h>

int main(void){
    int * t = malloc(sizeof(int) * 8);
    t[0] = 199;
    t[1] = 199;
    t[2] = 199;
    t[3] = 199;
    t[4] = 199;
    t[5] = 199;
    t[6] = 199;
    t[7] = 199;
    free(t);
    return 0;
}
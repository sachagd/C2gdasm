#include <stdio.h>
#include <stdbool.h>

int main(void) {
    bool c = true;
    int primes[1000];
    int count = 0;
    int candidate = 2;

    while (count < 1000) {
        int isPrime = 1;
        int j = 0;
        while (j < count
               && primes[j] * primes[j] <= candidate
               && isPrime)
        {
            if (candidate % primes[j] == 0) {
                isPrime = 0;
            }
            j++;
        }

        if (isPrime) {
            primes[count++] = candidate;
        }
        candidate++;
    }
    return 0;
}
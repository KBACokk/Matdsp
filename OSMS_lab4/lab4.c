#include <stdio.h>

#define LEN 31

void generate_gold(const int x_init[5], const int y_init[5], int out_seq[LEN]) {
    int x[5], y[5];
    for (int i = 0; i < 5; i++) {
        x[i] = x_init[i];
        y[i] = y_init[i];
    }

    for (int step = 0; step < LEN; step++) {
        out_seq[step] = x[4] ^ y[4];

        int xor_x = x[3] ^ x[4];
        int xor_y = y[1] ^ y[4];

        for (int j = 4; j > 0; j--) {
            x[j] = x[j - 1];
            y[j] = y[j - 1];
        }
        x[0] = xor_x;
        y[0] = xor_y;
    }
}

double calc_correlation(const int seq1[LEN], const int seq2[LEN], int *sovp, int *nesovp) {
    int m = 0;
    for (int i = 0; i < LEN; i++) {
        if (seq1[i] == seq2[i]) {
            m++;
        }
    }
    *sovp = m; 
    *nesovp = LEN - m;
    return (double)(*sovp - *nesovp) / LEN;
}

int main(void) {
    int x1[5] = {1, 0, 1, 1, 1};
    int y1[5] = {1, 1, 1, 1, 0};
    int gold1[LEN];

    generate_gold(x1, y1, gold1);

    printf("1) Последовательность Голда (Вариант 23):\n");
    for (int i = 0; i < LEN; i++) {
        printf("%d", gold1[i]);
    }
    printf("\n\n");

    printf("2) таблица сдвигов и автокорреляция \n");
    printf("Сдвиг | Последовательность бит          | Автокорреляция \n");
    printf("----------------------------------------------------------\n");

    int shifted[LEN];
    for (int shift = 0; shift <= LEN; shift++) {
        for (int i = 0; i < LEN; i++) {
            shifted[i] = gold1[(i - shift + LEN * 2) % LEN];
        }

        int m = 0, mm = 0;
        double r = calc_correlation(gold1, shifted, &m, &mm);

        printf("%5d | ", shift);
        for (int i = 0; i < LEN; i++) {
            printf("%d", shifted[i]);
        }
        printf(" | %3d/31 (%+.4f)\n", m - mm, r);
    }

    int x2[5] = {1, 1, 0, 0, 0};
    int y2[5] = {1, 1, 0, 0, 1};
    int gold2[LEN];

    generate_gold(x2, y2, gold2);

    int cm = 0, cmm = 0;
    double cross_r = calc_correlation(gold1, gold2, &cm, &cmm);

    // printf("2) таблица сдвигов и автокорреляция для второй последовательности \n");
    // int shifted2[LEN];
    // for (int shift = 0; shift <= LEN; shift++) {
    //     for (int i = 0; i < LEN; i++) {
    //         shifted2[i] = gold2[(i - shift + LEN * 2) % LEN];
    //     }

    //     int m = 0, mm = 0;
    //     double r = calc_correlation(gold2, shifted2, &m, &mm);

    //     printf("%5d | ", shift);
    //     for (int i = 0; i < LEN; i++) {
    //         printf("%d", shifted2[i]);
    //     }
    //     printf(" | %3d/31 (%+.4f)\n", m - mm, r);
    // }

    printf("\n3) Итоговые последовательности\n");
    for (int i = 0; i < LEN; i++) {
        printf("|%d|", gold1[i]);
    }
    printf ("\n");
    for (int i = 0; i < LEN; i++) {
        printf("|%d|", gold2[i]);
    }
    printf("\n");
    for (int i = 0; i < LEN; i++) {
            if (gold1[i] == gold2[i]) {
                printf ("|\x1b[1;32mс\x1b[0m|");
            }
            else {
                printf ("|\x1b[1;31mо\x1b[0m|");
            }
            
        }
    printf ("\n \x1b[1;32mс\x1b[0m - совпадают;\n \x1b[1;31mо\x1b[0m - отличаются\n"); 
    printf("\n4) Взаимная корреляция %d/31 (%+.4f)\n", cm - cmm, cross_r);

    return 0;
}
#include<stdio.h>

int main()
{
   int a = 2;
   int b = 3;
   printf(a);
   printf(b);
   int* pa = &a;
   int* p = &b;
   int** pb = &pa;
   pb = &p;
   printf(~pa);
   printf(~pb);
   printf(~~pb);
   return 0;
}

// #include<stdio.h>

// int main()
// {
//    int a = 2;
//    int b = 3;
//    printf(a);
//    printf(b);
//    int* pa = &a;
//    int* pb = &b;
//    int t = ~pb;
//    ~pb = ~pa;
//    ~pa = t*~pb*~pa / ~pb;
//    printf(~pa);
//    printf(~pb);
//    return 0;
// }

// #include<stdio.h>

// int main(){
//     int b[4];
//     b[2] = 6;
//     b[1] = 2;
//     int c;
//     c =  b[2];
//     int d = b[1];
//     c = c+d;
//     printf(c);
//     return 0;
// }

// #include<stdio.h>


// int main() {
//    int a = 50;
//    int sum = -1;

//    // outer loop
//    for (int i = 0; i < a * 2; i++) {
//        // inner loop
//        for (int j = 0; j < a ; j++) {
//            if (j < a / 2 && j % 2 != 0 ) {
//                sum = sum +  i * j / 2 + i * j;
//            } else {
//                while (sum > j || ! sum % 2 == 1) {
//                    sum = sum - 3 / 2;
//                }
//            }
//        }
//    }

//    // print the value of `sum`
//    printf( sum);

//    return 0;
// }


// #include<stdio.h>

// int main() {
//    int a = 1, b = 1;
//    int c;

//    // Fibonacci
//    for (int i = 2; i < 20; i++) {
//        c = a;
//        a = a + b;
//        b = c;
//    }
//    printf( a);
//    printf( b);
//    return 0;
// }



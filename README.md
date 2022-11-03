#lexer/C.lex使用方式

1.进入到lexer目录下，运行 lex C.lex

2.这个时候你会看到lexer目录下会生成lex.yy.c

3.gcc编译该c程序，gcc -o first lex.yy.c，得到可执行程序first

4.运行 ./first < main.c（main.c是你要进行词法分析的文件）

5.最终得到记号文件 testout.txt

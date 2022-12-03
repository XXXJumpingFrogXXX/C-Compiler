%option noinput
%{
    #include "y.tab.h"
    #include <string.h>
    int countn=0;
    int cnt=0;
    struct sym{
        char* idd;
    } s[1000];
    void addvalue(char* y);
%}
alpha [a-zA-Z]
digit [0-9]
unary "++"|"--"
%%

"printf"                    { strcpy(yylval.nd_obj.name,(yytext)); printf("PRINTFF\t\t%s\t\t\n",yytext); return PRINTFF; }
"scanf"                     { strcpy(yylval.nd_obj.name,(yytext)); printf("SCANFF\t\t%s\t\t\n",yytext); return SCANFF; }
"int"                       { strcpy(yylval.nd_obj.name,(yytext)); printf("INT\t\t%s\t\t\n",yytext); return INT; }
"float"                     { strcpy(yylval.nd_obj.name,(yytext)); printf("FLOAT\t\t%s\t\t\n",yytext); return FLOAT; }
"char"                      { strcpy(yylval.nd_obj.name,(yytext)); printf("CHAR\t\t%s\t\t\n",yytext); return CHAR; }
"void"                      { strcpy(yylval.nd_obj.name,(yytext)); printf("VOID\t\t%s\t\t\n",yytext); return VOID; }
"return"                    { strcpy(yylval.nd_obj.name,(yytext)); printf("RETURN\t\t%s\t\t\n",yytext); return RETURN; }
"for"	                    { strcpy(yylval.nd_obj.name,(yytext)); printf("FOR\t\t%s\t\t\n",yytext); return FOR; }
"while"                     { strcpy(yylval.nd_obj.name,(yytext)); printf("WHILE\t\t%s\t\t\n",yytext); return WHILE; }
"if"	                    { strcpy(yylval.nd_obj.name,(yytext)); printf("IF\t\t%s\t\t\n",yytext); return IF; }
"else"	                    { strcpy(yylval.nd_obj.name,(yytext)); printf("ELSE\t\t%s\t\t\n",yytext); return ELSE; }
^"#include"[ ]*<.+(\.h)?>      { strcpy(yylval.nd_obj.name,(yytext)); printf("INCLUDE\t\t%s\t\t\n",yytext); return INCLUDE; }
"true"                      { strcpy(yylval.nd_obj.name,(yytext)); printf("TRUE\t\t%s\t\t\n",yytext); return TRUE; }
"false"                     { strcpy(yylval.nd_obj.name,(yytext)); printf("FALSE\t\t%s\t\t\n",yytext); return FALSE; }
[-]?{digit}+                { strcpy(yylval.nd_obj.name,(yytext)); printf("NUMBER\t\t%s\t\t%s\n",yytext,yytext); return NUMBER; }
[-]?{digit}+\.{digit}{1,6}  { strcpy(yylval.nd_obj.name,(yytext)); printf("FLOAT_NUM\t\t%s\t\t%s\n",yytext,yytext); return FLOAT_NUM; }
({alpha}|_)({alpha}|{digit}|_)*   { strcpy(yylval.nd_obj.name,(yytext)); printf("ID\t\t%s\t\t",yytext); addvalue(yylval.nd_obj.name); return ID;}
{unary}                     { strcpy(yylval.nd_obj.name,(yytext)); printf("UNARY\t\t%s\t\t\n",yytext); return UNARY; }
"<="                        { strcpy(yylval.nd_obj.name,(yytext)); printf("LE\t\t%s\t\t\n",yytext); return LE; }
">="                        { strcpy(yylval.nd_obj.name,(yytext)); printf("GE\t\t%s\t\t\n",yytext); return GE; }
"=="                        { strcpy(yylval.nd_obj.name,(yytext)); printf("EQ\t\t%s\t\t\n",yytext); return EQ; }
"!="                        { strcpy(yylval.nd_obj.name,(yytext)); printf("NE\t\t%s\t\t\n",yytext); return NE; }
"!"                         { strcpy(yylval.nd_obj.name,(yytext)); printf("NOO\t\t%s\t\t\n",yytext); return NOO; }
">"	                        { strcpy(yylval.nd_obj.name,(yytext)); printf("GT\t\t%s\t\t\n",yytext); return GT; }
"<"	                        { strcpy(yylval.nd_obj.name,(yytext)); printf("LT\t\t%s\t\t\n",yytext); return LT; }
"&&"	                    { strcpy(yylval.nd_obj.name,(yytext)); printf("AND\t\t%s\t\t\n",yytext); return AND; }
"||"	                    { strcpy(yylval.nd_obj.name,(yytext)); printf("OR\t\t%s\t\t\n",yytext); return OR; }
"+"                         { strcpy(yylval.nd_obj.name,(yytext)); printf("ADD\t\t%s\t\t\n",yytext); return ADD; }
"-"                         { strcpy(yylval.nd_obj.name,(yytext)); printf("SUBTRACT\t%s\t\t\n",yytext); return SUBTRACT; }
"/"                         { strcpy(yylval.nd_obj.name,(yytext)); printf("DIVIDE\t\t%s\t\t\n",yytext); return DIVIDE; }
"%"                         { strcpy(yylval.nd_obj.name,(yytext)); printf("MODE\t\t%s\t\t\n",yytext); return MODE; }
"*"                         { strcpy(yylval.nd_obj.name,(yytext)); printf("MULTIPLY\t%s\t\t\n",yytext); return MULTIPLY; }
\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; }
[ \t]*                      { ; }
[\n]                        { countn++; }
.	                        { return *yytext; }
["].*["]                    { strcpy(yylval.nd_obj.name,(yytext)); printf("STR\t\t%s\t\t\n",yytext); return STR; }
['].[']                     { strcpy(yylval.nd_obj.name,(yytext)); printf("CHARACTER\t\t%s\t\t\n",yytext); return CHARACTER; }

%%

int yywrap() {
    return 1;
}

void addvalue(char *y){
    int i = 0;
    for (;i<cnt;i++){
        if (strcmp(y,s[i].idd)==0) {
            fprintf(yyout,"%ld\n",&s[i]);
            return;
        }
    }
    s[i].idd=strdup(y);
    cnt++;
    fprintf(yyout,"%ld\n",&s[i]);
    return;
}
%{
    #include"node.h"
    #include"parser.tab.h"
    string remove_ws(char* str, int len);
    string get_header(char* str, int len);
    int cnt=0;
    struct sym{
        char* idd;
    } s[64];
    int addvalue(char* y);
%}

%option yylineno

WS                  [\n\t ]+
number              [0-9]
letter              [A-Za-z]
INTEGER             ("+"|"-")?[1-9]{number}*|0
STRING              \"(\\.|[^"\\])*\"
ID                  ({letter}|_)({letter}|_|{number})*
ERROR               {number}+({letter}|_)+
TYPE                int({WS}|\*)*
INCLUDE             ^"#include"[ ]*<{letter}*+(\.h)?>
COMMENT             ("//"[^\n]*)|("/*"([^\*]|(\*)*[^\*/])*(\*)*"*/")

%%

{COMMENT}           {;}
{WS}                {;}
{INCLUDE}           {string temp(get_header(yytext, yyleng));yylval.node = new Node(temp, 0, yylineno); printf("INCLUDE\t\t%s\t\t\t\t%d\n",temp.c_str(),yylineno);return INCLUDE;}
{INTEGER}           {string temp(yytext);yylval.node=new Node(temp, atoi(yytext), yylineno);printf("INTEGER\t\t%d\t\t%d\t\t%d\n",yylval.node->val,yylval.node->val,yylineno);return INTEGER;}
"+"                 {yylval.node = new Node("", 0, yylineno);printf("PLUS\t\t%s\t\t\t\t%d\n",yytext,yylineno);return PLUS;}
"-"                 {yylval.node = new Node("", 0, yylineno);printf("MINUS\t\t%s\t\t\t\t%d\n",yytext,yylineno);return MINUS;}
"*"                 {yylval.node = new Node("", 0, yylineno);printf("MULTIPLY\t%s\t\t\t\t%d\n",yytext,yylineno);return MULTIPLY;}
"/"                 {yylval.node = new Node("", 0, yylineno);printf("DIVIDE\t\t%s\t\t\t\t%d\n",yytext,yylineno);return DIVIDE;}
"%"                 {yylval.node = new Node("", 0, yylineno);printf("MODEL\t\t%s\t\t\t\t%d\n",yytext,yylineno);return MODEL;}
"^"                 {yylval.node = new Node("", 0, yylineno);printf("POW\t\t%s\t\t\t\t%d\n",yytext,yylineno);return POW;}
">"                 {yylval.node = new Node("", 0, yylineno);printf("GREATER\t\t%s\t\t\t\t%d\n",yytext,yylineno);return GREATER;}
">="                {yylval.node = new Node("", 0, yylineno);printf("GREATEREQ\t%s\t\t\t\t%d\n",yytext,yylineno);return GREATEREQ;}
"<"                 {yylval.node = new Node("", 0, yylineno);printf("LESS\t\t%s\t\t\t\t%d\n",yytext,yylineno);return LESS;}
"<="                {yylval.node = new Node("", 0, yylineno);printf("LESSEQ\t\t%s\t\t\t\t%d\n",yytext,yylineno);return LESSEQ;}
"!="                {yylval.node = new Node("", 0, yylineno);printf("NEQUAL\t\t%s\t\t\t\t%d\n",yytext,yylineno);return NEQUAL;}
"=="                {yylval.node = new Node("", 0, yylineno);printf("EQUAL\t\t%s\t\t\t\t%d\n",yytext,yylineno);return EQUAL;}
"++"                {yylval.node = new Node("", 0, yylineno);printf("SELFPLUS\t%s\t\t\t\t%d\n",yytext,yylineno);return SELFPLUS;}
"--"                {yylval.node = new Node("", 0, yylineno);printf("SELFMINUS\t%s\t\t\t\t%d\n",yytext,yylineno);return SELFMINUS;}
"!"                 {yylval.node = new Node("", 0, yylineno);printf("NOT\t\t%s\t\t\t\t%d\n",yytext,yylineno);return NOT;}
","                 {yylval.node = new Node("", 0, yylineno);printf("COMMA\t\t%s\t\t\t\t%d\n",yytext,yylineno);return COMMA;}
"."                 {yylval.node = new Node("", 0, yylineno);printf("DOT\t\t%s\t\t\t\t%d\n",yytext,yylineno);return DOT;}
":"                 {yylval.node = new Node("", 0, yylineno);printf("COLON\t\t%s\t\t\t\t%d\n",yytext,yylineno);return COLON;}
"&&"                {yylval.node = new Node("", 0, yylineno);printf("AND\t\t%s\t\t\t\t%d\n",yytext,yylineno);return AND;}
"&"                 {yylval.node = new Node("", 0, yylineno);printf("ADDR\t\t%s\t\t\t\t%d\n",yytext,yylineno);return ADDR;}
"~"                 {yylval.node = new Node("", 0, yylineno);printf("POINT\t\t%s\t\t\t\t%d\n",yytext,yylineno);return POINT;}
"||"                {yylval.node = new Node("", 0, yylineno);printf("OR\t\t%s\t\t\t\t%d\n",yytext,yylineno);return OR;}
"return"            {yylval.node = new Node("", 0, yylineno);printf("RETURN\t\t%s\t\t\t\t%d\n",yytext,yylineno);return RETURN;}
"main"              {yylval.node = new Node("MAIN", 0, yylineno);printf("MAIN\t\t%s\t\t\t\t%d\n",yytext,yylineno);return MAIN;}
"void"              {yylval.node = new Node("VOID", 0, yylineno);printf("VOID\t\t%s\t\t\t\t%d\n",yytext,yylineno);return VOID;}
{TYPE}              {yylval.node = new Node(remove_ws(yytext, yyleng), 0, yylineno);printf("TYPE\t\t%s\t\t%s\t\t%d\n",yylval.node->key.c_str(),yylval.node->key.c_str(),yylineno);return TYPE;}
"if"                {yylval.node = new Node("", 0, yylineno);printf("IF\t\t%s\t\t\t\t%d\n",yytext,yylineno);return IF;}
"else"              {yylval.node = new Node("", 0, yylineno);printf("ELSE\t\t%s\t\t\t\t%d\n",yytext,yylineno);return ELSE;}
"while"             {yylval.node = new Node("", 0, yylineno);printf("WHILE\t\t%s\t\t\t\t%d\n",yytext,yylineno);return WHILE;}
"for"               {yylval.node = new Node("", 0, yylineno);printf("FOR\t\t%s\t\t\t\t%d\n",yytext,yylineno);return FOR;}
"printf"            {yylval.node = new Node("", 0, yylineno);printf("PRINTF\t\t%s\t\t\t\t%d\n",yytext,yylineno);return PRINTF;}
"scanf"             {yylval.node = new Node("", 0, yylineno);printf("SCANF\t\t%s\t\t\t\t%d\n",yytext,yylineno);return SCANF;}
"="                 {yylval.node = new Node("", 0, yylineno);printf("ASSIGN\t\t%s\t\t\t\t%d\n",yytext,yylineno);return ASSIGN;}
"("                 {yylval.node = new Node("", 0, yylineno);printf("LP\t\t%s\t\t\t\t%d\n",yytext,yylineno);return LP;}
")"                 {yylval.node = new Node("", 0, yylineno);printf("RP\t\t%s\t\t\t\t%d\n",yytext,yylineno);return RP;}
"{"                 {yylval.node = new Node("", 0, yylineno);printf("LBRACE\t\t%s\t\t\t\t%d\n",yytext,yylineno);return LBRACE;}
"}"                 {yylval.node = new Node("", 0, yylineno);printf("RBRACE\t\t%s\t\t\t\t%d\n",yytext,yylineno);return RBRACE;}
"["                 {yylval.node = new Node("", 0, yylineno);printf("LMB\t\t%s\t\t\t\t%d\n",yytext,yylineno);return LMB;}
"]"                 {yylval.node = new Node("", 0, yylineno);printf("RMB\t\t%s\t\t\t\t%d\n",yytext,yylineno);return RMB;}
";"                 {yylval.node = new Node("", 0, yylineno);printf("SEMICOLON\t%s\t\t\t\t%d\n",yytext,yylineno);return SEMICOLON;}
{ID}                {string temp(yytext);yylval.node=new Node(temp, 0, yylineno);int i(addvalue(yytext));printf("ID\t\t%s\t\t%d\t\t%d\n",yytext,i,yylineno);return ID;}
{ERROR}             {return ERROR;}

%%

string remove_ws(char* str, int len) {
    string res = "";
    for(int i = 0; i < len; i++) {
        if(str[i] != ' ' && str[i] != '\t') {
            res += str[i];
        }
    }
    return res;
}


string get_header(char* str, int len) {
    string res = "";
    int i = 8;
    while (str[i++] != '<');
    for (; str[i] != '>'; i++){
        res += str[i];
    }
    return res;
}

// 区分ID
int addvalue(char *y){
    int i = 0;
    for (;i<cnt;i++){
        if (strcmp(y,s[i].idd)==0) {
            long int j = long(&s[i]);
            int k = j % 1000;
            return k;
        }
    }
    s[i].idd=strdup(y);
    cnt++;
    long int j = long(&s[i]);
    int k = j % 1000;
    return k;
}

int yywrap()
{
    return 1;
}
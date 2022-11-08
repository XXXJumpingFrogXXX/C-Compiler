%option noyywrap
%top{
#include<math.h>
}
%{
#define SIZEOF 1
#define CONST 2
#define TYPEDEF 3
#define VOLATILE 4
#define AUTO 5
#define STATIC 6
#define EXTERN 7
#define REGISTER 8
#define IF 9
#define ELSE 10
#define SWITCH 11
#define CASE 12
#define DEFAULT 13
#define FOR 14
#define WHILE 15
#define DO 16
#define BREAK 17
#define CONTINUE 18
#define RETURN 19
#define GOTO 20
#define INT 21
#define CHAR 22
#define FLOAT 23
#define DOUBLE 24
#define LONG 25
#define SHORT 26
#define SIGNED 27
#define UNSIGNED 28
#define STRUCT 29
#define UNION 30
#define ENUM 31
#define VOID 32
#define INLINE 33
#define RESTRICT 34
#define BOOL 35
#define COMPLEX 36
#define IMAGINARY 37

#define ID 38 //identifyer
#define UnsignedInteger 39
#define Integer 40
#define Decimal 41
#define ScientificNotation 42
#define Character 43
#define String 44
#define Comments 45

#define LC 46 //{
#define RC 47 //}
#define LB 48 //[
#define RB 49 //]
#define LP 50 //(
#define RP 51 //)
#define LOGRE 52 //~
#define OR 53 // |
#define HAT 54 // ^
#define INPLUS 55 //++
#define INMINUS 56 //--
#define LOCRE 57 //!
#define AND 58 //&
#define STAR 59 //*
#define DIVOP 60 // /
#define COMOP 61 // %
#define PLUS  62 //+
#define MINUS 63 //-
#define RELG 64 //>
#define RELGEQ 65 //>=
#define RELL 66 //<
#define RELLEQ 67 //<=
#define EQUOP 68 //==
#define UEQUOP 69 //!=
#define ANDAND 70 //&&
#define OROR 71 // ||
#define EQUAL 72 // =
#define ASSIGNDIV 73 // /=
#define ASSIGNSTAR 74 //*=
#define ASSIGNCOM 75 //%=
#define ASSIGNPLUS 76 //+=
#define ASSIGNMINUS 77 //-=
#define SAL 78 //<<
#define SAR 79 //>>
#define ASSIGNSAL 80 //<<=
#define ASSIGNSAR 81 //>>=
#define ASSIGNAND 82 //&=
#define ASSIGNHAT 83 //^=
#define ASSIGNOR 84 //|=
#define COMMA 85 //,
#define HASH 86 //#
#define SEMI 87 //;
#define COLON 88 //:

%}

white [\t\n ]
digit [0-9]
plus [1-9]
letter [A-Za-z]

ID ({letter}|_)({letter}|{digit}|_)*
UnsignedInteger {plus}{digit}*|0
Integer ("+"|"-")?{digit}+
Decimal {Integer}.{digit}+
ScientificNotation {Integer}.{digit}+("e"(("+"|"-"){UnsignedInteger})?)?
Character \'.\'
String \"(\\.|[^"\\])*\"
Comments ("//"[^\n]*)|("/*"([^\*]|(\*)*[^\*/])*(\*)*"*/")
%x COMMENT
%%
{white}+ ;
{UnsignedInteger} {fprintf(yyout,"UnsignedInteger %d %s\n",UnsignedInteger,yytext);}
{Integer} {fprintf(yyout,"Integer %d %s\n",Integer,yytext);}
{Decimal} {fprintf(yyout,"Decimal %d %s\n",Decimal,yytext);}
{ScientificNotation} {fprintf(yyout,"ScientificNotation %d %s\n",ScientificNotation,yytext);}
{Character} {fprintf(yyout,"Character %d %s\n",Character,yytext);}
{String} {fprintf(yyout,"String %d %s\n",String,yytext);}
{Comments} {fprintf(yyout,"Comments %d %s\n",Comments,yytext);}
"sizeof" {fprintf(yyout,"SIZEOF %d %s\n",SIZEOF,yytext);}
"const" {fprintf(yyout,"CONST %d %s\n",CONST,yytext);}
"typedef" {fprintf(yyout,"TYPEDEF %d %s\n",TYPEDEF,yytext);}
"volatile" {fprintf(yyout,"VOLATILE %d %s\n",VOLATILE,yytext);}
"auto" {fprintf(yyout,"AUTO %d %s\n",AUTO,yytext);}
"static" {fprintf(yyout,"STATIC %d %s\n",STATIC,yytext);}
"extern" {fprintf(yyout,"EXTERN %d %s\n",EXTERN,yytext);}
"register" {fprintf(yyout,"REGISTER %d %s\n",REGISTER,yytext);}
"if" {fprintf(yyout,"IF %d %s\n",IF,yytext);}
"else" {fprintf(yyout,"ELSE %d %s\n",ELSE,yytext);}
"switch" {fprintf(yyout,"SWITCH	%d %s\n",SWITCH,yytext);}
"case" {fprintf(yyout,"CASE %d %s\n",CASE,yytext);}
"default" {fprintf(yyout,"DEFAULT %d %s\n",DEFAULT,yytext);}
"for" {fprintf(yyout,"FOR %d %s\n",FOR,yytext);}
"while" {fprintf(yyout,"WHILE %d %s\n",WHILE,yytext);}
"do" {fprintf(yyout,"DO	%d %s\n",DO,yytext);}
"break" {fprintf(yyout,"BREAK %d %s\n",BREAK,yytext);}
"continue" {fprintf(yyout,"CONTINUE %d %s\n",CONTINUE,yytext);}
"return" {fprintf(yyout,"RETURN %d %s\n",RETURN,yytext);}
"goto" {fprintf(yyout,"GOTO %d %s\n",GOTO,yytext);}
"int"  {fprintf(yyout,"INT %d %s\n",INT,yytext);}
"char" {fprintf(yyout,"CHAR %d %s\n",CHAR,yytext);}
"float" {fprintf(yyout,"FLOAT %d %s\n",FLOAT,yytext);}
"double" {fprintf(yyout,"DOUBLE %d %s\n",DOUBLE,yytext);}
"long" {fprintf(yyout,"LONG %d %s\n",LONG,yytext);}
"short" {fprintf(yyout,"SHORT %d %s\n",SHORT,yytext);}
"signed" {fprintf(yyout,"SIGNED %d %s\n",SIGNED,yytext);}
"unsigned" {fprintf(yyout,"UNSIGNED %d %s\n",UNSIGNED,yytext);}
"struct" {fprintf(yyout,"STRUCT %d %s\n",STRUCT,yytext);}
"union" {fprintf(yyout,"UNION %d %s\n",UNION,yytext);}
"enum" {fprintf(yyout,"ENUM %d %s\n",ENUM,yytext);}
"void" {fprintf(yyout,"VOID %d %s\n",VOID,yytext);}
"inline" {fprintf(yyout,"INLINE %d %s\n",INLINE,yytext);}
"restrict" {fprintf(yyout,"RESTRICT %d %s\n",RESTRICT,yytext);}
"_Bool" {fprintf(yyout,"BOOL %d %s\n",BOOL,yytext);}
"_Complex" {fprintf(yyout,"COMPLEX %d %s\n",COMPLEX,yytext);}
"_Imaginary" {fprintf(yyout,"IMAGINARY %d %s\n",IMAGINARY,yytext);}
{ID} {fprintf(yyout,"ID %d %s\n",ID,yytext);}
"{" {fprintf(yyout,"LC %d %s\n",LC,yytext);}
"}" {fprintf(yyout,"RC %d %s\n",RC,yytext);}
"[" {fprintf(yyout,"LB %d %s\n",LB,yytext);}
"]" {fprintf(yyout,"RB %d %s\n",RB,yytext);}
"(" {fprintf(yyout,"LP %d %s\n",LP,yytext);}
")" {fprintf(yyout,"RP %d %s\n",RP,yytext);}
"~" {fprintf(yyout,"LOGRE %d %s\n",LOGRE,yytext);}
"|" {fprintf(yyout,"OR %d %s\n",OR,yytext);}
"^" {fprintf(yyout,"HAT %d %s\n",HAT,yytext);}
"++" {fprintf(yyout,"INPLUS %d %s\n",INPLUS,yytext);}
"--" {fprintf(yyout,"INMINUS %d %s\n",INMINUS,yytext);}
"!" {fprintf(yyout,"LOCRE %d %s\n",LOCRE,yytext);}
"&" {fprintf(yyout,"AND %d %s\n",AND,yytext);}
"*" {fprintf(yyout,"STAR %d %s\n",STAR,yytext);}
"/" {fprintf(yyout,"DIVOP %d %s\n",DIVOP,yytext);}
"%" {fprintf(yyout,"COMOP %d %s\n",COMOP,yytext);}
"+" {fprintf(yyout,"PLUS %d %s\n",PLUS,yytext);}
"-" {fprintf(yyout,"MINUS %d %s\n",MINUS,yytext);}
">" {fprintf(yyout,"RELG %d %s\n",RELG,yytext);}
"<" {fprintf(yyout,"RELL %d %s\n",RELL,yytext);}
">=" {fprintf(yyout,"RELGEQ %d %s\n",RELGEQ,yytext);}
"<=" {fprintf(yyout,"RELLEQ %d %s\n",RELLEQ,yytext);}
"==" {fprintf(yyout,"EQUOP %d %s\n",EQUOP,yytext);}
"!=" {fprintf(yyout,"UEQUOP %d %s\n",UEQUOP,yytext);}
"&&" {fprintf(yyout,"ANDAND %d %s\n",ANDAND,yytext);}
"||" {fprintf(yyout,"OROR %d %s\n",OROR,yytext);}
"=" {fprintf(yyout,"EQUAL %d %s\n",EQUAL,yytext);}
"/=" {fprintf(yyout,"ASSIGNDIV %d %s\n",ASSIGNDIV,yytext);}
"*=" {fprintf(yyout,"ASSIGNSTAR %d %s\n",ASSIGNSTAR,yytext);}
"%=" {fprintf(yyout,"ASSIGNCOM %d %s\n",ASSIGNCOM,yytext);}
"+=" {fprintf(yyout,"ASSIGNPLUS %d %s\n",ASSIGNPLUS,yytext);}
"-=" {fprintf(yyout,"ASSIGNMINUS %d %s\n",ASSIGNMINUS,yytext);}
"<<" {fprintf(yyout,"SAL %d %s\n",SAL,yytext);}
">>" {fprintf(yyout,"SAR %d %s\n",SAR,yytext);}
"<<=" {fprintf(yyout,"ASSIGNSAL %d %s\n",ASSIGNSAL,yytext);}
">>=" {fprintf(yyout,"ASSIGNSAR %d %s\n",ASSIGNSAR,yytext);}
"&=" {fprintf(yyout,"ASSIGNAND %d %s\n",ASSIGNAND,yytext);}
"^=" {fprintf(yyout,"ASSIGNHAT %d %s\n",ASSIGNHAT,yytext);}
"|=" {fprintf(yyout,"ASSIGNOR %d %s\n",ASSIGNOR,yytext);}
"," {fprintf(yyout,"COMMA %d %s\n",COMMA,yytext);}
"#" {fprintf(yyout,"HASH %d %s\n",HASH,yytext);}
";" {fprintf(yyout,"SEMI %d %s\n",SEMI,yytext);}
":" {fprintf(yyout,"COLON %d %s\n",COLON,yytext);}
%%
int main()
{
    yyout=fopen("testout.txt","w");
    fprintf(yyout,"token name value\n");
    yylex();
    return 0;
}
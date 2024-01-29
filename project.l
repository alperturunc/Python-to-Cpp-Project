digit	[0-9]
letter	[A-Za-z]
%{
  #include <stdio.h>
  #include <string.h>
  #include "y.tab.h"
  #include <iostream>
  using namespace std;
  //extern int yylval;
  int linenum=1;

%}
%%
"elif" {yylval.str = strdup(yytext);return ELIF;}
"if" {yylval.str = strdup(yytext); return IF;}
"else" {yylval.str = strdup(yytext); return ELSE;}
{letter}({letter}|{digit})* {yylval.str = strdup(yytext); return VAR;}
"-"?{digit}+   {yylval.str = strdup(yytext); return INTVAL;} 
"-"?{digit}+\.{digit}+ {yylval.str = strdup(yytext); return FLOATVAL;}
(\".+\")|(\'.+\') {yylval.str = strdup(yytext); return STRING;}
"+"|"-"|"*"|"/" {yylval.str = strdup(yytext); return OPERATOR;}
"=="|"!="|"<"|"<="|">"|">=" {yylval.str = strdup(yytext); return COMPARISON;}
"=" {yylval.str = strdup(yytext); return EQ;}
":" return COLON;
"(" {yylval.str = strdup(yytext); return OP;}
")" {yylval.str = strdup(yytext); return CP;}
"{" {yylval.str = strdup(yytext); return OCP;}
"}" {yylval.str = strdup(yytext); return CCP;}
("\t"|" "{6})+ {yylval.str = strdup(yytext);return TAB;}


\n	{linenum++;}
[ \t]+
%%

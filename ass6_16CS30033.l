%{
#include <stdio.h>
#include <string.h>
#include "ass6_16CS30033_translator.h"
#include <math.h>
#include "y.tab.h"
%}

SINGLELINE_COMMENT		             "//"[^\n]*
ALL_EXCEPT_STAR				[^"*"]|\n
ALL_EXCEPT_SLASH 				[^"/"]|\n
ALL_EXCEPT_SLASH_STAR 			[^"/""*"]|\n
MULTILINE_COMMENT 			"/*"{ALL_EXCEPT_STAR}*"*"("*"|({ALL_EXCEPT_SLASH_STAR}{ALL_EXCEPT_STAR}*"*"))*"/"
COMMENTS 				{SINGLELINE_COMMENT}|{MULTILINE_COMMENT}

KEYWORD "auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"inline"|"int"|"long"|"register"|"restrict"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"while"|"_Bool"|"_Complex"|"_Imaginary"

IDENTIFIER_NONDIGIT     		"_"|[a-zA-Z]
DIGIT					[0-9]
IDENTIFIER 				{IDENTIFIER_NONDIGIT}({IDENTIFIER_NONDIGIT}|{DIGIT})*

NONZERO_DIGIT  			[1-9]
INTEGER_CONSTANT 			"0"|{NONZERO_DIGIT}{DIGIT}*
SIGN 					"+"|"-"
DIGIT_SEQUENCE			{DIGIT}+
FRACTIONAL_CONSTANT		({DIGIT_SEQUENCE}?"."{DIGIT_SEQUENCE})|({DIGIT_SEQUENCE}".")
EXPONENT				(E){SIGN}?{DIGIT_SEQUENCE}|(e){SIGN}?{DIGIT_SEQUENCE}
FLOATING_CONSTANT			({FRACTIONAL_CONSTANT}{EXPONENT}?)|({DIGIT_SEQUENCE}{EXPONENT})
ENUMERATION_CONSTANT		{IDENTIFIER}
ESCAPE_SEQUENCE			"\\\'"|"\\\""|"\\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"|"\\0"
C_CHAR				[^"\'""\\"\n]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE			{C_CHAR}+
CHARACTER_CONSTANT		"\'"{C_CHAR_SEQUENCE}"\'"
CONSTANT 				{INTEGER_CONSTANT}|{FLOATING_CONSTANT}|{ENUMERATION_CONSTANT}|{CHARACTER_CONSTANT}

S_CHAR				[^"\"""\\"\n]|{ESCAPE_SEQUENCE}
S_CHAR_SEQUENCE			{S_CHAR}+
STRING_LITERAL			"\""{S_CHAR_SEQUENCE}?"\""

PUNCTUATOR 				"["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"

%%

{KEYWORD}		{
if(strcmp(yytext,"auto")==0)			{ return AUTO; }
if(strcmp(yytext,"enum")==0)			{ return ENUM; }
if(strcmp(yytext,"restrict")==0)		{ return RESTRICT; } 
if(strcmp(yytext,"unsigned")==0)		{ return UNSIGNED; }
if(strcmp(yytext,"break")==0)			{ return BREAK; }
if(strcmp(yytext,"extern")==0)			{ return EXTERN; }
if(strcmp(yytext,"return")==0)			{ return RETURN; }
if(strcmp(yytext,"void")==0)			{ return VOID; }
if(strcmp(yytext,"case")==0)			{ return CASE; }
if(strcmp(yytext,"float")==0)			{ return FLOAT; }
if(strcmp(yytext,"short")==0)			{ return SHORT; }
if(strcmp(yytext,"volatile")==0)		{ return VOLATILE; }
if(strcmp(yytext,"char")==0)		  	{ return CHAR; }
if(strcmp(yytext,"for")==0)				{ return FOR; }
if(strcmp(yytext,"signed")==0)		  	{ return SIGNED; }
if(strcmp(yytext,"while")==0)			{ return WHILE; }
if(strcmp(yytext,"const")==0)			{ return CONST; }
if(strcmp(yytext,"goto")==0)			{ return GOTO; }
if(strcmp(yytext,"sizeof")==0)			{ return SIZEOF; }
if(strcmp(yytext,"_Bool")==0)			{ return BOOL; }
if(strcmp(yytext,"continue")==0)		{ return CONTINUE; }
if(strcmp(yytext,"if")==0)			{ return IF; }
if(strcmp(yytext,"static")==0)			{ return STATIC; }
if(strcmp(yytext,"_Complex")==0)		{ return COMPLEX; }
if(strcmp(yytext,"default")==0)			{ return DEFAULT; }
if(strcmp(yytext,"inline")==0)			{ return INLINE; }
if(strcmp(yytext,"struct")==0)			{ return STRUCT; }
if(strcmp(yytext,"_Imaginary")==0)		{ return IMAGINARY; }
if(strcmp(yytext,"do")==0)			{ return DO; }
if(strcmp(yytext,"int")==0)			{ return INT; }
if(strcmp(yytext,"switch")==0)			{ return SWITCH; }
if(strcmp(yytext,"double")==0)			{ return DOUBLE; }
if(strcmp(yytext,"long")==0)			{ return LONG; }
if(strcmp(yytext,"typedef")==0)			{ return TYPEDEF; }
if(strcmp(yytext,"else")==0)			{ return ELSE; }
if(strcmp(yytext,"register")==0)		{ return REGISTER; }
if(strcmp(yytext,"union")==0)			{ return UNION; }
}



{IDENTIFIER} 			{	yylval.symp = current_table->lookup(yytext);
					return IDENTIFIER;}
{FLOATING_CONSTANT}	{	yylval.charval = yytext;
					return FLOATING_CONSTANT;}
{INTEGER_CONSTANT}	{	yylval.intval = atoi(yytext);
					return INTEGER_CONSTANT;	}	
{CHARACTER_CONSTANT}  	{	yylval.charval = yytext;
						return CHARACTER_CONSTANT;	}
{ENUMERATION_CONSTANT}	{	return ENUMERATION_CONSTANT;	}
{STRING_LITERAL}		{	yylval.charval = yytext;
					return STRING_LITERAL;	}
"\n"|" "|"\t"  			{}
{COMMENTS}            { 	

}

{PUNCTUATOR}	{	
	if(strcmp(yytext,"[") == 0) return LEFT_SQUARE;
	if(strcmp(yytext,")") == 0) return RIGHT_BRACE;
	if(strcmp(yytext,"{") == 0) return LEFT_CURLY;
	if(strcmp(yytext,"}") == 0) return RIGHT_CURLY;
	if(strcmp(yytext,".") == 0) return DOT;
	if(strcmp(yytext,"]") == 0) return RIGHT_SQUARE;
	if(strcmp(yytext,"(") == 0) return LEFT_BRACE;
	if(strcmp(yytext,"->") == 0) return POINTING_SYMBOL;

	if(strcmp(yytext,"++") == 0) return INCREMENT;
	if(strcmp(yytext,"+") == 0) return PLUS;
	if(strcmp(yytext,"-") == 0) return MINUS;
	if(strcmp(yytext,"~") == 0) return NEGATION;
	if(strcmp(yytext,"!") == 0) return EX_MARK;

	if(strcmp(yytext,"--") == 0) return DECREMENT;
	if(strcmp(yytext,"&") == 0) return AND_UNARY;
	if(strcmp(yytext,"*") == 0) return MULTIPLY;


	if(strcmp(yytext,"/") == 0) return DIVIDE;
	if(strcmp(yytext,">") == 0) return GREATER_THAN;
	if(strcmp(yytext,"<=") == 0) return LESS_THAN_EQUAL;
	if(strcmp(yytext,">=") == 0) return GREATER_THAN_EQUAL;
	if(strcmp(yytext,"==") == 0) return EQUALITY;
	if(strcmp(yytext,"!=") == 0) return NOT_EQUAL;

	if(strcmp(yytext,"%") == 0) return MODULO;
	if(strcmp(yytext,"<<") == 0) return LEFT_SHIFT;
	if(strcmp(yytext,">>") == 0) return RIGHT_SHIFT;
	if(strcmp(yytext,"<") == 0) return LESS_THAN;
	
	if(strcmp(yytext,"^") == 0) return XOR;
	if(strcmp(yytext,"|") == 0) return OR_LOGICAL;
	if(strcmp(yytext,"&&") == 0) return AND;
	if(strcmp(yytext,"||") == 0) return OR;


	if(strcmp(yytext,"/=") == 0) return DIV_EQUAL;
	if(strcmp(yytext,"^=") == 0) return XOR_EQUAL;
	if(strcmp(yytext,"|=") == 0) return OR_EQUAL;
	if(strcmp(yytext,"?") == 0) return QUESTION_MARK;
	if(strcmp(yytext,":") == 0) return COLON;
	if(strcmp(yytext,";") == 0) return SEMI_COLON;
	if(strcmp(yytext,"...") == 0) return ELLIPSES;
	if(strcmp(yytext,"=") == 0) return ASSIGNMENT;
	if(strcmp(yytext,"%=") == 0) return MOD_EQUAL;
	if(strcmp(yytext,"+=") == 0) return ADD_EQUAL;
	if(strcmp(yytext,"-=") == 0) return SUB_EQUAL;
	if(strcmp(yytext,"<<=") == 0) return LEFT_SHIFT_EQUAL;
	if(strcmp(yytext,">>=") == 0) return RIGHT_SHIFT_EQUAL;
	if(strcmp(yytext,"&=") == 0) return AND_EQUAL;
	if(strcmp(yytext,"*=") == 0) return MUL_EQUAL;
	if(strcmp(yytext,",") == 0) return COMMA;
}



%%


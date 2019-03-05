%{
#include <iostream>
#include <cstdlib>
#include <string>
#include <stdio.h>
#include <sstream>
#include "ass6_16CS30033_translator.h"

extern int yylex();
void yyerror(string s);
extern string Type;
vector <string> allstrings;

using namespace std;
%}


%union {
  int intval;
  char* charval;
  int instr;
  Symbol* symp;
  Sym_type* symtp;
  expr* E;
  statement* S;
  array* A;
  char unaryOperator;
} 
%token AUTO
%token ENUM
%token RESTRICT
%token UNSIGNED
%token BREAK
%token EXTERN
%token RETURN
%token VOID
%token CASE
%token FLOAT
%token SHORT
%token VOLATILE
%token CHAR
%token FOR
%token SIGNED
%token WHILE
%token CONST
%token GOTO
%token SIZEOF
%token BOOL
%token CONTINUE
%token IF
%token STATIC
%token COMPLEX
%token DEFAULT
%token INLINE
%token STRUCT
%token IMAGINARY
%token DO
%token INT
%token SWITCH
%token DOUBLE
%token LONG
%token TYPEDEF
%token ELSE
%token REGISTER
%token UNION
%token<symp> IDENTIFIER
%token<intval> INTEGER_CONSTANT
%token<charval> FLOATING_CONSTANT
%token<charval> CHARACTER_CONSTANT ENUMERATION_CONSTANT
%token<charval> STRING_LITERAL
%token LEFT_SQUARE
%token RIGHT_SQUARE
%token LEFT_BRACE
%token RIGHT_BRACE
%token LEFT_CURLY
%token RIGHT_CURLY
%token DOT
%token POINTING_SYMBOL
%token INCREMENT
%token DECREMENT
%token AND_UNARY
%token MULTIPLY
%token PLUS
%token MINUS
%token NEGATION
%token EX_MARK
%token DIVIDE
%token MODULO
%token LEFT_SHIFT
%token RIGHT_SHIFT
%token LESS_THAN
%token GREATER_THAN
%token LESS_THAN_EQUAL
%token GREATER_THAN_EQUAL
%token EQUALITY
%token NOT_EQUAL
%token ELLIPSES
%token ASSIGNMENT
%token MUL_EQUAL
%token DIV_EQUAL
%token MOD_EQUAL
%token ADD_EQUAL
%token SUB_EQUAL
%token LEFT_SHIFT_EQUAL
%token RIGHT_SHIFT_EQUAL
%token XOR
%token OR_LOGICAL
%token AND
%token OR
%token QUESTION_MARK
%token COLON
%token SEMI_COLON
%token AND_EQUAL
%token XOR_EQUAL
%token OR_EQUAL
%token COMMA
%token HASH

%start translation_unit
//For the Dangling else problem
%right THEN ELSE

/////////////////////////////////////////Expressions///////////////////////////////////////////////////////
%type <E>
	expression
	primary_expression 
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression
	equality_expression
	AND_expression
	exclusive_OR_expression
	inclusive_OR_expression
	logical_AND_expression
	logical_OR_expression
	conditional_expression
	assignment_expression
	expression_statement

%type <intval> argument_expression_list

////////////////////////////////////////Array will be used Will be filled in later ////////////////////////////////////////
%type <A> postfix_expression
	unary_expression
	cast_expression

%type <unaryOperator> unary_operator
%type <symp> constant initializer
%type <symp> direct_declarator init_declarator declarator
%type <symtp> pointer

////////////////////////////////Non terminals P and Q introduced///////////////////////////////////
%type <instr> P
%type <S> Q


//////////////////////////////////////Statements////////////////////////////////////////////////////////////
%type <S>  statement
	labeled_statement 
	compound_statement
	selection_statement
	iteration_statement
	jump_statement
	block_item
	block_item_list

%%

primary_expression
	: IDENTIFIER {
	$$ = new expr();
	$$->loc = $1;
	$$->type = "NONBOOL";
	}
	| constant {
	$$ = new expr();
	$$->loc = $1;
	}
	| STRING_LITERAL {
	$$ = new expr();
	Sym_type* tmp = new Sym_type("PTR");
	$$->loc = gentemp(tmp, $1);
	$$->loc->type->ptr = new Sym_type("CHAR");

	allstrings.push_back($1);
	stringstream strs;
    	strs << allstrings.size()-1;
    	string temp_str = strs.str();
    	char* intStr = (char*) temp_str.c_str();
	string str = string(intStr);
	emit("EQUALSTR", $$->loc->name, str);

	}
	| LEFT_BRACE expression RIGHT_BRACE {
	$$ = $2;
	}
	;

constant
	:INTEGER_CONSTANT {
	stringstream strs;
    	strs << $1;
    	string temp_str = strs.str();
    	char* intStr = (char*) temp_str.c_str();
	string str = string(intStr);
	$$ = gentemp(new Sym_type("INTEGER"), str);
	emit("EQUAL", $$->name, $1);
	}
	|FLOATING_CONSTANT {
	$$ = gentemp(new Sym_type("DOUBLE"), string($1));
	emit("EQUAL", $$->name, string($1));
	}
	|ENUMERATION_CONSTANT  {//Will be filled in later 
	}
	|CHARACTER_CONSTANT {
	$$ = gentemp(new Sym_type("CHAR"),$1);
	emit("EQUALCHAR", $$->name, string($1));
	}
	;


postfix_expression
	:primary_expression {
		$$ = new array ();
		$$->array = $1->loc;
		$$->loc = $$->array;
		$$->type = $1->loc->type;
	}
	|postfix_expression LEFT_SQUARE expression RIGHT_SQUARE {
		$$ = new array();
		
		$$->array = $1->loc;					// Copying the base address
		$$->type = $1->type->ptr;				// Type = Type of element...
		$$->loc = gentemp(new Sym_type("INTEGER"));	// Computed Address
		
		// address(new)= computed_Address + $3 * new width 

		if ($1->cat=="ARR") {					
			Symbol* t = gentemp(new Sym_type("INTEGER"));
			stringstream strs;
		   	 strs <<size_type($$->type);
		    	string temp_str = strs.str();
		    	char* intStr = (char*) temp_str.c_str();
			string str = string(intStr);				
 			emit ("MULT", t->name, $3->loc->name, str);
			emit ("PLUS", $$->loc->name, $1->loc->name, t->name);
		}
 		else {
 			stringstream strs;
		    	strs <<size_type($$->type);
		    	string temp_str = strs.str();
		    	char* intStr1 = (char*) temp_str.c_str();
			string str1 = string(intStr1);		
	 		emit("MULT", $$->loc->name, $3->loc->name, str1);
 		}

 		// Mark that it contains array address and first time computation is done
		$$->cat = "ARR";
	}
	|postfix_expression LEFT_BRACE RIGHT_BRACE {
	//Will be filled in later 
	}
	|postfix_expression LEFT_BRACE argument_expression_list RIGHT_BRACE {
		$$ = new array();
		$$->array = gentemp($1->type);
		stringstream strs;
	    	strs <<$3;
	    	string temp_str = strs.str();
	    	char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);		
		emit("CALL", $$->array->name, $1->array->name, str);
	}
	|postfix_expression DOT IDENTIFIER {//Will be filled in later 
	}
	|postfix_expression POINTING_SYMBOL IDENTIFIER {//Will be filled in later 
	}
	|postfix_expression INCREMENT {
		$$ = new array();

		// Copy the contents of $1 to $$
		$$->array = gentemp($1->array->type);
		emit ("EQUAL", $$->array->name, $1->array->name);

		//  $1 = $1 + 1 
		emit ("PLUS", $1->array->name, $1->array->name, "1");
	}
	|postfix_expression DECREMENT {
		$$ = new array();


		// Copy the contents of $1 to $$
		$$->array = gentemp($1->array->type);
		emit ("EQUAL", $$->array->name, $1->array->name);

		// $1= $1 -1 
		emit ("MINUS", $1->array->name, $1->array->name, "1");
	}
	|LEFT_BRACE type_name RIGHT_BRACE LEFT_CURLY initializer_list RIGHT_CURLY {
		//Will be filled in later  
		$$ = new array();
		$$->array = gentemp(new Sym_type("INTEGER"));
		$$->loc = gentemp(new Sym_type("INTEGER"));
	}
	|LEFT_BRACE type_name RIGHT_BRACE LEFT_CURLY initializer_list COMMA RIGHT_CURLY {
		//Will be filled in later 
		$$ = new array();
		$$->array = gentemp(new Sym_type("INTEGER"));
		$$->loc = gentemp(new Sym_type("INTEGER"));
	}
	;

argument_expression_list
	:assignment_expression {
	emit ("PARAM", $1->loc->name);
	$$ = 1;
	}
	|argument_expression_list COMMA assignment_expression {
	emit ("PARAM", $3->loc->name);
	$$ = $1+1;
	}
	;

unary_expression
	:postfix_expression {
	$$ = $1;
	}
	|INCREMENT unary_expression {
		//  $2 = $2 + 1
		emit ("PLUS", $2->array->name, $2->array->name, "1");

		// Use the same value as $2
		$$ = $2;
	}
	|DECREMENT unary_expression {
		//  $2 = $ 2 -1 
		emit ("MINUS", $2->array->name, $2->array->name, "1");

		// Use the same value as $2
		$$ = $2;
	}
	|unary_operator cast_expression {
		$$ = new array();
		switch ($1) {
			case '&':
				$$->array = gentemp((new Sym_type("PTR")));
				$$->array->type->ptr = $2->array->type; 
				emit ("ADDRESS", $$->array->name, $2->array->name);
				break;
			case '*':
				$$->cat = "PTR";
				$$->loc = gentemp ($2->array->type->ptr);
				emit ("PTRR", $$->loc->name, $2->array->name);
				$$->array = $2->array;
				break;
			case '+':
				$$ = $2;
				break;
			case '-':
				$$->array = gentemp(new Sym_type($2->array->type->type));
				emit ("UMINUS", $$->array->name, $2->array->name);
				break;
			case '~':
				$$->array = gentemp(new Sym_type($2->array->type->type));
				emit ("BNOT", $$->array->name, $2->array->name);
				break;
			case '!':
				$$->array = gentemp(new Sym_type($2->array->type->type));
				emit ("LNOT", $$->array->name, $2->array->name);
				break;
			default:
				break;
		}
	}
	|SIZEOF unary_expression {
	//Will be filled in later 
	}
	|SIZEOF LEFT_BRACE type_name RIGHT_BRACE {
	//Will be filled in later 
	}
	;

unary_operator
	:AND_UNARY {
		$$ = '&';
	}
	|MULTIPLY {
		$$ = '*';
	}
	|PLUS {
		$$ = '+';
	}
	|MINUS {
		$$ = '-';
	}
	|NEGATION {
		$$ = '~';
	}
	|EX_MARK {
		$$ = '!';
	}
	;

cast_expression
	:unary_expression {
		$$=$1;
	}
	|LEFT_BRACE type_name RIGHT_BRACE cast_expression {
		//Will be filled in later 
		$$=$4;
	}
	;

multiplicative_expression
	:cast_expression {
		$$ = new expr();
		if ($1->cat=="ARR") { // Array
			$$->loc = gentemp($1->loc->type);
			emit("ARRR", $$->loc->name, $1->array->name, $1->loc->name);
		}
		else if ($1->cat=="PTR") { // Pointer
			$$->loc = $1->loc;
		}
		else { // otherwise
			$$->loc = $1->array;
		}
	}
	|multiplicative_expression MULTIPLY cast_expression {
		if (typecheck ($1->loc, $3->array) ) {
			$$ = new expr();
			$$->loc = gentemp(new Sym_type($1->loc->type->type));
			emit ("MULT", $$->loc->name, $1->loc->name, $3->array->name);
		}
		else cout << "Type Error"<< endl;
	}
	|multiplicative_expression DIVIDE cast_expression {
		if (typecheck ($1->loc, $3->array) ) {
			$$ = new expr();
			$$->loc = gentemp(new Sym_type($1->loc->type->type));
			emit ("DIVIDE", $$->loc->name, $1->loc->name, $3->array->name);
		}
		else cout << "Type Error"<< endl;
	}
	|multiplicative_expression MODULO cast_expression {
		if (typecheck ($1->loc, $3->array) ) {
			$$ = new expr();
			$$->loc = gentemp(new Sym_type($1->loc->type->type));
			emit ("MODOP", $$->loc->name, $1->loc->name, $3->array->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

additive_expression
	:multiplicative_expression {
		$$=$1;
	}
	|additive_expression PLUS multiplicative_expression {
		if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->loc = gentemp(new Sym_type($1->loc->type->type));
			emit ("PLUS", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	|additive_expression MINUS multiplicative_expression {
			if (typecheck ($1->loc, $3->loc) ) {
			$$ = new expr();
			$$->loc = gentemp(new Sym_type($1->loc->type->type));
			emit ("MINUS", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;

	}
	;

shift_expression
	:additive_expression {
		$$=$1;
	}
	|shift_expression LEFT_SHIFT additive_expression {
		if ($3->loc->type->type == "INTEGER") {
			$$ = new expr();
			$$->loc = gentemp (new Sym_type("INTEGER"));
			emit ("LEFTOP", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	|shift_expression RIGHT_SHIFT additive_expression{
		if ($3->loc->type->type == "INTEGER") {
			$$ = new expr();
			$$->loc = gentemp (new Sym_type("INTEGER"));
			emit ("RIGHTOP", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

relational_expression
	:shift_expression {$$=$1;}
	|relational_expression LESS_THAN shift_expression {  
		if (typecheck ($1->loc, $3->loc) ) {
			// New bool
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("LT", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relational_expression GREATER_THAN shift_expression {
		if (typecheck ($1->loc, $3->loc) ) {
			// New bool
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("GT", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relational_expression LESS_THAN_EQUAL shift_expression {
		if (typecheck ($1->loc, $3->loc) ) {
			// New bool
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("LE", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|relational_expression GREATER_THAN_EQUAL shift_expression {
		if (typecheck ($1->loc, $3->loc) ) {
			// New bool
			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("GE", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	;

equality_expression
	:relational_expression {$$=$1;}
	|equality_expression EQUALITY relational_expression {
		if (typecheck ($1->loc, $3->loc)) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);

			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("EQOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	|equality_expression NOT_EQUAL relational_expression {
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);

			$$ = new expr();
			$$->type = "BOOL";

			$$->truelist = makelist (nextinstr());
			$$->falselist = makelist (nextinstr()+1);
			emit("NEOP", "", $1->loc->name, $3->loc->name);
			emit ("GOTOOP", "");
		}
		else cout << "Type Error"<< endl;
	}
	;

AND_expression
	:equality_expression {$$=$1;}
	|AND_expression AND_UNARY equality_expression {
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);
			
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new Sym_type("INTEGER"));
			emit ("BAND", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

exclusive_OR_expression
	:AND_expression {$$=$1;}
	|exclusive_OR_expression XOR AND_expression {
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);
			
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new Sym_type("INTEGER"));
			emit ("XOR", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

inclusive_OR_expression
	:exclusive_OR_expression {$$=$1;}
	|inclusive_OR_expression OR_LOGICAL exclusive_OR_expression {
		if (typecheck ($1->loc, $3->loc) ) {
			// If any is bool get its value
			convertBool2Int ($1);
			convertBool2Int ($3);
			
			$$ = new expr();
			$$->type = "NONBOOL";

			$$->loc = gentemp (new Sym_type("INTEGER"));
			emit ("INC_OR", $$->loc->name, $1->loc->name, $3->loc->name);
		}
		else cout << "Type Error"<< endl;
	}
	;

logical_AND_expression
	:inclusive_OR_expression {$$=$1;}
	|logical_AND_expression Q AND P inclusive_OR_expression {
		convertInt2Bool($5);

		// using backpatching with Q to convert $1 to bool
		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);

		$$ = new expr();
		$$->type = "BOOL";

		backpatch($1->truelist, $4);
		$$->truelist = $5->truelist;
		$$->falselist = merge ($1->falselist, $5->falselist);
	}
	;

logical_OR_expression
	:logical_AND_expression {$$=$1;}
	|logical_OR_expression Q OR P logical_AND_expression {
		convertInt2Bool($5);

		// using backpatching with Q to convert $1 to bool
		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);

		$$ = new expr();
		$$->type = "BOOL";

		backpatch ($$->falselist, $4);
		$$->truelist = merge ($1->truelist, $5->truelist);
		$$->falselist = $5->falselist;
	}
	;

P 	: %empty{	// To store the address of the next instruction
		$$ = nextinstr();
	};

Q 	: %empty { 	// guard against fallthrough by explicitly emitting a goto 
		$$  = new statement();
		$$->nextlist = makelist(nextinstr());
		emit ("GOTOOP","");
	}

conditional_expression
	:logical_OR_expression {$$=$1;}
	|logical_OR_expression Q QUESTION_MARK P expression Q COLON P conditional_expression {
		//convert2bool($5);
		$$->loc = gentemp($5->loc->type);
		$$->loc->update($5->loc->type);
		emit("EQUAL", $$->loc->name, $9->loc->name);
		list<int> l = makelist(nextinstr());
		emit ("GOTOOP", "");

		backpatch($6->nextlist, nextinstr());
		emit("EQUAL", $$->loc->name, $5->loc->name);
		list<int> m = makelist(nextinstr());
		l = merge (l, m);
		emit ("GOTOOP", "");

		backpatch($2->nextlist, nextinstr());
		convertInt2Bool($1);
		backpatch ($1->truelist, $4);
		backpatch ($1->falselist, $8);
		backpatch (l, nextinstr());
	}
	;

assignment_expression
	:conditional_expression {$$=$1;}
	|unary_expression assignment_operator assignment_expression {
		if($1->cat=="ARR") {
			$3->loc = type_convert($3->loc, $1->type->type);
			emit("ARRL", $1->array->name, $1->array->name, $3->loc->name);	
			}
		else if($1->cat=="PTR") {
			emit("PTRL", $1->array->name, $3->loc->name);	
			}
		else{
			$3->loc = type_convert($3->loc, $1->array->type->type);
			emit("EQUAL", $1->array->name, $3->loc->name);
			}
		$$ = $3;
	}
	;

assignment_operator 
	:ASSIGNMENT {//Will be filled in later 
	}
	|MUL_EQUAL {//Will be filled in later 
	}
	|DIV_EQUAL {//Will be filled in later 
	}
	|MOD_EQUAL {//Will be filled in later 
	}
	|ADD_EQUAL {//Will be filled in later 
	}
	|SUB_EQUAL {//Will be filled in later 
	}
	|LEFT_SHIFT_EQUAL {//Will be filled in later 
	}
	|RIGHT_SHIFT_EQUAL {//Will be filled in later 
	}
	|AND_EQUAL {//Will be filled in later 
	}
	|XOR_EQUAL {//Will be filled in later 
	}
	|OR_EQUAL {//Will be filled in later 
	}
	;

expression
	:assignment_expression {$$=$1;}
	|expression COMMA assignment_expression {
	//Will be filled in later 
	}
	;

constant_expression
	:conditional_expression {
	//Will be filled in later 
	}
	;

declaration
	:declaration_specifiers init_declarator_list SEMI_COLON {//Will be filled in later 
	}
	|declaration_specifiers SEMI_COLON {//Will be filled in later 
	}
	;


declaration_specifiers
	:storage_class_specifier declaration_specifiers {//Will be filled in later 
	}
	|storage_class_specifier {//Will be filled in later 
	}
	|type_specifier declaration_specifiers {//Will be filled in later 
	}
	|type_specifier {//Will be filled in later 
	}
	|type_qualifier declaration_specifiers {//Will be filled in later 
	}
	|type_qualifier {//Will be filled in later 
	}
	|function_specifier declaration_specifiers {//Will be filled in later 
	}
	|function_specifier {//Will be filled in later 
	}
	;

init_declarator_list
	:init_declarator {//Will be filled in later 
	}
	|init_declarator_list COMMA init_declarator {//Will be filled in later 
	}
	;

init_declarator
	:declarator {$$=$1;}
	|declarator ASSIGNMENT initializer {
		if ($3->initial_value!="") $1->initial_value=$3->initial_value;
		emit ("EQUAL", $1->name, $3->name);
	}
	;

storage_class_specifier
	: EXTERN {//Will be filled in later 
	}
	| STATIC {//Will be filled in later 
	}
	| AUTO {//Will be filled in later 
	}
	| REGISTER {//Will be filled in later 
	}
	;

type_specifier
	: VOID {Type="VOID";}
	| CHAR {Type="CHAR";}
	| SHORT 
	| INT {Type="INTEGER";}
	| LONG
	| FLOAT
	| DOUBLE {Type="DOUBLE";}
	| SIGNED
	| UNSIGNED
	| BOOL
	| COMPLEX
	| IMAGINARY
	| enum_specifier
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {//Will be filled in later 
	}
	| type_specifier {//Will be filled in later 
	}
	| type_qualifier specifier_qualifier_list {//Will be filled in later 
	}
	| type_qualifier {//Will be filled in later 
	}
	;

enum_specifier
	:ENUM IDENTIFIER LEFT_CURLY enumerator_list RIGHT_CURLY {//Will be filled in later 
	}
	|ENUM LEFT_CURLY enumerator_list RIGHT_CURLY {//Will be filled in later 
	}
	|ENUM IDENTIFIER LEFT_CURLY enumerator_list COMMA RIGHT_CURLY {//Will be filled in later 
	}
	|ENUM LEFT_CURLY enumerator_list COMMA RIGHT_CURLY {//Will be filled in later 
	}
	|ENUM IDENTIFIER {//Will be filled in later 
	}
	;

enumerator_list
	:enumerator {//Will be filled in later 
	}
	|enumerator_list COMMA enumerator {//Will be filled in later 
	}
	;

enumerator
	:IDENTIFIER {//Will be filled in later 
	}
	|IDENTIFIER ASSIGNMENT constant_expression {//Will be filled in later 
	}
	;

type_qualifier
	:CONST {//Will be filled in later 
	}
	|RESTRICT {//Will be filled in later 
	}
	|VOLATILE {//Will be filled in later 
	}
	;

function_specifier
	:INLINE {//Will be filled in later 
	}
	;

declarator
	:pointer direct_declarator {
		Sym_type * t = $1;
		while (t->ptr !=NULL) t = t->ptr;
		t->ptr = $2->type;
		$$ = $2->update($1);
	}
	|direct_declarator {//Will be filled in later 
	}
	;


direct_declarator
	:IDENTIFIER {
		$$ = $1->update(new Sym_type(Type));
		symbol_curr = $$;
	}
	| LEFT_BRACE declarator RIGHT_BRACE {$$=$2;}
	| direct_declarator LEFT_SQUARE type_qualifier_list assignment_expression RIGHT_SQUARE {//Will be filled in later 
	}
	| direct_declarator LEFT_SQUARE type_qualifier_list RIGHT_SQUARE {//Will be filled in later 
	}
	| direct_declarator LEFT_SQUARE assignment_expression RIGHT_SQUARE {
		Sym_type * t = $1 -> type;
		Sym_type * prev = NULL;
		while (t->type == "ARR") {
			prev = t;
			t = t->ptr;
		}
		if (prev==NULL) {
			int temp = atoi($3->loc->initial_value.c_str());
			Sym_type* s = new Sym_type("ARR", $1->type, temp);
			$$ = $1->update(s);
		}
		else {
			prev->ptr =  new Sym_type("ARR", t, atoi($3->loc->initial_value.c_str()));
			$$ = $1->update ($1->type);
		}
	}
	| direct_declarator LEFT_SQUARE RIGHT_SQUARE {
		Sym_type * t = $1 -> type;
		Sym_type * prev = NULL;
		while (t->type == "ARR") {
			prev = t;
			t = t->ptr;
		}
		if (prev==NULL) {
			Sym_type* s = new Sym_type("ARR", $1->type, 0);
			$$ = $1->update(s);
		}
		else {
			prev->ptr =  new Sym_type("ARR", t, 0);
			$$ = $1->update ($1->type);
		}
	}
	| direct_declarator LEFT_SQUARE STATIC type_qualifier_list assignment_expression RIGHT_SQUARE {//Will be filled in later 
	}
	| direct_declarator LEFT_SQUARE STATIC assignment_expression RIGHT_SQUARE {//Will be filled in later 
	}
	| direct_declarator LEFT_SQUARE type_qualifier_list MULTIPLY RIGHT_SQUARE {//Will be filled in later 
	}
	| direct_declarator LEFT_SQUARE MULTIPLY RIGHT_SQUARE {//Will be filled in later 
	}
	| direct_declarator LEFT_BRACE Compound_Statement parameter_type_list RIGHT_BRACE {
		current_table->name = $1->name;

		if ($1->type->type !="VOID") {
			Symbol *s = current_table->lookup("return");
			s->update($1->type);		
		}
		$1->nested=current_table;
		$1->category = "function"; 
		current_table->parent = Table_global;
		switch_table (Table_global);				// Come back to globalsymbol current_table
		symbol_curr = $$;
	}
	| direct_declarator LEFT_BRACE identifier_list RIGHT_BRACE {//Will be filled in later 
	}
	| direct_declarator LEFT_BRACE Compound_Statement RIGHT_BRACE {
		current_table->name = $1->name;

		if ($1->type->type !="VOID") {
			Symbol *s = current_table->lookup("return");
			s->update($1->type);		
		}
		$1->nested=current_table;
		$1->category = "function";
		
		current_table->parent = Table_global;
		switch_table (Table_global);				// Come back to globalsymbol current_table
		symbol_curr = $$;
	}
	;

Compound_Statement // Used for changing to symbol table for a function
	: %empty { 															// Used for changing to symbol current_table for a function
		if (symbol_curr->nested==NULL) switch_table(new Symbol_table(""));	// Function symbol current_table doesn't already exist
		else {
			switch_table (symbol_curr ->nested);						// Function symbol current_table already exists
			emit ("FUNC", current_table->name);
		}
	}
	;

pointer
	:MULTIPLY type_qualifier_list {//Will be filled in later 
	}
	|MULTIPLY {
		$$ = new Sym_type("PTR");
	}
	|MULTIPLY type_qualifier_list pointer {//Will be filled in later 
	}
	|MULTIPLY pointer {
		$$ = new Sym_type("PTR", $2);
	}
	;

type_qualifier_list
	:type_qualifier {//Will be filled in later 
	}
	|type_qualifier_list type_qualifier {//Will be filled in later 
	}
	;

parameter_type_list
	:parameter_list {//Will be filled in later 
	}
	|parameter_list COMMA ELLIPSES {//Will be filled in later 
	}
	;

parameter_list
	:parameter_declaration {//Will be filled in later 
	}
	|parameter_list COMMA parameter_declaration {//Will be filled in later 
	}
	;

parameter_declaration
	:declaration_specifiers declarator {
		$2->category = "param";
	}
	|declaration_specifiers {//Will be filled in later 

	}
	;

identifier_list
	:IDENTIFIER {//Will be filled in later 
	}
	|identifier_list COMMA IDENTIFIER {//Will be filled in later 
	}
	;

type_name
	:specifier_qualifier_list {//Will be filled in later 
	}
	;

initializer
	:assignment_expression {
		$$ = $1->loc;
	}
	|LEFT_CURLY initializer_list RIGHT_CURLY {//Will be filled in later 
	}
	|LEFT_CURLY initializer_list COMMA RIGHT_CURLY {//Will be filled in later 
	}
	;


initializer_list
	:designation initializer {//Will be filled in later 
	}
	|initializer {//Will be filled in later 
	}
	|initializer_list COMMA designation initializer {//Will be filled in later 
	}
	|initializer_list COMMA initializer {//Will be filled in later 
	}
	;

designation
	:designator_list ASSIGNMENT {//Will be filled in later 
	}
	;

designator_list
	:designator {//Will be filled in later 
	}
	|designator_list designator {//Will be filled in later 
	}
	;

designator
	:LEFT_SQUARE constant_expression RIGHT_SQUARE {//Will be filled in later 
	}
	|DOT IDENTIFIER {//Will be filled in later 
	}
	;

statement
	:labeled_statement {//Will be filled in later 
	}
	|compound_statement {$$=$1;}
	|expression_statement {
		$$ = new statement();
		$$->nextlist = $1->nextlist;
	}
	|selection_statement {$$=$1;}
	|iteration_statement {$$=$1;}
	|jump_statement {$$=$1;}
	;

labeled_statement
	:IDENTIFIER COLON statement {$$ = new statement();}
	|CASE constant_expression COLON statement {$$ = new statement();}
	|DEFAULT COLON statement {$$ = new statement();}
	;

compound_statement
	:LEFT_CURLY block_item_list RIGHT_CURLY {$$=$2;}
	|LEFT_CURLY RIGHT_CURLY {$$ = new statement();}
	;

block_item_list
	:block_item {$$=$1;}
	|block_item_list P block_item {

		//debug ("P.instruction = " << $2);
		$$=$3;

		/*	if (gDebug) {
			debug ("1 contains: ");
			printlist($1->nextlist);}
		   	 if (gDebug) {
			debug ("3 contains: ");
			printlist($3->nextlist);
		} 
	*/
		backpatch ($1->nextlist, $2);
	//	debug ("backpathching for 1 done");
	}

	;

block_item
	:declaration {
		$$ = new statement();


	}
	|statement {$$ = $1;}
	;

expression_statement
	:expression SEMI_COLON {$$=$1;}
	|SEMI_COLON {$$ = new expr();}
	;

selection_statement
	:IF LEFT_BRACE expression Q RIGHT_BRACE P statement Q %prec THEN{
		backpatch ($4->nextlist, nextinstr());
		convertInt2Bool($3);
		$$ = new statement();
		backpatch ($3->truelist, $6);
		list<int> temp = merge ($3->falselist, $7->nextlist);
		$$->nextlist = merge ($8->nextlist, temp);
	}
	|IF LEFT_BRACE expression Q RIGHT_BRACE P statement Q ELSE P statement {
		backpatch ($4->nextlist, nextinstr());
		convertInt2Bool($3);
		$$ = new statement();


		backpatch ($3->truelist, $6);
		backpatch ($3->falselist, $10);
		list<int> temp = merge ($7->nextlist, $8->nextlist);
		$$->nextlist = merge ($11->nextlist,temp);
	}
	|SWITCH LEFT_BRACE expression RIGHT_BRACE statement {//Will be filled in later 
	}
	;

iteration_statement
	:WHILE P LEFT_BRACE expression RIGHT_BRACE P statement {
		$$ = new statement();
		convertInt2Bool($4);
		// P1 to go back to boolean again
		// P2 to go to statement if the boolean is true
		backpatch($7->nextlist, $2);
		backpatch($4->truelist, $6);
		$$->nextlist = $4->falselist;
		// Emit to prevent fallthrough
		stringstream strs;
	    strs << $2;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);

		emit ("GOTOOP", str);
	}
	|DO P statement P WHILE LEFT_BRACE expression RIGHT_BRACE SEMI_COLON {
		$$ = new statement();
		convertInt2Bool($7);
		// P1 to go back to statement if expression is true
		// P2 to go to check expression if statement is complete
		backpatch ($7->truelist, $2);
		backpatch ($3->nextlist, $4);

		// Some bug in the next statement 
		$$->nextlist = $7->falselist;
	}
	|FOR LEFT_BRACE expression_statement P expression_statement RIGHT_BRACE P statement{
		$$ = new statement();
		convertInt2Bool($5);
		backpatch ($5->truelist, $7);
		backpatch ($8->nextlist, $4);
		stringstream strs;
	    strs << $4;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);

		emit ("GOTOOP", str);
		$$->nextlist = $5->falselist;
	}
	|FOR LEFT_BRACE expression_statement P expression_statement P expression Q RIGHT_BRACE P statement{
		$$ = new statement();
		convertInt2Bool($5);
		backpatch ($5->truelist, $10);
		backpatch ($8->nextlist, $4);
		backpatch ($11->nextlist, $6);
		stringstream strs;
	    strs << $6;
	    string temp_str = strs.str();
	    char* intStr = (char*) temp_str.c_str();
		string str = string(intStr);
		emit ("GOTOOP", str);
		$$->nextlist = $5->falselist;
	}
	;

jump_statement
	:GOTO IDENTIFIER SEMI_COLON {$$ = new statement();}
	|CONTINUE SEMI_COLON {$$ = new statement();}
	|BREAK SEMI_COLON {$$ = new statement();}
	|RETURN expression SEMI_COLON {
		$$ = new statement();
		emit("RETURN",$2->loc->name);
	}
	|RETURN SEMI_COLON {
		$$ = new statement();
		emit("RETURN","");
	}
	;

translation_unit
	:external_declaration {}
	|translation_unit external_declaration {}
	;

external_declaration
	:function_definition {}
	|declaration {}
	;

function_definition
	:declaration_specifiers declarator declaration_list Compound_Statement compound_statement {}
	|declaration_specifiers declarator Compound_Statement compound_statement {
		emit ("FUNCEND", current_table->name);
		current_table->parent = Table_global;
		switch_table (Table_global);
	}
	;

declaration_list
	:declaration {//Will be filled in later 
	}
	|declaration_list declaration {//Will be filled in later 
	}
	;



%%

void yyerror(string s) {
    cout<<s<<endl;
}

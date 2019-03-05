// Name : Shaikh Moin Dastagir 	
// Roll no : 16CS30033
#ifndef TRANSLATE
#define TRANSLATE
#include <vector>
#include <algorithm>
#include <bits/stdc++.h>
#include <iostream>

#define CHAR_SIZE 		    1
#define INT_SIZE  		    4
#define DOUBLE_SIZE		    8
#define POINTER_SIZE	       	    4

extern  char* yytext;
extern  int yyparse();


using namespace std;

////////////////////////////////////Forward class declarations to avoid conflicts

class Sym_type;					// Type of a symbol in symbol current_table
class Quad;						// Entry in Quad array
class quadArray;					// QuadArray
class Symbol;						// Entry in a symbol current_table
class Symbol_table;					// Symbol Table


//////////////////////////////////////global variables used in the translator.cxx file are declared here

extern Symbol_table* current_table;				// Current Symbbol Table
extern Symbol_table* Table_global;				// Global Symbbol Table
extern quadArray q;						// Array of Quads
extern Symbol* symbol_curr;					// Pointer to just encountered symbol


///////////////////////////////////////Class definitions, non terminal type strucure and attributes and global functions

class Sym_type { // Type of symbols in symbol current_table
public:
	Sym_type(string type, Sym_type* ptr = NULL, int width = 1);
	string type;
	int width;					// Size of array (in case of arrays)
	Sym_type* ptr;				// for 2d arrays and pointers
};

class Quad { // Quad Class
public:
	string op;				// Operator
	string result;				// Result
	string arg1;				// Argument 1
	string arg2;				// Argument 2

	void print ();								// Print Quad
	Quad (string result, string arg1, string op = "EQUAL", string arg2 = "");			//constructors
	Quad (string result, int arg1, string op = "EQUAL", string arg2 = "");				//constructors
	Quad (string result, float arg1, string op = "EQUAL", string arg2 = "");			//constructors
};

class quadArray { // Array of quads
public:
	vector <Quad> array;;		                // Vector of quads
	void print ();								// Print the quadArray
};

class Symbol_table { // Symbol Table class
public:
	string name;				// Name of Table
	int count;					// Count of temporary variables
	list<Symbol> current_table; 			// The current_table of symbols
	Symbol_table* parent;				// Immediate parent of the symbol current_table
	////////////
	map<string, int> activation_record;			//activation record
	///////////
	Symbol_table (string name="NULL");
	Symbol* lookup (string name);								// Lookup for a symbol in symbol current_table
	void print();					            			// Print the symbol current_table
	void update();						        			// Update offset of the complete symbol current_table
};



class Symbol { // Symbols class
public:
	string name;				// Name of the symbol
	Sym_type *type;				// Type of the Symbol
	string initial_value;    		// Symbol initial valus (if any)
	///////////
	string category;    		        // global, local or param
	///////////
	int size;				// Size of the symbol
	int offset;				// Offset of symbol
	Symbol_table* nested;			// Pointer to nested symbol current_table

	Symbol (string name, string t="INTEGER", Sym_type* ptr = NULL, int width = 0); //constructor declaration
	Symbol* update(Sym_type * t); 	// A method to update different fields of an existing entry.
	Symbol* link_to_symbolTable(Symbol_table* t);
};



/////////////////////////////////////////Attributes and their explanation for different non terminal type
//Attributes for statements
struct statement {
	list<int> nextlist;				// Nextlist for statement
};

//Attributes for array
struct array {
	string cat;
	Symbol* loc;					// Temporary used for computing array address
	Symbol* array;					// Pointer to symbol current_table
	Sym_type* type;				// type of the subarray generated
};


//Attributes for expressions
struct expr {
	string type; 							//to store whether the expression is of type int or bool

	// Valid for non-bool type
	Symbol* loc;								// Pointer to the symbol current_table entry

	// Valid for bool type
	list<int> truelist;						// Truelist valid for boolean
	list<int> falselist;					// Falselist valid for boolean expressions

	// Valid for statement expression
	list<int> nextlist;
};

//////////////////////////////////////////Global functions required for the translator

Symbol* type_convert (Symbol*, string);							// TAC for Type conversion in program
bool typecheck(Symbol* &s1, Symbol* &s2);					// Checks if two symbols have same type
bool typecheck(Sym_type* t1, Sym_type* t2);			//checks if two Sym_type objects have same type



void emit(string op, string result, string arg1="", string arg2 = "");    //emits for adding quads to quadArray
void emit(string op, string result, int arg1, string arg2 = "");		  //emits for adding quads to quadArray (arg1 is int)
void emit(string op, string result, float arg1, string arg2 = "");        //emits for adding quads to quadArray (arg1 is float)


expr* convertInt2Bool (expr*);				// convert any expression (int) to bool
expr* convertBool2Int (expr*);				// convert bool to expression (int)


void backpatch (list <int> lst, int i);				// backpatch a list with the found label i 
list<int> makelist (int i);							        // Make a new list contaninig an integer
list<int> merge (list<int> &lst1, list <int> &lst2);		// Merge two lists into a single list

int size_type (Sym_type*);							// Calculate size of any symbol type 
string print_type(Sym_type*);						// For printing type of symbol recursive printing of type

void switch_table (Symbol_table* newtable);               //for changing the current sybol current_table
int nextinstr();									// Returns the next instruction number

Symbol* gentemp (Sym_type* t, string init = "");		// Generate a temporary variable and insert it in current symbol current_table



#endif




// Name : Shaikh Moin Dastagir 	
// Roll no : 16CS30033

#include "ass6_16CS30033_translator.h"
#include <sstream>
#include <string> 

using namespace std;

//reference to global variables declared in header file 
Symbol_table* Table_global;					// Global Symbol Table
quadArray q;							// Quad Array
string Type;							// Stores latest type
Symbol_table* current_table;						// Points to current symbol current_table
Symbol* symbol_curr; 					// points to current symbol



Sym_type::Sym_type(string type, Sym_type* ptr, int width)   // To store the type and width
{
	this->type=type;
	this->ptr=ptr;
	this->width=width;
}

Quad::Quad (string result, string arg1, string op, string arg2)       // Class for a unit of Quad used for generation of TAC
{
	this->result=result;
	this->arg1=arg1;
	this->op=op;
	this->arg2=arg2;
}

Quad::Quad (string result, int arg1, string op, string arg2){          // Class for a unit of Quad used for generation of TAC
		string intStr = std::to_string(arg1); 
		this->arg1 = intStr;
		this->result=result;
		this->op=op;
		this->arg2=arg2;
	}

Quad::Quad (string result, float arg1, string op, string arg2){      // Class for a unit of Quad used for generation of TAC
		string fltStr = std::to_string(arg1); 
		this->arg1 = fltStr;
		this->result=result;
		this->op=op;
		this->arg2=arg2;
	}


///////////////////////////////////////////////////////////////////To print the array of quads generated///////////////////////////////////////////////////////////////////
void quadArray::print() {                  
	cout << setw(30) << setfill ('=') << "="<< endl;
	cout << "Quad Translation" << endl;
	cout << setw(30) << setfill ('-') << "-"<< setfill (' ') << endl;
	for (vector<Quad>::iterator counter = array.begin(); counter!=array.end(); counter++) {
		if (counter->op == "FUNC") {
			cout << "\n";
			counter->print();
			cout << "\n";
		}
		else if (counter->op == "FUNCEND") {}
		else {
			cout << "\t" << setw(4) << counter - array.begin() << ":\t";
			counter->print();
		}
	}
	cout << setw(30) << setfill ('-') << "-"<< endl;
}


// //////////////////////////////////////////////To print a particular Quad// //////////////////////////////////////////////
void Quad::print () {           
	// ////////////////////////////////////////////////Binary Operations/////////////////////////////////////////////////////////////////////
	if (op=="PLUS")					cout << result << " = " << arg1 << " + " << arg2;
	else if (op=="MINUS")				cout << result << " = " << arg1 << " - " << arg2;
	else if (op=="MULT")			cout << result << " = " << arg1 << " * " << arg2;
	else if (op=="DIVIDE")			cout << result << " = " << arg1 << " / " << arg2;
	else if (op=="MODULO")			cout << result << " = " << arg1 << " % " << arg2;
	else if (op=="XOR")				cout << result << " = " << arg1 << " ^ " << arg2;
	else if (op=="INC_OR")			cout << result << " = " << arg1 << " | " << arg2;
	else if (op=="BAND")			cout << result << " = " << arg1 << " & " << arg2;
	///////////////////////////////////////////////////////////////////// Relational Operations///////////////////////////////////////////////////////////////////
	else if (op=="EQOP")			cout << "if " << arg1 <<  " == " << arg2 << " goto " << result;
	else if (op=="NEOP")			cout << "if " << arg1 <<  " != " << arg2 << " goto " << result;
	else if (op=="LT")				cout << "if " << arg1 <<  " < "  << arg2 << " goto " << result;
	else if (op=="GT")				cout << "if " << arg1 <<  " > "  << arg2 << " goto " << result;
	else if (op=="GE")				cout << "if " << arg1 <<  " >= " << arg2 << " goto " << result;
	else if (op=="LE")				cout << "if " << arg1 <<  " <= " << arg2 << " goto " << result;
	else if (op=="GOTOOP")			cout << "goto " << result;

	////////////////////////////////////////////////////////////////////Shift Operations///////////////////////////////////////////////////////////////////
	else if (op=="LEFTOP")			cout << result << " = " << arg1 << " << " << arg2;
	else if (op=="RIGHTOP")			cout << result << " = " << arg1 << " >> " << arg2;
	else if (op=="EQUAL")			cout << result << " = " << arg1 ;				
			
	/////////////////////////////////////////////////////////////////////Unary Operators///////////////////////////////////////////////////////////////////
	else if (op=="ADDRESS")			cout << result << " = &" << arg1;
	else if (op=="PTRR")			cout << result	<< " = *" << arg1 ;
	else if (op=="PTRL")			cout << "*" << result	<< " = " << arg1 ;
	else if (op=="UMINUS")			cout << result 	<< " = -" << arg1;
	else if (op=="BNOT")			cout << result 	<< " = ~" << arg1;
	else if (op=="LNOT")			cout << result 	<< " = !" << arg1;
	///////////////////////////////////////////////////////////////////Other identifiers///////////////////////////////////////////////////////////////////
	else if (op=="ARRR")	 		cout << result << " = " << arg1 << "[" << arg2 << "]";
	else if (op=="ARRL")	 		cout << result << "[" << arg1 << "]" <<" = " <<  arg2;
	else if (op=="RETURN") 			cout << "ret " << result;
	else if (op=="PARAM") 			cout << "param " << result;
	else if (op=="CALL") 			cout << result << " = " << "call " << arg1<< ", " << arg2;
	else if (op=="FUNC") 			cout << result << ": ";
	else if (op=="FUNCEND") 		cout << "";	
	else							cout << "op";			
	cout << endl;
}

///////////////////////////////////////////////////////////////////Symbol in symbol table///////////////////////////////////////////////////////////////////
Symbol::Symbol (string name, string t, Sym_type* ptr, int width){
	this->name=name;
	this->type = new Sym_type (t, ptr, width);
	this->nested = NULL;
	this->initial_value = "";
	this->category = "";
	this->offset = 0;
	this->size = size_type(type);
}

///////////////////////////////////////////////////////////////////Updating a symbol in symbol table///////////////////////////////////////////////////////////////////
Symbol* Symbol::update(Sym_type* t) {
	this->type = t;
	int temp_size=size_type(t);
	this -> size = temp_size;
	return this;
}

///////////////////////////////////////////////////////////////////New symbol table generation ///////////////////////////////////////////////////////////////////
Symbol_table::Symbol_table (string name){
	this->name=name;
	this->count=0;
}

///////////////////////////Functions for printing layout//////////////////////////////////////////////////
void print_design1()
{
	cout << endl;
	cout << setw(120) << setfill ('-') << "-"<< endl;
	cout << setfill (' ') << left << setw(20) << "Name";
	cout << left << setw(25) << "Type";
	cout << left << setw(15) << "Category";
	cout << left << setw(20) << "Initial Value";
	cout << left << setw(12) << "Size";
	cout << left << setw(12) << "Offset";
	cout << left << "Nested" << endl;
	cout << setw(120) << setfill ('-') << "-"<< setfill (' ') << endl;
}


void print_design2(string name,string stype,string initial_value,string category,int size,int offset)
{
	cout << left << setw(20) << name;
	cout << left << setw(25) << stype;
	cout << left << setw(15) << category;
	cout << left << setw(17) << initial_value;
	cout << left << setw(12) << size;
	cout << left << setw(11) << offset;
}
///////////////////////////////////////////////////////////////////Printing the symbol table///////////////////////////////////////////////////////////////////
void Symbol_table::print() {    
	list<Symbol_table*> tablelist;
	cout << setw(120) << setfill ('_') << "_"<< endl;
	cout << "Symbol Table: " << setfill (' ') << left << setw(50)  << this -> name ;
	cout << right << setw(25) << "Parent: ";
	if (this->parent!=NULL)
		cout << this -> parent->name;
	else cout << "null" ;

	print_design1();
		
	
	for (list <Symbol>::iterator counter = current_table.begin(); counter!=current_table.end(); counter++) {
		string stype = print_type(counter->type);

		print_design2(counter->name,stype,counter->initial_value,counter->category,counter->size,counter->offset);
		
		cout << left;
		if (counter->nested == NULL) {
			cout << "null" <<  endl;	
		}
		else {
			cout << counter->nested->name <<  endl;
			tablelist.push_back (counter->nested);
		}
	}
	cout << setw(120) << setfill ('-') << "-"<< setfill (' ') << endl;
	cout << endl;
	for (list<Symbol_table*>::iterator iterator = tablelist.begin();
			iterator != tablelist.end();
			++iterator) 
		{
	    	(*iterator)->print();
		}		
}









// ///////////////////////////////////////////////////////////////////Updating the offset of nested symbol tables///////////////////////////////////////////////////////////////////
void upDateOffset(Symbol_table * nested)
{	
	int currentoff=0;
	nested->update();
	for (list <Symbol>::iterator x = (nested->current_table).begin(); x!=(nested->current_table).end(); x++)
	 {
		if (x==(nested->current_table).begin()) 
		{
			x->offset = 0;
			currentoff = x->size;
		}
		else {
			x->offset = currentoff;
			currentoff = x->offset + x->size;
		}
		if (x->nested!=NULL)
			{
				upDateOffset(x->nested);
			}
	}

}

///////////////////////////////////////////////////////////////////Updating the offset of the current symbol table///////////////////////////////////////////////////////////////////
void Symbol_table::update() {
	int currentoff;
	for (list <Symbol>::iterator x = current_table.begin(); x!=current_table.end(); x++) {
		if (x==current_table.begin()) 
		{
			x->offset = 0;
			currentoff = x->size;
		}
		else 
		{
			x->offset = currentoff;
			currentoff = x->offset + x->size;
		}

		if (x->nested!=NULL) upDateOffset(x->nested);
	}
}

///////////////////////////////////////////////////////////////////Looking up for a particular symbol in symbol table///////////////////////////////////////////////////////////////////

Symbol* Symbol_table::lookup (string name) {
	Symbol* s;
	Symbol* found;
	list <Symbol>::iterator x;
	for (x = current_table.begin(); x!=current_table.end(); x++) 
	{
		if (x->name == name ) 
		{	
			found=&(*x);
			return found;
		}
	}
	                                              
	s =  new Symbol (name);
	s->category = "local";  				// symbol to be added to current_table
	current_table.push_back (*s);
	found=&current_table.back();
	return found;
}

//////////////////////////////////////////////////////////////////New Quad generation Type 1//////////////////////////////////////////////////////////////////
Quad new_quad(string result,string arg1,string op,string arg2)
{
	Quad* r= new Quad(result,arg1,op,arg2);
	return *r;
}
//////////////////////////////////////////////////////////////////New Quad generation Type 2//////////////////////////////////////////////////////////////////
Quad new_quad(string result,int arg1,string op,string arg2)
{
	Quad* r= new Quad(result,arg1,op,arg2);
	return *r;
}
//////////////////////////////////////////////////////////////////New Quad generation Type 3//////////////////////////////////////////////////////////////////
Quad new_quad(string result,float arg1,string op,string arg2)
{
	Quad* r= new Quad(result,arg1,op,arg2);
	return *r;
}
//////////////////////////////////////////////////////////////////Emitting or storing quads of Type 1 in the Quad array//////////////////////////////////////////////////////////////////


void emit(string op, string result, string arg1, string arg2) {
	q.array.push_back(new_quad(result,arg1,op,arg2));
}

//////////////////////////////////////////////////////////////////Emitting or storing quads of Type 2 in the Quad array//////////////////////////////////////////////////////////////////
void emit(string op, string result, int arg1, string arg2) {
	q.array.push_back(new_quad(result,arg1,op,arg2));
}
//////////////////////////////////////////////////////////////////Emitting or storing quads of Type 3 in the Quad array//////////////////////////////////////////////////////////////////
void emit(string op, string result, float arg1, string arg2) {
	q.array.push_back(new_quad(result,arg1,op,arg2));
}


enum string_code {
    INTEGER,_CHAR,DOUBLE,_VOID,PTR,ARR,FUNC
};


string_code hashstr(std::string const& inString) {
    if (inString == "INTEGER") return INTEGER;
    if (inString == "CHAR") return _CHAR;
    if (inString == "DOUBLE") return DOUBLE;
    if (inString == "VOID") return _VOID;
    if (inString == "PTR") return PTR;
    if (inString == "ARR") return ARR;
    if (inString == "FUNC") return FUNC;
}


//////////////////////////////////////////////////////////////////Converting type of a symbol//////////////////////////////////////////////////////////////////


Symbol* type_convert (Symbol* s, string t) {
	Symbol* temp = gentemp(new Sym_type(t));

	switch(hashstr(s->type->type))
	{
		case INTEGER: 
		{
			switch(hashstr(t))
			{
				case _CHAR:
						{
							emit ("EQUAL", temp->name, "int2char(" + s->name + ")");
							return temp;
						}
				case DOUBLE:
						{
							emit ("EQUAL", temp->name, "int2double(" + s->name + ")");
							return temp;
						}
			}
			return s;	
			
		}


		case DOUBLE: 
		{
			switch(hashstr(t))
			{
				case _CHAR:
						{
							emit ("EQUAL", temp->name, "double2char(" + s->name + ")");
							return temp;
						}
				case INTEGER:
						{
							emit ("EQUAL", temp->name, "double2int(" + s->name + ")");
							return temp;
						}
			}
			return s;
			
		}



		case _CHAR: 
		{
			switch(hashstr(t))
			{
				case DOUBLE:
						{
							emit ("EQUAL", temp->name, "char2double(" + s->name + ")");
							return temp;
						}
				case INTEGER:
						{
							emit ("EQUAL", temp->name, "char2int(" + s->name + ")");
							return temp;
						}
			}
			return s;

		}
	}

	return s;
	
}

//////////////////////////////////////////////////////////////////Checking type of two symbols for consistency//////////////////////////////////////////////////////////////////

bool typecheck(Symbol*& s1, Symbol*& s2)   // For checking that the symbols have the same type or not 
{ 	
	
	Sym_type* type1 = s1->type;
	Sym_type* type2 = s2->type;
	int t1=typecheck (type1, type2);
	if ( t1 ) return true;
	else if (s1 = type_convert (s1, type2->type) ) return true;
	else if (s2 = type_convert (s2, type1->type) ) return true;
	else return false;
}


//////////////////////////////////////////////////////////////////Chewcking type for two symbols given the pointer to their types //////////////////////////////////////////////////////////////////
bool typecheck(Sym_type* t1, Sym_type* t2){ 	// For checking whether the symbol types are same or not
	
	if(t1==NULL && t2==NULL) return true;
	else
	{          

		if(t1!=NULL && t2!=NULL)
		{
			if (t1->type==t2->type ) return typecheck(t1->ptr, t2->ptr);
			else
				return false;
		}
		else
			return false;
	}
}

//////////////////////////////////////////////////////////////////Backpatching//////////////////////////////////////////////////////////////////

void backpatch (list <int> l, int addr) 
{
    	string int_str = to_string(addr);
	for (list<int>::iterator x= l.begin(); x!=l.end(); x++) 
	{
		q.array[*x].result = int_str;
	}
}


//////////////////////////////////The next instruction number to be written//////////////////////////////////
int nextinstr() {
	int t=q.array.size();
	return t;
}

//////////////////////////////////////////////////////////////////To make a new list with for those goto whose label is not known yet//////////////////////////////////////////////////////////////////
list<int> makelist (int i)                // Make a newlist with instruction no i
{
    list<int> temp;
    temp.push_back(i);
    return temp;
}
//////////////////////////////////////////////////////////////////Merging two lists//////////////////////////////////////////////////////////////////

list<int> merge (list<int> &l1, list <int> &l2) {           // Merge two lists l1 and l2
	list<int> temp;
    	temp.merge(l1);
    	temp.merge(l2);
    	return temp;
}

/////////////////////////////////////////////// Bool Expression convert to Int///////////////////////////////////////////
expr* convertBool2Int (expr* e) {	// Bool Expression convert to Int
	if (e->type=="BOOL") {

		e->loc = gentemp(new Sym_type("INTEGER"));
		backpatch (e->truelist, nextinstr());
		emit ("EQUAL", e->loc->name, "true");
		stringstream strs;
	    
	    	char* integerStr = (char*) (to_string(nextinstr()+1)).c_str();
		string str = string(integerStr);
		emit ("GOTOOP", str);
		backpatch (e->falselist, nextinstr());
		emit ("EQUAL", e->loc->name, "false");
	}
}



///////////////////////////////////////////////// Int expression convert to Bool///////////////////////////////////////////////

expr* convertInt2Bool (expr* e) {	// Int expression convert to Bool
	if (e->type!="BOOL") {
		list<int>falselist,truelist;
		falselist	=makelist (nextinstr());
		e->falselist = falselist;
		emit ("EQOP", "", e->loc->name, "0");
		truelist	=makelist (nextinstr());
		e->truelist = truelist;
		emit ("GOTOOP", "");
	}
}



///////////////////////////////////////////// Change current symbol current_table//////////////////////////////////
void switch_table (Symbol_table* newtable) {	// Change current symbol current_table
	current_table = newtable;
} 


//////////////////////////////////To generate a new temporary//////////////////////////////////
Symbol* gentemp (Sym_type* t, string init) {
	char n[10];
	sprintf(n, "t%02d", current_table->count++);
	Symbol* s = new Symbol (n);
	s->type = t ;
	s->size=size_type(t) ;
	s-> initial_value = init;
	s->category = "temp";
	current_table->current_table.push_back (*s);           // To push isdt 
	return &current_table->current_table.back();
}




///////////////////////////////////////////////////////////////////////To print the type of a symbol//////////////////////////////////////////////
string print_type (Sym_type* t){
	if (t==NULL) return "null";
	switch(hashstr(t->type))
	{	
		case _VOID :  	return "void";
		case _CHAR : 	return  "char";
		case INTEGER:	return "integer";
		case DOUBLE : return "double";
		case PTR: 	{
					string temp="ptr("+ print_type(t->ptr)+")";
					return temp;	
				};
		case ARR: 	{
					string str = to_string(t->width);
					return "arr(" + str + ", "+ print_type (t->ptr) + ")";
				}
		case FUNC:	return "function";
	}
	return "_";
}


///////////////////////////////////////////////////To get the size of a particular symbol /////////////////////////////////////////////

int size_type (Sym_type* t){
	if(t->type=="VOID")	return 0;
	switch(hashstr(t->type))
	{	
		case _VOID :  	return 0;
		case _CHAR : 	return CHAR_SIZE;
		case INTEGER:	return INT_SIZE;
		case DOUBLE : return DOUBLE_SIZE;
		case PTR: 	return POINTER_SIZE;
		case ARR: 	{
					int temp=t->width;
					temp=temp*size_type(t->ptr);
					return temp;
				}
		case FUNC:	return 0;
	}
}




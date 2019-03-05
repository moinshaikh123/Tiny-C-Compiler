#include "ass6_16CS30033_translator.h"
#include <iostream>
#include <cstring>
#include <string>

extern FILE *yyin;
extern vector<string> allstrings;

using namespace std;

int labelCount=0;					// Label count in asm file
std::map<int, int> Label_Set;				// map from Quad number to label number
ofstream out;						// asm file stream
vector <Quad> array;					// Quad array
string asmfilename="ass6_16CS30033_";		// asm file name
string inputfile="ass6_16CS30033_test";		// input file name


void Compute_AR(Symbol_table* stable)
 {
	int param = -20;
	int local = -24;
	for (list <Symbol>::iterator it = stable->current_table.begin(); it!=stable->current_table.end(); it++) {

		if (it->category =="param") {
			stable->activation_record [it->name] = param;                       
			param +=it->size;			                 //Readjusting param for next Symbol
		}
		else if (it->name=="return") continue;                            
		else {
			stable->activation_record [it->name] = local;       // Readjusting local for the next Symbol 
			local -=it->size;
		}
	}
}


template<class T>
ostream& operator<<(ostream& os, const vector<T>& v)
{
	copy(v.begin(), v.end(), ostream_iterator<T>(os, " ")); 
	return os;
}



void Gen_Assembly() {
	array = q.array;

	//To update the goto labels
	for (vector<Quad>::iterator it = array.begin(); it!=array.end(); it++) {
	int i;
	if (it->op=="GOTOOP" || it->op=="LT" || it->op=="GT" || it->op=="LE" || it->op=="GE" || it->op=="EQOP" || it->op=="NEOP") {
		i = atoi(it->result.c_str());        // result contains the names of the labels(leaders)
		Label_Set [i] = 1;		 // Creating a set of all the labels where we need to jump 
	}
	}
	int count = 0;                                   
	for (std::map<int,int>::iterator it=Label_Set.begin(); it!=Label_Set.end(); ++it)
		it->second = count++;// Indexing the above createdset of leaders(labels)

	list<Symbol_table*> tablelist;   
	for (list <Symbol>::iterator it = Table_global->current_table.begin(); it!=Table_global->current_table.end(); it++) {
		if (it->nested!=NULL) tablelist.push_back (it->nested);              //Creating a list of all second level symbol tables 
	}
	for (list<Symbol_table*>::iterator iterator = tablelist.begin();  
		iterator != tablelist.end(); ++iterator) {			// Creating the respective activation records for the symbol tables 
		Compute_AR(*iterator);
	}

	//asmfile
	
	ofstream asmfile;
	asmfile.open(asmfilename.c_str());

	asmfile << "\t.file	\"test.c\"\n";
	for (list <Symbol>::iterator it = current_table->current_table.begin(); it!=current_table->current_table.end(); it++) {
		if (it->category!="function") {                                                        
			if (it->type->type=="CHAR") { // Global char
				if (it->initial_value!="") {
					asmfile << "\t.globl\t" << it->name << "\n";
					asmfile << "\t.type\t" << it->name << ", @object\n";
					asmfile << "\t.size\t" << it->name << ", 1\n";
					asmfile << it->name <<":\n";
					asmfile << "\t.byte\t" << atoi( it->initial_value.c_str()) << "\n";
				}
				else {
					asmfile << "\t.comm\t" << it->name << ",1,1\n";
				}
			}
			if (it->type->type=="INTEGER") { // Global int
				if (it->initial_value!="") {
					asmfile << "\t.globl\t" << it->name << "\n";
					asmfile << "\t.data\n";
					asmfile << "\t.align 4\n";
					asmfile << "\t.type\t" << it->name << ", @object\n";
					asmfile << "\t.size\t" << it->name << ", 4\n";
					asmfile << it->name <<":\n";
					asmfile << "\t.long\t" << it->initial_value << "\n";
				}
				else {
					asmfile << "\t.comm\t" << it->name << ",4,4\n";
				}
			}
		}
	}
	if (allstrings.size()) {
		asmfile << "\t.section\t.rodata\n";
		for (vector<string>::iterator it = allstrings.begin(); it!=allstrings.end(); it++) {
			asmfile << ".LC" << it - allstrings.begin() << ":\n";
			asmfile << "\t.string\t" << *it << "\n";	
		}	
	}
	asmfile << "\t.text	\n";

	vector<string> params;
	std::map<string, int> theMap;
	for (vector<Quad>::iterator it = array.begin(); it!=array.end(); it++) {
		if (Label_Set.count(it - array.begin())) {
			asmfile << ".L" << (2*labelCount+Label_Set.at(it - array.begin()) + 2 )<< ": " << endl;
		}
		
		string op = it->op;
		string result = it->result;
		string arg1 = it->arg1;
		string arg2 = it->arg2;
		string s=arg2;

		if(op=="PARAM"){
			params.push_back(result);
		}
		else {
			asmfile << "\t";
			// Binary Operations
			if (op=="PLUS") {
				bool flag=true;
				if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) flag=false ;
				else{
					char * p ;
					strtol(s.c_str(), &p, 10) ;
					if(*p == 0) flag=true ;
					else flag=false;
				}
				if (flag) {
					asmfile << "addl \t$" << atoi(arg2.c_str()) << ", " << current_table->activation_record[arg1] << "(%rbp)";
				}
				else {
					asmfile << "movl \t" << current_table->activation_record[arg1] << "(%rbp), " << "%eax" << endl;
					asmfile << "\tmovl \t" << current_table->activation_record[arg2] << "(%rbp), " << "%edx" << endl;
					asmfile << "\taddl \t%edx, %eax\n";
					asmfile << "\tmovl \t%eax, " << current_table->activation_record[result] << "(%rbp)";
				}
			}
			else if (op=="MINUS") {
				asmfile << "movl \t" << current_table->activation_record[arg1] << "(%rbp), " << "%eax" << endl;
				asmfile << "\tmovl \t" << current_table->activation_record[arg2] << "(%rbp), " << "%edx" << endl;
				asmfile << "\tsubl \t%edx, %eax\n";
				asmfile << "\tmovl \t%eax, " << current_table->activation_record[result] << "(%rbp)";
			}
			else if (op=="MULT") {
				asmfile << "movl \t" << current_table->activation_record[arg1] << "(%rbp), " << "%eax" << endl;
				bool flag=true;
				if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) flag=false ;
				else{
					char * p ;
					strtol(s.c_str(), &p, 10) ;
					if(*p == 0) flag=true ;
					else flag=false;
				}
				if (flag) {
					asmfile << "\timull \t$" << atoi(arg2.c_str()) << ", " << "%eax" << endl;
					Symbol_table* t = current_table;
					string val;
					for (list <Symbol>::iterator it = t->current_table.begin(); it!=t->current_table.end(); it++) {
						if(it->name==arg1) val=it->initial_value; 
					}
					theMap[result]=atoi(arg2.c_str())*atoi(val.c_str());
				}
				else asmfile << "\timull \t" << current_table->activation_record[arg2] << "(%rbp), " << "%eax" << endl;
				asmfile << "\tmovl \t%eax, " << current_table->activation_record[result] << "(%rbp)";			
			}
			else if(op=="DIVIDE") {
				asmfile << "movl \t" << current_table->activation_record[arg1] << "(%rbp), " << "%eax" << endl;
				asmfile << "\tcltd" << endl;
				asmfile << "\tidivl \t" << current_table->activation_record[arg2] << "(%rbp)" << endl;
				asmfile << "\tmovl \t%eax, " << current_table->activation_record[result] << "(%rbp)";		
			}

			// Bit Operators /* Ignored */
			else if (op=="MODULO")		asmfile << result << " = " << arg1 << " % " << arg2;
			else if (op=="XOR")			asmfile << result << " = " << arg1 << " ^ " << arg2;
			else if (op=="INC_OR")		asmfile << result << " = " << arg1 << " | " << arg2;
			else if (op=="BAND")		asmfile << result << " = " << arg1 << " & " << arg2;
			// Shift Operations /* Ignored */
			else if (op=="LEFTOP")		asmfile << result << " = " << arg1 << " << " << arg2;
			else if (op=="RIGHTOP")		asmfile << result << " = " << arg1 << " >> " << arg2;

			else if (op=="EQUAL")	{
				s=arg1;
				bool flag=true;
				if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) flag=false ;
				else{
					char * p ;
					strtol(s.c_str(), &p, 10) ;
					if(*p == 0) flag=true ;
					else flag=false;
				}
				if (flag) 
					asmfile << "movl\t$" << atoi(arg1.c_str()) << ", " << "%eax" << endl;
				else
					asmfile << "movl\t" << current_table->activation_record[arg1] << "(%rbp), " << "%eax" << endl;
				asmfile << "\tmovl \t%eax, " << current_table->activation_record[result] << "(%rbp)";
			}			
			else if (op=="EQUALSTR")	{
				asmfile << "movq \t$.LC" << arg1 << ", " << current_table->activation_record[result] << "(%rbp)";
			}
			else if (op=="EQUALCHAR")	{
				asmfile << "movb\t$" << atoi(arg1.c_str()) << ", " << current_table->activation_record[result] << "(%rbp)";
			}					
			// Relational Operations
			else if (op=="EQOP") {
				asmfile << "movl\t" << current_table->activation_record[arg1] << "(%rbp), %eax\n";
				asmfile << "\tcmpl\t" << current_table->activation_record[arg2] << "(%rbp), %eax\n";
				asmfile << "\tje .L" << (2*labelCount+Label_Set.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="NEOP") {
				asmfile << "movl\t" << current_table->activation_record[arg1] << "(%rbp), %eax\n";
				asmfile << "\tcmpl\t" << current_table->activation_record[arg2] << "(%rbp), %eax\n";
				asmfile << "\tjne .L" << (2*labelCount+Label_Set.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="LT") {
				asmfile << "movl\t" << current_table->activation_record[arg1] << "(%rbp), %eax\n";
				asmfile << "\tcmpl\t" << current_table->activation_record[arg2] << "(%rbp), %eax\n";
				asmfile << "\tjl .L" << (2*labelCount+Label_Set.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="GT") {
				asmfile << "movl\t" << current_table->activation_record[arg1] << "(%rbp), %eax\n";
				asmfile << "\tcmpl\t" << current_table->activation_record[arg2] << "(%rbp), %eax\n";
				asmfile << "\tjg .L" << (2*labelCount+Label_Set.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="GE") {
				asmfile << "movl\t" << current_table->activation_record[arg1] << "(%rbp), %eax\n";
				asmfile << "\tcmpl\t" << current_table->activation_record[arg2] << "(%rbp), %eax\n";
				asmfile << "\tjge .L" << (2*labelCount+Label_Set.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="LE") {
				asmfile << "movl\t" << current_table->activation_record[arg1] << "(%rbp), %eax\n";
				asmfile << "\tcmpl\t" << current_table->activation_record[arg2] << "(%rbp), %eax\n";
				asmfile << "\tjle .L" << (2*labelCount+Label_Set.at(atoi( result.c_str() )) +2 );
			}
			else if (op=="GOTOOP") {
				asmfile << "jmp .L" << (2*labelCount+Label_Set.at(atoi( result.c_str() )) +2 );
			}
			// Unary Operators
			else if (op=="ADDRESS") {
				asmfile << "leaq\t" << current_table->activation_record[arg1] << "(%rbp), %rax\n";
				asmfile << "\tmovq \t%rax, " <<  current_table->activation_record[result] << "(%rbp)";
			}
			else if (op=="PTRR") {
				asmfile << "movl\t" << current_table->activation_record[arg1] << "(%rbp), %eax\n";
				asmfile << "\tmovl\t(%eax),%eax\n";
				asmfile << "\tmovl \t%eax, " <<  current_table->activation_record[result] << "(%rbp)";	
			}
			else if (op=="PTRL") {
				asmfile << "movl\t" << current_table->activation_record[result] << "(%rbp), %eax\n";
				asmfile << "\tmovl\t" << current_table->activation_record[arg1] << "(%rbp), %edx\n";
				asmfile << "\tmovl\t%edx, (%eax)";
			} 			
			else if (op=="UMINUS") {
				asmfile << "negl\t" << current_table->activation_record[arg1] << "(%rbp)";
			}
			else if (op=="BNOT")		asmfile << result 	<< " = ~" << arg1;
			else if (op=="LNOT")			asmfile << result 	<< " = !" << arg1;
			else if (op=="ARRR") {
				int off=0;
				off=theMap[arg2]*(-1)+current_table->activation_record[arg1];
//				asmfile << "movq\t" << current_table->activation_record[arg2] << "(%rbp), "<<"%rax" << endl;
				asmfile << "movq\t" << off << "(%rbp), "<<"%rax" << endl;
				asmfile << "\tmovq \t%rax, " <<  current_table->activation_record[result] << "(%rbp)";
			}	 			
			else if (op=="ARRL") {
				int off=0;
				off=theMap[arg1]*(-1)+current_table->activation_record[result];
//				asmfile << "movq\t" << current_table->activation_record[arg1] << "(%rbp), "<<"%rax" << endl;
				asmfile << "movq\t" << current_table->activation_record[arg2] << "(%rbp), "<<"%rdx" << endl;
				asmfile << "\tmovq\t" << "%rdx, " << off << "(%rbp)";
			}	 
			else if (op=="RETURN") {
				if(result!="") asmfile << "movl\t" << current_table->activation_record[result] << "(%rbp), "<<"%eax";
				else asmfile << "nop";
			}
			else if (op=="PARAM") {
				params.push_back(result);
			}
			else if (op=="CALL") {
				// Function Table
				Symbol_table* t = Table_global->lookup(arg1)->nested;
				int i,j=0;	// index
				for (list <Symbol>::iterator it = t->current_table.begin(); it!=t->current_table.end(); it++) {
					i = distance ( t->current_table.begin(), it);
					if (it->category== "param") {
						if(j==0) {
							asmfile << "movl \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%eax" << endl;
							asmfile << "\tmovq \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%rdi" << endl;
							//asmfile << "\tmovl \t%eax, " << (t->activation_record[it->name]-8 )<< "(%rsp)\n\t";
							j++;
						}
						else if(j==1) {
							asmfile << "movl \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%eax" << endl;
							asmfile << "\tmovq \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%rsi" << endl;
							//asmfile << "\tmovl \t%eax, " << (t->activation_record[it->name]-8 )<< "(%rsp)\n\t";
							j++;
						}
						else if(j==2) {
							asmfile << "movl \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%eax" << endl;
							asmfile << "\tmovq \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%rdx" << endl;
							//asmfile << "\tmovl \t%eax, " << (t->activation_record[it->name]-8 )<< "(%rsp)\n\t";
							j++;
						}
						else if(j==3) {
							asmfile << "movl \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%eax" << endl;
							asmfile << "\tmovq \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%rcx" << endl;
							//asmfile << "\tmovl \t%eax, " << (t->activation_record[it->name]-8 )<< "(%rsp)\n\t";
							j++;
						}
						else {
							asmfile << "\tmovq \t" << current_table->activation_record[params[i]] << "(%rbp), " << "%rdi" << endl;							
						}
					}
					else break;
				}
				params.clear();
				asmfile << "\tcall\t"<< arg1 << endl;
				asmfile << "\tmovl\t%eax, " << current_table->activation_record[result] << "(%rbp)";
			}
			else if (op=="FUNC") {
				asmfile <<".globl\t" << result << "\n";
				asmfile << "\t.type\t"	<< result << ", @function\n";
				asmfile << result << ": \n";
				asmfile << ".LFB" << labelCount <<":" << endl;
				asmfile << "\t.cfi_startproc" << endl;
				asmfile << "\tpushq \t%rbp" << endl;
				asmfile << "\t.cfi_def_cfa_offset 8" << endl;
				asmfile << "\t.cfi_offset 5, -8" << endl;
				asmfile << "\tmovq \t%rsp, %rbp" << endl;
				asmfile << "\t.cfi_def_cfa_register 5" << endl;
				current_table = Table_global->lookup(result)->nested;
				asmfile << "\tsubq\t$" << current_table->current_table.back().offset+24 << ", %rsp"<<endl;
				
				// Function Table
				Symbol_table* t = current_table;
				int i=0;
				for (list <Symbol>::iterator it = t->current_table.begin(); it!=t->current_table.end(); it++) {
					if (it->category== "param") {
						if (i==0) {
							asmfile << "\tmovq\t%rdi, " << current_table->activation_record[it->name] << "(%rbp)";
							i++;
						}
						else if(i==1) {
							asmfile << "\n\tmovq\t%rsi, " << current_table->activation_record[it->name] << "(%rbp)";
							i++;
						}
						else if (i==2) {
							asmfile << "\n\tmovq\t%rdx, " << current_table->activation_record[it->name] << "(%rbp)";
							i++;
						}
						else if(i==3) {
							asmfile << "\n\tmovq\t%rcx, " << current_table->activation_record[it->name] << "(%rbp)";
							i++;
						}
					}
					else break;
				}
			}		
			else if (op=="FUNCEND") {
				asmfile << "leave\n";
				asmfile << "\t.cfi_restore 5\n";
				asmfile << "\t.cfi_def_cfa 4, 4\n";
				asmfile << "\tret\n";
				asmfile << "\t.cfi_endproc" << endl;
				asmfile << ".LFE" << labelCount++ <<":" << endl;
				asmfile << "\t.size\t"<< result << ", .-" << result;
			}
			else asmfile << "op";
			asmfile << endl;
		}
	}
	asmfile << 	"\t.ident\t	\"Compiled by 16CS30033\"\n";
	asmfile << 	"\t.section\t.note.GNU-stack,\"\",@progbits\n";
	asmfile.close();
}



int main(int Argc, char* Argv[])
 {
	inputfile=inputfile+string(Argv[Argc-1])+string(".c");
	asmfilename=asmfilename+string(Argv[Argc-1])+string(".s");
	Table_global = new Symbol_table("Global");
	current_table = Table_global;
	yyin = fopen(inputfile.c_str(),"r"); 
	yyparse();
	Table_global->update();
	Table_global->print();
	q.print();
	Gen_Assembly();
}
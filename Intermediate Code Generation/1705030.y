
%{
#include <bits/stdc++.h>
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include <string> 
#include <sstream>
#include <algorithm> 
#include <string.h>
#include"Symboltable.cpp"


using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern int error_count;

SymbolTable *s;
FILE *fp, *fp1, *log_parser, *error_parser, *code_file,*optimized_file;
struct reuse_struct
{
	string var;
	int statement;
};

vector<SymbolInfo*> parameter_vector;
vector<SymbolInfo*> argument_vector;
vector<string> data_vector;
vector<string> temp_vector;
vector<reuse_struct> reuse_vector;


string type_speci_var;
int arg_start;

int error_line=-1;

extern string str_fun_name;
string str_fun_type="";
string return_str ="";
bool in_function = false;
string is_main = "no";

int scope_index=0;
int temp_count=0;

int statement_index = 0;
string new_temp_var(int statement_id)
{
	for(int i=0; i<reuse_vector.size(); i++)
	{
		if(reuse_vector[i].statement!=statement_id)
		{
			string temp = reuse_vector[i].var;
			reuse_vector.erase(reuse_vector.begin()+i);
			return temp;
		}
				
	}
	string temp ="t" + to_string(temp_count++);
	data_vector.push_back(temp+ " dw ?");
	temp_vector.push_back(temp);
	return temp;
}
int label_count=0;
string new_label()
{
	return "L" + to_string(label_count++);
}

void void_check(SymbolInfo* s1, SymbolInfo* s2=NULL)
{
	if(s1->get_type_speci()=="VOID_TYPE" && error_line!=line_count)
	{
		error_count++;
		error_line=line_count;
		fprintf(error_parser, "Error at line %d : Void function used in expression\n\n", line_count);
		fprintf(log_parser, "Error at line %d : Void function used in expression\n\n", line_count);

	}
	if(s2!=NULL && s2->get_type_speci()=="VOID_TYPE" && error_line!=line_count)
	{
		error_count++;
		error_line=line_count;

		fprintf(error_parser, "Error at line %d : Void function used in expression\n\n", line_count);
		fprintf(log_parser, "Error at line %d : Void function used in expression\n\n", line_count);



	}
}


void yyerror(char *s)
{
	fprintf(error_parser, "Error at line %d : %s\n\n", line_count, s);
	fprintf(log_parser, "Error at line %d : %s\n\n", line_count, s);

}



void optimize(string code)
{
	istringstream f(code);
    string line, prev_line="";  
	string optimized_code;
	
  
    while (getline(f, line)) {
        //cout << line << std::endl;
		//line.erase(std::remove(line.begin(), line.end(), '\t'), line.end());

		if((line.find("mov") != std::string::npos) && (prev_line.find("mov") != std::string::npos) && (prev_line.substr(5, 2)==line.substr(9, 5))&&(line.substr(5, 2)==prev_line.substr(9, 5)))
		{
			//cout << prev_line << std::endl;
			//cout << prev_line.substr(5, 2) << std::endl;
			//cout << prev_line.substr(9, 5) << std::endl;
			optimized_code +="\n";
			
		}
		else
		{

			cout << line << std::endl;
			optimized_code+=line+"\n";

			
		}
		prev_line = line;


    }
	fprintf(optimized_file, "%s", optimized_code.c_str());


}

%}

%union{
SymbolInfo* symbolInfo;
}


%token IF ELSE FOR WHILE DO BREAK INT FLOAT VOID RETURN SWITCH CASE DEFAULT CONTINUE LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON 
%token NUM_INT NUM_FLOAT PRINTLN DOUBLE ASSIGNOP INCOP DECOP



%token <symbolInfo> CONST_INT CONST_FLOAT ID MULOP ADDOP RELOP NOT LOGICOP 
%type <symbolInfo> fdef_after_rparen type_specifier declaration_list factor variable expression logic_expression rel_expression simple_expression term unary_expression statement expression_statement
%type <symbolInfo> parameter_list argument_list arguments var_declaration program start unit func_declaration func_definition compound_statement statements


%type fdef_after_rparen
%type fdec_after_rparen
%type cstate_after_lcurl



%nonassoc LOWER_THAN_ELSE
%nonassoc less_id
%nonassoc less_para_id
%nonassoc error
%nonassoc ELSE
%nonassoc LESS_THAN_COMMA_2
%nonassoc LOWER_THAN_COMMA
%nonassoc COMMA


%%

start : program
	{
		$$=$1;
		fprintf(log_parser, "Line %d: start : program \n\n\n", line_count);
		if(error_count == 0)
		{
			string temp = ".MODEL small\n.STACK 100h\n.DATA\nra dw ?\n";
		
			for(int i=0; i<data_vector.size(); i++)
			{
				temp += data_vector[i]+"\n";
			}
			temp+=".CODE\n";



			temp+="println PROC\n\tPUSH AX\n\tPUSH BX\n\tPUSH CX\n\tPUSH DX\n\tPUSH BP\n\tMOV BP, SP\n\tMOV AX, [bp+12]\n\tCMP AX, 0H\n\tJL PRINT_NEG\n\tJMP POS_OUT\n";
			temp+="PRINT_NEG:\n\tMOV AH, 2\n\tMOV DL, 2DH\n\tINT 21H\nNEG_OUT:\n\tMOV AX, [bp+12]\n\tNEG AX\nPOS_OUT:\n\tMOV CL, 0H\n";
			temp+="WHILE_COUNT_IN:\n\tCMP AX, 0AH\n\tJL END_COUNT_IN\n\tADD CL, 1H\n\tMOV BX, 0AH\n\tCWD\n\tIDIV BX\n\tPUSH DX\n\tJMP WHILE_COUNT_IN\nEND_COUNT_IN:\n\tPUSH AX\n\tADD CL, 1H\n";      
			temp+="WHILE_COUNT_OUT:\n\tCMP CL, 0H\n\tJE END_COUNT_OUT\n\tPOP BX\n\tMOV AH, 2\n\tMOV DL, BL \n\tADD DL, 30H\n\tINT 21H\n\tSUB CL, 1H\n\tJMP WHILE_COUNT_OUT\n";
			temp+="END_COUNT_OUT:\n\tMOV DL, 10\n\tMOV AH, 02h\n\tINT 21h\n\tMOV DL, 13\n\tMOV AH, 02h\n\tINT 21h\n";
			temp+="\tPOP BP\n\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tRET\nprintln ENDP\n\n\n\n";
			

			$$->set_code(temp + $$->get_code()+"\nEND main_proc");
			fprintf(code_file, "%s", $$->get_code().c_str());
			optimize($$->get_code());

		}


	}
	;

program : program unit 
		{
			SymbolInfo *si = new SymbolInfo($1->get_name()+'\n'+$2->get_name(), "program");	
			$$=si;
			fprintf(log_parser, "Line %d: program : program unit\n\n", line_count);
			fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
			$$->set_code($1->get_code()+$2->get_code());

		}
	| unit
	{
		$$=$1;
		fprintf(log_parser, "Line %d: program : unit\n\n", line_count);
		fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());

	}
	;
	
unit : var_declaration
		{
			$$=$1;
			fprintf(log_parser, "Line %d: unit : var_declaration\n\n", line_count);
			fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());

		}
     | func_declaration
	 {
		$$=$1;
		fprintf(log_parser, "Line %d: unit : func_declaration\n\n", line_count);
		fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());

	 }
     | func_definition
	 {
		$$=$1;
		$$->set_code("\n\n"+$$->get_code()+"\n\n");
		fprintf(log_parser, "Line %d: unit : func_definition\n\n", line_count);
		fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());

	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN fdec_after_rparen SEMICOLON
					{
						
							SymbolInfo *si = new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+");", "func_declaration");
							$$=si;
							fprintf(log_parser, "Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n", line_count);
							fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());


					}
		| type_specifier ID LPAREN RPAREN fdec_after_rparen SEMICOLON
		{
			{
				
					SymbolInfo *si = new SymbolInfo($1->get_name()+" "+$2->get_name()+"();", "func_declaration");
					$$=si;
					fprintf(log_parser, "Line %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n", line_count);
					fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());

			}
			
		}
		| type_specifier ID LPAREN parameter_list RPAREN fdec_after_rparen error
					{
						
							SymbolInfo *si = new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+");", "func_declaration");
							$$=si;
							fprintf(log_parser, "Error at line %d : Missing SEMICOLON after function declaration\n\n", line_count);
							fprintf(error_parser, "Error at line %d : Missing SEMICOLON after function declaration\n\n", line_count);
							error_count++;
							fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());

					}
		| type_specifier ID LPAREN RPAREN fdec_after_rparen error
		{
			{
				
					SymbolInfo *si = new SymbolInfo($1->get_name()+" "+$2->get_name()+"();", "func_declaration");
					$$=si;
					fprintf(log_parser, "Error at line %d : Missing SEMICOLON after function declaration\n\n", line_count);
					fprintf(error_parser, "Error at line %d : Missing SEMICOLON after function declaration\n\n", line_count);
					error_count++;
					fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());

			}
			
		}
		| type_specifier ID LPAREN error RPAREN fdec_after_rparen SEMICOLON
		{
			{
				
					SymbolInfo *si = new SymbolInfo($1->get_name()+" "+$2->get_name()+"();", "func_declaration");
					$$=si;
					error_count++;
					fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());

			}
			
		}
		;
fdec_after_rparen	:	{
						string name, type;

						istringstream ss(str_fun_name);
						ss>>name;

						istringstream ss2(str_fun_type);
						ss2>>type;
						str_fun_type="";
						str_fun_name="";

						SymbolInfo* temp = s->look_up_curr(name);
						if(temp!=NULL)
						{
							error_count++;
							fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count, name.c_str());
							fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count, name.c_str());

						}
						else{
							s->insert_symbol(name, "ID");
							SymbolInfo *si = s->look_up_curr(name);
							si->set_return_type(type);
							si->set_type_speci(type);
							si->set_fun_status("declared");
							for(int i=0; i<parameter_vector.size(); i++)
							{
								si->push_func_parameter(parameter_vector[i]->get_type_speci()); //INT_TYPE FLOAT_TYPE
							}
							

							

						}
						parameter_vector.clear();

						
					}
					; 
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN fdef_after_rparen compound_statement
				{
							
					
					SymbolInfo *si2 = new SymbolInfo($1->get_name()+" "+$2->get_name()+"("+$4->get_name()+")"+$7->get_name()+'\n', "func_definition");
					$$=si2;

					fprintf(log_parser, "Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n", line_count);
					fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
					string start = $2->get_name()+ "_proc PROC\n\tpop ra\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush di\n\tpush bp\n\tmov bp, sp\n";
					string end = "\n\tpop bp\n\tpop di\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tpush ra\n\tret\n";
					string start_main = "\tpop ra\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush di\n\tpush bp\n\tmov bp, sp\n";

					if($2->get_name() != "main") {
						if(s->look_up($2->get_name())->get_return_type()!="VOID_TYPE")
						{							
						     $$->set_code(start+ $6->get_code() + $7->get_code()  + $2->get_name()+"_proc ENDP\n");

						}
						else
						{
							
						     $$->set_code(start+ $6->get_code() + $7->get_code() + end);

						}

            		}
					else{
						$$->set_code("main_proc PROC\n\tmov ax, @data\n\tmov ds, ax\n\n"+ $6->get_code()+ $7->get_code()+"\n\n\tmov ah, 4ch\n\tint 21h\n\tret\nmain_proc ENDP\n\n");
					}
					temp_vector.clear();

					
	

				}
		| type_specifier ID LPAREN RPAREN fdef_after_rparen compound_statement

		{
			{
				
				
					SymbolInfo *si2 = new SymbolInfo($1->get_name()+" "+$2->get_name()+"()"+$6->get_name()+'\n', "func_definition");
					$$=si2;
					
					fprintf(log_parser, "Line %d: func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n", line_count);
					fprintf(log_parser, "%s\n\n", si2->get_name().c_str());
					string start = $2->get_name()+ "_proc PROC\n\tpop ra\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush di\n\tpush bp\n\tmov bp, sp\n";
					string end = "\n\tpop bp\n\tpop di\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tpush ra\n\tret\n";
					string start_main = "\tpop ra\n\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush di\n\tpush bp\n\tmov bp, sp\n";

					if($2->get_name() != "main") {
						if(s->look_up($2->get_name())->get_return_type()!="VOID_TYPE")
						{							
						     $$->set_code(start + $5->get_code()+ $6->get_code()  + $2->get_name()+"_proc ENDP\n");

						}
						else
						{
						     $$->set_code(start+ $5->get_code() + $6->get_code() + end);

						}

            		}
					else{
						$$->set_code("main_proc PROC\n\tmov ax, @data\n\tmov ds, ax\n\n" + $5->get_code()+ $6->get_code()+"\n\n\tmov ah, 4ch\n\tint 21h\n\tret\nmain_proc ENDP\n\n");
					}

			}
		}
 		;				

			
fdef_after_rparen	:	{
		
						string name, type;

						istringstream ss(str_fun_name);
						ss>>name;

						istringstream ss2(str_fun_type);
						ss2>>type;
						str_fun_type="";
						str_fun_name="";
						
						SymbolInfo *temp = s->look_up_curr(name);
						if(name=="main") is_main ="yes";
						else is_main ="no";
						
						if(temp!=NULL)
						{
							
							if(temp->get_fun_status()=="declared")
							{
								temp->set_fun_status("defined");
								bool match = true;
						
								s->enter_scope();
								SymbolInfo* node = new SymbolInfo("fdef", "None");

								for(int i=0, j=12; i<parameter_vector.size(); i++, j=j+2)
								{
									s->insert_symbol(parameter_vector[i]->get_name(), parameter_vector[i]->get_type());
									SymbolInfo* si2 = s->look_up_curr(parameter_vector[i]->get_name());
									si2->set_type_speci(parameter_vector[i]->get_type_speci());

									
									node->add_code("\tmov ax, [bp+"+ to_string(j) + "]\n");
									node->add_code("\tmov "+si2->get_name()+to_string(scope_index)+", ax\n");
									si2->set_symbol(si2->get_name()+to_string(scope_index));
									temp_vector.push_back(si2->get_name()+to_string(scope_index));
									data_vector.push_back(si2->get_name()+to_string(scope_index)+" dw ?");

									
									if(parameter_vector[i]->get_type_speci()!=temp->get_func_parameter(i))
									{
										match=false;

									}
									
								}
								$$=node;
								if(parameter_vector.size()!=temp->get_parameter_size() && error_line!=line_count)
								{
									error_count++;
									error_line=line_count;
									fprintf(error_parser, "Error at line %d : Total number of arguments mismatch with declaration in function var\n\n", line_count);
									fprintf(log_parser, "Error at line %d : Total number of arguments mismatch with declaration in function var\n\n", line_count);

								}
								else if(match==false && error_line!=line_count)
								{
									error_count++;
									error_line=line_count;
									fprintf(error_parser, "Error at line %d : Function definiton and decleration doesn't match \n\n", line_count);
									fprintf(log_parser, "Error at line %d : Function definiton and decleration doesn't match \n\n", line_count);

								}
								if(temp->get_return_type()!=type && error_line!=line_count)
								{
									error_count++;
									error_line=line_count;
									fprintf(error_parser, "Error at line %d : Return type mismatch with function declaration in function %s\n\n", line_count, name.c_str());
									fprintf(log_parser, "Error at line %d : Return type mismatch with function declaration in function %s\n\n", line_count, name.c_str());

								}
							

								parameter_vector.clear();

							}
							else if(temp->get_fun_status()=="None"){
								s->enter_scope();
								for(int i=0; i<parameter_vector.size(); i++)
								{
									if(parameter_vector[i]->get_type_speci()=="ERROR_TYPE")
									{
										fprintf(log_parser, "Error at line %d : %dth parameter's name not given in function definition of var\n\n", line_count, i+1);
										fprintf(error_parser, "Error at line %d : %dth parameter's name not given in function definition of var\n\n", line_count, i+1);
										error_count++;
										error_line=line_count;
									}
									else
									{
										s->insert_symbol(parameter_vector[i]->get_name(), parameter_vector[i]->get_type());
										SymbolInfo* si2 = s->look_up_curr(parameter_vector[i]->get_name());
										si2->set_type_speci(parameter_vector[i]->get_type_speci());
									

									}
									
								}
								if(error_line!=line_count)
								{
									fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count, name.c_str());
									fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count, name.c_str());

									error_count++;
									error_line=line_count;

								}

								
								parameter_vector.clear();
							}
							else if(temp->get_fun_status()=="defined"){
								s->enter_scope();
								for(int i=0; i<parameter_vector.size(); i++)
								{
									if(parameter_vector[i]->get_type_speci()=="ERROR_TYPE")
									{
										fprintf(log_parser, "Error at line %d : %dth parameter's name not given in function definition of var\n\n", line_count, i+1);
										fprintf(error_parser, "Error at line %d : %dth parameter's name not given in function definition of var\n\n", line_count, i+1);
										error_count++;
										error_line=line_count;
									}
									else
									{
										s->insert_symbol(parameter_vector[i]->get_name(), parameter_vector[i]->get_type());
										SymbolInfo* si2 = s->look_up_curr(parameter_vector[i]->get_name());
										si2->set_type_speci(parameter_vector[i]->get_type_speci());
									

									}
									
								}
								if(error_line!=line_count){
								fprintf(log_parser, "Error at line %d : Multiple definition of %s\n\n", line_count, name.c_str());
								fprintf(error_parser, "Error at line %d : Multiple definition of %s\n\n", line_count, name.c_str());

								error_count++;
								error_line=line_count;}
								
								parameter_vector.clear();
							}


						}
						else{
							s->insert_symbol(name, "ID");
							SymbolInfo *si = s->look_up_curr(name);
							si->set_return_type(type);
							si->set_type_speci(type);
							si->set_fun_status("defined");
							int i;
							for(i=0; i<parameter_vector.size(); i++)
							{
								if(parameter_vector[i]->get_type_speci()=="ERROR_TYPE")
									{
										fprintf(log_parser, "Error at line %d : %dth parameter's name not given in function definition of var\n\n", line_count, i+1);
										fprintf(error_parser, "Error at line %d : %dth parameter's name not given in function definition of var\n\n", line_count, i+1);
										error_count++;
										error_line=line_count;
									}
								else
								{
									si->push_func_parameter(parameter_vector[i]->get_type_speci()); //INT_TYPE FLOAT_TYPE
								}
								
							}

							s->enter_scope();
							SymbolInfo* node = new SymbolInfo("fdef", "None");

							for(int i=0, j=12; i<parameter_vector.size(); i++, j=j+2)
							{
								if(parameter_vector[i]->get_type_speci()!="ERROR_TYPE")
									{
										s->insert_symbol(parameter_vector[i]->get_name(), parameter_vector[i]->get_type());
										SymbolInfo* si2 = s->look_up_curr(parameter_vector[i]->get_name());
										si2->set_type_speci(parameter_vector[i]->get_type_speci());
										
										
										node->add_code("\tmov ax, [bp+"+ to_string(j) + "]\n");
										node->add_code("\tmov "+si2->get_name()+to_string(scope_index)+", ax\n");
										si2->set_symbol(si2->get_name()+to_string(scope_index));
										temp_vector.push_back(si2->get_name()+to_string(scope_index));

										data_vector.push_back(si2->get_name()+to_string(scope_index)+" dw ?");
										
										
									}

							}
							$$=node;


							parameter_vector.clear();


						}
						in_function = true;
						
					}
					; 


parameter_list  : parameter_list COMMA type_specifier ID
				{

					SymbolInfo *si = new SymbolInfo($1->get_name()+","+$3->get_name()+" "+$4->get_name(), "parameter_list");
					SymbolInfo* temp=new SymbolInfo($4->get_name(), "ID");
					if($3->get_type()=="INT") temp->set_type_speci("INT_TYPE");
					else if($3->get_type()=="FLOAT") temp->set_type_speci("FLOAT_TYPE");
					else if($3->get_type()=="VOID") temp->set_type_speci("VOID_TYPE");
					
					for(int i=0; i<parameter_vector.size(); i++)
					{
						if(parameter_vector[i]->get_name()==$4->get_name() && error_line!=line_count)
						{
							error_count++;
							error_line=line_count;
							fprintf(error_parser, "Error at line %d : Multiple declaration of %s in parameter\n\n", line_count, $4->get_name().c_str());
							fprintf(log_parser, "Error at line %d : Multiple declaration of %s in parameter\n\n", line_count, $4->get_name().c_str());
							break;

						}
						
					}
					parameter_vector.push_back(temp);
					$$=si;
					fprintf(log_parser, "Line %d: parameter_list : parameter_list COMMA type_specifier ID\n\n", line_count);
					fprintf(log_parser, "%s\n\n", si->get_name().c_str());
					
				}
				| parameter_list error COMMA type_specifier ID
				{

					SymbolInfo *si = new SymbolInfo($1->get_name()+","+$4->get_name(), "parameter_list");
					
					$$=si;
					fprintf(log_parser, "%s\n\n", si->get_name().c_str());

					error_count++;
					error_line=line_count;
					
				}
		| parameter_list COMMA type_specifier
		{
			SymbolInfo *si = new SymbolInfo($1->get_name()+","+$3->get_name(), "parameter_list");
			SymbolInfo* temp = new SymbolInfo("NONE", "ID");
			if($3->get_type()=="INT") temp->set_type_speci("INT_TYPE");
			else if($3->get_type()=="FLOAT") temp->set_type_speci("FLOAT_TYPE");
			else if($3->get_type()=="VOID") temp->set_type_speci("VOID_TYPE");
			parameter_vector.push_back(temp);

			$$=si;
			fprintf(log_parser, "Line %d: parameter_list : parameter_list COMMA type_specifier\n\n", line_count);
			fprintf(log_parser, "%s\n\n", si->get_name().c_str());
		

		}
 		| type_specifier ID
		 {
			SymbolInfo *si = new SymbolInfo($1->get_name()+" "+$2->get_name(), "parameter_list");
			SymbolInfo* temp = new SymbolInfo($2->get_name(), "ID");
			fprintf(log_parser, "Line %d: parameter_list : type_specifier ID\n\n", line_count);
			fprintf(log_parser, "%s\n\n", si->get_name().c_str());
			if($1->get_type()=="INT") temp->set_type_speci("INT_TYPE");
			else if($1->get_type()=="FLOAT") temp->set_type_speci("FLOAT_TYPE");
			else if($1->get_type()=="VOID") temp->set_type_speci("VOID_TYPE");
			bool valid=true;
			for(int i=0; i<parameter_vector.size(); i++)
			{
				if(parameter_vector[i]->get_name()==$2->get_name() && error_line!=line_count)
				{
					error_count++;
					error_line=line_count;
					valid=false;
					fprintf(error_parser, "Error at line %d : Multiple declaration of a in parameter\n\n", line_count);
					fprintf(log_parser, "Error at line %d : Multiple declaration of a in parameter\n\n", line_count);

					break;

				}
				
			}
			if(valid==true) parameter_vector.push_back(temp);
			$$=si;


		 }%prec less_para_id
		| type_specifier
		{
			SymbolInfo *si = new SymbolInfo($1->get_name(), "parameter_list");
			SymbolInfo* temp = new SymbolInfo("NONE", "ID");
			if($1->get_type()=="INT") temp->set_type_speci("INT_TYPE");
			else if($1->get_type()=="FLOAT") temp->set_type_speci("FLOAT_TYPE");
			else if($1->get_type()=="VOID") temp->set_type_speci("VOID_TYPE");
			parameter_vector.push_back(temp);
			$$=si;
			fprintf(log_parser, "Line %d: parameter_list : type_specifier\n\n", line_count);
			fprintf(log_parser, "%s\n\n", si->get_name().c_str());

		}
		| parameter_list error
		{
			SymbolInfo *temp = parameter_vector.back();
			parameter_vector.pop_back();
			temp->set_type_speci("ERROR_TYPE");
			parameter_vector.push_back(temp);

			$$=$1;
			//fprintf(log_parser, "Line %d: parameter_list : type_specifier\n\n", line_count);
			fprintf(log_parser, "%s\n\n", $$->get_name().c_str());

			error_count++;
			error_line=line_count;
			yyerrok;
			yyclearin;
		}%prec LESS_THAN_COMMA_2

 		;

 		
compound_statement : LCURL cstate_after_lcurl statements RCURL
					{
						SymbolInfo *si= new SymbolInfo("{\n"+$3->get_name()+"\n}", $3->get_type());
						$$=si;
						fprintf(log_parser, "Line %d: compound_statement : LCURL statements RCURL\n\n", line_count);
						fprintf(log_parser, "%s\n\n\n\n", $$->get_name().c_str());
						
						s->print_all_scope();
						s->exit_scope();
						in_function = false;
						$$->set_code($3->get_code());
					

					}
 		    | LCURL RCURL
			 {
				SymbolInfo *si= new SymbolInfo("{}\n\n", "LCURL RCURL");
				$$=si;
				fprintf(log_parser, "Line %d: compound_statement : LCURL RCURL\n\n", line_count);
				fprintf(log_parser, "%s", si->get_name().c_str());
				s->print_all_scope();
				s->exit_scope();
				in_function = false;
				
			 }
 		    ;
cstate_after_lcurl	:
					{
						scope_index++;
						if(in_function==false)
						{
							s->enter_scope();
						}
						in_function=false;
					}
					;
 		    
var_declaration : type_specifier declaration_list SEMICOLON
				{
					SymbolInfo *si= new SymbolInfo($1->get_name()+" "+$2->get_name()+";", "var_declaration");
					$$=si;
					fprintf(log_parser, "Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n\n", line_count);
					if($1->get_type()=="VOID" && error_line!=line_count)
					{
						error_count++;
						error_line=line_count;

						fprintf(error_parser, "Error at line %d : Variable type cannot be void\n\n", line_count);
						fprintf(log_parser, "Error at line %d : Variable type cannot be void\n\n", line_count);

					}
					fprintf(log_parser, "%s\n\n", si->get_name().c_str());
					str_fun_name="";
					str_fun_type="";
					

				}
				
 		 ;
 		 
type_specifier	: INT
				{
					SymbolInfo *si = new SymbolInfo("int", "INT");
					$$=si;
					type_speci_var="INT_TYPE";
					str_fun_type+=" ";
					str_fun_type+="INT_TYPE";
					fprintf(log_parser, "Line %d: type_specifier : INT\n\nint\n\n", line_count);


				}
 				| FLOAT
				 {
					SymbolInfo *si = new SymbolInfo("float", "FLOAT");
					$$=si;
					type_speci_var="FLOAT_TYPE";
					str_fun_type+=" ";
					str_fun_type+="FLOAT_TYPE";
					fprintf(log_parser, "Line %d: type_specifier : FLOAT\n\nfloat\n\n", line_count);

				 }
 				| VOID
				 {
					SymbolInfo *si = new SymbolInfo("void", "VOID");
					$$=si;
					type_speci_var="VOID_TYPE";
					str_fun_type+=" ";
					str_fun_type+="VOID_TYPE";
					fprintf(log_parser, "Line %d: type_specifier : VOID\n\nvoid\n\n", line_count);

				 }
 				;
 		
declaration_list : declaration_list COMMA ID
				{
					bool valid=true;
					if(type_speci_var=="VOID_TYPE")
					{
						valid=false;
					}
					if(s->look_up_curr($3->get_name()))
					{
						fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$3->get_name().c_str());
						fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$3->get_name().c_str());

						error_count++;
						error_line=line_count;
					}
					else if(valid==true)
					{
						s->insert_symbol($3->get_name(), "ID");
						SymbolInfo* si2 = s->look_up_curr($3->get_name());
						si2->set_type_speci(type_speci_var);
					}
					SymbolInfo* si=new SymbolInfo($1->get_name()+","+$3->get_name(), $3->get_type());
					$$=si;
					fprintf(log_parser, "Line %d: declaration_list : declaration_list COMMA ID\n\n", line_count);
					fprintf(log_parser, "%s\n\n", $$->get_name().c_str());

					str_fun_name="";


					SymbolInfo *temp = s->look_up($3->get_name());
					temp->set_symbol($3->get_name()+ to_string(scope_index));
					data_vector.push_back(temp->get_symbol() + " dw ?");



				}
				| declaration_list error COMMA ID
				{
					bool valid=true;
					if(type_speci_var=="VOID_TYPE")
					{
						valid=false;
					}
					if(s->look_up_curr($4->get_name()))
					{
						fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$4->get_name().c_str());
						fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$4->get_name().c_str());

						error_count++;
						error_line=line_count;
					}
					else if(valid==true)
					{
						s->insert_symbol($4->get_name(), "ID");
						SymbolInfo* si2 = s->look_up_curr($4->get_name());
						si2->set_type_speci(type_speci_var);
					}
					SymbolInfo* si=new SymbolInfo($1->get_name()+","+$4->get_name(), $4->get_type());
					$$=si;
					fprintf(log_parser, "%s\n\n", $$->get_name().c_str());


					error_count++;
					error_line=line_count;
					str_fun_name="";
				}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD
		   {
			   bool valid=true;
					if(type_speci_var=="VOID_TYPE")
					{
						valid=false;
					}
			   	if(s->look_up_curr($3->get_name()))
				{
					fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$3->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$3->get_name().c_str());

					error_count++;
					error_line=line_count;
				}
				else if(valid==true)
				{
					s->insert_symbol($3->get_name(), "ID");
					SymbolInfo* si2 = s->look_up_curr($3->get_name());
					si2->set_type_speci(type_speci_var);
					si2->set_array_size(atoi($5->get_name().c_str()));
				}
				SymbolInfo *si = new SymbolInfo($1->get_name()+","+$3->get_name()+"["+$5->get_name()+"]", $3->get_type());
				si->set_array_size(stoi($5->get_name()));
				$$=si;
				fprintf(log_parser, "Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n", line_count);
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());

				str_fun_name="";
				SymbolInfo *temp = s->look_up($3->get_name());
				temp->set_symbol($3->get_name()+ to_string(scope_index));
				data_vector.push_back($3->get_name()+to_string(scope_index)+ " dw "+$5->get_name()+" dup ($)");

			   

		   }
 		  | declaration_list error COMMA ID LTHIRD CONST_INT RTHIRD
		   {
			   bool valid=true;
					if(type_speci_var=="VOID_TYPE")
					{
						valid=false;
					}
			   	if(s->look_up_curr($4->get_name()))
				{
					fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$4->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$4->get_name().c_str());

					error_count++;
					error_line=line_count;
				}
				else if(valid==true)
				{
					s->insert_symbol($4->get_name(), "ID");
					SymbolInfo* si2 = s->look_up_curr($4->get_name());
					si2->set_type_speci(type_speci_var);
					si2->set_array_size(atoi($6->get_name().c_str()));
				}
				SymbolInfo *si = new SymbolInfo($1->get_name()+","+$4->get_name()+"["+$6->get_name()+"]", $4->get_type());
				si->set_array_size(stoi($6->get_name()));
				$$=si;

				error_count++;
				error_line=line_count;
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());

				str_fun_name="";
			   

		   }
 		  | declaration_list COMMA ID LTHIRD error RTHIRD
		   {
			   bool valid=true;
					if(type_speci_var=="VOID_TYPE")
					{
						valid=false;
					}
			   	if(s->look_up_curr($3->get_name()))
				{
					fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$3->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$3->get_name().c_str());

					error_count++;
					error_line=line_count;
				}
				else if(valid==true)
				{
					s->insert_symbol($3->get_name(), "ID");
					SymbolInfo* si2 = s->look_up_curr($3->get_name());
					si2->set_type_speci(type_speci_var);
					//si2->set_array_size(atoi($5->get_name().c_str()));
				}
				SymbolInfo *si = new SymbolInfo($1->get_name()+","+$3->get_name()+"[]", $3->get_type());
				//si->set_array_size(stoi($5->get_name()));
				$$=si;
				if(error_line!=line_count){fprintf(log_parser, "Error at Line %d : declaration_list : Array size not defined\n\n", line_count);
				fprintf(error_parser, "Error at Line %d : declaration_list : Array size not defined\n\n", line_count);

				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				error_count++;
				error_line=line_count;}
				str_fun_name="";
			   

		   }
 		  | ID
		   {
			   
			   	bool valid=true;
					if(type_speci_var=="VOID_TYPE")
					{
						valid=false;
					}
				
				if(s->look_up_curr($1->get_name()))
				{
					fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$1->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$1->get_name().c_str());

					error_count++;
					error_line=line_count;
				}
				else if(valid==true){
					s->insert_symbol($1->get_name(), "ID");
					SymbolInfo* si2 = s->look_up_curr($1->get_name());
					si2->set_type_speci(type_speci_var);					
				}
				SymbolInfo *si = new SymbolInfo($1->get_name(), $1->get_type());
				$$=si;
				fprintf(log_parser, "Line %d: declaration_list : ID\n\n", line_count);
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				str_fun_name="";
				SymbolInfo *temp = s->look_up($1->get_name());
				temp->set_symbol($1->get_name()+ to_string(scope_index));
				$$->set_symbol($1->get_name()+ to_string(scope_index));
				data_vector.push_back(temp->get_symbol() + " dw ?");



		   }%prec less_id
 		  | declaration_list error
		   {
				$$=$1;
				error_count++;
				error_line=line_count;
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				str_fun_name="";

		   }%prec LOWER_THAN_COMMA;
 		  | ID LTHIRD CONST_INT RTHIRD
		   {
			   bool valid=true;
					if(type_speci_var=="VOID_TYPE")
					{
						fprintf(error_parser, "Error at line %d : Variable type cannot be void\n\n", line_count);
						fprintf(log_parser, "Error at line %d : Variable type cannot be void\n\n", line_count);

						valid=false;
					}
			   if(s->look_up_curr($1->get_name()))
				{
					fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$1->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$1->get_name().c_str());

					error_count++;
					error_line=line_count;
				}
				else if(valid==true)
				{
					s->insert_symbol($1->get_name(), "ID");
					SymbolInfo* si2 = s->look_up_curr($1->get_name());
					si2->set_type_speci(type_speci_var);
					si2->set_array_size(atoi($3->get_name().c_str()));
				}
				SymbolInfo *si = new SymbolInfo($1->get_name()+"["+$3->get_name()+"]", $1->get_type());
				si->set_array_size(stoi($3->get_name()));
				$$=si;
				fprintf(log_parser, "Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n", line_count);
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
			   
			
				str_fun_name="";

				SymbolInfo *temp = s->look_up($1->get_name());
				temp->set_symbol($1->get_name()+ to_string(scope_index));
				data_vector.push_back($1->get_name()+to_string(scope_index)+ " dw "+$3->get_name()+" dup ($)");

		   }
 		  | ID LTHIRD error RTHIRD
		   {
			   bool valid=true;
					if(type_speci_var=="VOID_TYPE")
					{
						fprintf(error_parser, "Error at line %d : Variable type cannot be void\n\n", line_count);
						fprintf(log_parser, "Error at line %d : Variable type cannot be void\n\n", line_count);

						valid=false;
					}
			   if(s->look_up_curr($1->get_name()))
				{
					fprintf(error_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$1->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Multiple declaration of %s\n\n", line_count,$1->get_name().c_str());

					error_count++;
					error_line=line_count;
				}
				else if(valid==true)
				{
					s->insert_symbol($1->get_name(), "ID");
					SymbolInfo* si2 = s->look_up_curr($1->get_name());
					si2->set_type_speci(type_speci_var);
					//si2->set_array_size(atoi($3->get_name().c_str()));
				}
				SymbolInfo *si = new SymbolInfo($1->get_name()+"[]", $1->get_type());
				//si->set_array_size(stoi($3->get_name()));
				$$=si;
				if(error_line!=line_count){fprintf(log_parser, "Error at Line %d : array size missing\n\n", line_count);
				fprintf(error_parser, "Error at Line %d : array size missing\n\n", line_count);
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				error_count++;}
				error_line=line_count;
			   
			
				str_fun_name="";
		   }
 		  ;
 		  
statements : statement
			{
				$$=$1;
				fprintf(log_parser, "Line %d: statements : statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());
				//$$->add_code(";"+$$->get_name()+"\n");

			}
	   | statements statement
	   {
				SymbolInfo *si=new SymbolInfo($1->get_name()+"\n"+$2->get_name(), $1->get_type());
				$$=si;
				fprintf(log_parser, "Line %d: statements : statements statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				$$->set_code($1->get_code()+$2->get_code());
	   }
	   	| statements func_definition
	   {
				SymbolInfo *si=new SymbolInfo($1->get_name()+"\n"+$2->get_name(), $1->get_type());
				$$=si;
				if(error_line!=line_count){fprintf(log_parser, "Error at Line %d : Function definition inside function \n\n", line_count);
				fprintf(error_parser, "Error at Line %d : Function definition inside function \n\n", line_count);
				error_count++;
				error_line=line_count;}
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
	   }
	   	| statements func_declaration
	   {
				SymbolInfo *si=new SymbolInfo($1->get_name()+"\n"+$2->get_name(), $1->get_type());
				$$=si;
				if(error_line!=line_count){fprintf(log_parser, "Error at Line %d : Function decleration inside function \n\n", line_count);
				fprintf(error_parser, "Error at Line %d : Function decleration inside function \n\n", line_count);
				error_count++;
				error_line=line_count;}
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
	   }
	   	| func_definition
	   {
				
				$$=$1;
				if(error_line!=line_count){fprintf(log_parser, "Error at Line %d : Function definition inside function \n\n", line_count);
				fprintf(error_parser, "Error at Line %d : Function definition inside function \n\n", line_count);
				error_count++;
				error_line=line_count;}
				fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());
	   }
	   	| func_declaration
	   {
				$$=$1;
				if(error_line!=line_count){fprintf(log_parser, "Error at Line %d : Function decleration inside function \n\n", line_count);
				fprintf(error_parser, "Error at Line %d : Function decleration inside function \n\n", line_count);
				error_count++;
				error_line=line_count;}
				fprintf(log_parser, "%s\n\n\n", $$->get_name().c_str());
	   }
	   	| error
	   {
		   	SymbolInfo *si=new SymbolInfo("Invalid statement", "Invalid statement");
			$$=si;
			error_count++;
			error_line=line_count;
	   }
	   ;
	   
statement : var_declaration
			{
				SymbolInfo *si = new SymbolInfo($1->get_name(), "statement");
				$$=si;
				$$->set_code($1->get_code());
				fprintf(log_parser, "Line %d: statement : var_declaration\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				$$->add_code(";"+$$->get_name()+"\n");
				statement_index++;

			}
	  | expression_statement
	  {
				SymbolInfo *si = new SymbolInfo($1->get_name(), "statement");
				$$=si;
				fprintf(log_parser, "Line %d: statement : expression_statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				$$->set_code($1->get_code());
				$$->add_code(";"+$$->get_name()+"\n");
				statement_index++;


	  }
	  | compound_statement
	  {
		  		SymbolInfo *si = new SymbolInfo($1->get_name(), "statement");
				$$=si;
				fprintf(log_parser, "Line %d: statement : compound_statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				$$->set_code($1->get_code());
				statement_index++;

	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
	  {
		  		SymbolInfo *si = new SymbolInfo("for("+$3->get_name()+$4->get_name()+$5->get_name()+")"+$7->get_name(), "statement");
				$$=si;
				fprintf(log_parser, "Line %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				$$->add_code($3->get_code());
				string label1 = new_label();
				string label2 = new_label();
				$$->add_code("\n"+label1+":\n");
				$$->add_code($4->get_code());
				$$->add_code("mov ax, "+$4->get_symbol()+"\n");
				$$->add_code("cmp ax, 0\n");
				$$->add_code("je "+label2+"\n");
				$$->add_code($7->get_code());
				$$->add_code($5->get_code());
				$$->add_code("jmp "+label1+"\n");
				$$->add_code("\n"+label2+":\n");
				$$->add_code(";for("+$3->get_name()+$4->get_name()+$5->get_name()+")"+"\n");
				statement_index++;

	  } 
	  | IF LPAREN expression RPAREN statement 
	  {
		  		SymbolInfo *si = new SymbolInfo("if ("+$3->get_name()+")"+$5->get_name(), "statement");
				$$=si;
				fprintf(log_parser, "Line %d: statement : IF LPAREN expression RPAREN statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				string label=new_label();
				$$->set_code($3->get_code());
				$$->add_code("mov ax, "+$3->get_symbol()+"\n");
				$$->add_code("cmp ax, 0\n");
				$$->add_code("je "+label+"\n");
				$$->add_code($5->get_code());
				$$->add_code("\n"+label+":\n");
				$$->add_code(";if ("+$3->get_name()+")");
				statement_index++;
	  }%prec LOWER_THAN_ELSE;
	  | IF LPAREN expression RPAREN statement ELSE statement
	  {
		  		SymbolInfo *si = new SymbolInfo("if ("+$3->get_name()+")"+$5->get_name()+"\nelse\n"+$7->get_name(), "statement");
				$$=si;
				fprintf(log_parser, "Line %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				string l1=new_label();
				string l2=new_label();
				$$->set_code($3->get_code());
				$$->add_code("\nmov ax, "+$3->get_symbol()+"\n");
				$$->add_code("cmp ax, 0\n");
				$$->add_code("je "+l1+"\n");
				$$->add_code($5->get_code());
				$$->add_code("jmp "+l2+"\n");
				$$->add_code(l1+":\n");
				$$->add_code($7->get_code());
				$$->add_code("\n"+l2+":\n");
				statement_index++;
	  }
	  | ELSE statement
	  {
		  		SymbolInfo *si = new SymbolInfo("else\n"+$2->get_name(), "statement");
				$$=si;
				if(error_line!=line_count){fprintf(log_parser, "Error at Line %d : statement : ELSE without IF statement\n\n", line_count);
				fprintf(error_parser, "Error at Line %d : statement : ELSE without IF statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				error_count++;}
				error_line=line_count;

	  }
	  | WHILE LPAREN expression RPAREN statement
	  {
		  		SymbolInfo *si = new SymbolInfo("while("+$3->get_name()+")"+$5->get_name(), "statement");
				$$=si;
				fprintf(log_parser, "Line %d: statement : WHILE LPAREN expression RPAREN statement\n\n", line_count);
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
		
				string label1 = new_label();
				string label2 = new_label();
				$$->add_code("\n"+label1+":\n");
				$$->add_code($3->get_code());
				$$->add_code("mov ax, "+$3->get_symbol()+"\n");
				$$->add_code("cmp ax, 0\n");
				$$->add_code("je "+label2+"\n");
				$$->add_code($5->get_code());
				$$->add_code("jmp "+label1+"\n");
				$$->add_code(label2+":\n");
				statement_index++;
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON
	  {
		  		SymbolInfo *si = new SymbolInfo("printf("+$3->get_name()+");", "statement");
				$$=si;
				fprintf(log_parser, "Line %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n", line_count);
				SymbolInfo* temp=s->look_up($3->get_name());
				if(temp==NULL && error_line!=line_count)
				{
					error_count++;
					error_line=line_count;
					fprintf(error_parser, "Error at line %d : Undeclared variable %s\n\n", line_count, $3->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Undeclared variable %s\n\n", line_count, $3->get_name().c_str());

				}
				fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
				
				str_fun_name="";

				SymbolInfo* si_id = s->look_up($3->get_name());

				$$->set_code("\tpush "+si_id->get_symbol()+"\n");
				$$->add_code("\tcall println\n");
				$$->add_code("\tpop ax\n");
				$$->add_code(";"+$$->get_name()+"\n");
				statement_index++;

				
	  }
	  | RETURN expression SEMICOLON
	  {
		SymbolInfo *si = new SymbolInfo("return "+$2->get_name()+";", "statement");
		$$=si;
		fprintf(log_parser, "Line %d: statement : RETURN expression SEMICOLON\n\n", line_count);
		fprintf(log_parser, "%s\n\n\n", si->get_name().c_str());
		

		
		if(is_main=="yes")
		{
		}
		else{
			$$->set_code($2->get_code());
			string end = "\n\tpop bp\n\tpop di\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tpush "+$2->get_symbol()+"\n\tpush ra\n\tret\n";
			$$->add_code(end);
		}


		

		$$->add_code(";"+$$->get_name()+"\n");
		statement_index++;




		  
	  }
	  ;
	  
expression_statement 	: SEMICOLON	
						{
							SymbolInfo *si=new SymbolInfo(";", "expression_statement");
							$$=si;
							fprintf(log_parser, "Line %d: expression_statement : SEMICOLON\n\n", line_count);
							fprintf(log_parser, "%s\n\n", $$->get_name().c_str());


						}		
			| expression SEMICOLON 
			{
				SymbolInfo *si=new SymbolInfo($1->get_name()+";", "expression_statement");
				$$=si;
				fprintf(log_parser, "Line %d: expression_statement : expression SEMICOLON\n\n", line_count);
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				$$->set_code($1->get_code());
				$$->set_symbol($1->get_symbol());


				
			}
			| expression error
			{
				SymbolInfo *si=new SymbolInfo($1->get_name()+";", "expression_statement");
				$$=si;
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				if(error_line!=line_count){fprintf(log_parser, "Error at Line %d : Missing SEMICOLON\n\n", line_count);
				fprintf(error_parser, "Error at Line %d : Missing SEMICOLON \n\n", line_count);
				error_count++;
				error_line=line_count;}

				
			}
			;
	  
variable : ID 		
			{
				SymbolInfo* id=s->look_up($1->get_name());
				if(id)
				{
					SymbolInfo* si= s->look_up($1->get_name());
					$$=si;
					fprintf(log_parser, "Line %d: variable : ID\n\n", line_count);
					
					if(si->get_array_size()>0 && error_line!=line_count)
					{
						error_count++;
						error_line=line_count;
						fprintf(error_parser, "Error at line %d : Type mismatch, %s is an array\n\n", line_count, $1->get_name().c_str());
						fprintf(log_parser, "Error at line %d : Type mismatch, %s is an array\n\n", line_count, $1->get_name().c_str());

					}
					else if(si->get_return_type()!="None" && error_line!=line_count)
					{
						error_count++;
						error_line=line_count;
						fprintf(error_parser, "Error at line %d : Type mismatch, %s is a function\n\n", line_count, $1->get_name().c_str());
						fprintf(log_parser, "Error at line %d : Type mismatch, %s is a function\n\n", line_count, $1->get_name().c_str());

					}
					
					
				}
				else{
					SymbolInfo* si2=new SymbolInfo($1->get_name(), "ID");
					si2->set_type_speci("ERROR_TYPE");
					$$=si2;
					fprintf(log_parser, "Line %d: variable : ID\n\n", line_count);

					if(error_line!=line_count){
					fprintf(error_parser, "Error at line %d : Undeclared variable %s\n\n", line_count,$1->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Undeclared variable %s\n\n", line_count,$1->get_name().c_str());

					error_count++;
					error_line=line_count;}
				}
				
				
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				
				str_fun_name="";
				$$->set_symbol(id->get_symbol());


			}
	 | ID LTHIRD expression RTHIRD 
		{
			fprintf(log_parser, "Line %d: variable : ID LTHIRD expression RTHIRD\n\n", line_count);
			SymbolInfo* id=s->look_up($1->get_name());
			if(id)
				{
					SymbolInfo *si = s->look_up($1->get_name());
					si->set_cur_arr_idx($3->get_name());

					SymbolInfo* vsi = new SymbolInfo(si->get_name()+"["+$3->get_name()+"]", si->get_type());
					vsi->set_type_speci(si->get_type_speci());
					vsi->set_array_size(si->get_array_size());
					vsi->set_cur_arr_idx(si->get_cur_arr_idx());


					
					if(si->get_array_size()<0 && error_line!=line_count)
					{
						error_count++;
						error_line=line_count;
						fprintf(error_parser, "Error at line %d : %s not an array\n\n", line_count, $1->get_name().c_str());
						fprintf(log_parser, "Error at line %d : %s not an array\n\n", line_count, $1->get_name().c_str());
						vsi->set_type_speci("ERROR_TYPE");
					}
					else if($3->get_type_speci()!="INT_TYPE")
					{
						error_count++;
						error_line=line_count;
						fprintf(error_parser, "Error at line %d : Expression inside third brackets not an integer\n\n", line_count);
						fprintf(log_parser, "Error at line %d : Expression inside third brackets not an integer\n\n", line_count);

					}
					$$=vsi;			
				}
			else{
				
					SymbolInfo* vsi = new SymbolInfo($1->get_name()+"["+$3->get_name()+"]", $1->get_type());
					vsi->set_type_speci("FLOAT_TYPE");
					vsi->set_array_size(10);
					vsi->set_cur_arr_idx($3->get_name());


					$$=vsi;
					if(error_line!=line_count){error_count++;
					error_line=line_count;
					fprintf(error_parser, "Error at line %d : Undeclared variable %s\n\n", line_count,$1->get_name().c_str());
					fprintf(log_parser, "Error at line %d : Undeclared variable %s\n\n", line_count,$1->get_name().c_str());
					}
				}
				
				fprintf(log_parser, "%s[%s]\n\n", $1->get_name().c_str(), $3->get_name().c_str());
				
				str_fun_name="";

				$$->set_code($3->get_code());
				$$->add_code("\tmov di, "+$3->get_symbol()+"\n\tadd di, di\n");
				$$->set_symbol(id->get_symbol());

			
		}
	 ;
	 
expression : logic_expression	
			{
				$$=$1;
				fprintf(log_parser, "Line %d: expression : logic expression\n\n", line_count);
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
			}
	   | variable ASSIGNOP logic_expression 
	   {
		   
		   				
			SymbolInfo *si=new SymbolInfo($1->get_name()+"="+$3->get_name(), $1->get_type());
			si->set_type_speci($1->get_type_speci());
			$$=si;
			fprintf(log_parser, "Line %d: expression : variable ASSIGNOP logic_expression\n\n", line_count);
			if($3->get_type_speci()=="ERROR_TYPE"){}
			else if($3->get_type_speci()=="VOID_TYPE" && error_line!=line_count)
		   	{
			    error_count++;
				error_line=line_count;
				fprintf(error_parser, "Error at line %d : Void function used in expression\n\n", line_count);
				fprintf(log_parser, "Error at line %d : Void function used in expression\n\n", line_count);

		   	}
			else if(!(($1->get_type_speci()=="INT_TYPE" && ($3->get_type_speci()=="INT_TYPE"|| $3->get_type()=="CONST_INT")) || ($1->get_type_speci()=="FLOAT_TYPE" && ($3->get_type_speci()=="INT_TYPE"|| $3->get_type_speci()=="FLOAT_TYPE" || $3->get_type()=="CONST_INT" || $3->get_type()=="CONST_FLOAT")) ) && $1->get_type_speci()!="None" && $3->get_type()!="None")
		   	{
				   if($1->get_type_speci()!="ERROR_TYPE" && $3->get_type_speci()!="ERROR_TYPE" && error_line!=line_count)
				   {
					    error_count++;
						error_line=line_count;
			 		  	fprintf(error_parser, "Error at line %d : Type Mismatch\n\n", line_count,$1->get_name());			
					  	fprintf(log_parser, "Error at line %d : Type Mismatch\n\n", line_count,$1->get_name());			


				   }
			  
		 	}
			fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
			
			string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
			$$->set_code($1->get_code()+$3->get_code());
			$$->add_code("\tmov ax, "+$3->get_symbol()+"\n");
			if($1->get_array_size()==-1){ 
				$$->add_code("\tmov "+$1->get_symbol()+", ax\n");
				$$->set_symbol($1->get_symbol());
			}
			
			else{
				$$->add_code("\tmov  "+$1->get_symbol()+"[di], ax\n");
				$$->add_code("\tmov "+temp+", ax\n");
				$$->set_symbol(temp);

			}



		   


	   }	
	   ;
			
logic_expression : rel_expression 	
				{
					$$=$1;
					fprintf(log_parser, "Line %d: logic_expression : rel_expression\n\n", line_count);
					fprintf(log_parser, "%s\n\n", $$->get_name().c_str());


				}
		 | rel_expression LOGICOP rel_expression 
		 {
			SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(), "CONST_INT");
			si->set_type_speci("INT_TYPE");
			$$=si;
			fprintf(log_parser, "Line %d: logic_expression : rel_expression LOGICOP rel_expression\n\n", line_count);
			fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
			void_check($1,$3);

			string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});

			string l1 = new_label();
			string l2 = new_label();
			$$->set_code($1->get_code());
			$$->add_code($3->get_code());
			$$->add_code("\tmov ax, "+$1->get_symbol()+"\n");
			$$->add_code("\tcmp ax, 0\n");
			if($2->get_name()=="&&")
			{
				$$->add_code("\n\tje "+l1+"\n");
				$$->add_code("\tmov ax, "+$3->get_symbol()+"\n");
				$$->add_code("\tcmp ax, 0\n");
				$$->add_code("\tje "+l1+"\n");
				$$->add_code("\tmov "+temp+", 1\n");
				$$->add_code("\tjmp "+l2+"\n");
				$$->add_code(l1+":\n");
				$$->add_code("\tmov "+temp+", 0\n");
				$$->add_code(l2+":\n");

			}
			else if($2->get_name()=="||")
			{
				$$->add_code("\n\tjne "+l1+"\n");
				$$->add_code("\tmov ax, "+$3->get_symbol()+"\n");
				$$->add_code("\tcmp ax, 0\n");
				$$->add_code("\tjne "+l1+"\n");
				$$->add_code("\tmov "+temp+", 0\n");
				$$->add_code("\tjmp "+l2+"\n");
				$$->add_code(l1+":\n");
				$$->add_code("\tmov "+temp+", 1\n");
				$$->add_code(l2+":\n");
				
			}
			$$->set_symbol(temp);

		 }	
		 ;
			
rel_expression	: simple_expression 
				{
					$$=$1;
					fprintf(log_parser, "Line %d: rel_expression : simple_expression\n\n", line_count);
					fprintf(log_parser, "%s\n\n", $$->get_name().c_str());

				}
		| simple_expression RELOP simple_expression	
		{
			SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(), "CONST_INT");
			si->set_type_speci("INT_TYPE");
			$$=si;
			fprintf(log_parser, "Line %d: rel_expression : simple_expression RELOP simple_expression\n\n", line_count);
			fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
			void_check($1,$3);

			$$->set_code($1->get_code() + $3->get_code());
			$$->add_code("mov ax, " + $1->get_symbol()+"\n");
			$$->add_code("cmp ax, " + $3->get_symbol()+"\n");
			string temp=new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});

			string label1=new_label();
			string label2=new_label();

			if($2->get_name()=="=="){
				$$->add_code("je " +label1+"\n");

			}
			else if($2->get_name()=="!="){
				$$->add_code("jne " +label1+"\n");

			}
			else if($2->get_name()=="<"){
				$$->add_code("jl " +label1+"\n");
			}
			else if($2->get_name()==">"){
				$$->add_code("jg " +label1+"\n");

			}
			else if($2->get_name()=="<="){
				$$->add_code("jle " +label1+"\n");

			}

			else if($2->get_name()==">="){
				$$->add_code("jge " +label1+"\n");

			}

			
			$$->add_code("\nmov "+temp +", 0\n");
			$$->add_code("jmp "+ label2 +"\n");
			$$->add_code(label1+":\nmov "+temp+", 1\n");
			$$->add_code(label2+":\n");
			$$->set_symbol(temp);

		}
		;
				
simple_expression : term 
				{
					$$=$1;
					fprintf(log_parser, "Line %d: simple_expression : term\n\n", line_count);
					fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				}

		  | simple_expression ADDOP term 
		  {

			  if($1->get_type_speci()=="INT_TYPE" && $3->get_type_speci()=="INT_TYPE")
			  {
				SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(), "INT_TYPE");
				si->set_type_speci("INT_TYPE");
				$$=si;
				fprintf(log_parser, "Line %d: simple_expression : simple_expression ADDOP term\n\n", line_count);
				fprintf(log_parser, "%s\n\n", si->get_name().c_str()); 

			  }
			  else{
				SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(), "FLOAT_TYPE");
				si->set_type_speci("FLOAT_TYPE");
				$$=si;
				fprintf(log_parser, "Line %d: simple_expression : simple_expression ADDOP term\n\n", line_count);
				fprintf(log_parser, "%s\n\n", si->get_name().c_str()); 
			  }
				void_check($1,$3);
				string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
				$$->set_code($1->get_code());
				$$->add_code($3->get_code());
				$$->add_code("\tmov ax, "+$1->get_symbol()+"\n");
			  if($2->get_name()=="+")
			  {

				  $$->add_code("\tadd ax, "+$3->get_symbol()+"\n");


			  }
			  else if($2->get_name()=="-")
			  {
				  	$$->add_code("\tsub ax, "+$3->get_symbol()+"\n");

			  }
			$$->add_code("\tmov "+temp+", ax\n");
			$$->set_symbol(temp);
	

		  }
		  | simple_expression ADDOP error term 
		  {

			  if($1->get_type_speci()=="INT_TYPE" && $4->get_type_speci()=="INT_TYPE")
			  {
				SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name()+$4->get_name(), "INT_TYPE");
				si->set_type_speci("INT_TYPE");
				$$=si;
				//fprintf(log_parser, "Line %d: simple_expression : simple_expression ADDOP term\n\n", line_count);
				fprintf(log_parser, "%s\n\n", si->get_name().c_str()); 

			  }
			  else{
				SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name()+$4->get_name(), "FLOAT_TYPE");
				si->set_type_speci("FLOAT_TYPE");
				$$=si;
				//fprintf(log_parser, "Line %d: simple_expression : simple_expression ADDOP term\n\n", line_count);
				fprintf(log_parser, "%s\n\n", si->get_name().c_str()); 
			  }
				void_check($1,$4);

			

				error_count++;
				error_line=line_count;

	

		  }

		  
		  ;
					
term :	unary_expression
		{
			$$=$1;
			fprintf(log_parser, "Line %d: term : unary_expression\n\n", line_count);
			fprintf(log_parser, "%s\n\n", $$->get_name().c_str());

		}
     |  term MULOP unary_expression
	 {
		 if($2->get_name()=="%")
		 {
			 		
			SymbolInfo *si=new SymbolInfo($1->get_name()+"%"+$3->get_name(), "CONST_INT");
			si->set_type_speci("INT_TYPE");
			
			fprintf(log_parser, "Line %d: term : term MULOP unary_expression\n\n", line_count);

			if($3->get_name()=="0" && error_line!=line_count)
			{
				error_count++;
				error_line=line_count;
				fprintf(error_parser, "Error at line %d : Modulus by Zero\n\n", line_count);
				fprintf(log_parser, "Error at line %d : Modulus by Zero\n\n", line_count);

			}
			if($1->get_type_speci()!="INT_TYPE" || $3->get_type_speci()!="INT_TYPE" && error_line!=line_count)
			{
				si->set_type_speci("ERROR_TYPE");
				error_count++;
				error_line=line_count;
				fprintf(error_parser, "Error at line %d : Non-Integer operand on modulus operator\n\n", line_count);
				fprintf(log_parser, "Error at line %d : Non-Integer operand on modulus operator\n\n", line_count);

			}
			$$=si;

			string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
			$$->set_code($1->get_code());
			$$->add_code($3->get_code());
			$$->add_code("\tmov ax, "+$1->get_symbol()+"\n");
			$$->add_code("\tcwd\n");
			$$->add_code("\tmov bx, "+$3->get_symbol()+"\n");
			$$->add_code("\tdiv bx\n");
			$$->add_code("\tmov "+temp+", dx\n");
			$$->set_symbol(temp);


			 
		 }
		 else
		 {
			 if($1->get_type_speci()=="FLOAT_TYPE"||$3->get_type_speci()=="FLOAT_TYPE")
			 {
				SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(), "CONST_FLOAT");
				si->set_type_speci("FLOAT_TYPE");
				$$=si;
			 }
			 else{
				SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name()+$3->get_name(), "CONST_INT");
				si->set_type_speci("INT_TYPE");
				$$=si;
			 }
			fprintf(log_parser, "Line %d: term : term MULOP unary_expression\n\n", line_count);

			if($2->get_name()=="*")
			{
				string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
				$$->set_code($1->get_code());
				$$->add_code($3->get_code());
				$$->add_code("\tmov ax, "+$1->get_symbol()+"\n");
				$$->add_code("\tmov bx, "+$3->get_symbol()+"\n");
				$$->add_code("\tmul bx\n");
				$$->add_code("\tmov "+temp+", ax\n");
				$$->set_symbol(temp);

			}
			else if($2->get_name()=="/")
			{
				string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
				$$->set_code($1->get_code());
				$$->add_code($3->get_code());
				$$->add_code("\tmov ax, "+$1->get_symbol()+"\n");
				$$->add_code("\tcwd\n");
				$$->add_code("\tmov bx, "+$3->get_symbol()+"\n");
				$$->add_code("\tdiv bx\n");
				$$->add_code("\tmov "+temp+", ax\n");
				$$->set_symbol(temp);

			}

			


		 }		
		 void_check($1,$3);
		fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
		

	 }
     ;

unary_expression : ADDOP unary_expression  
				{
			
				SymbolInfo *si=new SymbolInfo($1->get_name()+$2->get_name(), $2->get_type());
				si->set_type_speci($2->get_type_speci());
				$$=si;
				fprintf(log_parser, "Line %d: unary_expression : ADDOP unary_expression\n\n", line_count);
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				void_check($2);
				if($1->get_name()=="+")
				{
					$$->set_code($1->get_code());
					$$->set_symbol($1->get_symbol());
				}
				else
				{
					string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
					$$->set_code($2->get_code());
					$$->add_code("\tmov ax, "+$2->get_symbol()+"\n");
					$$->add_code("\tmov "+temp+", ax\n");
					$$->add_code("\tneg "+temp+"\n");
					$$->set_symbol(temp);

				}

				}
		 | NOT unary_expression 
		 {
			SymbolInfo *si=new SymbolInfo("!"+$2->get_name(), "CONST_INT");
			si->set_type_speci("INT_TYPE");
			$$=si;
			fprintf(log_parser, "Line %d: unary_expression : NOT unary expression\n\n", line_count);
			fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
			void_check($2);
			string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
			$$->set_code($2->get_code());
			$$->add_code("\tmov ax, "+$2->get_symbol()+"\n");
			$$->add_code("\tnot ax\n");
			$$->add_code("\tmov "+temp+", ax\n");
			$$->set_symbol(temp);



		 }
		 | factor 
		 {
			 $$=$1;
			fprintf(log_parser, "Line %d: unary_expression : factor\n\n", line_count);
			fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
		 }
		 ;
	
factor	: variable 
		{
			$$=$1;
			fprintf(log_parser, "Line %d: factor : variable\n\n", line_count);
			fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
			if($1->get_array_size()!=-1)
			{
				string temp= new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
				$$->add_code("mov ax, " + $1->get_symbol() + "[di]\n");
				$$->add_code("mov " + temp + ", ax\n");
				$$->set_symbol(temp);
			}

		}
	| ID LPAREN argument_list RPAREN
	{
		fprintf(log_parser, "Line %d: factor : ID LPAREN argument_list RPAREN\n\n", line_count);

		SymbolInfo* temp = s->look_up($1->get_name());
		SymbolInfo *si;
		if(temp!=NULL)
		{
			if(temp->get_fun_status()=="None" && error_line!=line_count)
			{
				error_count++;
				error_line=line_count;
				fprintf(error_parser, "Error at line %d : %s is not a function\n\n", line_count,$1->get_name().c_str());
				fprintf(log_parser, "Error at line %d : %s is not a function\n\n", line_count,$1->get_name().c_str());
					
			}
			else if(temp->get_fun_status()!="defined" && error_line!=line_count)
			{
				error_count++;
				error_line=line_count;
				fprintf(error_parser, "Error at line %d : Undefined function %s\n\n", line_count,$1->get_name().c_str());
				fprintf(log_parser, "Error at line %d : Undefined function %s\n\n", line_count,$1->get_name().c_str());
					
			}
			else if(argument_vector.size()-arg_start!=temp->get_parameter_size() && error_line!=line_count)
			{
				error_count++;
				error_line=line_count;
				fprintf(error_parser, "Error at line %d : Total number of arguments mismatch in function %s\n\n", line_count,$1->get_name().c_str());
				fprintf(log_parser, "Error at line %d : Total number of arguments mismatch in function %s\n\n", line_count,$1->get_name().c_str());
					
			}
			else
			{
				for(int i=arg_start, j=0; i<argument_vector.size(); i++, j++)
				{
				
					if(temp->get_func_parameter(j)!=argument_vector[i]->get_type_speci() && error_line!=line_count)
					{
						error_count++;
						error_line=line_count;
						fprintf(error_parser, "Error at line %d : %dth argument mismatch in function %s\n\n", line_count,j+1,$1->get_name().c_str());
						fprintf(log_parser, "Error at line %d : %dth argument mismatch in function %s\n\n", line_count,j+1,$1->get_name().c_str());

						break;
					}
				}

			}

	
			

			si=new SymbolInfo(temp->get_name()+"("+$3->get_name()+")", temp->get_return_type());
			si->set_type_speci(temp->get_type_speci());
				

			

		}
		else
		{
			si=new SymbolInfo($1->get_name()+"("+$3->get_name()+")", "FLOAT_TYPE");
			si->set_type_speci("INT_TYPE");
			if(error_line!=line_count){error_count++;
			error_line=line_count;
			fprintf(error_parser, "Error at line %d : Undeclared function %s\n\n", line_count,$1->get_name().c_str());
			fprintf(log_parser, "Error at line %d : Undeclared function %s\n\n", line_count,$1->get_name().c_str());
			}

		}
		$$=si;
		fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
		//argument_vector.clear();
	if(argument_vector.size()!=0)
	{
		for(int i=argument_vector.size()-1; i>=arg_start; i--) { //push arguments
			//SymbolInfo *sym = s->look_up(argument_vector[i]->get_name());
			$$->add_code("\n"+argument_vector[i]->get_code());
			
         }
		 		
	}
	string temp_var = new_temp_var(statement_index);
	if(temp_vector.size()!=0)
	{
		for(int i=0; i<temp_vector.size(); i++)
		{
			if(temp_vector[i]!=temp_var) $$->add_code("\n\tpush " + temp_vector[i]);
		}
	}
	$$->add_code("\n\tpush ra\n");
	if(argument_vector.size()!=0)
	{
		for(int i=argument_vector.size()-1; i>=arg_start; i--) { //push arguments
			//SymbolInfo *sym = s->look_up(argument_vector[i]->get_name());

            $$->add_code("\tpush " + argument_vector[i]->get_symbol()+"\n");
			
         }
		 		
	}
	$$->add_code("\tcall "+ $1->get_name()+"_proc\n");

	
			reuse_vector.push_back((reuse_struct){temp_var, statement_index});
	if(s->look_up($1->get_name())->get_type_speci()!="VOID_TYPE") $$->add_code("\tpop "+temp_var+"\n"); //pop return value
	if(argument_vector.size()!=0)
	{
		
		for(int i=argument_vector.size()-1; i>=arg_start; i--){ //pop arguments
			//SymbolInfo *sym = s->look_up(argument_vector[i]->get_name());
            $$->add_code("\tpop cx\n");
			
         }
		
	}
	$$->add_code("\tpop ra\n");
	if(temp_vector.size()!=0)
	{
		for(int i=temp_vector.size()-1; i>=0; i--)
		{
			if(temp_vector[i]!=temp_var) $$->add_code("\tpop " + temp_vector[i]+"\n");
		}
	}


		 $$->set_symbol(temp_var); //a = return value of foo()
		argument_vector.erase(argument_vector.begin() + arg_start, argument_vector.begin() + argument_vector.size());
		arg_start=0;
		str_fun_name="";

	}
	| LPAREN expression RPAREN
	{
		SymbolInfo *si=new SymbolInfo("("+$2->get_name()+")", $2->get_type());
		si->set_type_speci($2->get_type_speci());
		$$=si;
		fprintf(log_parser, "Line %d: factor : LPAREN expression RPAREN\n\n", line_count);
		fprintf(log_parser, "%s\n\n", si->get_name().c_str());
		$$->set_code($2->get_code());
		$$->set_symbol($2->get_symbol());

	}
	| CONST_INT
	{
		SymbolInfo *si=new SymbolInfo($1->get_name(), "CONST_INT");
		si->set_type_speci("INT_TYPE");
		$$=si;
		fprintf(log_parser, "Line %d: factor : CONST_INT\n\n", line_count);
		fprintf(log_parser, "%s\n\n", si->get_name().c_str());
		$$->set_symbol($1->get_name());


	} 
	| CONST_FLOAT
	{
		SymbolInfo *si=new SymbolInfo($1->get_name(), "CONST_FLOAT");
		si->set_type_speci("FLOAT_TYPE");
		$$=si;
		fprintf(log_parser, "Line %d: factor : CONST_FLOAT\n\n", line_count);
		fprintf(log_parser, "%s\n\n", si->get_name().c_str());
		$$->set_symbol($1->get_name());
	}
	| variable INCOP
	{
		
		
		SymbolInfo* si=new SymbolInfo($1->get_name()+"++", $1->get_type());
		si->set_array_size($1->get_array_size());
		si->set_type_speci($1->get_type_speci());
			
		$$=si;
		fprintf(log_parser, "Line %d: factor : variable INCOP\n\n", line_count);
		fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
		if(si->get_array_size()!= -1)
		{
			string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
			$$->add_code($1->get_code());
			$$->add_code("\tmov ax,"+$1->get_symbol()+"[di]\n");
			$$->add_code("\tmov "+temp+", ax\n");
			$$->add_code("\tinc "+$1->get_symbol()+"[di]\n");
			$$->set_symbol(temp);

		}
		else
		{
			
			string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
			$$->add_code($1->get_code());
			$$->add_code("\tmov ax,"+$1->get_symbol()+"\n");
			$$->add_code("\tmov "+temp+", ax\n");
			$$->add_code("\tinc "+ $1->get_symbol()+"\n");
			$$->set_symbol(temp);

		}
	} 
	| variable DECOP
	{	
		SymbolInfo* si=new SymbolInfo($1->get_name()+"--", $1->get_type());
		si->set_array_size($1->get_array_size());
		si->set_type_speci($1->get_type_speci());
			
		$$=si;
		fprintf(log_parser, "Line %d: factor : variable DECOP\n\n", line_count);
		fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
		if(si->get_array_size()!= -1)
		{
			string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
			$$->add_code($1->get_code());
			$$->add_code("\tmov ax,"+$1->get_symbol()+"[di]\n");
			$$->add_code("\tmov "+temp+", ax\n");
			$$->add_code("\tdec "+$1->get_symbol()+"[di]\n");
			$$->set_symbol(temp);

		}
		else
		{
			
			string temp = new_temp_var(statement_index);
			reuse_vector.push_back((reuse_struct){temp, statement_index});
			$$->add_code($1->get_code());
			$$->add_code("\tmov ax,"+$1->get_symbol()+"\n");
			$$->add_code("\tmov "+temp+", ax\n");
			$$->add_code("\tdec "+ $1->get_symbol()+"\n");
			$$->set_symbol(temp);

		}

		
	} 
	;
	
argument_list : arguments
				{	
					$$=$1;
					fprintf(log_parser, "Line %d: argument_list : arguments\n\n", line_count);
					fprintf(log_parser, "%s\n\n", $$->get_name().c_str());
				}
			  |
			  {
				arg_start=argument_vector.size();
				SymbolInfo* si = new SymbolInfo("", "arguments");
				$$=si;
				fprintf(log_parser, "Line %d: argument_list :		\n\n", line_count);
			  }	
			  ;
	
arguments : arguments COMMA logic_expression
			{
				SymbolInfo* si = new SymbolInfo($1->get_name()+","+$3->get_name(), "arguments");

				argument_vector.push_back($3);
				$$=si;
				fprintf(log_parser, "Line %d: arguments : arguments COMMA logic_expression\n\n", line_count);
				fprintf(log_parser, "%s\n\n", $$->get_name().c_str());

			}
	      | logic_expression
		  {
			  arg_start=argument_vector.size();
			  
			  SymbolInfo* temp= new SymbolInfo($1->get_name(), $1->get_type());
			  argument_vector.push_back($1);
			  $$=$1;
			  fprintf(log_parser, "Line %d: arguments : logic_expression\n\n", line_count);
			  fprintf(log_parser, "%s\n\n", $$->get_name().c_str());

		  }
	      ;
 

%%
int main(int argc,char *argv[])
{

	if((yyin=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	

	log_parser = fopen("log.txt","w");
	fclose(log_parser);
	error_parser= fopen("error.txt","w");
	fclose(error_parser);
	code_file = fopen("code.asm","w");
	fclose(code_file);
	optimized_file = fopen("optimized_code.asm","w");
	fclose(optimized_file);
	
	log_parser = fopen("log.txt","a");
	error_parser= fopen("error.txt","a");
	code_file = fopen("code.asm", "a");
	optimized_file = fopen("optimized_code.asm", "a");
	s=new SymbolTable(30, log_parser);
	
	yyparse();
	s->print_all_scope();
	

	
	fprintf(log_parser, "Total lines: %d\n", line_count);
	fprintf(log_parser, "Total errors: %d\n", error_count);


	fclose(log_parser);
	fclose(error_parser);
	fclose(code_file);
	fclose(optimized_file);
	
	return 0;
}


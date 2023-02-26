%option noyywrap
%x SIG_COMMENT
%x STRING
%x MULTI_CMT
%x CHAR
%{
#include<stdio.h>
#include<stdlib.h>
#include<iostream>
#include"Symboltable.cpp"
using namespace std;
int line_count=1,temp;
int word_count=0;
int error_count=0;
string str, str2;


FILE *logout;
FILE *tokenout;
SymbolTable *s;

%}

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE (\n|\r)
LINE \n
LINE_NR [\r]?[\n]


LINE_CH "\\n"
ID [_a-zA-Z][_a-zA-Z0-9]*
NUM_INT {DIGIT}+
NUM_FLOAT ({DIGIT}+)+(\.)?({DIGIT}+)?([Ee][+-]?{DIGIT}+)?|({DIGIT}*)+(\.)?({DIGIT}+)([Ee][+-]?{DIGIT}+)?
STR2 [^(\")(\\)(\n)]*

STR_S (\")

STR_L (\\){NEWLINE}
STR_L2 (\\){LINE}
CMT_OL (\\)
CMT_L (\\)
STR_Q \\{STR_S}
STR_SQ \\'

CMT_BODY [^\\]


CHAR_S '
CHAR_E ([^(\n)(\r)(\\)(')]')
CHAR_ERR_BS (\\)'
CHAR_ERR_MULTI [^(\n)(\r)(')][^(\n)(\r)(')]+'
CHAR_ERR_UNTER [^(\n)(\r)(')]*[\r]?[\n]
CHAR_SQ "\\''"|"\\\"'"

NL '\\n'
RNL '\\r'
STR_RNL (\\r)
TAB '\\t'
STR_T (\\t)
BS '\\\\'
STR_BS (\\\\)
ALARM '(\\a)'
STR_ALARM (\\a)
FF '(\\f)'
STR_FF (\\f)
BSP '(\\b)'
STR_BSP (\\b)
VT '(\\v)'
STR_VT (\\v)
NULL_CH '(\\0)'
STR_NE (\\.)
STR_NULL_CH (\\0)


COMMENT "//"
MULTI_CMNT_S "/\*"
MULTI_CMNT_E "\*/"
MULTI_CMNT "/\*([^*]|\*+[^/*])*\*+/"
ANY .


ERROR_1 ({DIGIT}*)(\.)+({DIGIT}*)(\.)+(({DIGIT}*)(\.)*)*
ERROR_2 {DIGIT}+(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+(\.{DIGIT}+))
ERROR_3 ({DIGIT}+)(\.*)?({ID})
ERROR_6 ''



STR_SIG_ERR \"[^(\")(\\)(\n)]*(\n)
STR_SIG_ERR2 [^(\")(\\)(\n)]*[^(\")(\\)]$

mulstr \"([^(\")(\\)]*(\\)(\n))+([^(\")(\\)]*)(\n)

UNRECOGNIZED [^ \t\f\r\v\n\r]
%%



	

{LINE_NR} 	{
			line_count++;}
{NL}		{
			fprintf(tokenout,"<CHAR_CONST,\n> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\n> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}

{TAB}		{
			fprintf(tokenout,"<CHAR_CONST,\t> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\t> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}
{BS}		{
			fprintf(tokenout,"<CHAR_CONST,\\> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\\> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}
{ALARM}		{
			fprintf(tokenout,"<CHAR_CONST,\a> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\a> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}
{FF}		{
			fprintf(tokenout,"<CHAR_CONST,\f> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\f> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}
{BSP}		{
			fprintf(tokenout,"<CHAR_CONST,\b> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\b> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}
{VT}		{
			fprintf(tokenout,"<CHAR_CONST,\v> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\v> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}
{NULL_CH}		{
			fprintf(tokenout,"<CHAR_CONST,\n> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\n> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}
{RNL}		{
			fprintf(tokenout,"<CHAR_CONST,\n> ");
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme %s found --> <CHAR_CONST,\n> \n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
		}



"("	{
			fprintf(tokenout,"<LPAREN, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <LPAREN> Lexeme %s found\n\n",line_count,yytext);
	}
")"	{
			fprintf(tokenout,"<RPAREN, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <RPAREN> Lexeme %s found\n\n",line_count,yytext);
	}
"{"	{
			fprintf(tokenout,"<LCURL, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <LCURL> Lexeme %s found\n\n",line_count,yytext);
			s->enter_scope();
	}
"}"	{
			fprintf(tokenout,"<RCURL, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <RCURL> Lexeme %s found\n\n",line_count,yytext);
			s->exit_scope();
	}
"["	{
			fprintf(tokenout,"<LTHIRD, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <LTHIRD> Lexeme %s found\n\n",line_count,yytext);
	}
"]"	{
			fprintf(tokenout,"<RTHIRD, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <RTHIRD> Lexeme %s found\n\n",line_count,yytext);
	}
","	{
			fprintf(tokenout,"<COMMA, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <COMMA> Lexeme %s found\n\n",line_count,yytext);
	}
";"	{
			fprintf(tokenout,"<SEMICOLON, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <SEMICOLON> Lexeme %s found\n\n",line_count,yytext);
	}
"="	{
			fprintf(tokenout,"<ASSIGNOP, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <ASSIGNOP> Lexeme %s found\n\n",line_count,yytext);
	}
"!"	{
			fprintf(tokenout,"<NOT, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <NOT> Lexeme %s found\n\n",line_count,yytext);
	}
"<"	|
"<="	|
">"	|
">="	|
"=="	|
"!="	{
			fprintf(tokenout,"<RELOP, %s> ", yytext);
			fprintf(logout,"Line no %d: Token <RELOP> Lexeme %s found\n\n",line_count,yytext);
	}


"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP, %s> ",yytext);
			fprintf(logout,"Line no %d: Token <ADDOP> Lexeme %s found\n\n",line_count,yytext);
		}
"*"		|
"/"		|

"%"		{
			fprintf(tokenout,"<MULOP, %s> ",yytext);
			fprintf(logout,"Line no %d: Token <MULOP> Lexeme %s found\n\n",line_count,yytext);
		}
"++"		|

"--"		{
			fprintf(tokenout,"<INCOP, %s> ",yytext);
			fprintf(logout,"Line no %d: Token <INCOP> Lexeme %s found\n\n",line_count,yytext);
		}
"&&"		|

"||"		{
			fprintf(tokenout,"<LOGICOP, %s> ",yytext);
			fprintf(logout,"Line no %d: Token <LOGICOP> Lexeme %s found\n\n",line_count,yytext);
		}

"if"	{
			fprintf(tokenout,"<IF> ");
			fprintf(logout,"Line no %d: Token <IF> Lexeme %s found\n\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE> ");
			fprintf(logout,"Line no %d: Token <ELSE> Lexeme %s found\n\n",line_count,yytext);
		}
"for"	{
			fprintf(tokenout,"<FOR> ");
			fprintf(logout,"Line no %d: Token <FOR> Lexeme %s found\n\n",line_count,yytext);
		}
		
"while"	{
			fprintf(tokenout,"<WHILE> ");
			fprintf(logout,"Line no %d: Token <WHILE> Lexeme %s found\n\n",line_count,yytext);
		}
"do"	{
			fprintf(tokenout,"<DO> ");
			fprintf(logout,"Line no %d: Token <DO> Lexeme %s found\n\n",line_count,yytext);
		}
		
"break"	{
			fprintf(tokenout,"<BREAK> ");
			fprintf(logout,"Line no %d: Token <BREAK> Lexeme %s found\n\n",line_count,yytext);
		}
"int"	{
			fprintf(tokenout,"<INT> ");
			fprintf(logout,"Line no %d: Token <INT> Lexeme %s found\n\n",line_count,yytext);

	}
"char"	{
			fprintf(tokenout,"<CHAR> ");
			fprintf(logout,"Line no %d: Token <CHAR> Lexeme %s found\n\n",line_count,yytext);

	}
"float"	{
			fprintf(tokenout,"<FLOAT> ");
			fprintf(logout,"Line no %d: Token <FLOAT> Lexeme %s found\n\n",line_count,yytext);
		}
		
"double"	{
			fprintf(tokenout,"<DOUBLE> ");
			fprintf(logout,"Line no %d: Token <DOUBLE> Lexeme %s found\n\n",line_count,yytext);
		}
"void"	{
			fprintf(tokenout,"<VOID> ");
			fprintf(logout,"Line no %d: Token <VOID> Lexeme %s found\n\n",line_count,yytext);
		}
"return"	{
			fprintf(tokenout,"<RETURN> ");
			fprintf(logout,"Line no %d: Token <RETURN> Lexeme %s found\n\n",line_count,yytext);
		}
"switch"	{
			fprintf(tokenout,"<SWITCH> ");
			fprintf(logout,"Line no %d: Token <SWITCH> Lexeme %s found\n\n",line_count,yytext);
		}
		
"case"	{
			fprintf(tokenout,"<CASE> ");
			fprintf(logout,"Line no %d: Token <CASE> Lexeme %s found\n\n",line_count,yytext);
		}
"default"	{
			fprintf(tokenout,"<DEFAULT> ");
			fprintf(logout,"Line no %d: Token <DEFAULT> Lexeme %s found\n\n",line_count,yytext);
		}
		
"continue"	{
			fprintf(tokenout,"<CONTINUE> ");
			fprintf(logout,"Line no %d: Token <CONTINUE> Lexeme %s found\n\n",line_count,yytext);
		}
{STR_SIG_ERR}	{	error_count++;
			string i=yytext;
			if (!i.empty() && i[i.length()-1] == '\n') i.erase(i.length()-1);
			char arr[i.length() + 1]; 
   			strcpy(arr, i.c_str()); 
			fprintf(logout,"Error at line no %d: Unterminated String %s\n\n",line_count,arr);
			line_count++;
		}	
{mulstr}	{	error_count++;
			
			string i=yytext;
			if (!i.empty() && i[i.length()-1] == '\n') i.erase(i.length()-1);
			char arr[i.length() + 1]; 
   			strcpy(arr, i.c_str()); 
			fprintf(logout,"Error at line no %d: Unterminated String %s\n\n",line_count,arr);}
			line_count++;

		
		
{NUM_INT} 	{
		
				fprintf(tokenout,"<CONST_INT, %s> ",yytext);
				fprintf(logout,"Line no %d: Token <CONST_INT> Lexeme %s found\n\n",line_count,yytext);
				fclose(logout);
				bool x=s->insert_symbol(yytext, "CONST_INT");
				if(x)s->print_all_scope();
				logout= fopen("1705030_log.txt","a");
				
		}
{NUM_FLOAT} 	{
				fprintf(tokenout,"<CONST_FLOAT, %s> ",yytext);
				fprintf(logout,"Line no %d: Token <CONST_FLOAT> Lexeme %s found\n\n",line_count,yytext);
				fclose(logout);
				bool x=s->insert_symbol(yytext, "CONST_FLOAT");
				if(x)s->print_all_scope();
				logout= fopen("1705030_log.txt","a");
				
		}

{CHAR_S}	{BEGIN(CHAR);}
<CHAR>{CHAR_E}	{
			string ss(yytext);
			char ch = ss.at(0); 
			string k="'"+ss;
			fprintf(tokenout,"<CHAR_CONST, %c> ",ch);			
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme '%s found --> <CHAR_CONST, %c>\n\n",line_count,yytext,ch);
			fclose(logout);
			bool x=s->insert_symbol(k, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
			BEGIN(INITIAL);
		}
<CHAR>{CHAR_SQ}	{
			string ss(yytext);
			char ch = ss.at(1); 
			string k="'"+ss;
			fprintf(tokenout,"<CHAR_CONST, %c> ",ch);			
			fprintf(logout,"Line no %d: Token <CONST_CHAR> Lexeme '%s found --> <CHAR_CONST, %c>\n\n",line_count,yytext,ch);
			fclose(logout);
			bool x=s->insert_symbol(k, "CONST_CHAR");
			if(x)s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
			BEGIN(INITIAL);
		}
<CHAR>{CHAR_ERR_BS}	{
			error_count++;
			string i(yytext);
			if (!i.empty() && i[i.length()-1] == '\n') i.erase(i.length()-1);
			char arr[i.length() + 1]; 
   			strcpy(arr, i.c_str()); 
			fprintf(logout,"Error at line no %d: Unterminated character '%s\n\n",line_count,arr);
			BEGIN(INITIAL);
			}
<CHAR>{CHAR_ERR_MULTI}	{
			error_count++;
			fprintf(logout,"Error at line no %d: Multi character constant error '%s\n\n",line_count,yytext);
			BEGIN(INITIAL);			
			}
<CHAR>{CHAR_ERR_UNTER}	{
			
			string i(yytext);
			if (!i.empty() && i[i.length()-1] == '\n') i.erase(i.length()-1);
			char arr[i.length() + 1]; 
   			strcpy(arr, i.c_str()); 
			fprintf(logout,"Error at line no %d: Unterminated character '%s\n\n",line_count,arr);
			error_count++;
			line_count++;
			BEGIN(INITIAL);			
			}
		

{STR_S} 	{ 		
						
			BEGIN(STRING); 
			temp=line_count;
			str="";
			str2="";
						
			}



<STRING>{STR_S} {				
			char arr[str.length() + 1]; 
   			strcpy(arr, str.c_str()); 
   			char arr2[str2.length() + 1];  
   			strcpy(arr2, str2.c_str()); 
			fprintf(logout,"Line no %d: Token <STRING> Lexeme \"%s\" found --> <STRING, \"%s\">\n\n",temp,arr,arr2);
			fprintf(tokenout,"<STRING, \"%s\"> ",arr2);
			str="";
			BEGIN(INITIAL); 
				}
<STRING>{STR_SIG_ERR2}	{
			line_count=temp;
			int c=0;
			str=str+yytext;
			string x=str;
			std::string::size_type i = 0;
			while (i < x.length()) {
			    i = x.find('\n', i);
			    if (i == std::string::npos) {
				break;
			    }
			    c++;
			    x.erase(i);
			}
			line_count+=c;
			error_count++;
			if (!str.empty() && str[str.length()-1] == '\n') str.erase(str.length()-1);
			char arr[str.length() + 1];  
   			strcpy(arr, str.c_str()); 
   			char arr2[str2.length() + 1]; 
   			strcpy(arr2, str2.c_str()); 
			fprintf(logout,"Error at line no %d: Unterminated String \"%s\n\n",temp,arr);
			BEGIN(INITIAL);



			}	
<STRING>{STR2}	{	
			str=str+yytext;
			str2=str2+yytext;
			
			
		}
<STRING><<EOF>> { 	error_count++;
			string i(str);
			if (!i.empty() && i[i.length()-1] == '\n') i.erase(i.length()-1);
			char arr[i.length() + 1]; 
   			strcpy(arr, i.c_str()); 
			fprintf(logout,"Error at line no %d: Unterminated String %s\n\n",line_count,arr);
			BEGIN(INITIAL);
			fclose(logout);	
			s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
			fprintf(logout,"Total lines: %d\nTotal errors: %d\n\n",--line_count,error_count); 
			return 0;
		 }
<STRING>{LINE_CH}	{
			str=str+"\\n";	
			str2=str2+"\n";
			line_count++;		
			
}
<STRING>{STR_T}	{ 
			str=str+"\\t";	
			str2=str2+"\t";		
			
}
<STRING>{STR_ALARM}	{
			str=str+"\\a";	
			str2=str2+"\a";		
			
}
<STRING>{STR_FF}	{
			str=str+"\\f";	
			str2=str2+"\f";		
			
}
<STRING>{STR_BSP}	{
			str=str+"\\b";	
			str2=str2+"\b";		
			
}
<STRING>{STR_VT}	{
			str=str+"\\v";	
			str2=str2+"\v";		
			
}
<STRING>{STR_RNL}	{
			str=str+"\\r";	
			str2=str2+"\n";		
			
}
<STRING>{STR_NULL_CH}	{
			str=str+"\\0";	
			str2=str2+"\n";		
			
}
<STRING>{STR_BS}	{
			str=str+"\\\\";	
			str2=str2+"\\";		
			
}
<STRING>{STR_L}	{
				str=str+"\\"+"\n"; 
				line_count++;			
}
<STRING>{STR_Q}	{
			str=str+"\\\""; 
			str2=str2+"\""; 	
			
			}
<STRING>{STR_SQ}	{
			str=str+"\\\'"; 
			str2=str2+"\'"; 	
			
			}
<STRING>{STR_NE}	{
			str=str+yytext; 
			str2=str2+yytext; 	
			
			}
{COMMENT}		{ 	str="";
				temp=line_count;
				BEGIN(SIG_COMMENT);		
		}

<SIG_COMMENT>{LINE_NR} {
			line_count++;
			string i(str);
			if (!i.empty() && i[i.length()-1] == '\n') i.erase(i.length()-1);
			char arr[i.length() + 1]; 
 
   			strcpy(arr, i.c_str()); 
			
			fprintf(logout,"Line no %d: Token <COMMENT> Lexeme //%s found\n\n",temp,arr);
			
			BEGIN(INITIAL);
			str="";	
				
			}
<SIG_COMMENT>{CMT_BODY}	{
				str=str+yytext;
			}
<SIG_COMMENT>{STR_L2}	{	line_count++;
				str=str+"\\"+"\n";
			}
<SIG_COMMENT>{CMT_OL}	{str=str+"\\";}
{MULTI_CMNT_S} {	str="";
			temp=line_count;
			BEGIN(MULTI_CMT);
		}
<MULTI_CMT>{ANY}	{

			str=str+yytext;	
		}
<MULTI_CMT>{LINE_NR}	{
			str=str+yytext;
			line_count++;	
		}
<MULTI_CMT>{MULTI_CMNT_E}	{
			char arr[str.length() + 1]; 
   			strcpy(arr, str.c_str());
			fprintf(logout,"Line no %d: Token <COMMENT> Lexeme /*%s*/ found\n\n",temp,arr);
			BEGIN(INITIAL);
			}
<MULTI_CMT><<EOF>>	{
			line_count=temp;
			int c=0;
			string x=str;
			std::string::size_type i = 0;
			while (i < x.length()) {
			    i = x.find('\n', i);
			    if (i == std::string::npos) {
				break;
			    }
			    c++;
			    x.erase(i);
			}
			line_count+=c;
			error_count++;
			string v(str);
			if (!v.empty() && v[v.length()-1] == '\n'|'\r') v.erase(v.length()-1);
			char arr[v.length() + 1]; 
   			strcpy(arr, v.c_str());
			fprintf(logout,"Error at line no %d: Unterminated Comment /*%s\n\n",temp,arr);
			BEGIN(INITIAL);
			fclose(logout);	
			s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
			fprintf(logout,"Total lines: %d\nTotal errors: %d\n\n",--line_count,error_count); 
			return 0;
			}
						
			
				





{ERROR_1}	{	error_count++;
			fprintf(logout,"Error at line no %d: Too many decimal points %s\n\n",line_count,yytext);
	}
{ERROR_2}	{	error_count++;
			fprintf(logout,"Error at line no %d: Ill formed number %s\n\n",line_count,yytext);
	}
{ERROR_3}	{	error_count++;
			fprintf(logout,"Error at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n\n",line_count,yytext);
	}
{ERROR_6}	{	error_count++;
			fprintf(logout,"Error at line no %d: Empty character constant error %s\n\n",line_count,yytext);
	}




{ID} 	{
			fprintf(tokenout,"<ID, %s> ",yytext);
			fprintf(logout,"Line no %d: Token <ID> Lexeme %s found\n\n",line_count,yytext);
			fclose(logout);
			bool x=s->insert_symbol(yytext, "ID");
			if(x) s->print_all_scope();
			logout= fopen("1705030_log.txt","a");
	}




			

{UNRECOGNIZED}	{
		error_count++;
		fprintf(logout,"Error at line no %d: Unrecognized character %s\n\n",line_count,yytext);
	}
<<EOF>> {
	
	fclose(logout);	
	s->print_all_scope();
	logout= fopen("1705030_log.txt","a");
	fprintf(logout,"Total lines: %d\nTotal errors: %d\n\n",--line_count,error_count); 
	return 0;}
%%

int main(int argc,char *argv[]){
		
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1705030_log.txt","w");
	tokenout= fopen("1705030_token.txt","w");
	fprintf(logout,"\n");

	yyin= fin;
	s=new SymbolTable(7);
	yylex();
	
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}

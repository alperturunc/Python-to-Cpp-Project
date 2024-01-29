%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <string.h>
	#include <vector>
	#include <map>
	#include <algorithm>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);
	extern int linenum;// use variable linenum from the lex file
	map<string,int> variables_map; // it stores the var name and its type
	vector<string> variables; // vector to keep the declared variables
	vector<int> types; // vector to keep the declared variable types
	bool not_declared = true; // checks if a variable is already declared
	int tabCount = 0; // counts the tabs for each line
	bool tab_not_occurred = true; // checks if tab exists
	vector<int> statement_types; // vector to keep the statement types if assign its value is 4 and if its cond it is 5
	vector<int> statement_tabs; //vector to keep the tab count of the statements
	vector<bool> is_open; // vector to keep if an statement is open or not
	vector<string> cond_statements; // vector to keep if a cond statement is "if", "elif", or "else" 
	vector<int> cond_statements_line; // vector to keep at which line an cond statement occurred
	vector<int> cond_statements_tab; // vector to keep what is the tab count of cond statement
	
	
	
	
	
	
	
	
	
%}

%union
{
	int number;
	char * str;
	
	struct ccode{
		int type;
		char * name;
	};
	ccode cpp;

}

%token<str> IF ELIF ELSE VAR INTVAL FLOATVAL STRING OPERATOR COMPARISON EQ COLON TAB OP CP OCP CCP
%type<str> statements assign_statement cond_statements if_statement elif_statement else_statement comparison_part 
%type<cpp> operand_list operand statement 
%left COMPARISON
%left OPERATOR


%%

program:
	statements
	{
		
		//for loops for printing the values of the vectors. I used them while finding an correct algorithm to check inconsistencies
		/*
		for(int a = 0; a<statement_types.size();a++){
			cout<<"Type: "<<statement_types[a]<<" TabCount: "<<statement_tabs[a]<<" Is open: "<<is_open[a]<<endl;
		}*/
		/*
		for(int a = 0; a<cond_statements.size(); a++){
			cout<<"Cond: "<<cond_statements[a]<<" TabCount: "<<cond_statements_tab[a]<<" linenum: "<<cond_statements_line[a]<<endl;
		}*/
		


		// CODE SEGMENT FOR CHECKING TAB consistency
		if(statement_tabs[0]!=0){
			cout<<"tab inconsistency in line 1"<<endl;
			return 0;
		}

		for(int t = 1; t<statement_types.size(); t++){
			if(statement_types[t-1] == 5){
				if(statement_tabs[t] > statement_tabs[t-1]+1){
					cout<<"tab inconsistency in line "<<t+1<<endl;
					return 0;
				}
				else if(statement_tabs[t] == statement_tabs[t-1]){
					cout<<"error in line "<<t+1<<": at least one line should be inside if/elif/else block "<<endl;
					return 0;
				}
			}
			
			if((statement_types[t-1] == 4)&& (statement_tabs[t-1]==0)){
				if(statement_tabs[t] != statement_tabs[t-1] ){
					cout<<"tab inconsistency in line "<<t+1<<endl;
					return 0;
				}
			}	
			
			
		}
		


		// CODE SEGMENT FOR CHECKING IF ELSE CONSISTENCY
		bool else_with_elif = false;
		for(int i = cond_statements.size(); i>0 ; i--){
			if((cond_statements[i]== "elif")&& (cond_statements[i-1]=="else")&& (cond_statements_tab[i]== cond_statements_tab[i-1])){
				cout<<"elif after else in line "<<cond_statements_line[i]<<endl;
				return 0;
			}

			else if(cond_statements[0]=="else"){
				cout<<"else without if in line "<<cond_statements_line[0]<<endl;
				return 0;
			}
			else if(cond_statements[0]=="elif"){
				cout<<"elif without if in line "<<cond_statements_line[0]<<endl;
					return 0;
			}
			
			else if(cond_statements[i]=="else"){
				for(int j = i-1; j>0; j--){
					if( (cond_statements[j]=="if" || cond_statements[j]=="elif")&&(cond_statements_tab[i] == cond_statements_tab[j])){
						else_with_elif = true;
					}
				}
				if(else_with_elif == false){
					cout<<"else without if in line "<<cond_statements_line[i]<<endl;
					return 0;
				}
			}
			
		}


		
		
		
		// CODE SEGMENT FOR PRINTING C++ DECLERATIONS 
		cout<<"void main()\n{"<<endl;
		
		vector<string> decl_ints;
    		vector<string> decl_floats;
    		vector<string> decl_strings;
		for (int i = 0; i < variables.size(); i++) {
			
        		string type_of_var;
        		
        		if (types[i] == 1) {

            			type_of_var = "int";
				decl_ints.push_back(variables[i] + "_" + type_of_var);
       			} else if (types[i] == 2) {

            			type_of_var = "flt";
				decl_floats.push_back(variables[i] + "_" + type_of_var);
        		} else {

            			type_of_var = "str";
				decl_strings.push_back(variables[i] + "_" + type_of_var);
        		}
    		}

		if (!decl_ints.empty()) {
        		cout << "\tint " << decl_ints[0];
        		for (int i = 1; i < decl_ints.size(); i++) {
            			cout << "," << decl_ints[i];
        		}
        		cout << ";" <<endl;
    		}
		
		if (!decl_floats.empty()) {
        		cout << "\tfloat " << decl_floats[0];
        		for (int i = 1; i < decl_floats.size(); i++) {
            			cout << "," << decl_floats[i];
        		}
        		cout << ";" <<endl;
    		}
		
		
		if (!decl_strings.empty()) {
        		cout << "\tstring " << decl_strings[0];
        		for (int i = 1; i < decl_strings.size(); i++) {
            			cout << "," << decl_strings[i];
        		}
        		cout << ";" <<endl;
    		}



		// Code segment for checking if there is an unclosed conditional statement left 
		// if there are close them
		vector<int> end_tabs;
		int endCounter = 0;

		for(int i=statement_types.size(); i>0; i-- ){

			if((statement_types[i]==5)&&(is_open[i]==true)){
				is_open[i]= 0;
				endCounter++;
				end_tabs.push_back(statement_tabs[i]);
				
				
			}
			else{
				continue;
			}
			
			
		}
		string combined="";
		for(int i=0;i<endCounter;i++){
			combined += "\n";
			for(int j=0; j<end_tabs[i]; j++){
				//cout<<end_tabs[i]<<endl;
				combined = combined + "\t";
			}
			combined += "}\n";
		}
		
		


		// CODE SEGMENT FOR PRINTING THE C++ CODE OF THE INPUT PYTHON CODE
		cout<<"\n\t";
		string codes = string($1) + combined;
		int i=0;
		while(codes[i]!='\0'){
			if(codes[i]=='\n'){
				cout<<"\n\t";
			}
			else{
				cout<<codes[i];
			}
			i++;
		}
		cout<<"\n}"<<endl;
		
	}

statements:
	statement
	{
		$$ = strdup($1.name);
		
	
	}
	|
	statement statements
	{
		
		string tmp = string($1.name) + "\n" + string($2) ;
		$$=strdup(tmp.c_str());
		
	}
	;

statement:
	assign_statement
	{
		vector<int> end_tabs; 
		bool isEnd = false; // variable to check if there is an unclosed cond_statement
		int endCounter = 0; 
		for(int i=statement_types.size(); i>0; i-- ){
			if((statement_types[i]==5)&& (statement_tabs[i] >= tabCount)&&(is_open[i]==true)){
				is_open[i]= 0;
				endCounter++;
				end_tabs.push_back(statement_tabs[i]);
				isEnd = true;
				
			}
			
		}
		string combined="";
		

		for(int i=0;i<endCounter-1;i++){
			for(int j=0; j<end_tabs[i]; j++){
				//cout<<end_tabs[i]<<endl;
				combined = combined + "\t";
			}
			combined += "}\n";
		}



		for(int i=0;i<tabCount;i++){
			combined = combined + "\t";
		}

		if(isEnd){
			combined += "}\n"+ string($1);
			$$.name = strdup(combined.c_str());
		}
		else{
			$$.name = strdup($1);
		}

		$$.type = 4; 

		statement_types.push_back(4);
		statement_tabs.push_back(tabCount);
		is_open.push_back(false);

		tabCount = 0; // resets the tabCount
		
		
	}
	|
	cond_statements
	{
		
		vector<int> end_tabs;
		int endCounter = 0;

		bool isEnd = false; // variable to check if there is an unclosed cond_statement
		for(int i=statement_types.size(); i>0; i-- ){


			if((statement_types[i]==5)&& (statement_tabs[i] >= tabCount)&&(is_open[i]==true)){
				is_open[i]= 0;
				endCounter++;
				end_tabs.push_back(statement_tabs[i]);
				isEnd = true;
				
			}
			else{
				continue;
			}
			
			
		}


		string combined="";

		
		for(int i=0;i<endCounter-1;i++){
			for(int j=0; j<end_tabs[i]; j++){
				//cout<<end_tabs[i]<<endl;
				combined = combined + "\t";
			}
			combined += "}\n";
		}

		

		for(int i=0;i<tabCount;i++){
			combined = combined + "\t";
		}
		
		if(isEnd){
			combined += "}\n";
			
		}
		else{
			combined="";
		}

		
		string tmp = combined +   string($1);
		
		for(int i=0;i<tabCount;i++){
			tmp = tmp + "\t";
		}
		tmp += "{";

		$$.name = strdup(tmp.c_str());
		$$.type = 5;

		statement_types.push_back(5);
		statement_tabs.push_back(tabCount);
		is_open.push_back(true);

		tabCount = 0; // resets the tabCount
		
		
	}
	;

assign_statement:
	VAR EQ operand_list
	{
		
		variables_map[string($1)] = $3.type;
		
		
		for(int i=0; i<variables.size(); i++){
			if(variables[i]==string($1)){
				if(types[i]==$3.type){
					not_declared = false;
				}
			}
		}
		if(not_declared){
			variables.push_back(string($1));
			types.push_back($3.type);
		}
		
		
		
		string type_of_var;
		if(variables_map[string($1)] == 1){
			type_of_var = "_int";
		}
		else if(variables_map[string($1)] == 2){
			type_of_var = "_flt";
		}
		else if(variables_map[string($1)] == 3){
			type_of_var = "_str";	
		}
		string combined = string($1)+ type_of_var + " = " + $3.name + ";";
		$$  = strdup(combined.c_str());
		not_declared = true;
		
		
	}
	|
	TAB assign_statement
	{
		string tab_string = string($1);
		tabCount = 0;
		for(int i=0; tab_string[i]!='\0';i++)
		{
			
			if(tab_string[i]==' '){
				tabCount++;
				i+=6;
			}
			else if(tab_string[i]=='\t'){
				tabCount++;
			}
			
		}
		string combined = string($1)+ string($2) ;
		$$  = strdup(combined.c_str());
		
	}
	;

cond_statements:
	if_statement
	{
		$$ = strdup($1);
		cond_statements.push_back("if");
		cond_statements_line.push_back(linenum);
		cond_statements_tab.push_back(tabCount);
		
		
	}
	|
	elif_statement
	{
		$$ = strdup($1);
		cond_statements.push_back("elif");
		cond_statements_line.push_back(linenum);
		cond_statements_tab.push_back(tabCount);
	}
	|
	else_statement
	{
		$$ = strdup($1);
		cond_statements.push_back("else");
		cond_statements_line.push_back(linenum);
		cond_statements_tab.push_back(tabCount);
		
		
	}
	;

if_statement:
	IF comparison_part COLON 
	{
		
		string tmp = "if(" + string($2) + ")\n";
		$$ = strdup(tmp.c_str());
		
		
		              
	}
	|
	TAB if_statement
	{
		string tab_string = string($1);
		tabCount = 0;
		for(int i=0; tab_string[i]!='\0';i++)
		{
			
			if(tab_string[i]==' '){
				tabCount++;
				i+=6;
			}
			else if(tab_string[i]=='\t'){
				tabCount++;
			}
			
		}
		//cout<<tabCount<<"at line "<<linenum<<endl;
		string combined = string($1)+ string($2);
		$$  = strdup(combined.c_str());
		
	}
	;


elif_statement:
	ELIF comparison_part COLON 
	{
		
		string tmp = "else if ("+ string($2)+ ")\n";
		$$ = strdup(tmp.c_str());
		
		
		
		
	}
	|
	TAB elif_statement
	{
		
		string tab_string = string($1);
		tabCount = 0;
		for(int i=0; tab_string[i]!='\0';i++)
		{
			
			if(tab_string[i]==' '){
				tabCount++;
				i+=6;
			}
			else if(tab_string[i]=='\t'){
				tabCount++;
			}
			
		}
		string combined = string($1)+ string($2);
		$$  = strdup(combined.c_str());
		

	}
	;

else_statement:
	ELSE COLON 
	{
		string tmp = "else\n";
		$$ = strdup(tmp.c_str());
		
	}
	|
	TAB else_statement
	{
		string tab_string = string($1);
		tabCount = 0;
		for(int i=0; tab_string[i]!='\0';i++)
		{
			
			if(tab_string[i]==' '){
				tabCount++;
				i+=6;
			}
			else if(tab_string[i]=='\t'){
				tabCount++;
			}
			
		}
		string combined = string($1)+ string($2);
		$$  = strdup(combined.c_str());
	}
	;

comparison_part:
	operand COMPARISON operand
	{
		if(($1.type==3 && $3.type==2)||($1.type==2 && $3.type==3)|| ($1.type==1 && $3.type==3)|| ($1.type==3 && $3.type==1))
		{
				cout<<"comparison type mismatch in line "<<linenum<<endl;
				return 0;
		}
		string tmp = " "+string($1.name) + " " + string($2) + " " + string($3.name)+" ";
		$$ = strdup(tmp.c_str());
	}
	;


operand_list:
	operand
	{
		
		$$.type = $1.type;
		$$.name = strdup(string($1.name).c_str());;
	}
	|
	operand_list OPERATOR operand_list
	{
		string combined = string($1.name)+" "+string($2)+" "+string($3.name);
		$$.name = strdup(combined.c_str());
		if($1.type == $3.type){
			$$.type = $3.type;
		}
		else if (($1.type == 1) && ($3.type == 2 )){
			$$.type = $3.type;
		}
		else if (($1.type == 2) && ($3.type == 1 )){
			$$.type = $1.type;
		}
		else{
			cout<<"type mismatch in line "<<linenum<<endl;
			return 0;
		}
	}
	;

operand:
	VAR
	{
		$$.type = variables_map[string($1)];
		
		if(variables_map[string($1)] == 1){
			$$.name = strdup((string($1)+"_int").c_str());
		}
		else if(variables_map[string($1)] == 2){
			$$.name = strdup((string($1)+"_flt").c_str());
		}
		else if(variables_map[string($1)] == 3){
			$$.name = strdup((string($1)+"_str").c_str());
		}
		

	}
	|
	INTVAL
	{
		string tmp = string($1);
		$$.name = strdup(tmp.c_str());
		$$.type = 1;
	}
	|
	FLOATVAL
	{
		string tmp = string($1);
		$$.name = strdup(tmp.c_str());
		$$.type = 2;
	}
	|
	STRING
	{
		string tmp = string($1);
		$$.name = strdup(tmp.c_str());
		$$.type = 3;
	}
	
	;

	
			 
	
%%
void yyerror(string s){
	cerr<<"Error at line: "<<linenum<<endl;
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin); 
    return 0;
}

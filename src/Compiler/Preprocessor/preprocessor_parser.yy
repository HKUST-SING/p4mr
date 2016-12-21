/* parser for preprocessing functions */
%{
# include <stdio.h>
# include <stdlib.h>
# include "../symbol_table.c"

static Data_Set* new_data_set(Data_Type, Data_Set*);

%}


%union {
  char* symbol;
  Data_Type d_type;
  Data_Set* data_set;
  unsigned int par_number;
}


/* declare tokens */
%token <symbol> NAME 
%token <d_type> VAR_TYPE
%token EOL 
%token <par_number> PAR_NUMBER

 

%type <data_set> type_set


%start beg_prep


%%

/*beginning of the compiler rules*/

beg_prep: stmtlist { printf("beg_prep:\n"); }      
    ;


stmtlist: stmtlist func { printf("stmtlist: func\n"); } 
        | %empty        { printf("stmtlist: empty\n"); }
        ;



func: NAME '{' type_set '}' '(' PAR_NUMBER ')' ';' { add_function_API($1, $3, $6); }
    ;


type_set: VAR_TYPE               { $$ = new_data_set($1, NULL); }
        | VAR_TYPE ',' type_set  { $$ = new_data_set($1, $3); }
        | %empty                 { $$ = NULL; }

%%

/*function returns a Data_Set pointer that is later passed in order to create a structure for a symbol of an API function*/
static Data_Set* 
new_data_set(Data_Type func_type, Data_Set* next_type)
{
  Data_Set* ptr = malloc(sizeof(Data_Set));
 
  if(!ptr) 
  {
    printf("Out of memory for symbol\n");
    exit(1);
  }  
  
  ptr->m_dtype = func_type;
  ptr->m_next = next_type;

  return ptr;

}


int main(int argc, char** argv)
{

 if(argc < 2)
 {
   printf("Please input a source file for reading.\n"); 
   return 1;
 } 

 if(argc > 2)
 {
   printf("Too many arguments passed.\n");
   return 1;
 }

 FILE* file = fopen(argv[1], "r");
 if(!file) 
 {
  printf("No such file found: \"%s\"\n", argv[1]); 
  return 1;
 } 
 yyin = file;
 
 /*initialize root for storing the tilte of the progrma*/
 init_symbol_table(); /*initialize the symbol table*/ 

 /*initialization ends here*/


 /*parse the entire file*/
 do
 { 
   yyparse();
 }while(!feof(yyin));



 printf("\n###### Done! ######\n\n");
 fclose(file); /* close the source file */ 

 return 0;
}





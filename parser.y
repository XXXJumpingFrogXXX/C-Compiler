%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>
	extern char* yytext;
    struct node {
        struct node *left;
        struct node *right;
        char *token;
        char *type;
    };
    void add(char);
    void insert_type();
    int search(char *);
    	void insert_type();
    	void print_tree(struct node*);
    	void print_tree_util(struct node*, int);
    	void print_inorder(struct node *);
    void check_declaration(char *);
    	void check_return_type(char *);
    	int check_types(char *, char *);
    	char *get_type(char *);
    struct dataType {
            char * id_name;
            char * data_type;
            char * type;
            int line_no;
    	} symbol_table[100];
    void newscope();
    void delscope();
    int count=0;
    int q;
    	char type[10];
    extern int countn;
    	struct node *head;
    	int sem_errors=0;
    	int ic_idx=0;
    	int temp_var=0;
    	int label=0;
    	int is_for=0;
    	char buff[100];
    	char errors[10][100];
    	char reserved[13][10] = {"int", "float", "char", "void", "if", "else", "for", "main", "return", "include","printf","scanf","while"};
    	char icg[100][100];
    void yyerror(const char *s);
    int yylex();
    int yywrap();

    int vec_left[100] = {0};
    void Display(struct node* root, int ident);

    void printtree(struct node*);
    void printInorder(struct node *);
    struct node* mknode(struct node *left, struct node *right, char *token,char *type);

    extern int countn;
    struct node *head;

%}

%union {
	struct var_name {
        			char name[100];
        			struct node* nd;
        		} nd_obj;

        		struct var_name2 {
        			char name[100];
        			struct node* nd;
        			char type[5];
        		} nd_obj2;

        		struct var_name3 {
        			char name[100];
        			struct node* nd;
        			char if_body[5];
        			char else_body[5];
        		} nd_obj3;
}

%token <nd_obj> CHARACTER PRINTFF SCANFF INT FLOAT CHAR FOR WHILE IF ELSE TRUE FALSE NUMBER FLOAT_NUM ID LE GE EQ NE NOO GT LT AND OR STR ADD MULTIPLY DIVIDE MODE SUBTRACT UNARY INCLUDE RETURN VOID
%type <nd_obj> headers main body ope return datatype statement arithmetic1 arithmetic2 relop program  else luoji ans hhh
%type<nd_obj2> init value fei expression txpression hxpression
%type <nd_obj3> condition
%%

program: headers  main '(' ')' '{' body return '}' { $2.nd = mknode($6.nd, $7.nd, "main","Main Function"); $$.nd = mknode($1.nd, $2.nd, "program","Program Compound"); head = $$.nd; }
;

headers: headers headers { $$.nd = mknode($1.nd, $2.nd, "headers","Header"); }
| INCLUDE { add('H'); }  { $$.nd = mknode(NULL, NULL, $1.name,"Include"); }
;


main: datatype ID { add('F'); }
;

datatype: INT { insert_type(); }
| FLOAT { insert_type(); }
| CHAR { insert_type(); }
| VOID { insert_type(); }
;

body: FOR {add('K'); is_for = 1; } '(' statement ';' condition ';' statement ')' '{' {newscope();} body {delscope();}'}' {
	 struct node *temp = mknode($6.nd, $8.nd, "CONDITION","Forloop Condition");
	 struct node *temp2 = mknode($4.nd, temp, "CONDITION","Forloop Condition");
	 $$.nd = mknode(temp2, $12.nd, $1.name,"Forloop Compound");
	 sprintf(icg[ic_idx++], buff);
	 sprintf(icg[ic_idx++], "JUMP to %s\n", $6.if_body);
	 sprintf(icg[ic_idx++], "\nLABEL %s:\n", $6.else_body);
  }
| WHILE { add('K'); is_for = 2; } '(' condition ')' '{'{newscope();} body {delscope();} '}' {
  	$$.nd = mknode($4.nd, $8.nd, $1.name,"WhileCompound");
  	sprintf(icg[ic_idx++], buff);
  	sprintf(icg[ic_idx++], "JUMP to %s\n", $4.if_body);
  	sprintf(icg[ic_idx++], "\nLABEL %s:\n", $4.else_body);
  	}
| IF { add('K'); is_for = 0; } '(' condition ')'  { sprintf(icg[ic_idx++], "\nLABEL %s:\n", $4.if_body); } '{' {newscope();} body {delscope();} '}' { sprintf(icg[ic_idx++], "\nLABEL %s:\n", $4.else_body); }  else {
	struct node *iff = mknode($4.nd, $9.nd, $1.name,"If Compound");
	$$.nd = mknode(iff, $13.nd, "if-else","if-else Compound");
        sprintf(icg[ic_idx++], "GOTO next\n");
	}
| statement ';' { $$.nd = $1.nd; }
| body body { $$.nd = mknode($1.nd, $2.nd, "statements","Compound"); }
| PRINTFF { add('K'); } '(' ans ')' ';' {  $$.nd = mknode($4.nd, NULL, "printf","Printf Function"); }
| SCANFF  { add('K'); } '(' STR ',' '&' ID ')' ';' { $$.nd = mknode(NULL, NULL, "scanf","Scanf Function"); }
;

ans:STR {struct node *temp =mknode(NULL,NULL,$1.name,"STR"); $$.nd=temp;}
| value {struct node *temp =mknode(NULL,NULL,$1.name,"Printf Content"); $$.nd=temp;}
| ans ',' ans {$$.nd=mknode($1.nd,$3.nd,"content","Printf Content");}
;
else: ELSE  { add('K'); } '{' body '}' { $$.nd = mknode(NULL, $4.nd, $1.name,"Else Compound"); }
| { $$.nd = NULL; }
;

condition: value relop value {
  $$.nd = mknode($1.nd, $3.nd, $2.name,"Condition Expression");
  if(is_for==1||is_for==2) {
  		sprintf($$.if_body, "L%d", label++);
  		sprintf(icg[ic_idx++], "\nLABEL %s:\n", $$.if_body);
  		sprintf(icg[ic_idx++], "\nif NOT (%s %s %s) GOTO L%d\n", $1.name, $2.name, $3.name, label);
  		sprintf($$.else_body, "L%d", label++);
  	}
      else {
  		sprintf(icg[ic_idx++], "\nif (%s %s %s) GOTO L%d else GOTO L%d\n", $1.name, $2.name, $3.name, label, label+1);
  		sprintf($$.if_body, "L%d", label++);
  		sprintf($$.else_body, "L%d", label++);
  	}
  }
| TRUE { add('K'); $$.nd = NULL; }
| FALSE { add('K'); $$.nd = NULL; }
| NOO value { $$.nd = mknode($2.nd, NULL, "!","Condition Expression"); }
| value { $$.nd = mknode($1.nd, NULL, "","Condition Expression"); }
| { $$.nd = NULL; }
| condition luoji condition {$$.nd = mknode($1.nd, $3.nd, $2.name,"Condition Expression");}
;

value:FLOAT_NUM { strcpy($$.name, $1.name); sprintf($$.type, "float");$$.nd = mknode(NULL, NULL, $1.name,"Folat Declaration"); }
| CHARACTER { strcpy($$.name, $1.name); sprintf($$.type, "char");$$.nd = mknode(NULL, NULL, $1.name,"Char Declaration"); }
| fei
| value ope value  { $$.nd = mknode($1.nd, $3.nd ,$2.name,"Expression"); }
;

fei:NOO ID {check_declaration($2.name);strcpy($$.name, $1.name); char *id_type = get_type($1.name);struct node * temp= mknode(NULL, NULL, $2.name,"ID Declaration"); $$.nd=mknode(temp,NULL,"!","NOT");}
|ID {check_declaration($1.name);strcpy($$.name, $1.name); char *id_type = get_type($1.name); $$.nd = mknode(NULL, NULL, $1.name,"ID Declaration"); }
|NUMBER { strcpy($$.name, $1.name); sprintf($$.type, "int"); add('C'); $$.nd = mknode(NULL, NULL, $1.name,"Number Declaration"); }
|NOO NUMBER {strcpy($$.name, $1.name); sprintf($$.type, "int"); add('C'); struct node * temp= mknode(NULL, NULL, $2.name,"Number Declaration"); $$.nd=mknode(temp,NULL,"!","NOT");}
;

luoji:AND
| OR
;

ope:MULTIPLY
|DIVIDE
|SUBTRACT
|ADD
|MODE
;

statement: datatype ID { add('V'); } init hhh {
	$2.nd = mknode(NULL, NULL, $2.name,"ID Declaration");
	int t = check_types($1.name, $4.type);
        	if(t>0) {
        		if(t == 1) {
        			struct node *temp = mknode(NULL, $4.nd, "floattoint","");
        			$$.nd = mknode($2.nd, temp, "declaration","");
        		}
        		else if(t == 2) {
        			struct node *temp = mknode(NULL, $4.nd, "inttofloat","");
        			$$.nd = mknode($2.nd, temp, "declaration","");
        		}
        		else if(t == 3) {
        			struct node *temp = mknode(NULL, $4.nd, "chartoint","");
        			$$.nd = mknode($2.nd, temp, "declaration","");
        		}
        		else if(t == 4) {
        			struct node *temp = mknode(NULL, $4.nd, "inttochar","");
        			$$.nd = mknode($2.nd, temp, "declaration","");
        		}
        		else if(t == 5) {
        			struct node *temp = mknode(NULL, $4.nd, "chartofloat","");
        			$$.nd = mknode($2.nd, temp, "declaration","");
        		}
        		else{
        			struct node *temp = mknode(NULL, $4.nd, "floattochar","");
        			$$.nd = mknode($2.nd, temp, "declaration","");
        		}
        	}
        else{
	struct node *temp = mknode($2.nd, $4.nd, "=","Assignment");
	$$.nd=mknode(temp,$4.nd,"Declaration","");
	}
	sprintf(icg[ic_idx++], "%s = %s\n", $2.name, $4.name);
	}
| ID { check_declaration($1.name); } '=' expression {
 	$1.nd = mknode(NULL, NULL, $1.name,"ID Declaration");
 	char *id_type = get_type($1.name);
 	if(id_type){
 	if(strcmp(id_type, $4.type)) {
        		if(!strcmp(id_type, "int")) {
        			if(!strcmp($4.type, "float")){
        				struct node *temp = mknode(NULL, $4.nd, "floattoint","");
        				$$.nd = mknode($1.nd, temp, "=","");
        			}
        			else{
        				struct node *temp = mknode(NULL, $4.nd, "chartoint","");
        				$$.nd = mknode($1.nd, temp, "=","");
        			}

        		}
        		else if(!strcmp(id_type, "float")) {
        			if(!strcmp($4.type, "int")){
        				struct node *temp = mknode(NULL, $4.nd, "inttofloat","");
        				$$.nd = mknode($1.nd, temp, "=","");
        			}
        			else{
        				struct node *temp = mknode(NULL, $4.nd, "chartofloat","");
        				$$.nd = mknode($1.nd, temp, "=","");
        			}

        		}
        		else{
        			if(!strcmp($4.type, "int")){
        				struct node *temp = mknode(NULL, $4.nd, "inttochar","");
        				$$.nd = mknode($1.nd, temp, "=","");
        			}
        			else{
        				struct node *temp = mknode(NULL, $4.nd, "floattochar","");
        				$$.nd = mknode($1.nd, temp, "=","");
        			}
        		}
        	}
        	else {
        		 $$.nd = mknode($1.nd, $4.nd, "=","Assignment");
        	}
        		sprintf(icg[ic_idx++], "%s = %s\n", $1.name, $4.name);
 	}
 }
| ID { check_declaration($1.name); } relop expression { $1.nd = mknode(NULL, NULL, $1.name,"ID Declaration"); $$.nd = mknode($1.nd, $4.nd, $3.name,""); }
| ID { check_declaration($1.name); } UNARY {
	$1.nd = mknode(NULL, NULL, $1.name,"ID Declaration");
	$3.nd = mknode(NULL, NULL, $3.name,"");
	$$.nd = mknode($1.nd, $3.nd, "ITERATOR","");
	if(!strcmp($3.name, "++")) {
        		sprintf(buff, "t%d = %s + 1\n%s = t%d\n", temp_var, $1.name, $1.name, temp_var++);
        	}
        	else {
        		sprintf(buff, "t%d = %s + 1\n%s = t%d\n", temp_var, $1.name, $1.name, temp_var++);
        	}
	}
| UNARY ID {
	check_declaration($2.name);
	$1.nd = mknode(NULL, NULL, $1.name,"");
	$2.nd = mknode(NULL, NULL, $2.name,"ID Declaration");
	$$.nd = mknode($1.nd, $2.nd, "ITERATOR","");
	if(!strcmp($1.name, "++")) {
        	sprintf(buff, "t%d = %s + 1\n%s = t%d\n", temp_var, $2.name, $2.name, temp_var++);
        }
        else {
        	sprintf(buff, "t%d = %s - 1\n%s = t%d\n", temp_var, $2.name, $2.name, temp_var++);

        }
}
;

hhh:',' ID { add('V');} '=' expression {$2.nd=mknode(NULL,NULL,$2.name,"ID Declaration"),$$.nd=mknode($2.nd,$5.nd,"=","Assignment");}
| { $$.nd = NULL;}
;

init: '=' value { $$.nd = $2.nd; sprintf($$.type, $2.type); strcpy($$.name, $2.name);}
| {sprintf($$.type, "null"); $$.nd = mknode(NULL, NULL, "Assignment","Expression");strcpy($$.name, "NULL");  }
;

expression: expression arithmetic2 txpression {
	if(!strcmp($1.type, $3.type)) {
		sprintf($$.type, $1.type);
		$$.nd = mknode($1.nd, $3.nd, $2.name,"Expression");
	}
	else {
        	if(!strcmp($1.type, "int") && !strcmp($3.type, "float")) {
        		struct node *temp = mknode(NULL, $1.nd, "inttofloat","");
        		sprintf($$.type, $3.type);
        		$$.nd = mknode(temp, $3.nd, $2.name,"");
        	}
        	else if(!strcmp($1.type, "float") && !strcmp($3.type, "int")) {
        		struct node *temp = mknode(NULL, $3.nd, "inttofloat","");
        		sprintf($$.type, $1.type);
        		$$.nd = mknode($1.nd, temp, $2.name,"");
        	}
        	else if(!strcmp($1.type, "int") && !strcmp($3.type, "char")) {
        		struct node *temp = mknode(NULL, $3.nd, "chartoint","");
        		sprintf($$.type, $1.type);
        		$$.nd = mknode($1.nd, temp, $2.name,"");
        	}
        	else if(!strcmp($1.type, "char") && !strcmp($3.type, "int")) {
        		struct node *temp = mknode(NULL, $1.nd, "chartoint","");
        		sprintf($$.type, $3.type);
        		$$.nd = mknode(temp, $3.nd, $2.name,"");
        	}
        	else if(!strcmp($1.type, "float") && !strcmp($3.type, "char")) {
        		struct node *temp = mknode(NULL, $3.nd, "chartofloat","");
        		sprintf($$.type, $1.type);
        		$$.nd = mknode($1.nd, temp, $2.name,"");
        	}
        	else {
        		struct node *temp = mknode(NULL, $1.nd, "chartofloat","");
        		sprintf($$.type, $3.type);
        		$$.nd = mknode(temp, $3.nd, $2.name,"");
        	}
       	}
        sprintf($$.name, "t%d", temp_var);
        temp_var++;
       	sprintf(icg[ic_idx++], "%s = %s %s %s\n",  $$.name, $1.name, $2.name, $3.name);
 }
| txpression { $$.nd = $1.nd; }
;

txpression: txpression arithmetic1 hxpression { $$.nd = mknode($1.nd, $3.nd, $2.name,"Expression"); }
| hxpression { $$.nd = $1.nd; }
;

hxpression:hxpression MODE hxpression { $$.nd = mknode($1.nd, $3.nd, $2.name,"Expression"); }
| value {strcpy($$.name, $1.name); sprintf($$.type, $1.type); $$.nd = $1.nd; }
;

arithmetic1:MULTIPLY
| DIVIDE
;

arithmetic2:ADD
| SUBTRACT
;

relop: LT
| GT
| LE
| GE
| EQ
| NE
;

return: RETURN { add('K'); }  value ';' { check_return_type($3.name);$1.nd = mknode(NULL, NULL, "return",""); $$.nd = mknode($1.nd, $3.nd, "RETURN",""); }
| { $$.nd = NULL; }
;

%%

int main() {
   yyparse();
       printf("\n\n");
   	printf("\t\t\t\t\t\t\t\t PHASE 1: LEXICAL ANALYSIS \n\n");
   	printf("\nSYMBOL   DATATYPE   TYPE   LINE NUMBER \n");
   	printf("_______________________________________\n\n");
   	int i=0;
   	for(i=0; i<count; i++) {
   		printf("%s\t%s\t%s\t%d\t\n", symbol_table[i].id_name, symbol_table[i].data_type, symbol_table[i].type, symbol_table[i].line_no);
   	}
   	for(i=0;i<count;i++) {
   		free(symbol_table[i].id_name);
   		free(symbol_table[i].type);
   	}
   	printf("\n\n");
   	printf("\t\t\t\t\t\t\t\t PHASE 2: SYNTAX ANALYSIS \n\n");
   	printtree(head);
   	printf("\n\n\n\n");
   	printf("\t\t\t\t\t\t\t\t PHASE 3: SEMANTIC ANALYSIS \n\n");
   	if(sem_errors>0) {
   		printf("Semantic analysis completed with %d errors\n", sem_errors);
   		for(int i=0; i<sem_errors; i++){
   			printf("\t - %s", errors[i]);
   		}
   	} else {
   		printf("Semantic analysis completed with no errors");
   	}
   	printf("\n\n");
   	printf("\t\t\t\t\t\t\t   PHASE 4: INTERMEDIATE CODE GENERATION \n\n");
   	for(int i=0; i<ic_idx; i++){
   		printf("%s", icg[i]);
   	}
   	printf("\n\n");
}
int search(char *type) {
	int i;
	for(i=count-1; i>=0; i--) {
		if(strcmp(symbol_table[i].id_name, type)==0) {
			return -1;
			break;
		}
	}
	return 0;
}
void check_declaration(char *c) {
    q = search(c);
    if(!q) {
        sprintf(errors[sem_errors], "Line %d: Variable \"%s\" not declared before usage!\n", countn+1, c);
		sem_errors++;
    }
}

void check_return_type(char *value) {
	char *main_datatype = get_type("main");
	char *return_datatype = get_type(value);
	if((!strcmp(main_datatype, "int") && !strcmp(return_datatype, "CONST")) || !strcmp(main_datatype, return_datatype)){
		return ;
	}
	else {
		sprintf(errors[sem_errors], "Line %d: Return type mismatch\n", countn+1);
		sem_errors++;
	}
}

int check_types(char *type1, char *type2){
	// declaration with no init
	if(!strcmp(type2, "null"))
		return -1;
	// both datatypes are same
	if(!strcmp(type1, type2))
		return 0;
	// both datatypes are different
	if(!strcmp(type1, "int") && !strcmp(type2, "float"))
		return 1;
	if(!strcmp(type1, "float") && !strcmp(type2, "int"))
		return 2;
	if(!strcmp(type1, "int") && !strcmp(type2, "char"))
		return 3;
	if(!strcmp(type1, "char") && !strcmp(type2, "int"))
		return 4;
	if(!strcmp(type1, "float") && !strcmp(type2, "char"))
		return 5;
	if(!strcmp(type1, "char") && !strcmp(type2, "float"))
		return 6;
}

char *get_type(char *var){
	for(int i=0; i<count; i++) {
		// Handle case of use before declaration
		if(!strcmp(symbol_table[i].id_name, var)) {
			return symbol_table[i].data_type;
		}
	}
	return NULL;
}

void add(char c) {
	if(c == 'V'){
		for(int i=0; i<13; i++){
			if(!strcmp(reserved[i], strdup(yytext))){
        		sprintf(errors[sem_errors], "Line %d: Variable name \"%s\" is a reserved keyword!\n", countn+1, yytext);
				sem_errors++;
				return;
			}
		}
	}
    q=search(yytext);
	if(!q) {
		if(c == 'H') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Header");
			count++;
		}
		else if(c == 'K') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("N/A");
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Keyword\t");
			count++;
		}
		else if(c == 'V') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Variable");
			count++;
		}
		else if(c == 'C') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup("CONST");
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Constant");
			count++;
		}
		else if(c == 'F') {
			symbol_table[count].id_name=strdup(yytext);
			symbol_table[count].data_type=strdup(type);
			symbol_table[count].line_no=countn;
			symbol_table[count].type=strdup("Function");
			count++;
		}
    }
    else if(c == 'V' && q) {
        sprintf(errors[sem_errors], "Line %d: Multiple declarations of \"%s\" not allowed!\n", countn+1, yytext);
		sem_errors++;
    }
}
struct node* mknode(struct node *left, struct node *right, char *token,char *type) {
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newtok = (char *)malloc(strlen(token)+1);
	strcpy(newtok, token);

	char *newtype = (char *)malloc(strlen(type)+1);
	strcpy(newtype, type);

	newnode->left = left;
	newnode->right = right;
	newnode->token = newtok;
	newnode->type = newtype;
	return(newnode);
}

void printtree(struct node* tree) {
	Display(tree, 0);
}

void Display(struct node* root, int ident)
{
    if(ident > 0)
    {
        for(int i = 0; i < ident - 1; ++i)
        {
            printf(vec_left[i] ? "|    " : "    ");
        }
        printf(vec_left[ident-1] ? "{---- " : "+---- ");
    }

    if(!root)
    {
        printf("(null)\n");
        return;
    }

    printf("%s: %s\n", root->type,root->token);
    if(!root->left && !root->right)
    {
        return;
    }

    vec_left[ident] = 1;
    Display(root->left, ident + 1);
    vec_left[ident] = 0;
    Display(root->right, ident + 1);
}

void printInorder(struct node *tree) {
	int i;
	if (tree->left) {
		printInorder(tree->left);
	}
	printf("%s,%s", tree->type,tree->token);
	if (tree->right) {
		printInorder(tree->right);
	}
}
void insert_type() {
	strcpy(type, yytext);
}
void newscope(){
	symbol_table[count].id_name="{{";
        symbol_table[count].data_type="flag";
        symbol_table[count].line_no=0;
        symbol_table[count].type="flag";
        count++;
}
void delscope(){
 	int i;
        for(i=count-1; i>=0; i--) {

        	if(strcmp(symbol_table[i].id_name, "{{")==0) {
        		count--;
        		break;
        	}
        	else{
        		count--;
        	}
        }
}
void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}
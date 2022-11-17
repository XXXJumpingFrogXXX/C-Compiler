%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    #include<ctype.h>

    struct node { 
        struct node *left; 
        struct node *right; 
        char *token; 
    };

    void yyerror(const char *s);
    int yylex();
    int yywrap();

    int vec_left[100] = {0};
    void Display(struct node* root, int ident);

    void printtree(struct node*);
    void printInorder(struct node *);
    struct node* mknode(struct node *left, struct node *right, char *token);

    extern int countn;
    struct node *head;
   
%}

%union { 
	struct var_name { 
		char name[100]; 
		struct node* nd;
	} nd_obj; 
} 

%token <nd_obj> CHARACTER PRINTFF SCANFF INT FLOAT CHAR FOR WHILE IF ELSE TRUE FALSE NUMBER FLOAT_NUM ID LE GE EQ NE GT LT AND OR STR ADD MULTIPLY DIVIDE SUBTRACT UNARY INCLUDE RETURN VOID
%type <nd_obj> headers main body return datatype expression txpression statement init value arithmetic1 arithmetic2 relop program condition else

%%

program: headers main '(' ')' '{' body return '}' { $2.nd = mknode($6.nd, $7.nd, "main"); $$.nd = mknode($1.nd, $2.nd, "program"); head = $$.nd; } 
;

headers: headers headers { $$.nd = mknode($1.nd, $2.nd, "headers"); }
| INCLUDE { $$.nd = mknode(NULL, NULL, $1.name); }
;

main: datatype ID
;

datatype: INT
| FLOAT
| CHAR
| VOID
;

body: FOR '(' statement ';' condition ';' statement ')' '{' body '}' { struct node *temp = mknode($5.nd, $7.nd, "CONDITION"); struct node *temp2 = mknode($3.nd, temp, "CONDITION"); $$.nd = mknode(temp2, $10.nd, $1.name); }
| WHILE '(' condition ')''{' body '}' { $$.nd = mknode($3.nd, $6.nd, $1.name); }
| IF '(' condition ')' '{' body '}' else { struct node *iff = mknode($3.nd, $6.nd, $1.name); 	$$.nd = mknode(iff, $8.nd, "if-else"); }
| statement ';' { $$.nd = $1.nd; }
| body body { $$.nd = mknode($1.nd, $2.nd, "statements"); }
| PRINTFF '(' STR ')' ';' { $$.nd = mknode(NULL, NULL, "printf"); }
| SCANFF '(' STR ',' '&' ID ')' ';' { $$.nd = mknode(NULL, NULL, "scanf"); }
;

else: ELSE '{' body '}' { $$.nd = mknode(NULL, $3.nd, $1.name); }
| { $$.nd = NULL; }
;

condition: value relop value { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| TRUE { $$.nd = NULL; }
| FALSE { $$.nd = NULL; }
| { $$.nd = NULL; }
;

statement: datatype ID init { $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($2.nd, $3.nd, "declaration"); }
| ID '=' expression { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $3.nd, "="); }
| ID relop expression { $1.nd = mknode(NULL, NULL, $1.name); $$.nd = mknode($1.nd, $3.nd, $2.name); }
| ID UNARY { $1.nd = mknode(NULL, NULL, $1.name); $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($1.nd, $2.nd, "ITERATOR"); }
| UNARY ID { $1.nd = mknode(NULL, NULL, $1.name); $2.nd = mknode(NULL, NULL, $2.name); $$.nd = mknode($1.nd, $2.nd, "ITERATOR"); }
;

init: '=' value { $$.nd = $2.nd; }
| { $$.nd = mknode(NULL, NULL, "NULL"); }
;

expression: expression arithmetic2 txpression { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| txpression { $$.nd = $1.nd; }
;

txpression: txpression arithmetic1 value { $$.nd = mknode($1.nd, $3.nd, $2.name); }
| value { $$.nd = $1.nd; }
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

value: NUMBER { $$.nd = mknode(NULL, NULL, $1.name); }
| FLOAT_NUM { $$.nd = mknode(NULL, NULL, $1.name); }
| CHARACTER { $$.nd = mknode(NULL, NULL, $1.name); }
| ID { $$.nd = mknode(NULL, NULL, $1.name); }
;

return: RETURN value ';' { $1.nd = mknode(NULL, NULL, "return"); $$.nd = mknode($1.nd, $2.nd, "RETURN"); }
| { $$.nd = NULL; }
;

%%

int main() {
    printf("\n\n --------------符号表如下-------------------\n\n");
	printf("\nTYPE\t\tKEYWORD\t\tATTRIBUTE\n");
	printf("_______________________________________\n\n");
    yyparse();
	printf("\n\n");
	printf("\n\n --------------语法树如下-------------------\n\n");
	printtree(head); 
	printf("\n\n");
}

struct node* mknode(struct node *left, struct node *right, char *token) {	
	struct node *newnode = (struct node *)malloc(sizeof(struct node));
	char *newstr = (char *)malloc(strlen(token)+1);
	strcpy(newstr, token);
	newnode->left = left;
	newnode->right = right;
	newnode->token = newstr;
	return(newnode);
}

void printtree(struct node* tree) {
	printf("\n\n Inorder traversal of the Parse Tree: \n\n");
	printInorder(tree);
	printf("\n\n Inorder traversal of the Parse Tree: \n\n");
	Display(tree, 0);
}

void Display(struct node* root, int ident)
{
    if(ident > 0)
    {
        for(int i = 0; i < ident - 1; ++i)
        {
            printf(vec_left[i] ? "|   " : "    ");
        }
        printf(vec_left[ident-1] ? "|-- " : "^-- ");
    }

    if(!root)
    {
        printf("(null)\n");
        return;
    }

    printf("%s\n", root->token);
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
	printf("%s, ", tree->token);
	if (tree->right) {
		printInorder(tree->right);
	}
}

void yyerror(const char* msg) {
    fprintf(stderr, "%s\n", msg);
}
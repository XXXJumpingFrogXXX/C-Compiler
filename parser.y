%{
	#include"node.h"
	#include"table.h"
	#include"address3.h"
	#include"writeasm.h"
	extern int yylex();
	int yyerror(const char* msg);
	Node* root;
	bool parse_error = false;
	int cntt=0;
	char error_str[128][128];
	void print(Node* p, int interval);
	void insertChildren(Node*par, ...);
	void returnError(Node*t, Node*root);
	void insertError(int type, string arg1, string arg2, int line);
%}

%union{
	char* str;
	class Node* node;
}
%token<node> INTEGER
%token<node> ID
%token<node> MAIN COMMA VOID LP RP PRINTF IF FOR WHILE  DOT COLON RETURN SELFPLUS SELFMINUS
%token<node> POINT ADDR TYPE PLUS MINUS MULTIPLY DIVIDE POW MODEL
%token<node> ASSIGN INCLUDE ELSE SCANF
%token<node> LMB RMB SEMICOLON ERROR LBRACE RBRACE
%token<node> GREATER LESS NEQUAL EQUAL NOT GREATEREQ LESSEQ AND OR
%type<node> Compound Content Conclude VarInt Expr InitInt BeforeMain MainFunc Include Before
%type<node> Opnum OpnumNull Outputk ForHeader Inputk Type VarOpnum Loop Condition IDdec Const start ReturnStmt
%type<node> Array DecArray InitArray InitArrayInner

%nonassoc LOWEST
%right ASSIGN
%left OR
%left AND
%left EQUAL NEQUAL
%left GREATER LESS GREATEREQ LESSEQ
%left PLUS MINUS
%left MULTIPLY DIVIDE MODEL
%right POW
%nonassoc RETURN PRINTF SCANF IF FOR WHILE RBRACE TYPE
%right SELFPLUS SELFMINUS NOT ADDR POINT
%left LP RP
%nonassoc ID INTEGER
%nonassoc LBRACE
%nonassoc ELSE
%nonassoc SEMICOLON
%right MINUSINTEGER
%%
 // 开始符号
start:		BeforeMain MainFunc
	{$$=new Node("Program", 0);insertChildren($$, $1, $2, new Node("$", 0));print($$, 2);root = $$;}
	|	MainFunc
	{$$=new Node("Program", 0);insertChildren($$, $1, new Node("$", 0));print($$, 2);root = $$;}
 ;


MainFunc: 	Type MAIN LP RP Compound
	{$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $5, new Node("$", 0));returnError($1, $5);}
	|	Type MAIN RP Compound
	{$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $4, new Node("$", 0));
	insertError(1,"(","",$2->line);returnError($1, $4);
	parse_error = true;}
	|	Type MAIN LP Compound
	{$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $4, new Node("$", 0));
	insertError(1,")","",$3->line);returnError($1, $4);
	parse_error = true;}
	|	Type MAIN Compound
	{$$=new Node("MainFunc", 0);insertChildren($$, $1, $2, $3, new Node("$", 0));
	insertError(2,"(",")",$2->line);returnError($1, $3);
	parse_error = true;}
	;

Type: 	TYPE	{$$=$1;}
	|	VOID	{$$=$1;}	
	;

 // 大括号包起来的部分
Compound:		LBRACE Content RBRACE {$$=$2;}
	|			LBRACE RBRACE {$$=new Node("Compound", 0);}
	// 缺右括号
	|			LBRACE Content %prec LOWEST
	{$$=$2;insertError(1,"}","",$$->line);parse_error = true;}
	|			LBRACE %prec LOWEST
	{$$=new Node("Compound", 0);insertError(1,"}","",$$->line);parse_error = true;}
	;

 // 大括号里包含的内容
Content:		Conclude
		{$$=new Node("Compound", 0);insertChildren($$,$1,new Node("$", 0));}
	|			Content Conclude
		{insertChildren($$,$2,new Node("$", 0));}
	;
 // 大括号里包含的内容的具体归纳
Conclude:		VarInt	SEMICOLON			{$$=$1;}
	|			DecArray	SEMICOLON		{$$=$1;}
	|			VarInt						{$$=$1;insertError(1,";","",$$->line);parse_error = true;}
	|			Opnum SEMICOLON				{$$=$1;}
	|			Opnum %prec LOWEST			{$$=$1;insertError(1,";","",$$->line);parse_error = true;}
	|			Loop						{$$=$1;}
	|			Condition					{$$=$1;}
	|			ReturnStmt					{$$=$1;}
	|			Outputk						{$$=$1;}
	|			Inputk						{$$=$1;}
	;
 
 // 输出的语句
Outputk:		PRINTF OpnumNull SEMICOLON 
	{$$=new Node("Outputk", 0);insertChildren($$, $2, new Node("$", 0));
	if($2->key == "NULL"){
		insertError(1,"expr","",$2->line);parse_error = true;}
	}
	|			PRINTF OpnumNull
	{$$=new Node("Outputk", 0);insertChildren($$, $2, new Node("$", 0));
	if($2->key == "NULL"){
		insertError(1,"expr","",$2->line);
	}
	insertError(1,";","",$2->line);	parse_error = true;}
	;

Inputk:			SCANF IDdec SEMICOLON
	{$$=new Node("Inputk", 0); insertChildren($$, $2, new Node("$", 0));}
	|			SCANF IDdec
	{$$=new Node("Inputk", 0); insertChildren($$, $2, new Node("$", 0));
	insertError(1,";","",$2->line);parse_error = true;}
	;

 // 返回的语句
ReturnStmt:	RETURN SEMICOLON
	{$$=$1;$$->key="Return statement";}
	|			RETURN %prec LOWEST // return后缺少了分号报错
	{$$=$1;$$->key="Return statement";insertError(1,";","",$$->line);
	parse_error = true;}
	|			RETURN Opnum SEMICOLON
	{$$=$1;$$->key="Return expr statement";insertChildren($$, $2,new Node("$", 0));}
	|			RETURN Opnum %prec LOWEST  // return后缺少了分号报错
	{$$=$1;$$->key="Return expr statement";insertChildren($$, $2,new Node("$", 0));
	insertError(1,";","",$$->line);	parse_error = true;}
	;
BeforeMain:		Before
	{$$=new Node("BeforeMain", 0);insertChildren($$, $1, new Node("$", 0));}
	|			BeforeMain Before
	{insertChildren($$, $2, new Node("$", 0));}
	;

Before: 		Include			{$$=$1;}
	;

 // 条件结构
Condition:		IF LP Opnum RP Compound %prec LOWEST		
	{$$=new Node("Ifbody", 0);insertChildren($$,$3,$5,new Node("$", 0));}
	|			IF LP Opnum RP Compound ELSE Compound	
	{$$=new Node("Elsebody", 0);insertChildren($$,$3,$5,$7,new Node("$", 0));}
	|			IF LP Opnum RP Compound ELSE Condition		
	{$$=new Node("Elsebody", 0);insertChildren($$,$3,$5,$7,new Node("$", 0));}
 	// 缺左括号
	|			IF Opnum RP Compound %prec LOWEST		
	{$$=new Node("Ifbody", 0);insertChildren($$,$2,$4,new Node("$", 0));
	insertError(1,"(","",$1->line);	parse_error = true;}
	|			IF Opnum RP Compound ELSE Compound		
	{$$=new Node("Elsebody", 0);insertChildren($$,$2,$4,$6,new Node("$", 0));
	insertError(1,"(","",$1->line);	parse_error = true;}
	|			IF Opnum RP Compound ELSE Condition		
	{$$=new Node("Elsebody", 0);insertChildren($$,$2,$4,$6,new Node("$", 0));
	insertError(1,"(","",$1->line);	parse_error = true;}
	// 缺右括号
	|			IF LP Opnum Compound %prec LOWEST		
	{$$=new Node("Ifbody", 0);insertChildren($$,$3,$4,new Node("$", 0));
	insertError(1,")","",$3->line);	parse_error = true;}
	|			IF LP Opnum Compound ELSE Compound		
	{$$=new Node("Elsebody", 0);insertChildren($$,$3,$4,$6,new Node("$", 0));
	insertError(1,")","",$3->line);	parse_error = true;}
	|			IF LP Opnum Compound ELSE Condition		
	{$$=new Node("Elsebody", 0);insertChildren($$,$3,$4,$6,new Node("$", 0));
	insertError(1,")","",$3->line);	parse_error = true;}
	// 缺两个括号
	|			IF Opnum Compound %prec LOWEST		
	{$$=new Node("Ifbody", 0);insertChildren($$,$2,$3,new Node("$", 0));
	insertError(1,"(","",$1->line);	insertError(1,")","",$2->line);
	parse_error = true;}
	|			IF Opnum Compound ELSE Compound	
	{$$=new Node("Elsebody", 0);insertChildren($$,$2,$3,$5,new Node("$", 0));
	insertError(1,"(","",$1->line);	insertError(1,")","",$2->line);
	parse_error = true;}
	|			IF Opnum Compound ELSE Condition		
	{$$=new Node("Elsebody", 0);insertChildren($$,$2,$3,$5,new Node("$", 0));
	insertError(1,"(","",$1->line);	insertError(1,")","",$2->line);
	parse_error = true;}
	;


 // 循环体结构
Loop:		FOR LP ForHeader RP Compound
	{$$=new Node("Forloop", 0);insertChildren($$, $3, $5, new Node("$", 0));}
	|			WHILE LP Opnum RP Compound
	{$$=new Node("Whileloop", 0);insertChildren($$,$3,$5,new Node("$", 0));
	if($3->key == "NULL")
	{
		insertError(1,"expr","",$2->line);
		parse_error = true;
	}}
	|			WHILE LP RP Compound
	{$$=new Node("Whileloop ", 0);insertChildren($$,new Node("NULL", 0),$4,new Node("$", 0));
	insertError(1,"expr","",$2->line);parse_error = true;}
	// 缺左括号
	|			FOR ForHeader RP Compound
	{$$=new Node("Forloop ", 0);insertChildren($$, $2, $4, new Node("$", 0));
	insertError(1,"(","",$1->line);parse_error = true;}
	|			WHILE OpnumNull RP Compound
	{$$=new Node("Whileloop", 0);insertChildren($$, $2, $4, new Node("$", 0));
	if($2->key == "NULL"){
		insertError(1,"expr","",$1->line);
	}
	insertError(1,"(","",$1->line);parse_error = true;}
	// 缺右括号
	|			FOR LP ForHeader Compound
	{$$=new Node("Forloop ", 0);insertChildren($$, $3, $4, new Node("$", 0));
	insertError(1,")","",$3->line);parse_error = true;}
	|			WHILE LP OpnumNull Compound
	{$$=new Node("Whileloop", 0);insertChildren($$,$3,$4,new Node("$", 0));
	if($3->key == "NULL"){
		insertError(1,"expr","",$2->line);
	}
	insertError(1,")","",$2->line);parse_error = true;}
	// 缺少两个括号
	|			FOR ForHeader Compound
	{$$=new Node("Forloop", 0);insertChildren($$, $2, $3, new Node("$", 0));
	insertError(1,"(","",$1->line);insertError(1,")","",$2->line);
	parse_error = true;}
	|			WHILE OpnumNull Compound
	{$$=new Node("Whileloop", 0);insertChildren($$,$2,$3,new Node("$", 0));
	if($2->key == "NULL"){
		insertError(1,"expr","",$1->line);
	}
	insertError(1,"(","",$1->line);insertError(1,")","",$2->line);
	parse_error = true;}
	;

 // for循环小括号内三个表达式
ForHeader:		VarOpnum SEMICOLON OpnumNull SEMICOLON OpnumNull // 不缺分号
	{$$=new Node("ForHeader", 0);insertChildren($$, $1, $3, $5, new Node("$", 0));}
	|			VarOpnum OpnumNull SEMICOLON OpnumNull // 缺第一个分号
	{$$=new Node("ForHeader", 0);insertChildren($$, $1, $2, $4, new Node("$", 0));
	insertError(1,";","",$1->line);parse_error = true;}
	|			VarOpnum SEMICOLON OpnumNull OpnumNull // 缺第二个分号
	{$$=new Node("ForHeader", 0);insertChildren($$, $1, $3, $4, new Node("$", 0));
	insertError(1,";","",$3->line);parse_error = true;}
	|			VarOpnum OpnumNull OpnumNull // 缺两个分号
	{$$=new Node("ForHeader", 0);insertChildren($$, $1, $2, $3, new Node("$", 0));
	insertError(1,";","",$1->line);insertError(1,";","",$2->line);
	parse_error = true;}
	;


 // 声明变量 或者 声明变量并赋值
VarInt:		TYPE InitInt
	{$$=new Node("VarInt", 0);insertChildren($$, $1, $2, new Node("$", 0));
	$2->children[0]->type = $1->key;$$->type = $1->key;
	write_table($2->children[0]->key, $2->children[0]->type);
	if($2->children[0]->type != $2->children[1]->type) {
		insertError(4,$2->children[0]->type,$2->children[1]->type,$2->children[0]->line);
		parse_error = true;}
	}
	|		TYPE IDdec
	{$$=new Node("VarInt", 0);insertChildren($$, $1, $2, new Node("$", 0));
	$2->type = $1->key;	$$->type = $1->key;
	write_table($2->key, $$->type);}
	|		VarInt COMMA IDdec
	{insertChildren($$, $3, new Node("$", 0));
	$3->type = $$->type;
	write_table($3->key, $3->type);}
	|		VarInt COMMA InitInt
	{insertChildren($$, $3, new Node("$", 0));
	$3->children[0]->type = $$->type;
	write_table($3->children[0]->key, $3->children[0]->type);
	if($3->children[0]->type != $3->children[1]->type) {
		insertError(4,$3->children[0]->type,$3->children[1]->type,$3->children[0]->line);
		parse_error = true;}
	}
	;
	 
 // 定义一个变量
InitInt:		IDdec ASSIGN Opnum
	{$$=new Node("InitInt", 0); insertChildren($$, $1, $3, new Node("$", 0));}
	;

 // 数组声明
DecArray:	TYPE Array
	{$$=new Node("DecArray", 0);insertChildren($$, $1, $2, new Node("$", 0));
	$2->children[0]->type = $1->key + "*";
	write_table($2->children[0]->key, $2->children[0]->type);
	$$->type = $2->children[0]->type;$2->type = $1->key;}
	|		DecArray COMMA Array
	{insertChildren($$, $3,  new Node("$", 0));
	$3->children[0]->type = $$->type;
	write_table($3->children[0]->key, $$->type);
	$3->type = $1->key;}
	|		TYPE InitArray
	{$$=new Node("DecArray", 0);insertChildren($$, $1, $2, new Node("$", 0));
	$2->children[0]->children[0]->type = $1->key + "*";
	write_table($2->children[0]->children[0]->key, $2->children[0]->children[0]->type);
	$$->type = $2->children[0]->type;
	$2->children[0]->type = $1->key;}
	|		DecArray COMMA InitArray
	{insertChildren($$, $3,  new Node("$", 0));
	$3->children[0]->children[0]->type = $$->type;
	write_table($3->children[0]->children[0]->key, $$->type);
	$3->children[0]->type = $1->key;}
	;

 // 数组初始化
InitArray:		Array ASSIGN LBRACE InitArrayInner RBRACE
	{$$=new Node("InitArray", 0);insertChildren($$, $1, $4, new Node("$", 0));}
	;
 // 数组初始化内部
InitArrayInner:   Const
   {$$=new Node("InitArrayInner", 0);insertChildren($$, $1, new Node("$", 0));}
   |              InitArrayInner COMMA Const
   {insertChildren($$, $3,  new Node("$", 0));}
   ;
 // 声明或者表达式加上 ';'
VarOpnum:	VarInt {$$=$1;}
	|		OpnumNull {$$=$1;}   
	// for循环第一个式子为opnum的情况
	;
  // Opnum或者NULL
OpnumNull:		Opnum %prec LOWEST {$$=$1;}
	|			%prec LOWEST {$$=new Node("NULL", 0);}			
	;

 // 表达式
Expr:		Opnum PLUS Opnum	
	{$$=new Node("+", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum MINUS Opnum		
	{$$=new Node("-", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum MULTIPLY Opnum		
	{$$=new Node("*", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum DIVIDE Opnum		
	{$$=new Node("/", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum MODEL Opnum		
	{$$=new Node("%", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum POW Opnum		
	{$$=new Node("^", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum GREATER Opnum		
	{$$=new Node(">", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum GREATEREQ Opnum		
	{$$=new Node(">=", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum LESS Opnum		
	{$$=new Node("<", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum LESSEQ Opnum		
	{$$=new Node("<=", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != "int"){
		insertError(3,$1->type,"",$$->line);
		parse_error = true;
	}
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum NEQUAL Opnum		
	{$$=new Node("!=", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum EQUAL Opnum		
	{$$=new Node("==", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum ASSIGN Opnum		
	{$$=new Node("=", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = $1->type;}
	|		Opnum AND Opnum		
	{$$=new Node("&&", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = "int";}
	|		Opnum OR Opnum		
	{$$=new Node("||", 0);insertChildren($$,$1,$3,new Node("$", 0));
	if($1->type != $3->type){
		insertError(4,$1->type,$3->type,$1->line);
		parse_error = true;
	}
	$$->type = "int";}
	|		Opnum SELFPLUS
	{$$=$2;$$->key="i++";insertChildren($$,$1,new Node("$", 0));
	$$->type = $1->type;}
	|		Opnum SELFMINUS
	{$$=$2;$$->key="i--";insertChildren($$,$1,new Node("$", 0));
	$$->type = $1->type;}
	|		SELFPLUS Opnum		
	{$$=new Node("++i", 0);insertChildren($$,$2,new Node("$", 0));
	$$->type = $2->type;}
	|		SELFMINUS Opnum		
	{$$=new Node("--i", 0);insertChildren($$,$2,new Node("$", 0));
	$$->type = $2->type;}
	|		NOT Opnum		
	{$$=new Node("!", 0);insertChildren($$,$2,new Node("$", 0));
	$$->type = $2->type;}
	|		ADDR Opnum		
	{$$=new Node("&", 0);insertChildren($$,$2,new Node("$", 0));
	$$->type = $2->type + "*";}
	|		POINT Opnum		
	{$$=new Node("~", 0);insertChildren($$,$2,new Node("$", 0));
	$$->type = $2->type.substr(0, $2->type.length()-1);}
	|		LP Opnum RP %prec LOWEST
	{$$=$2;}
	;
 //操作数
Opnum:		Const	{$$=$1;}
	|		IDdec	{$$=$1;}
	|		Expr 	{$$=$1;}
	|		Array	{$$=$1;}
	;

Array:		IDdec LMB Opnum RMB 
	{$$=new Node("Array", 0);insertChildren($$, $1, $3, new Node("$", 0));
	$$->type = $1->type.substr(0, $1->type.length()-1);}
	;

 //标识符声明
IDdec:		ID
	{$$=$1;
	if(countid($$->key) != 0) {
		$$->type = table[$$->key]->type;
	}}
	;

Include:	INCLUDE
	{$$=new Node("Include ", 0);insertChildren($$, $1, new Node("$", 0));}
	;

 //常量
Const:		INTEGER		{$$=$1;$$->type = "int";}
	|		MINUS INTEGER %prec MINUSINTEGER
	{$$=$2;$$->type = "int";$$->key = "-"+$$->key;$$->val = -$$->val;}
	;


%%

int yyerror(const char* msg)
{
	printf("%s", msg);
	return 0;
}

//打印整个树的形状
void print(Node* p, int interval){
	for(int i=0;i<interval;i++)
	{
		if(i<interval-1)
		{
			cout<<"| ";
		}
		else if(i==interval-1)
		{
			cout<<"|";
		}
	}
	cout << "——▶" << p->key << "    " << p->type << endl;
	for(int i=0;i<p->children.size();i++)
	{
		print(p->children[i], interval+1);
	}
}

//新建一个节点，并且将从下方传递来的节点加入其子结点
void insertChildren(Node*par, ...){
	va_list list;
	va_start(list,par);
	Node *child;
	int count=0;
	while(1)
	{
		count++;
		child = va_arg(list, Node*);
		if(child!=NULL)
		{
			if(child->key != "$")
			{
				par->join_Children(child);
				if(child->line > par->line)
				{
					par->line = child->line;
				}
				if(child->line < par->line)
				{
					child->line = par->line;
				}
			}
			else
				break;
		}
		else
			continue;
		}
		va_end(list);
}

//处理返回语句的语法错误
void returnError(Node*t, Node*root){
	printf("\n\n");
   	printf("\t\t\t\t PHASE 2: SYNTAX ANALYSIS \n\n");
   	for (int i = 0; i < cntt; i++) {
		printf("%s",error_str[i]);
	}

	bool k = true;	// 是否需要返回值
	bool hasret = false;
	if (t->key=="VOID"){
		k = false;
	}

	Node* p;
	deque<Node*> dq;
	dq.push_back(root);
	while(!dq.empty()){
		p = dq.front();
		dq.pop_front();
		for(int i = 0; i < p->children.size(); i++)
		{
			dq.push_back(p->children[i]);
			if(!hasret && (p->children[i]->key == "Return expr statement" || p->children[i]->key == "Return statement")){
				hasret = true;
			}
			if (hasret) {
				if(p->children[i]->key == "Return expr statement" && !k) {
					// void不需要返回语句或者可以只return，所以当return expr时报错
					cout<<"return error : unexpected expr after return at line "<<p->children[i]->line<<endl;
					parse_error = true;
				}
				else if (p->children[i]->key == "Return statement" && k) {
					// type需要return expr，因此无return报错
					cout<<"return error : need expr after return at line "<<p->children[i]->line<<endl;
					parse_error = true;
				}
			}
		}
	}
	if (!hasret && k) {
		cout<<"int main() need a return statement"<<endl;
		parse_error = true;
	}
}

void insertError(int type, string arg1, string arg2, int line){
	switch (type)
	{
	case 1:
		sprintf(error_str[cntt++],"need a %s in line %d\n", arg1.c_str(), line);
		break;
	case 2:
		sprintf(error_str[cntt++],"need a %s and a %s in line %d\n", arg1.c_str(), arg2.c_str(), line);
		break;
	case 3:
		sprintf(error_str[cntt++],"type error: %s is not int in line %d\n", arg1.c_str(), line);
		break;
	case 4:
		sprintf(error_str[cntt++],"type error: %s and %s in line %d\n", arg1.c_str(), arg2.c_str(), line);
		break;
	default:
		break;
	}
}

int main()
{
	printf("\n\t\t\t\t PHASE 1: LEXICAL ANALYSIS\n\n");
	printf("\nSYMBOL\t\tDATATYPE\tTYPE\t\tLINE NUMBER \n");
	yyparse();
	if(!parse_error)
	{
		gen_code(root);
		printf("\n\n");
		printf("\t\t\t\t PHASE 3: INTERMEDIATE CODE GENERATION \n\n");
		print_address();
		printf("\n");
		write_asm();
	}
	else {
		cout<<"parse_error"<<endl;
	}
}

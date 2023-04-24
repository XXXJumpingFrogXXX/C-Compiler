#include<iostream>
#include<vector>
#include<string.h>
#include<map>
using namespace std;

struct address3 {
    string op;
    Node* res, *arg1, *arg2;
    int jumpto = -1;
};
int countn = 0;
vector<address3*> address_table;

void gen_code_InitInt(Node* p) {
    address3* temp_n = new address3();
    temp_n->op = "=";
    temp_n->res = p->children[0];
    temp_n->arg1 = p->children[1];
    address_table.push_back(temp_n);
}

void gen_code_Array(Node* p) {
    p->key = "variate" + to_string(countn++);
    address3* temp_n = new address3();
    temp_n->op = "[]";
    temp_n->res = p;
    temp_n->arg1 = p->children[0];
    temp_n->arg2 = p->children[1];
    p->istemp = true;
    address_table.push_back(temp_n);
}

void gen_code_one(Node* p, string op, bool val) {
    address3* temp_n = new address3();
    temp_n->op = op;
    temp_n->res = p;
    p->key = "variate" + to_string(countn++);
    p->istemp = true;
    if (val)
        temp_n->arg2 = p->children[0];
    else 
        temp_n->arg1 = p->children[0];
    address_table.push_back(temp_n);
}

void gen_code_two(Node* p, string op) {
    address3* temp_n = new address3();
    temp_n->op = op;
    temp_n->res = p;
    p->key = "variate" + to_string(countn++);
    p->istemp = true;
    temp_n->arg1 = p->children[0];
    temp_n->arg2 = p->children[1];
    address_table.push_back(temp_n);
}

void gen_code_Assign(Node* p, string key){
    address3* temp_n = new address3();
    temp_n->op = key + "=";
    temp_n->res = p->children[0]->children[0];
    temp_n->arg1 = p->children[1];
    address_table.push_back(temp_n);
}

//判断一个结点是否为数字常量
bool is_num(Node* p) {
    return p->val != 0 || p->key == "0";
}

bool compute(Node* p, string oper) {
    if(is_num(p->children[0]) && is_num(p->children[1])) {
        if (oper == "+")
            p->val = p->children[0]->val + p->children[1]->val;
        else if (oper == "-")
            p->val = p->children[0]->val - p->children[1]->val;
        else if (oper == "*")
            p->val = p->children[0]->val * p->children[1]->val;
        else if (oper == "/")
            p->val = p->children[0]->val / p->children[1]->val;
        else if (oper == "%")
            p->val = p->children[0]->val % p->children[1]->val;
        else if (oper == "&&")
            p->val = p->children[0]->val && p->children[1]->val;
        else if (oper == "||")
            p->val = p->children[0]->val || p->children[1]->val;
        else if (oper == "^")
            p->val = (int)pow(p->children[0]->val, p->children[1]->val);
        else if (oper == ">")
            p->val = (p->children[0]->val > p->children[1]->val)?1:0;
        else if (oper == "<")
            p->val = (p->children[0]->val < p->children[1]->val)?1:0;
        else if (oper == ">=")
            p->val = (p->children[0]->val >= p->children[1]->val)?1:0;
        else if (oper == "<=")
            p->val = (p->children[0]->val <= p->children[1]->val)?1:0;
        else if (oper == "!=")
            p->val = (p->children[0]->val != p->children[1]->val)?1:0;
        else if (oper == "==")
            p->val = (p->children[0]->val == p->children[1]->val)?1:0;
        
        p->key = to_string(p->val);
        return false;
    }
    return true;
}

void gen_code_rw(Node* p, string oper){
    address3* temp_n = new address3();
    temp_n->op = oper;
    temp_n->arg1 = p->children[0];
    address_table.push_back(temp_n);
}

void gen_code(Node* p) {
    vector<Node*> c_node = p->children;
    string key = p->key;
    if(key == "InitInt") {
        gen_code(c_node[1]);
        gen_code_InitInt(p);
    }
    else if(key == "DecArray") {
        table_node* node = table[c_node[1]->children[0]->key];
        node->length = c_node[1]->children[1]->val;
        node->array = new int[node->length];
        for(int i=0;i<node->length;i++) {
            node->array[i] = 0;
        }
    }
    else if(key == "InitArray") {
        table_node* node = table[c_node[0]->children[0]->key];
        node->length = c_node[0]->children[1]->val;
        node->array = new int[node->length];
        for(int i=0;i<node->length;i++) {
            if(c_node[1]->children[i])
                node->array[i] = c_node[1]->children[i]->val;
            else
                node->array[i] = 0;
        }
    }
    else if(key == "Array") {
        if(is_num(c_node[1])) {
            table[c_node[0]->key]->length = (table[c_node[0]->key]->length == 0)?c_node[1]->val:table[c_node[0]->key]->length;
        }
        gen_code(c_node[1]);
        gen_code_Array(p);
    }
    else if(key == "Forloop") {
        gen_code(c_node[0]->children[0]);
        int begin = address_table.size();
        
        gen_code(c_node[0]->children[1]);
        address3* position_T = new address3();
        position_T->op = "!=";
        position_T->arg1 = c_node[0]->children[1];
        position_T->arg2 = new Node("0", 0);
        position_T->jumpto = address_table.size() + 2;
        address_table.push_back(position_T);

        address3* position_F = new address3();
        address_table.push_back(position_F);

        gen_code(c_node[1]);
        gen_code(c_node[0]->children[2]);

        address3* goto_begin = new address3();
        address_table.push_back(goto_begin);
        goto_begin->jumpto = begin;
        position_F->jumpto = address_table.size();
    }
    else if(key == "Ifbody") {
        gen_code(c_node[0]);
        address3* position_T = new address3();
        position_T->op = "!=";
        position_T->arg1 = c_node[0];
        position_T->arg2 = new Node("0", 0);
        position_T->jumpto = address_table.size() + 2;
        address_table.push_back(position_T);

        address3* position_F = new address3();
        address_table.push_back(position_F);
        gen_code(c_node[1]);
        position_F->jumpto = address_table.size();
    }
    else if(key == "Elsebody") {
        gen_code(c_node[0]);
        address3* position_T = new address3();
        position_T->op = "!=";
        position_T->arg1 = c_node[0];
        position_T->arg2 = new Node("0", 0);
        position_T->jumpto = address_table.size() + 2;
        address_table.push_back(position_T);
        address3* position_F = new address3();
        address_table.push_back(position_F);
        
        gen_code(c_node[1]);
        address3* next = new address3();
        address_table.push_back(next);
        position_F->jumpto = address_table.size();

        gen_code(c_node[2]);
        next->jumpto = address_table.size();
    }
    else if(key == "Whileloop") {
        int begin = address_table.size();
        gen_code(c_node[0]);
        address3* position_T = new address3();
        position_T->op = "!=";
        position_T->arg1 = c_node[0];
        position_T->arg2 = new Node("0", 0);
        position_T->jumpto = address_table.size() + 2;
        address_table.push_back(position_T);

        address3* position_F = new address3();
        address_table.push_back(position_F);

        gen_code(c_node[1]);
        address3* goto_begin = new address3();
        address_table.push_back(goto_begin);
        goto_begin->jumpto = begin;
        position_F->jumpto = address_table.size();
    }
    else if(key == "=") {
        if(c_node[0]->key == "Array") {
            table_node* node = table[p->children[0]->children[0]->key];
            node->array[c_node[0]->children[1]->val] = c_node[1]->val;
       }
        else if(c_node[0]->key == "~" || c_node[0]->key == "&") {
            gen_code(c_node[1]);
            gen_code_Assign(p,c_node[0]->key);
        }
        else if(countid(c_node[0]->key)){
            gen_code(c_node[1]);
            gen_code_InitInt(p);
        }
        else{
            cout<<c_node[0]->key<<"未声明的变量"<<endl;
        }
    }
    else if(key == "+" || key == "-" || key == "*" || key == "/" || key == "%" || key == "^" || key == ">" || key == "<" ||
     key == "&&" || key == "||" || key == "<=" || key == ">=" || key == "!=" || key == "==") {
        if (compute(p, key)) {
            gen_code(p->children[0]);
            gen_code(p->children[1]);
            if(compute(p, key)) {
                gen_code_two(p, key);
            }
        }
    }
    else if(key == "!") {
        if(is_num(c_node[0])) {
            p->val = (c_node[0]->val == 0)?1:0;
            p->key = to_string(p->val);
        }
        else {
            gen_code(c_node[0]);
            gen_code_one(p, "!", false);
        }
    }
    else if(key == "~" || key == "&") {
        gen_code(c_node[0]);
        gen_code_one(p, key, false);
    }
    else if(key == "i++") {
        gen_code(c_node[0]);
        gen_code_one(p, "++", false);
    }
    else if(key == "++i") {
        gen_code(c_node[0]);
        gen_code_one(p, "++", true);
    }
    else if(key == "i--") {
        gen_code(c_node[0]);
        gen_code_one(p, "--", false);
    }
    else if(key == "--i") {
        gen_code(c_node[0]);
        gen_code_one(p, "--", true);
    }
    else if(key == "Outputk") {
        gen_code(c_node[0]);
        gen_code_rw(p,"printf");
    }
    else if(key == "Inputk") {
        gen_code(c_node[0]);
        gen_code_rw(p,"scanf");
    }
    else {
        for(int i=0; i<c_node.size(); i++) {
            gen_code(c_node[i]);
        }
    }
}

void print_address(){
    for(int i = 0; i < address_table.size(); i++) {
        cout<<i<<": "<<address_table[i]->op<<"\t ";
        if(address_table[i]->res){
            cout<<address_table[i]->res->key<<"\t ";
        }
		if(address_table[i]->arg1){
            cout<<address_table[i]->arg1->key<<"\t ";
        }
        if(address_table[i]->arg2){
            cout<<address_table[i]->arg2->key<<"\t ";
        }
        if(address_table[i]->jumpto != -1){
            cout<<address_table[i]->jumpto<<"\t ";
        }
		cout<<endl;
    }
}

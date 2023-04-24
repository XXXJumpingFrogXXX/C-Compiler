void write_asm() {
    ofstream f;
    f.open("target.asm", ios::out);
    f<<"extern printf"<<endl;
    f<<"extern exit"<<endl;

    f<<"section .data"<<endl;
    for(int i=0; i<symbol_table.size(); i++) {
        if(table[symbol_table[i]]->length == 0) {
            f<<"\t"<<symbol_table[i]<<": resb 8"<<endl;
        }
    }
    for(int i=0; i<address_table.size(); i++) {
        if(address_table[i]->res && address_table[i]->res->istemp) {
            f<<"\t"<<address_table[i]->res->key<<": resb 8"<<endl;
        }
    }

    f<<"\tformat db \"%d\", 0ah, 0"<<endl;
    for(int i=0; i<symbol_table.size(); i++) {
        table_node* node = table[symbol_table[i]];
        if(node->length > 0) {
            f<<"\t"<<symbol_table[i]<<"_ dd ";
            for(int j=0;j<node->length;j++) {
                f<<node->array[j]<<", ";
            }
            f<<"0\n\t"<<symbol_table[i]<<" dd "<<symbol_table[i]<<"_, 0"<<endl;
        }
    }

    //代码部分
    f<<endl<<"section .text"<<endl;
    f<<"\tglobal main"<<endl;
    f<<"main:"<<endl;
    for(int i=0; i<address_table.size(); i++) {
        string num = to_string(i);
        string label = "label" + num;
        f<<label<<":"<<endl;
        string arg1 = "", arg2 = "", res = "";
        if(address_table[i]->arg1){
            if(((address_table[i]->arg1->key[0]>='0' && address_table[i]->arg1->key[0]<='9') || (address_table[i]->arg1->key[0] == '-'))) {
                arg1 = address_table[i]->arg1->key;
            }
            else {
                arg1 = "dword [" + address_table[i]->arg1->key + "]";
            }
        }
        if(address_table[i]->arg2){
            if(((address_table[i]->arg2->key[0]>='0' && address_table[i]->arg2->key[0]<='9') || (address_table[i]->arg2->key[0] == '-'))) {
                arg2 = address_table[i]->arg2->key;
            }
            else {
                arg2 = "dword [" + address_table[i]->arg2->key + "]";
            }
        }
        if(address_table[i]->res){
            res = "dword [" + address_table[i]->res->key + "]";
        }
        //有操作运算的且没有跳转指令
        if(address_table[i]->op != "" && address_table[i]->jumpto == -1) {
            if((address_table[i]->op == "[]")) {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tmov ebx, "<<arg2<<endl;
                f<<"\tmov ebx, [ eax + 4 * ebx]"<<endl;
                f<<"\tmov "<<res<<", ebx"<<endl;
            }
            //指针
            else if((address_table[i]->op == "~=")) {
                f<<"\tmov eax, "<<address_table[i]->res->key<<endl;
                f<<"\tmov eax, [eax]"<<endl;
                f<<"\tmov ebx, "<<arg1<<endl;
                f<<"\tmov "<<"dword [eax]"<<", ebx"<<endl;
            }
            else if((address_table[i]->op == "&=")) {
                f<<"\tmov eax, "<<address_table[i]->arg1->key<<endl;
                f<<"\tmov ebx, "<<arg1<<endl;
                f<<"\tmov "<<res<<", ebx"<<endl;
            }
            else if(address_table[i]->op == "+") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tadd eax, "<<arg2<<endl;
                f<<"\tmov "<<res<<", eax"<<endl<<endl;
            }
            else if(address_table[i]->op == "-") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tsub eax, "<<arg2<<endl;
                f<<"\tmov  "<<res<<", eax"<<endl<<endl;
            }

            else if(address_table[i]->op == "*") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tmov ebx, "<<arg2<<endl;
                f<<"\txor  edx,edx"<<endl;
                f<<"\timul ebx"<<endl;
                f<<"\tmov "<<res<<", eax"<<endl<<endl;
            }

            else if(address_table[i]->op == "/") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tmov ebx, "<<arg2<<endl;
                f<<"\txor  edx,edx"<<endl;
                f<<"\tdiv ebx"<<endl;
                f<<"\tmov "<<res<<", eax"<<endl<<endl;
            }

            else if(address_table[i]->op == "%") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tmov ebx, "<<arg2<<endl;
                f<<"\txor  edx,edx"<<endl;
                f<<"\tdiv ebx"<<endl;
                f<<"\tmov "<<res<<", edx"<<endl<<endl;
            }

            else if(address_table[i]->op == "^") {
                f<<"\tmov eax, 0"<<endl;
                f<<"\tmov ebx, 1"<<endl;
                f<<"\t"<<label<<"_0:"<<endl;
                f<<"\tcmp eax, "<<arg2<<endl;
                f<<"\tjl "<<label<<"_1"<<endl;
                f<<"\tjmp "<<label<<"_2"<<endl;
                f<<"\t"<<label<<"_1:"<<endl;
                f<<"\timul ebx, "<<arg1<<endl;
                f<<"\tadd eax, 1"<<endl;
                f<<"\tjmp "<<label<<"_0"<<endl;
                f<<"\t"<<label<<"_2:"<<endl;
                f<<"\tmov "<<res<<", ebx"<<endl<<endl;
            }


            else if(address_table[i]->op == "!") {
                string label1 = label + "_1";
                string label2 = label + "_2";
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tcmp eax, 0"<<endl;
                f<<"\tje "<<label1<<endl;
                f<<"\tmov "<<res<<", 0"<<endl;
                f<<"\tjmp "<<label2<<endl;
                f<<label1<<":"<<endl;
                f<<"mov "<<res<<", 1"<<endl;
                f<<label2<<":"<<endl;
            }
            else if(address_table[i]->op == "&") {
                f<<"\tmov eax, "<<address_table[i]->arg1->key<<endl;
                f<<"\tmov "<<res<<", eax"<<endl;
            }

            else if(address_table[i]->op == "~") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tmov ebx, [eax]"<<endl;
                f<<"\tmov "<<res<<", ebx"<<endl;
            }

            else if(address_table[i]->op == "=") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tmov "<<res<<", eax"<<endl<<endl;
            }

            else if(address_table[i]->op == "++") {
                if(address_table[i]->arg1) {
                    f<<"\tmov eax, "<<arg1<<endl;
                    f<<"\tmov "<<res<<", eax"<<endl;
                    f<<"\tinc "<<arg1<<endl;
                }
                else {
                    f<<"\t;++i"<<endl;
                    f<<"\tinc "<<arg2<<endl;
                    f<<"\tmov eax, "<<arg2<<endl;
                    f<<"\tmov "<<res<<", eax"<<endl;
                }
            }

            else if(address_table[i]->op == "--") {
                if(address_table[i]->arg1) {
                    f<<"\tmov eax, "<<arg1<<endl;
                    f<<"\tmov "<<res<<", eax"<<endl;
                    f<<"\tdec "<<arg1<<endl;
                }
                else {
                    f<<"\tdec "<<arg2<<endl;
                    f<<"\tmov eax, "<<arg2<<endl;
                    f<<"\tmov "<<res<<", eax"<<endl;
                }
            }

            else if(address_table[i]->op == "&&") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tand eax, "<<arg2<<endl;
                f<<"\tmov "<<res<<", eax"<<endl<<endl;
            }

            else if(address_table[i]->op == "||") {
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tor eax, "<<arg2<<endl;
                f<<"\tmov "<<res<<", eax"<<endl<<endl;
            }

            else if(address_table[i]->op == ">") {
                string label1 = label + "_1";
                string label2 = label + "_2";
	            f<<"\tmov "<<res<<", 0"<<endl;
	            f<<"\tmov eax, "<<arg1<<endl;
	            f<<"\tcmp eax, "<<arg2<<endl;
	            f<<"\tjg "<<label1<<endl;
                f<<"\tjmp "<<label2<<endl;
                f<<label1<<":"<<endl;
                f<<"\tmov "<<res<<", 1"<<endl;
	            f<<label2<<":"<<endl;
            }

            else if(address_table[i]->op == ">=") {
                string label1 = label + "_1";
                string label2 = label + "_2";
                f<<"\tmov "<<res<<", 0"<<endl;
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tcmp eax, "<<arg2<<endl;
                f<<"\tjge "<<label1<<endl;
                f<<"\tjmp "<<label2<<endl;
                f<<label1<<":"<<endl;
                f<<"\tmov "<<res<<", 1"<<endl;
                f<<label2<<":"<<endl;
            }

            else if(address_table[i]->op == "<") {
                string label1 = label + "_1";
                string label2 = label + "_2";
                f<<"\tmov "<<res<<", 0"<<endl;
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tcmp eax, "<<arg2<<endl;
                f<<"\tjl "<<label1<<endl;
                f<<"\tjmp "<<label2<<endl;
                f<<label1<<":"<<endl;
                f<<"\tmov "<<res<<", 1"<<endl;
                f<<label2<<":"<<endl;
            }
            else if(address_table[i]->op == "<=") {
                string label1 = label + "_1";
                string label2 = label + "_2";
	            f<<"\tmov "<<res<<", 0"<<endl;
	            f<<"\tmov eax, "<<arg1<<endl;
	            f<<"\tcmp eax, "<<arg2<<endl;
	            f<<"\tjle "<<label1<<endl;
                f<<"\tjmp "<<label2<<endl;
                f<<label1<<":"<<endl;
                f<<"\tmov "<<res<<", 1"<<endl;
	            f<<label2<<":"<<endl;
            }
            else if(address_table[i]->op == "==") {
                string label1 = label + "_1";
                string label2 = label + "_2";
	            f<<"\tmov "<<res<<", 0"<<endl;
	            f<<"\tmov eax, "<<arg1<<endl;
	            f<<"\tcmp eax, "<<arg2<<endl;
	            f<<"\tje "<<label1<<endl;
                f<<"\tjmp "<<label2<<endl;
                f<<label1<<":"<<endl;
                f<<"\tmov "<<res<<", 1"<<endl;
	            f<<label2<<":"<<endl;
            }

            else if(address_table[i]->op == "!=") {
                string label1 = label + "_1";
                string label2 = label + "_2";
	            f<<"\tmov "<<res<<", 0"<<endl;
	            f<<"\tmov eax, "<<arg1<<endl;
	            f<<"\tcmp eax, "<<arg2<<endl;
	            f<<"\tjne "<<label1<<endl;
                f<<"\tjmp "<<label2<<endl;
                f<<label1<<":"<<endl;
                f<<"\tmov "<<res<<", 1"<<endl;
	            f<<label2<<":"<<endl;
            }

            else if(address_table[i]->op == "printf") {
                f<<"\tpush "<<arg1<<endl;
                f<<"\tpush format"<<endl;
                f<<"\tcall printf"<<endl;
            }
            else if(address_table[i]->op == "scanf") {
                f<<"\tpush "<<address_table[i]->arg1->key<<endl;
                f<<"\tpush scanf_format"<<endl;
                f<<"\tcall scanf"<<endl;
            }
        }
        //跳转语句
        else if(address_table[i]->jumpto != -1)  {
            if(address_table[i]->op == "!="){
                string label1 = "label" + to_string(address_table[i]->jumpto);
                f<<"\tmov eax, "<<arg1<<endl;
                f<<"\tcmp eax, "<<arg2<<endl;
                f<<"\tjne "<<label1<<endl;
            }
            else if(address_table[i]->op == "") {
                string label1 = "label" + to_string(address_table[i]->jumpto);
                f<<"\tjmp "<<label1<<endl;
            }
        }
    }
    string num = to_string(address_table.size());
    f<<"label"<<num<<":"<<endl;
    f<<endl<<"\tpush 0"<<endl;
    f<<"\tcall exit"<<endl;
}

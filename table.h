struct table_node {
    string type;
    int* array;
    int length=0;
};
vector<string> symbol_table;
map<string, table_node*> table;
void write_table(string id, string type) {
    table_node* node = new table_node();
    node->type = type;
    table.insert(pair<string, table_node*>(id,node));
    symbol_table.push_back(id);
}
int countid(string id) {
	return table.count(id);
}

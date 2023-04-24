#include<iostream>
#include<vector>
#include<stdio.h>
#include<cstdlib>
#include<iomanip>
#include<string>
#include<string.h>
#include<map>
#include<math.h>
#include<stdarg.h>
#include<deque>
#include<fstream>
using namespace std;

class Node {
    public:
        string key;
        int val;
        int line = 0;
        string type = "";
        bool istemp;
        vector<Node*>children;
        Node(string key, int val) {
            this->val = val;
            this->key = key;
            istemp = false;
        }
        Node(string key, int val, int line) {
            this->val = val;
            this->key = key;
            this->line = line;
            istemp = false;
        }        
        void join_Children(Node* c) {
            this->children.push_back(c);
        }
};

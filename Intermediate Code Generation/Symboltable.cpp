#ifndef SYMBOL_TABLE
#define SYMBOL_TABLE


#include<iostream>
#include<string>
#include<bits/stdc++.h>

using namespace std;

class SymbolInfo
{
private:
    string symbol;
    string name;
    string type;
    string type_speci;
    string fun_status;
    SymbolInfo *next;

    int array_size;
    string cur_arr_idx;
    string return_type;
    vector<string> func_parameter_list;

    string code;
public:
    SymbolInfo()
    {
    }
    SymbolInfo(string name, string type)
    {
        this->name=name;
        this->type=type;
        this->next=NULL;
        array_size=-1;
        cur_arr_idx=-1;
        return_type="None";
        type_speci="None";
        fun_status="None";
        code = "";
        symbol = "None";

    }
    void add_code(string s){this->code = this->code + s;}
    void set_code(string s){this->code = s;}
    string get_symbol(){return this->symbol;}
    void set_symbol(string s){this->symbol = s;}

    string get_code(){return code;}

    void push_func_parameter(string s){func_parameter_list.push_back(s);}
    string get_func_parameter(int i){
        if(i>=func_parameter_list.size()) return "None";
        else return func_parameter_list[i];
    }
    int get_parameter_size(){return func_parameter_list.size();}
    void set_array_size(int n){this->array_size=n;}
    int get_array_size(){return this->array_size;}
    string get_return_type(){return this->return_type;}
    void set_return_type(string type){this->return_type=type;}
    string get_type_speci(){return type_speci;}
    void set_type_speci(string s){this->type_speci=s;}
    void set_cur_arr_idx(string x){this->cur_arr_idx=x;}
    string get_cur_arr_idx(){return cur_arr_idx;}
    void set_fun_status(string status){this->fun_status=status;}
    string get_fun_status(){return this->fun_status;}

    string get_name(){return name;}
    void set_name(string name){this->name=name;}
    string get_type(){return type;}
    void set_type(string type){this->type=type;}
    SymbolInfo* get_next(){return this->next;}
    void set_next(SymbolInfo* s){this->next=s;}
    ~SymbolInfo()
    {
        delete next;
    }
};

class ScopeTable
{
private:
    SymbolInfo** arr_symbol;
    ScopeTable* parentScope;
    int total_buckets;
    string id;
    int child_scope_no;
    FILE* logfile;
public:
    ScopeTable(int n, ScopeTable* parentScope, FILE* logfile)
    {
        this->total_buckets=n;
        this->logfile=logfile;
        arr_symbol=new SymbolInfo*[n];
        for(int i=0; i<n; i++)
        {
            arr_symbol[i]=new SymbolInfo;
            arr_symbol[i]=NULL;
        }
        child_scope_no=0;

        this->set_parent(parentScope);
        if(parentScope)
        {
            parentScope->set_child_scope_no(parentScope->get_child_scope_no()+1);
            id=parentScope->get_id() + "." + to_string(parentScope->get_child_scope_no());
            //cout<<"New ScopeTable with id "+id+" created"<<endl<<endl;
            //outputToFile("New ScopeTable with id "+id+" created\n\n", logfile);
        }

    }
    string get_id(){return id;}
    void set_id(string id){this->id=id;}
    ScopeTable* get_parent(){return parentScope;}
    void set_parent(ScopeTable* parentScope)
    {
        this->parentScope=parentScope;
    }
    int get_child_scope_no(){return child_scope_no;}
    void set_child_scope_no(int child_scope_no){this->child_scope_no=child_scope_no;}
    int my_hash(string name)
    {
        int len=name.length();
        int ascii=0;
        char arr_ch[len+1];
        strcpy(arr_ch, name.c_str());
        for(int i=0; i<len; i++)
        {
            ascii+=arr_ch[i];
        }
        return ascii%total_buckets;
    }
    bool insert_symbol(string name, string type)
    {
        SymbolInfo* new_symbolinfo=new SymbolInfo(name, type);
        int position=my_hash(name);
        int counter=0;
        if(arr_symbol[position]==NULL)
        {
            arr_symbol[position]=new_symbolinfo;
            //cout<<"Inserted in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)<<endl<<endl;
            //outputToFile("Inserted in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)+"\n\n");
            return true;
        }

        SymbolInfo* s=arr_symbol[position];
        SymbolInfo* prev_s=NULL;
        while(s)
        {
            if(s->get_name()==name)
            {
                //cout<<"<"+name+" "+type+">"+" already exists in current ScopeTable"<<endl<<endl;
                //outputToFile(name+" already exists in current ScopeTable\n\n");
                return false;
            }
            counter++;
            prev_s=s;
            s=s->get_next();
        }
        //cout<<"Inserted in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)<<endl<<endl;
        //outputToFile("Inserted in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)+"\n\n");
        prev_s->set_next(new_symbolinfo);
        return true;
    }

    SymbolInfo* look_up(string name)
    {
        int position=my_hash(name);
        int counter=0;
        SymbolInfo* s=arr_symbol[position];
        while(s)
        {
            if(s->get_name()==name)
            {
                //cout<<"Found in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)<<endl<<endl;
                //outputToFile("Found in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)+"\n\n");
                return s;

            }
            counter++;
            s=s->get_next();
        }
        return NULL;
    }

    bool delete_symbol(string name)
    {
        int position=my_hash(name);
        int counter=0;
        SymbolInfo* prev_s=NULL;
        SymbolInfo* s=arr_symbol[position];
        while(s)
        {
            if(s->get_name()==name)
            {

                if(prev_s)
                {
                    prev_s->set_next(s->get_next());
                }
                else arr_symbol[position]=s->get_next();

                //cout<<"Found in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)<<endl<<endl;
                //outputToFile("Found in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)+"\n\n");
                //cout<<"Deleted Entry "+to_string(position)+", "+to_string(counter)+" from current ScopeTable"<<endl<<endl;
                //outputToFile("Deleted Entry "+to_string(position)+", "+to_string(counter)+" from current ScopeTable\n\n");
                return true;

            }
            else
            {
                prev_s=s;
                s=s->get_next();
                counter++;
            }
        }
        //cout<<"Not found"<<endl<<endl<<name+" not found"<<endl<<endl;
        //outputToFile("Not found\n\n"+name+" not found\n\n");
        return false;

    }
    inline bool fileExist(const std::string& name)
    {
    ifstream file(name);
    if(!file)
        return false;
    else
        return true;
    }
    void outputToFile(string s, FILE* outfile)
    {
        fprintf(outfile, s.c_str());
    }


    void print(FILE *outfile)
    {
        //outfile << "ScopeTable # " + this->id+"\n";
        //cout<<endl<<"ScopeTable # " + this->id<<endl;
        outputToFile("\nScopeTable # " + this->id+"\n", outfile);
        for(int i=0; i<total_buckets; i++)
        {
            SymbolInfo* s=arr_symbol[i];
            //outfile<<" "+to_string(i)+" --> ";
            //cout<<to_string(i)+" -->";
            if(s) outputToFile(" "+to_string(i)+" --> ", outfile);
            while(s)
            {
                //cout<<" < "+s->get_name()+" : "+s->get_type()+">";
                outputToFile("< "+s->get_name()+" , "+s->get_type()+" > ", outfile);
                //outfile<<"< "+s->get_name()+" : "+s->get_type()+"> ";
                s=s->get_next();
                if(!s) outputToFile("\n", outfile);
                //if(!s) outfile<<"\n";
            }
            //cout<<endl;

        }
        //cout<<endl;
        outputToFile("\n", outfile);
        //outfile<<"\n";
    }
    ~ScopeTable()
    {
        for (int i = 0; i < total_buckets; i++)
        {
            delete arr_symbol[i];
        }
        delete[] arr_symbol;
        delete parentScope;
    }



};

class SymbolTable
{
private:
    ScopeTable* current_scope;
    int total_buckets;
    FILE* logfile;
public:
    SymbolTable(int total_buckets, FILE *logfile)
    {
        current_scope=new ScopeTable(total_buckets, NULL, logfile);
        current_scope->set_id("1");
        this->total_buckets=total_buckets;
        this->logfile=logfile;

    }
    void enter_scope()
    {
        ScopeTable *new_scope=new ScopeTable(total_buckets, current_scope, logfile);
        current_scope=new_scope;
    }

    inline bool fileExist(const std::string& name)
    {
    ifstream file(name);
    if(!file)
        return false;
    else
        return true;
    }
    void outputToFile(string s, FILE* outfile)
    {
        fprintf(outfile, s.c_str());
    }
    void exit_scope()
    {
        //cout<<"ScopeTable with id "+current_scope->get_id()+" removed"<<endl<<endl;
        //outputToFile("ScopeTable with id "+current_scope->get_id()+" removed\n\n", logfile);
        ScopeTable* temp=current_scope;
        current_scope=current_scope->get_parent();
        temp->set_parent(NULL);
        delete temp;
    }
    bool insert_symbol(string name, string type)
    {
        return current_scope->insert_symbol(name, type);
    }
    bool remove_symbol(string name)
    {
        return current_scope->delete_symbol(name);
    }
    SymbolInfo* look_up(string name)
    {
        if(name.empty()) return NULL;
        ScopeTable *s=current_scope;
        while(s)
        {
            SymbolInfo* temp=s->look_up(name);
            if(temp) return temp;
            s=s->get_parent();

        }
        //cout<<"Not found"<<endl<<endl;
        //outputToFile("Not found\n\n");
        return NULL;
    }
    SymbolInfo* look_up_curr(string name)
    {
        if(name.empty()) return NULL;
        ScopeTable *s=current_scope;

        SymbolInfo* temp=s->look_up(name);
        if(temp) return temp;



        //cout<<"Not found"<<endl<<endl;
        //outputToFile("Not found\n\n");
        return NULL;
    }
    void print_current_scope()
    {
        current_scope->print(logfile);
    }
    void print_all_scope()
    {
        ScopeTable *s=current_scope;
        while(s)
        {
            s->print(logfile);
            s=s->get_parent();
            outputToFile("\n", logfile);

        }
    }
    ~SymbolTable()
    {
        delete current_scope;
    }
};






//int main()
//{
//    inputFromFile("input.txt");
//
//    return 0;
//}
#endif // SYMBOL_TABLE

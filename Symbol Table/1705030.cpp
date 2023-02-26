#include<iostream>
#include<string>
#include<bits/stdc++.h>

using namespace std;
inline bool fileExist(const std::string& name)
{
    ifstream file(name);
    if(!file)
        return false;
    else
        return true;
}
void outputToFile(string s, string outputFilename="my_output.txt")
{
    ofstream outfile;

    if(!fileExist(outputFilename))
    {
        outfile.open(outputFilename);
        outfile << s;
    }
    else{
        outfile.open(outputFilename, std::ios_base::app);
        outfile << s;
    }
}


class SymbolInfo
{
private:
    string name;
    string type;
    SymbolInfo *next;
public:
    SymbolInfo()
    {
    }
    SymbolInfo(string name, string type)
    {
        this->name=name;
        this->type=type;
        this->next=NULL;

    }
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
public:
    ScopeTable(int n, ScopeTable* parentScope)
    {
        this->total_buckets=n;
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
            cout<<"New ScopeTable with id "+id+" created"<<endl<<endl;
            outputToFile("New ScopeTable with id "+id+" created\n\n");
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
            cout<<"Inserted in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)<<endl<<endl;
            outputToFile("Inserted in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)+"\n\n");
            return true;
        }

        SymbolInfo* s=arr_symbol[position];
        SymbolInfo* prev_s=NULL;
        while(s)
        {
            if(s->get_name()==name)
            {
                cout<<"<"+name+" "+type+">"+" already exists in current ScopeTable"<<endl<<endl;
                outputToFile("<"+name+" "+type+">"+" already exists in current ScopeTable\n\n");
                return false;
            }
            counter++;
            prev_s=s;
            s=s->get_next();
        }
        cout<<"Inserted in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)<<endl<<endl;
        outputToFile("Inserted in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)+"\n\n");
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
                cout<<"Found in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)<<endl<<endl;
                outputToFile("Found in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)+"\n\n");
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

                cout<<"Found in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)<<endl<<endl;
                outputToFile("Found in ScopeTable# "+id+" at position "+to_string(position)+", "+to_string(counter)+"\n\n");
                cout<<"Deleted Entry "+to_string(position)+", "+to_string(counter)+" from current ScopeTable"<<endl<<endl;
                outputToFile("Deleted Entry "+to_string(position)+", "+to_string(counter)+" from current ScopeTable\n\n");
                return true;

            }
            else
            {
                prev_s=s;
                s=s->get_next();
                counter++;
            }
        }
        cout<<"Not found"<<endl<<endl<<name+" not found"<<endl<<endl;
        outputToFile("Not found\n\n"+name+" not found\n\n");
        return false;

    }
    void print()
    {
        cout<<endl<<"ScopeTable # " + this->id<<endl;
        outputToFile("\nScopeTable # " + this->id+"\n");
        for(int i=0; i<total_buckets; i++)
        {
            SymbolInfo* s=arr_symbol[i];
            cout<<to_string(i)+" --> ";
            outputToFile(to_string(i)+" --> ");
            while(s)
            {
                cout<<" < "+s->get_name()+" : "+s->get_type()+">";
                outputToFile(" < "+s->get_name()+" : "+s->get_type()+">");
                s=s->get_next();
            }
            cout<<endl;
            outputToFile("\n");
        }
        cout<<endl;
        outputToFile("\n");
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
public:
    SymbolTable(int total_buckets)
    {
        current_scope=new ScopeTable(total_buckets, NULL);
        current_scope->set_id("1");
        this->total_buckets=total_buckets;

    }
    void enter_scope()
    {
        ScopeTable *new_scope=new ScopeTable(total_buckets, current_scope);
        current_scope=new_scope;
    }

    void exit_scope()
    {
        cout<<"ScopeTable with id "+current_scope->get_id()+" removed"<<endl<<endl;
        outputToFile("ScopeTable with id "+current_scope->get_id()+" removed\n\n");
        current_scope=current_scope->get_parent();
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
        ScopeTable *s=current_scope;
        while(s)
        {
            SymbolInfo* temp=s->look_up(name);
            if(temp) return temp;
            s=s->get_parent();

        }
        cout<<"Not found"<<endl<<endl;
        outputToFile("Not found\n\n");
        return NULL;
    }
    void print_current_scope()
    {
        current_scope->print();
    }
    void print_all_scope()
    {
        ScopeTable *s=current_scope;
        while(s)
        {
            s->print();
            s=s->get_parent();
        }
    }
    ~SymbolTable()
    {
        delete current_scope;
    }
};



void inputFromFile(string filename)
{
    int n;
    if(!fileExist(filename)) cout<<"Input File not found!"<<endl;
    ifstream is(filename);

    is>>n;
    SymbolTable st(n);
    string x, name, type, mode;

    while (is >> x)
    {
        if(x=="I")
        {
            is>>name>>type;
            cout<<x+" "+name+" "+type<<endl<<endl;
            outputToFile(x+" "+name+" "+type+"\n\n");
            st.insert_symbol(name, type);

        }
        else if(x=="L")
        {
            is>>name;
            cout<<x+" "+name<<endl<<endl;
            outputToFile(x+" "+name+"\n\n");
            st.look_up(name);

        }
        else if(x=="D")
        {
            is>>name;
            cout<<x+" "+name<<endl<<endl;
            outputToFile(x+" "+name+"\n\n");
            st.remove_symbol(name);

        }
        else if(x=="P")
        {
            is>>mode;
            cout<<x+" "+mode<<endl<<endl;
            outputToFile(x+" "+mode+"\n\n");
            if(mode=="C") st.print_current_scope();
            else st.print_all_scope();

        }
        else if(x=="S")
        {
            cout<<x<<endl<<endl;
            outputToFile(x+"\n\n");
            st.enter_scope();

        }
        else if(x=="E")
        {
            cout<<x<<endl<<endl;
            outputToFile(x+"\n\n");
            st.exit_scope();
        }
        else
        {
            cout<<"Please enter valid input."<<endl;
        }
    }




    is.close();
}


int main()
{
    inputFromFile("input.txt");

    return 0;
}

#define TERNARY 999
#define MAX_ARGS 3
#define GARBAGE 0

extern struct Array* array;

struct Node {
    int type;
    int leaf_value;
    struct Node* args[MAX_ARGS];
};

struct Node* mkleaf(int type, int value);

struct Node* mknode(int type, struct Node* a0, struct Node* a1, struct Node* a2);
void print_the_tree(struct Node* p, int level);
int execute(struct Node* p);

#define TERNARY 999
#define MAX_ARGS 3
#define GARBAGE 0

extern struct Array* array;

struct Node {
    int type;
    int leaf_value;
    struct Node* args[MAX_ARGS];
};

struct Node* makeLeaf(int type, int value);

struct Node* makeNode(int type, struct Node* a0, struct Node* a1, struct Node* a2);
void printTree(struct Node* p, int level);
int execute(struct Node* p);

#include "stack.h"
#include "assert.h"

#define GC_NODE_INIT_THRESH 128

struct gmachine {
    struct stack stack;
    struct node_base* gc_nodes;
    int64_t gc_node_cnt;
    int64_t gc_node_thresh;
};


struct node_base* gmachine_track(struct gmachine* g, struct node_base* n);
void gmachine_init(struct gmachine* g);
void gmachine_free(struct gmachine* g);
void gmachine_slide(struct gmachine* g, size_t n);
void gmachine_update(struct gmachine* g, size_t o);
void gmachine_alloc(struct gmachine* g, size_t o);
void gmachine_pack(struct gmachine* g, size_t n, int8_t t);
void gmachine_split(struct gmachine* g, size_t n);
struct node_base* gmachine_track(struct gmachine* g, struct node_base* b);
void gmachine_gc(struct gmachine* g);
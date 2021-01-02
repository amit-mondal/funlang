
#ifndef NODE_H
#define NODE_H

#include <stdint.h>

struct stack;

#define MAX_NODE_SIZE sizeof(struct node_app)

enum node_kind {
		NODE_APP = 0,
		NODE_NUM,
		NODE_GLOBAL,
		NODE_IND,
		NODE_DATA
};

struct node_base {
    enum node_kind kind;
    int8_t gc_reachable;
    struct node_base* gc_next;
};

struct node_app {
    struct node_base base;
    struct node_base* left;
    struct node_base* right;
};

struct node_num {
    struct node_base base;
    int32_t val;
};

struct node_global {
    struct node_base base;
    int32_t arity;
    void (*fn) (struct stack*);
};

struct node_ind {
    struct node_base base;
    struct node_base* next;
};

struct node_data {
    struct node_base base;
    int8_t tag;
    struct node_base** arr;
};


struct node_base* alloc_node();
struct node_app* alloc_app(struct node_base* l, struct node_base* r);
struct node_num* alloc_num(int32_t n);
struct node_global* alloc_global(void (*f)(struct stack*), int32_t a);
struct node_ind* alloc_ind(struct node_base* n);

#endif

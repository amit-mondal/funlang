
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>
#include "node.h"

struct node_base* alloc_node() {
    struct node_base* new_node = malloc(sizeof(struct node_app));
    assert(new_node != NULL);
    new_node->gc_reachable = 0;
    new_node->gc_next = NULL;
    return new_node;
}

struct node_app* alloc_app(struct node_base* l, struct node_base* r) {
    struct node_app* node = (struct node_app*) alloc_node();
    node->base.kind = NODE_APP;
    node->left = l;
    node->right = r;
    return node;
}

struct node_num* alloc_num(int32_t n) {
    struct node_num* node = (struct node_num*) alloc_node();
    node->base.kind = NODE_NUM;
    node->val = n;
    return node;
}

struct node_str* alloc_str(char* c, uint32_t len) {
    struct node_str* node = (struct node_str*) alloc_node();
    node->base.kind = NODE_STR;
    node->val = c;
    node->len = len;
    return node;
}

struct node_global* alloc_global(void (*f)(struct stack*), int32_t a) {
    struct node_global* node = (struct node_global*) alloc_node();
    node->base.kind = NODE_GLOBAL;
    node->arity = a;
    node->fn = f;
    return node;
}

struct node_ind* alloc_ind(struct node_base* n) {
    struct node_ind* node = (struct node_ind*) alloc_node();
    node->base.kind = NODE_IND;
    node->next = n;
    return node;
}
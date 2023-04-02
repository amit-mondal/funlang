#include "gmachine.h"
#include "node.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

void gmachine_init(struct gmachine* g) {
    stack_init(&g->stack);
    g->gc_nodes = NULL;
    g->gc_node_cnt = 0;
    g->gc_node_thresh = GC_NODE_INIT_THRESH;
}

void gmachine_slide(struct gmachine* g, size_t n) {
    assert(g->stack.count > n);
    g->stack.data[g->stack.count - n - 1] = g->stack.data[g->stack.count - 1];
    g->stack.count -= n;
}

void gmachine_update(struct gmachine* g, size_t o) {
    assert(g->stack.count > o + 1);
    struct node_ind* ind = (struct node_ind*) g->stack.data[g->stack.count - o - 2];
    ind->base.kind = NODE_IND;
    g->stack.count--;
    ind->next = g->stack.data[g->stack.count];
}

void gmachine_alloc(struct gmachine* g, size_t o) {
    unsigned i;
    for (i = 0; i < o; i++) {
	    //gmachine_push(&g->stack, (struct node_base*) alloc_ind(NULL));
        stack_push(&g->stack, gmachine_track(g, (struct node_base*) alloc_ind(NULL)));
    }
}

void gmachine_pack(struct gmachine* g, size_t n, int8_t t) {
    assert(g->stack.count >= n);

    struct node_base** data = malloc(sizeof(*data) * (n + 1));
    NOT_NULL(data);
    memcpy(data, &g->stack.data[g->stack.count - n], n * sizeof(*data));
    data[n] = NULL;

    struct node_data* new_node = (struct node_data*) alloc_node();
    new_node->arr = data;
    new_node->base.kind = NODE_DATA;
    new_node->tag = t;

    stack_popn(&g->stack, n);
    stack_push(&g->stack, gmachine_track(g, (struct node_base*) new_node));
}

void gmachine_split(struct gmachine* g, size_t n) {
    struct node_data* node = (struct node_data*) stack_pop(&g->stack);
    unsigned i;
    for (i = 0; i < n; i++) {
	    stack_push(&g->stack, node->arr[i]);
    }
}

/**
 * Recursively mark nodes and all children as reachable.
 */
void gc_visit_node(struct node_base* n) {
    if (n->gc_reachable) {
        return;
    }

    n->gc_reachable = 1;
    switch (n->kind) {
    case NODE_APP: {
        struct node_app* app = (struct node_app*) n;
        gc_visit_node(app->left);
        gc_visit_node(app->right);
        break;
    }
    case NODE_IND: {
        struct node_ind* ind = (struct node_ind*) n;
        gc_visit_node(ind->next);
        break;
    }
    case NODE_DATA: {
        struct node_data* data = (struct node_data*) n;
        struct node_base** data_node = data->arr;

        while (*data_node) {
            gc_visit_node(*data_node);
            data_node++;
        }
    }
    default:
        break;
    }
}

/**
 * Add node to list of nodes to be tracked by the runtime. GC when we've exceeded double the
 * prior threshold.
 */
struct node_base* gmachine_track(struct gmachine* g, struct node_base* n) {
    /* Update count, add node to gmachine's linked list */
    g->gc_node_cnt++;
    n->gc_next = g->gc_nodes;
    g->gc_nodes = n;

    /* GC if we'v'e exceeded the threshold, and double the threshold */
    if (g->gc_node_cnt > g->gc_node_thresh) {
        uint64_t nodes_before = g->gc_node_cnt;
        /* We must visit the node here to mark it and its children as reachable. Otherwise,
           we run the risk of accidentally GCing values, as in the case of gmachine_pack */
        gc_visit_node(n);
        gmachine_gc(g);
        g->gc_node_thresh = nodes_before * 2;
    }

    return n;
}

void free_node_data(struct node_base* n) {
    switch (n->kind) {
        case NODE_DATA: free(((struct node_data*) n)->arr);
            break;
        case NODE_STR: free(((struct node_str*) n)->val);
            break;
        default:
            break;
    }
}

void gmachine_gc(struct gmachine* g) {
    for (size_t i = 0; i < g->stack.count; i++) {
        gc_visit_node(g->stack.data[i]);
    }

    struct node_base** node_ptr = &g->gc_nodes;

    /* If a node has been marked reachable in this pass, unmark it for
    future passes. Otherwise, we free the node and decrement the node count. */
    size_t init_node_cnt = g->gc_node_cnt;
    while (*node_ptr) {
        if ((*node_ptr)->gc_reachable) {
            (*node_ptr)->gc_reachable = 0;
            node_ptr = &((*node_ptr)->gc_next);
        } else {
            struct node_base* garbage_node = *node_ptr;
            *node_ptr = garbage_node->gc_next;
            free_node_data(garbage_node);
            free(garbage_node);
            g->gc_node_cnt--;
        }
    }
    //printf("freed %llu\n", (init_node_cnt - g->gc_node_cnt));
}

struct node_base* extern_strconcat(struct gmachine* g, struct node_base* l, struct node_base* r) {
    /* TODO: this is not GC trackable */
    struct node_str* ls = (struct node_str*) l;
    struct node_str* rs = (struct node_str*) r;
    char* concat = (char*) malloc(sizeof(char) * (ls->len + rs->len));
    memcpy(concat, ls->val, ls->len);
    for (size_t i = 0; i < rs->len; i++)  {
        concat[ls->len + i] = rs->val[i];
    }
    rs->val = concat;
    rs->len = (rs->len + ls->len);
    gmachine_track(g, rs);
    return (struct node_base*) rs;
}

struct node_base* extern_easyadd(struct gmachine* g, struct node_base* a, struct node_base* b, struct node_base* c, struct node_base* d) {
    printf("it's so easy!\n");
    struct node_num* ai = (struct node_num*) a;
    struct node_num* bi = (struct node_num*) b;
    struct node_num* ci = (struct node_num*) c;
    struct node_num* di = (struct node_num*) d;
    int32_t sum = ai->val + bi->val + ci->val + di->val;
    printf("%d+%d+%d+%d=%d", ai->val, bi->val, ci->val, di->val, sum);
    return alloc_num(sum);
}
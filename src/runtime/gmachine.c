#include "gmachine.h"
#include "node.h"

void gmachine_init(struct gmachine* g) {
    stack_init(g->stack);
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
	    gmachine_push(&g->stack, (struct node_base*) alloc_ind(NULL));
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
    stack_push(&g->stack, (struct node_base*) new_node);
}

void gmachine_split(struct gmachine* g, size_t n) {
    struct node_data* node = (struct node_data*) stack_pop(&g->stack);
    unsigned i;
    for (i = 0; i < n; i++) {
	    stack_push(&g->stack, node->arr[i]);
    }
}

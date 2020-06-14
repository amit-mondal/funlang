
#include "stack.h"
#include "node.h"
#include <stdlib.h>
#include <assert.h>
#include <string.h>


void stack_init(struct stack* s) {
    s->size = STACK_INIT_SIZE;
    s->count = 0;
    s->data = malloc(sizeof(*s->data) * s->size);
    NOT_NULL(s->data);
}


void stack_free(struct stack* s) {
    free(s->data);
}

void stack_push(struct stack* s, struct node_base* n) {
    size_t new_size = s->size;
    
    while (new_size <= s->count) {
	    new_size *= 2;
    }

    if (new_size != s->size) {
	    s->size = new_size;
	    s->data = realloc(s->data, sizeof(*s->data) * s->size);
	    NOT_NULL(s->data);
    }

    s->data[s->count] = n;
    s->count++;    
    NOT_NULL(stack_peek(s, 0));   
}

struct node_base* stack_pop(struct stack* s) {
    assert(s->count > 0);
    s->count--;
    return s->data[s->count];
}

struct node_base* stack_peek(struct stack* s, size_t o) {
    assert(s->count > o);
    return s->data[s->count - o - 1];
}

void stack_popn(struct stack* s, size_t n) {
    assert(s->count > n);
    s->count -= n;
}
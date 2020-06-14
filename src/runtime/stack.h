
#ifndef STACK_H
#define STACK_H

#include <stddef.h>
#include <stdint.h>

#define NOT_NULL(e) assert((e) != NULL)

#define STACK_INIT_SIZE 4

struct node_base;

struct stack {
    size_t size;
    size_t count;
    struct node_base** data;
};


void stack_init(struct stack* s);
void stack_free(struct stack* s);
void stack_push(struct stack* s, struct node_base* n);
struct node_base* stack_pop(struct stack* s);
struct node_base* stack_peek(struct stack* s, size_t o);
void stack_popn(struct stack* s, size_t n);

#endif

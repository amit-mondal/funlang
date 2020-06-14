#include "runtime.h"

void f_plus(struct stack *s)
{
    struct node_num *left = (struct node_num *)eval(stack_peek(s, 0));
    struct node_num *right = (struct node_num *)eval(stack_peek(s, 1));
    stack_push(s, (struct node_base *)alloc_num(left->val + right->val));
}

void f_add(struct stack *s)
{
    struct node_base *call_peek = stack_peek(s, 1);
    stack_push(s, call_peek);
    struct node_base *call_peek1 = stack_peek(s, 1);
    stack_push(s, call_peek1);
    struct node_base *call_alloc_global = alloc_global(f_plus, 2);
    stack_push(s, call_alloc_global);
    struct node_base *call_pop = stack_pop(s);
    struct node_base *call_pop2 = stack_pop(s);
    struct node_base *call_alloc_app = alloc_app(call_pop, call_pop2);
    stack_push(s, call_alloc_app);
    struct node_base *call_pop3 = stack_pop(s);
    struct node_base *call_pop4 = stack_pop(s);
    struct node_base *call_alloc_app5 = alloc_app(call_pop3, call_pop4);
    stack_push(s, call_alloc_app5);
    stack_update(s, 2);
    stack_popn(s, 2);
    return;
}

void f_main(struct stack *s)
{
    struct node_base *call_alloc_num = alloc_num(2);
    stack_push(s, call_alloc_num);
    struct node_base *call_alloc_num1 = alloc_num(1);
    stack_push(s, call_alloc_num1);
    struct node_base *call_alloc_global = alloc_global(f_add, 2);
    stack_push(s, call_alloc_global);
    struct node_base *call_pop = stack_pop(s);
    struct node_base *call_pop2 = stack_pop(s);
    struct node_base *call_alloc_app = alloc_app(call_pop, call_pop2);
    stack_push(s, call_alloc_app);
    struct node_base *call_pop3 = stack_pop(s);
    struct node_base *call_pop4 = stack_pop(s);
    struct node_base *call_alloc_app5 = alloc_app(call_pop3, call_pop4);
    stack_push(s, call_alloc_app5);
    stack_update(s, 0);
    stack_popn(s, 0);
    return;
}

/*
void f_main(struct stack *s)
{
    // PushInt 320
    stack_push(s, (struct node_base *)alloc_num(320));

    // PushInt 6
    stack_push(s, (struct node_base *)alloc_num(6));

    // PushGlobal f_add (the function for +)
    stack_push(s, (struct node_base *)alloc_global(f_add, 2));

    struct node_base *left;
    struct node_base *right;

    // MkApp
    left = stack_pop(s);
    right = stack_pop(s);
    stack_push(s, (struct node_base *)alloc_app(left, right));

    // MkApp
    left = stack_pop(s);
    right = stack_pop(s);
    stack_push(s, (struct node_base *)alloc_app(left, right));

    stack_push(s, (struct node_base *)alloc_num(2));
    stack_push(s, (struct node_base *)alloc_num(1));
}
*/
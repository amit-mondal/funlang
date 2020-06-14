
#ifndef RUNTIME_H
#define RUNTIME_H

#include "stack.h"
#include "node.h"

void unwind(struct stack* s);
struct node_base* eval(struct node_base* n);

#endif

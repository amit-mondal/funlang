
#ifndef RUNTIME_H
#define RUNTIME_H

#include "stack.h"
#include "node.h"
#include "gmachine.h"

void unwind(struct gmachine* g);
struct node_base* eval(struct node_base* n);

#endif


#include "runtime.h"
#include <assert.h>
#include <stdio.h>


char *NODE_KIND_TO_STR[] = {
	"App",
	"Num",
	"Global",
	"Ind",
	"Data"
};

void unwind(struct gmachine *g) {
	struct stack* s = &g->stack;
	while (1) {
		struct node_base *peek = stack_peek(s, 0);
		switch (peek->kind) {
		case NODE_APP:
			stack_push(s, ((struct node_app *)peek)->left);
			break;
		case NODE_GLOBAL: {
			struct node_global* n = (struct node_global *)peek;
			assert(s->count > (size_t) n->arity);

			for (int i = 1; i <= n->arity; i++) {
				s->data[s->count - i] = ((struct node_app *)s->data[s->count - i - 1])->right;
			}

			n->fn(s);
			break;
		}
		case NODE_IND:
			stack_pop(s);
			stack_push(s, ((struct node_ind *)peek)->next);
			break;
		case NODE_DATA:
		case NODE_NUM:
			return;
		}
	}
}

void print_node(struct node_base *n) {
	switch (n->kind) {
	case NODE_APP: {
		struct node_app* na = (struct node_app*) n;
		print_node(na->left);
		printf(" -> ");
		print_node(na->right);
		break;
	}
	case NODE_GLOBAL: {
		struct node_global* g = (struct node_global *)n;
		printf("(Global, arity %d)", g->arity);
		break;
	}
	case NODE_IND:
		printf("(Indirect => ");
		print_node(((struct node_ind*) n)->next);
		printf(")");
		break;
	case NODE_DATA: {
		struct node_data* d = (struct node_data*) n;
		printf("((Packed) Data, tag %d, arr [?])", d->tag);
		break;
	}
	case NODE_NUM:
		printf("(Num %d)", ((struct node_num*)n)->val);
	}
}

extern void f_main(struct stack *s);

int main(__attribute__((unused)) int argc, __attribute__((unused)) char **argv) {
	struct gmachine gmachine;
	struct node_global* start = alloc_global(f_main, 0);
	struct node_base* res;

	gmachine_init(&gmachine);
	gmachine_track(&gmachine, (struct node_base*) start);
	stack_push(&gmachine.stack, (struct node_base*) start);
	unwind(&gmachine);
	res = stack_pop(&gmachine.stack);
	print_node(res);
	printf("\n");
}

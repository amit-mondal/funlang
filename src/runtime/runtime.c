
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

void unwind(struct stack *s) {

	while (1) {
		struct node_base *peek = stack_peek(s, 0);
		switch (peek->kind) {
		case NODE_APP:
			stack_push(s, ((struct node_app *)peek)->left);
			break;
		case NODE_GLOBAL: {
			struct node_global *g = (struct node_global *)peek;
			assert(s->count > g->arity);

			for (unsigned i = 1; i <= g->arity; i++) {
				s->data[s->count - i] = ((struct node_app *)s->data[s->count - i - 1])->right;
			}

			g->fn(s);
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

struct node_base *eval(struct node_base *n) {
	struct stack s;
	stack_init(&s);
	stack_push(&s, n);
	unwind(&s);
	struct node_base *res = stack_pop(&s);
	printf("Stack size before free: %zu\n", s.count);
	stack_free(&s);
	return res;
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
		printf("(Data, tag %d, arr [?])", d->tag);
		break;
	}
	case NODE_NUM:
		printf("(Num %d)", ((struct node_num*)n)->val);
	}
}

extern void f_main(struct stack *s);

int main(int argc, char **argv) {
	struct node_global *start = alloc_global(f_main, 0);
	struct node_base *res = eval((struct node_base *)start);
	print_node(res);
	printf("\n");
}

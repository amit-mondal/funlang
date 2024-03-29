
#include "runtime.h"
#include <assert.h>
#include <stdio.h>


char *NODE_KIND_TO_STR[] = {
	"App",
	"Num",
	"Str",
	"Global",
	"Ind",
	"Data"
};

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
		printf("((Packed) Data, tag %d, arr [", d->tag);
		struct node_base** arr_ptr = d->arr;
		while (*arr_ptr != NULL) {
			print_node(*arr_ptr);
			printf(", ");
			arr_ptr++;
		}
		printf("])");
		break;
	}
	case NODE_STR: {
		struct node_str* s = (struct node_str*) n;
		printf("%.*s", (int) s->len, s->val);
		break;
	}
	case NODE_NUM:
		printf("(Num %d)", ((struct node_num*)n)->val);
	}
}

void print_stack(struct stack* s) {
	printf("-----STACK DUMP-----\n");
	for (size_t i = s->count; i > 0; i--) {
		assert(i > 0);
		size_t idx = i - 1;
		struct node_base* node = s->data[idx];
		print_node(node);
		printf("\n");
	}
	printf("-----STACK END------\n");
}


void unwind(struct gmachine *g) {
	struct stack* s = &g->stack;
	while (1) {
		struct node_base *peek = stack_peek(s, 0);
		print_stack(s);
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
		case NODE_STR:
			return;
		}
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

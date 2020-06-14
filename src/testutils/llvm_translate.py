import sys
import re


def print_header(name):
    print(f'void f_{name}(struct stack* s) {{')


def extract_param(s):
    if s == '%0':
        return 's'
    elif s.startswith('%') or s.startswith('@'):
        return s[1:]
    return s

def get_params(paramstr):
    return [extract_param(p.split()[-1]) for p in paramstr.split(',')]

def translate_assign(line):
    matches = re.search(r"%(\w+) = call %(\w+)\* @(\w+)\((.*)\)", line)
    if not matches:
        print(f'could not translate assign {line}')
        return
    var_name = matches.group(1)
    struct_name = matches.group(2)
    func_name = matches.group(3)
    params = get_params(matches.group(4))
    print(f'struct {struct_name}* {var_name} = {func_name}({", ".join(params)});')

def translate_call(line):
    matches = re.search(r"call void @(\w+)\((.*)\)", line)
    if not matches:
        print(f'could not translate call {line}')
        return
    func_name = matches.group(1)
    params = get_params(matches.group(2))
    print(f'{func_name}({", ".join(params)});')

def translate_line(line):
    if line == '}':
        print(line)
    elif line.startswith('ret'):
        print("return;")
    elif line.startswith('%'):
        translate_assign(line)
    else: 
        translate_call(line)


def translate_function(lines):
    func_name = re.search(r"define void @f_(\w+)\(\%stack\* \%0\) {", lines[0]).group(1)
    print_header(func_name)
    for line in lines[2:]:
        #print(f'line is {line.strip()}')
        translate_line(line.strip())



def main():
    func = '''
define void @f_main(%stack* %0) {
entry:
  %call_alloc_num = call %node_base* @alloc_num(i32 2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num)
  %call_alloc_num1 = call %node_base* @alloc_num(i32 1)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_num1)
  %call_alloc_global = call %node_base* @alloc_global(void (%stack*)* @f_add, i32 2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_global)
  %call_pop = call %node_base* @stack_pop(%stack* %0)
  %call_pop2 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app = call %node_base* @alloc_app(%node_base* %call_pop, %node_base* %call_pop2)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app)
  %call_pop3 = call %node_base* @stack_pop(%stack* %0)
  %call_pop4 = call %node_base* @stack_pop(%stack* %0)
  %call_alloc_app5 = call %node_base* @alloc_app(%node_base* %call_pop3, %node_base* %call_pop4)
  call void @stack_push(%stack* %0, %node_base* %call_alloc_app5)
  call void @stack_update(%stack* %0, i64 0)
  call void @stack_popn(%stack* %0, i64 0)
  ret void
}
'''
    translate_function(list(filter(lambda l: l, func.splitlines())))


if __name__ == "__main__":
    main()
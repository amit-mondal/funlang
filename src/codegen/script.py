

funs = [
    ('pop', [], True),
    ('peek', ['off'], True),
    ('push', ['v'], False),    
    ('popn', ['off'], False),
    ('update', ['off'], False),
    ('pack', ['c', 't'], False),
    ('split', ['c'], False),
    ('slide', ['off'], False),
    ('alloc', ['n'], False)
]

for fun in funs:
    argstr = ', '.join([f"{n}: BasicValueEnum<'ctx>" for n in fun[1]])
    argstr = argstr if len(fun[1]) == 0 else ', ' + argstr
    name = fun[0]
    args = ', '.join(fun[1])
    retstr = " -> BasicValueEnum<'ctx>" if fun[2] else ''
    
    print(f'''
    pub fn create_{name}(&self, f: FunctionValue<'ctx>{argstr}){retstr} {{
	let func = self.funcs.get("stack_{name}").unwrap();
	self.builder.build_call(*func, &[f.get_first_param().unwrap(), {args}], "call_{name}");
    }}\n''')

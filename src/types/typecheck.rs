use super::call_graph::CallGraph;
use super::free_var_visit::FreeVarVisitor;
use super::type_visit::TypeVisitor;
use super::Type;
use crate::ast::Program;
use std::collections::{HashMap, HashSet};
use std::rc::Rc;

pub struct TypecheckContext {
    v: FreeVarVisitor,
}

impl TypecheckContext {
    pub fn new() -> TypecheckContext {
        let mut v = FreeVarVisitor::new();
        v.env_stack.push();

        let int_type = Rc::new(Type::Base(String::from("Int"), None));
        let string_type = Rc::new(Type::Base(String::from("String"), None));
        let int_to_string_type = Rc::new(Type::Function(
            Rc::clone(&int_type),
            Rc::clone(&string_type),
        ));
        let int_binop_type = Rc::new(Type::Function(
            Rc::clone(&int_type),
            Rc::new(Type::Function(Rc::clone(&int_type), Rc::clone(&int_type))),
        ));

        v.env_stack.bind_type(String::from("String"), string_type);
        v.env_stack.bind_type(String::from("Int"), int_type);

        v.env_stack
            .bind_from_type(String::from("+"), Rc::clone(&int_binop_type));
        v.env_stack
            .bind_from_type(String::from("-"), Rc::clone(&int_binop_type));
        v.env_stack
            .bind_from_type(String::from("*"), Rc::clone(&int_binop_type));
        v.env_stack
            .bind_from_type(String::from("/"), Rc::clone(&int_binop_type));
        v.env_stack.bind_from_type(
            String::from("int_to_string"),
            Rc::clone(&int_to_string_type),
        );

        TypecheckContext { v }
    }

    pub fn typecheck(mut self, p: &mut Program) {
        for (_, type_defn) in &mut p.type_defns {
            type_defn.insert_types(&mut self.v);
        }

        for (_, type_defn) in &mut p.type_defns {
            type_defn.insert_constructors(&mut self.v);
        }

        for (_, func_defn) in &mut p.func_defns {
            self.v.visit_func_defn(func_defn);
        }

        let mut call_dep_graph = CallGraph::new();

        for (external_func_name, external_decl) in &p.extern_decls {
            call_dep_graph.add_function(external_func_name);
            let type_ = external_decl.to_type(&self.v).unwrap();
            //extern_func_types.insert(external_func_name, type_);
            self.v.env_stack.bind_from_type(external_func_name.clone(), type_);
        }

        for (_, func_defn) in &p.func_defns {
            let fd_name = func_defn.name.to_owned();
            call_dep_graph.add_function(&fd_name);
            for dep in &func_defn.free_vars {
                if !p.func_defns.contains_key(dep) && !p.extern_decls.contains_key(dep) {
                    panic!(
                        "could not find call graph dependency 
                        {} in the list of function definitions",
                        dep
                    );
                } else {
                    call_dep_graph.add_edge(&fd_name, dep);
                }
            }
        }

        let ordered_groups = call_dep_graph.compute_order();
        let ordered_groups = ordered_groups.iter().map(|group| {
            group.iter().filter(|func_name|!p.extern_decls.contains_key(*func_name)).collect::<HashSet<_>>()
        }).collect::<Vec<_>>();

        for group in ordered_groups.iter().rev() {
            for func_name in group {
                let func = p.func_defns.get(*func_name).unwrap();
                func.insert_types(&mut self.v);
            }
        }

        let mut type_visitor = TypeVisitor::new(self.v);
        for group in ordered_groups.iter().rev() {
            println!("{:?}", group);
            for func_name in group {
                let func = p.func_defns.get_mut(*func_name).unwrap();
                type_visitor.visit_func_defn(func);
            }

            for func_name in group {
                type_visitor.generalize_func_type(type_visitor.env_stack.global_env_id, func_name);
            }
        }
        type_visitor.print_global_names();
    }
}

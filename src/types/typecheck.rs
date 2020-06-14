use std::rc::Rc;
use std::cell::RefCell;
use std::collections::HashMap;
use super::type_visit::{TypeVisitor, TypeResolveVisitor};
use super::{Type, TypeData};
use crate::ast::{Definition, Program};

pub struct TypecheckContext {
    visitor: TypeVisitor,
    defined_types: HashMap<String, Rc<Type>>
}

impl TypecheckContext {

    pub fn new() -> TypecheckContext {
        let mut v = TypeVisitor::new();
        v.push_env();

        let int_type = Rc::new(Type::Base(String::from("Int"), None));
        let int_binop_type = Rc::new(Type::Function(
            Rc::clone(&int_type), Rc::new(Type::Function(Rc::clone(&int_type), Rc::clone(&int_type)))));

        v.env_bind(String::from("+"), Rc::clone(&int_binop_type));
        v.env_bind(String::from("-"), Rc::clone(&int_binop_type));
        v.env_bind(String::from("*"), Rc::clone(&int_binop_type));
        v.env_bind(String::from("/"), Rc::clone(&int_binop_type));

        // Built-in types defined here.
        let mut t = HashMap::new();
        t.insert(String::from("Int"), Rc::clone(&int_type));

        TypecheckContext { visitor: v, defined_types: t }
    }

    pub fn typecheck(&mut self, p: &mut Program) {

        /* Keep track of all user defined types in defined_types for use when checking type parameters of 
           type constructors */
        for def in p.defns.iter_mut() {
            if let Definition::Type(td) = def {
                let def_type = Rc::new(Type::Base(td.name.to_owned(), Some(RefCell::new(TypeData::new()))));
                self.defined_types.insert(td.name.to_owned(), def_type);
            }
        }

        /* Fill in all known types from type definitions and add placeholder types on functions */
        for def in p.defns.iter_mut() {
            self.create_partial_types(def)
        }

        /* Fully typecheck based on partial types */
        for def in p.defns.iter_mut() {
            self.typecheck_definition(def)
        }

        /* Replace all placeholder types with their corresponding base type */
        for def in p.defns.iter_mut() {
            self.type_resolve_definition(def, &mut TypeResolveVisitor::new(&self.visitor))
        }
    }

    fn create_partial_types(&mut self, def: &mut Definition) {
        match def {
            Definition::Func(fd) => {
                // This is the return type of the function.
                let mut full_type = Rc::new(self.visitor.new_placeholder());
                fd.return_type = Some(Rc::clone(&full_type));

                for _ in fd.params.iter().rev() {
                    let param_type = Rc::new(self.visitor.new_placeholder());
                    full_type = Rc::new(Type::Function(Rc::clone(&param_type), Rc::clone(&full_type)));
                    // Note that parameter types are pushed in reverse order.
                    fd.param_types.push(param_type);
                }

                self.visitor.env_bind(fd.name.to_owned(), full_type);

            },
            Definition::Type(td) => {
                let return_type = Rc::clone(self.defined_types.get(&td.name.to_owned()).unwrap());
                /* This if-statement always evaluates to true. It's only needed to get at the internals of
                   the return_type variable we just made */
                if let Type::Base(type_name, Some(type_data)) = &*Rc::clone(&return_type) {
                    self.defined_types.insert(type_name.clone(), Rc::clone(&return_type));
                    let mut curr_tag = 0;               
                    for constructor in td.constructors.iter_mut() {
                        /* Store unique tag for each constructor in the Type enum itself */
                        constructor.tag = curr_tag;
                        type_data.borrow_mut().constr_tags.insert(constructor.name.to_owned(), curr_tag);
                        curr_tag += 1;
                        
                        let mut full_type = Rc::clone(&return_type);
                        /* Type parameters are read in forward, so we must iterate backwards to
                        create a right-recursive type definition */
                        for type_name in constructor.types.iter().rev() {
                            //let curr_type = Rc::new(Type::Base((*type_name).to_owned(), None));
                            if let Some(curr_type) = self.defined_types.get(&(*type_name).to_owned()) {
                                full_type = Rc::new(Type::Function(Rc::clone(curr_type), full_type));
                            } else {
                                panic!("expected {} to be defined in typecheck context", type_name)
                            }
                        }

                        self.visitor.env_bind(constructor.name.to_owned(), full_type);
                    }
                } else {
                    panic!("expected Base(_, Some(_)), got {:?}", return_type);             
                }
            }
        }
    }

    fn typecheck_definition(&mut self, def: &mut Definition) {
        match def {
            Definition::Func(fd) => {
                self.visitor.push_env();
                for (param, param_type) in fd.params.iter().zip(fd.param_types.iter().rev()) {
                    self.visitor.env_bind((*param).to_owned(), Rc::clone(param_type))
                }

                let body_type = fd.body.type_accept(&mut self.visitor);
                self.visitor.unify(body_type, Rc::clone(fd.return_type.as_ref().unwrap())).unwrap();
                self.visitor.pop_env();
            }
            Definition::Type(_) => {}
        }
    }

    fn type_resolve_definition(&self, def: &mut Definition, trv: &mut TypeResolveVisitor) {
        match def {
            Definition::Func(fd) => {
                for param_type in fd.param_types.iter_mut() {
                    trv.resolve_type(param_type).unwrap();
                }
                trv.resolve_type(fd.return_type.as_mut().unwrap()).unwrap();
                fd.body.accept(trv);
            }
            Definition::Type(_) => ()
        }
    }
}

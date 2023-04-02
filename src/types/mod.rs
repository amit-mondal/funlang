
use std::error::Error;
use std::rc::Rc;
use std::collections::HashMap;
use std::cell::RefCell;
use std::fmt;

pub mod type_env;
pub mod free_var_visit;
pub mod type_visit;
pub mod typecheck;
pub mod call_graph;

use type_visit::{TypeVisitor, Either};


#[derive(Debug)]
pub struct TypeError {
    msg: String
}

impl fmt::Display for TypeError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "SemanticError: {}", self.msg)
    }
}

impl Error for TypeError {}

#[derive(Debug, PartialEq, Eq)]
pub struct TypeData {
    pub constr_tags: HashMap<String, i32>
}

impl TypeData {
    pub fn new() -> TypeData {
        TypeData { constr_tags: HashMap::new() }
    }
}

#[derive(Debug, PartialEq, Eq)]
pub enum Type {
    Placeholder(String),
    Base(String, Option<RefCell<TypeData>>),
    Function(Rc<Type>, Rc<Type>)        
}

impl Type {
    pub fn format(&self, tv: &TypeVisitor) -> String {
        match self {
            Type::Placeholder(s) => {
                if let Some(t) = tv.types.get(s) {
                    t.format(tv)
                } else {
                    s.clone()
                }
            }
            Type::Base(s, _) => s.clone(),
            Type::Function(l, r) => format!("({} -> {})", l.format(tv), r.format(tv))
        }
    }
}

/// Used to represent polytypes
#[derive(Debug)]
pub struct TypeScheme {
    pub forall: Vec<String>,
    pub monotype: Rc<Type>
}

impl TypeScheme {
    pub fn new(t: Rc<Type>) -> TypeScheme {
        TypeScheme { forall: Vec::new(), monotype: t}
    }

    // Specialize this polytype to a monotype.
    pub fn instantiate(&self, tv: &mut TypeVisitor) -> Rc<Type> {
        // Type scheme represents a monotype.
        if self.forall.is_empty() {
            return Rc::clone(&self.monotype);
        }

        let mut subst_map = HashMap::new();
        for var in &self.forall {
            subst_map.insert(var.clone(), Rc::new(tv.new_placeholder()));
        }
        TypeScheme::substitute(tv, &mut subst_map, &self.monotype)
    }

    fn substitute(tv: &mut TypeVisitor, subst_map: &mut HashMap<String, Rc<Type>>, t: &Rc<Type>) -> Rc<Type> {
        match tv.resolve(Rc::clone(t)) {
            Either::NotFound((placeholder_name, placeholder_type)) => {
                if let Some(subst_type) = subst_map.get(&placeholder_name) {
                    Rc::clone(subst_type)
                } else {
                    Rc::clone(&placeholder_type)
                }
            }
            Either::Found(found_type) => {
                if let Type::Function(l, r) = &*found_type {
                    let lres = TypeScheme::substitute(tv, subst_map, l);
                    let rres = TypeScheme::substitute(tv, subst_map, r);
                    if &lres == l && &rres == r {
                        Rc::clone(t)
                    } else {
                        Rc::new(Type::Function(lres, rres))
                    }
                } else {
                    Rc::clone(t)
                }
            }
        }
    }

    pub fn format(&self, tv: &TypeVisitor) -> String {
        return format!("∀{}. {}", self.forall.join(" "), self.monotype.format(tv));
    }
}

pub struct PlaceholderGenerator {
    curr_id: u32
}

impl PlaceholderGenerator {
    fn new() -> PlaceholderGenerator {
        PlaceholderGenerator { curr_id: 0 }
    }

    pub fn new_placeholder(&mut self) -> Type {
        let mut v = Vec::with_capacity((self.curr_id / 26) as usize);
        let mut id = self.curr_id;

        if id == 0 {
            v.push('a' as u8);
        } else {
            while id > 0 {
                let c = (id % 26) + 'a' as u32;
                v.push(c as u8);
                id /= 26;
            }
        }
        self.curr_id += 1;
        Type::Placeholder(String::from_utf8(v).unwrap())
    }
}

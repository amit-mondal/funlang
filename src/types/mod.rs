
use std::error::Error;
use std::rc::Rc;
use std::collections::HashMap;
use std::cell::RefCell;
use std::fmt;

pub mod type_env;
pub mod type_visit;
pub mod typecheck;


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

#[derive(Debug)]
pub struct TypeData {
    pub constr_tags: HashMap<String, i32>
}

impl TypeData {
    pub fn new() -> TypeData {
        TypeData { constr_tags: HashMap::new() }
    }
}

#[derive(Debug)]
pub enum Type {
    Placeholder(String),
    Base(String, Option<RefCell<TypeData>>),
    Function(Rc<Type>, Rc<Type>)        
}

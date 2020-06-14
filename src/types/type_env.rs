use std::rc::Rc;
use std::collections::HashMap;
use super::Type;

pub struct TypeEnv {
    names: HashMap<String, Rc<Type>>,
    pub enclosing_env: Option<Box<TypeEnv>>
}

impl TypeEnv {

    pub fn from_parent(parent: Option<Box<TypeEnv>>) -> TypeEnv {
        TypeEnv { names: HashMap::new(), enclosing_env: parent }
    }

    pub fn lookup(&self, name: &String) -> Option<Rc<Type>> {
        let res = self.names.get(name);
        if let Some(t) = res {
            Some(Rc::clone(t))
        } else {
            if let Some(env) = &self.enclosing_env {
                env.lookup(name)
            } else {
                None
            }
        }
    }

    pub fn bind(&mut self, name: String, t: Rc<Type>) {
        self.names.insert(name, t);
    }
}

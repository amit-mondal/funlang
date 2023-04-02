use std::rc::Rc;
use std::cell::RefCell;
use std::collections::HashMap;
use id_arena::{Arena, Id};
use super::{Type, TypeScheme, TypeError};

#[derive(Debug)]
pub struct TypeEnv {
    pub names: HashMap<String, Rc<RefCell<TypeScheme>>>,
    type_names: HashMap<String, Rc<Type>>,
    enclosing_env: Option<Id<TypeEnv>>
}

impl TypeEnv {
    pub fn new() -> TypeEnv {
        TypeEnv {
            names: HashMap::new(),
            type_names: HashMap::new(),
            enclosing_env: None
        }
    }

    pub fn from_parent(parent_env: Id<TypeEnv>) -> TypeEnv {
        TypeEnv {
            names: HashMap::new(),
            type_names: HashMap::new(),
            enclosing_env: Some(parent_env)
        }
    }

    pub fn bind(&mut self, name: String, scheme: Rc<RefCell<TypeScheme>>) {
        self.names.insert(name, scheme);
    }

    pub fn bind_type(&mut self, name: String, t: Rc<Type>) {
        self.type_names.insert(name, t);
    }
}


/// A stack of TypeEnvs, with a vector used as the stack. The vector
/// is technically not necessary, since each TypeEnv contains an id
/// to its parent pointer, so we could just keep an id to the last
/// TypeEnv in the chain, and chase ids when we need to do lookup.
/// Use FixedTypeEnvStack when we no longer need to insert anything
/// into the stack, and can just lookup by chasing ids.
pub struct TypeEnvStack {
    arena: Arena<TypeEnv>,
    pub envs: Vec<Id<TypeEnv>>
}

impl TypeEnvStack {

    pub fn new() -> TypeEnvStack {
        TypeEnvStack { arena: Arena::new(), envs: Vec::new() }
    }

    pub fn push(&mut self) {
        let new_env = self.arena.alloc(
            if let Some(last_idx) = self.envs.last() {
                TypeEnv::from_parent(*last_idx)
            } else {
                TypeEnv::new()
            });
        self.envs.push(new_env);
    }

    pub fn pop(&mut self) {
        self.envs.pop();
    }

    pub fn curr_env(&mut self) -> Option<&mut TypeEnv> {
        let last = self.envs.last();
        if let Some(last_id) = last {
            Some(self.arena.get_mut(*last_id).unwrap())
        } else {
            None
        }
    }

    pub fn curr_env_id(&mut self) -> Option<Id<TypeEnv>> {
        return self.envs.last().map(|env| *env)
    }

    pub fn lookup(&self, name: &String) -> Option<Rc<RefCell<TypeScheme>>> {
        for type_env in self.envs.iter().rev() {
            if let Some(t) = self.arena[*type_env].names.get(name) {
                return Some(Rc::clone(t));
            }
        }
        None
    }

    pub fn lookup_type(&self, name: &String) -> Option<Rc<Type>> {
        for type_env in self.envs.iter().rev() {
            if let Some(t) = self.arena[*type_env].type_names.get(name) {
                return Some(Rc::clone(t));
            }
        }
        None
    }

    pub fn bind_from_type(&mut self, name: String, t: Rc<Type>) {
        let scheme = Rc::new(RefCell::new(TypeScheme::new(t)));
        self.curr_env().unwrap().bind(name, scheme);
    }

    pub fn bind(&mut self, name: String, scheme: Rc<RefCell<TypeScheme>>) {
        self.curr_env().unwrap().bind(name, scheme);
    }

    pub fn bind_type(&mut self, name: String, t: Rc<Type>) {
        if self.lookup_type(&name).is_some() {
            let _: () = Err(TypeError{msg: format!("cannot redeclare type  \"{}\"", name)}).unwrap();
        }
        self.curr_env().unwrap().type_names.insert(name, t);
    }

    pub fn to_fixed(self) -> FixedTypeEnvStack {
        FixedTypeEnvStack {
            arena: self.arena,
            global_env_id: self.envs[0]
        }
    }
}

/// Like the previous TypeEnvStack, but only to be used for lookups, and
/// because we no longer use the vector stack, we can only perform lookups
/// by chasing ids.
pub struct FixedTypeEnvStack {
    pub arena: Arena<TypeEnv>,
    pub global_env_id: Id<TypeEnv>
}

impl FixedTypeEnvStack {
    pub fn lookup(&self, name: &String, id: Id<TypeEnv>) -> Option<Rc<RefCell<TypeScheme>>> {
        let curr_env = self.arena.get(id).unwrap();
        let res = curr_env.names.get(name);
        if let Some(t) = res {
            Some(Rc::clone(t))
        } else {
            if let Some(env_id) = curr_env.enclosing_env {
                self.lookup(name, env_id)
            } else {
                None
            }
        }
    }

    pub fn get_env(&self, id: Id<TypeEnv>) -> &TypeEnv {
        self.arena.get(id).unwrap()
    }
}
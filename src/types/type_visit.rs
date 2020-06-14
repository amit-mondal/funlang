use std::collections::HashMap;
use std::result::Result;
use std::rc::Rc;
use super::{Type, TypeError};
use super::type_env::TypeEnv;
use crate::ast::*;


pub enum Either<U, V> {
    Found(U),
    NotFound(V)
}

pub struct TypeVisitor {
    curr_id: u32,
    types: HashMap<String, Rc<Type>>,
    curr_env: Option<Box<TypeEnv>>
}

impl TypeVisitor {

    pub fn new() -> TypeVisitor {
        TypeVisitor { curr_id: 0, types: HashMap::new(), curr_env: None }
    }

    fn env_lookup(&self, name: &String) -> Option<Rc<Type>> {
        self.curr_env.as_ref().unwrap().lookup(name)
    }

    pub fn env_bind(&mut self, name: String, t: Rc<Type>) {
        self.curr_env.as_mut().unwrap().bind(name, t)
    }

    pub fn push_env(&mut self) {
        let new_env = Box::new(TypeEnv::from_parent(self.curr_env.take()));
        self.curr_env = Some(new_env);
    }

    pub fn pop_env(&mut self) {
        let old_env = self.curr_env.take().unwrap().enclosing_env.take();
        self.curr_env = old_env;
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

    pub fn new_function(&mut self) -> Type {
        Type::Function(Rc::new(self.new_placeholder()), Rc::new(self.new_placeholder()))
    }

    pub fn resolve(&self, t: Rc<Type>) -> Either<Rc<Type>, String>  {

        let mut curr_type = Rc::clone(&t);

        while let Type::Placeholder(id) = &*curr_type {
            if let Some(found_type) = self.types.get(id) {
                curr_type = Rc::clone(found_type);
            } else {
                return Either::NotFound(id.clone())
            }
        }

        Either::Found(curr_type)
    }

    pub fn unify(&mut self, l: Rc<Type>, r: Rc<Type>) -> Result<(), TypeError> {
        let lres = self.resolve(Rc::clone(&l));
        let rres = self.resolve(Rc::clone(&r));

        match (lres, rres) {
            (Either::NotFound(n), _) => {
                self.bind(n, r);
                Ok(())
            }
            (_, Either::NotFound(n)) => {
                self.bind(n, l);
                Ok(())
            }
            (Either::Found(ltype), Either::Found(rtype)) => {
                match (&*ltype, &*rtype) {
                    (Type::Function(ll, lr), Type::Function(rl, rr)) => {
                        self.unify(Rc::clone(ll), Rc::clone(rl))?;
                        self.unify(Rc::clone(lr), Rc::clone(rr))?;
                        Ok(())
                    }
                    (Type::Base(ln, _), Type::Base(rn, _)) => {
                        if ln == rn {
                            Ok(())
                        } else {
                            Err(TypeError{msg: format!("could not resolve base types {} and {}", ln, rn)})
                        }
                    }
                    _ => {
                        Err(TypeError{msg: format!("cannot unify {:?} and {:?}", ltype, rtype)})
                    }
                }
            }
        }
    }

    pub fn bind(&mut self, name: String, t: Rc<Type>) {
        if let Type::Placeholder(id) = &*t {
            if *name == *id {
                return
            }
        }
        self.types.insert(name, t);
    }


    pub fn visit_appbase(&mut self, ab: &mut AppBase) -> Rc<Type> {
        match ab {
            AppBase::Int(_) => Rc::new(Type::Base(String::from("Int"), None)),
            AppBase::LowerId(name, _) => {
                self.env_lookup(&(*name).to_owned()).expect(&format!("{} is not a known function or symbol", name))
            }
            AppBase::UpperId(name, _) => self.env_lookup(&(*name).to_owned()).unwrap(),
            AppBase::Expr(expr) => expr.type_accept(self),
            AppBase::Match(matchexpr) => matchexpr.type_accept(self)
        }
    }

    pub fn visit_binop(&mut self, bo: &mut BinOp) -> Rc<Type> {
        let (ltype, rtype) = (bo.lhs.type_accept(self), bo.rhs.type_accept(self));
        let func_name = bo.kind.name();
        let func_type = self.env_lookup(&func_name);

        if func_type.is_none() {
            let _: () = Err(TypeError{msg: format!("\"{}\" is not a valid binary operation", func_name)}).unwrap();
        }

        let func_type = func_type.unwrap();
        let return_type = Rc::new(self.new_placeholder());
        let right_arrow = Rc::new(Type::Function(rtype, Rc::clone(&return_type)));
        let left_arrow = Rc::new(Type::Function(ltype, right_arrow));
        self.unify(func_type, left_arrow).unwrap();

        return_type
    }

    pub fn visit_app(&mut self, a: &mut App) -> Rc<Type> {
        let (ltype, rtype) = (a.left.type_accept(self), a.right.type_accept(self));
        let return_type = Rc::new(self.new_placeholder());
        let arrow = Rc::new(Type::Function(rtype, Rc::clone(&return_type)));
        self.unify(arrow, ltype).unwrap();

        return_type
    }

    pub fn visit_match(&mut self, m: &mut Match) -> Rc<Type> {
        let match_type = m.expr.type_accept(self);
        let branch_type = Rc::new(self.new_placeholder());

        for branch in m.branches.iter_mut() {
            self.push_env();
            self.matcht(Rc::clone(&match_type), &branch.pat);
            let curr_branch_type = branch.expr.type_accept(self);
            self.unify(curr_branch_type, Rc::clone(&branch_type)).unwrap();
            self.pop_env();
        }

        branch_type
    }

    fn matcht(&mut self, t: Rc<Type>, p: &Pattern) {
        match p {
            Pattern::Var(name) => self.env_bind((*name).to_owned(),  t),
            Pattern::Constr(name, params) => {
                let ctype = self.env_lookup(&(*name).to_owned());
                if ctype.is_none() {
                    let _: () = Err(TypeError{msg: format!("{} is not a matchable type", name)}).unwrap();
                }
                let mut ctype = ctype.unwrap();

                for param in params {
                    if let Type::Function(l, r) = &*ctype {
                        self.env_bind((*param).to_owned(), Rc::clone(l));
                        ctype = Rc::clone(r);
                    } else {
                        let _: () = Err(TypeError{msg: format!("\"{}\" is not a valid parameter for pattern constructor \"{}\"", param, name)}).unwrap();
                    }
                }

                self.unify(t, Rc::clone(&ctype)).unwrap();
                if let Type::Base(_, _) = &*ctype {} else {
                    let _: () = Err(TypeError{msg: format!("\"{}\" is not a valid pattern constructor", name)}).unwrap();
                }
            }
        }
    }
}


pub struct TypeResolveVisitor<'a> {
    tv: &'a TypeVisitor
}

impl<'a> TypeResolveVisitor<'a> {
    pub fn new(tv: &'a TypeVisitor) -> TypeResolveVisitor {
        TypeResolveVisitor { tv }
    }

    fn resolve(&self, t: Rc<Type>) -> Option<Rc<Type>> {
        if let Type::Function(l, r) = &*t {
            let (lres, rres) = (self.tv.resolve(Rc::clone(l)), self.resolve(Rc::clone(r)));
            match (lres, rres) {
                (Either::Found(ltype), Some(rtype)) => Some(Rc::new(Type::Function(ltype, rtype))),
                (_, _) => None
            }
        } else {
            match self.tv.resolve(t) {
                Either::Found(base_type) => Some(base_type),
                _ => None
            }
        }
    }

    pub fn resolve_type(&self, t: &mut Rc<Type>) -> Result<(), TypeError> {
        let r = self.resolve(Rc::clone(t));
        if let Some(rtype) = r {
            *t = rtype;
            Ok(())
        } else {
            Err(TypeError{msg: format!("couldn't resolve type {:?}", t)})
        }
    }

    fn resolve_ast(&self, n: &mut dyn AST) -> Result<(), TypeError> {
        match self.resolve(n.get_type().unwrap()) {
            Some(resolved_type) => {
                n.set_type(resolved_type);
                Ok(())
            },
            None => Err(TypeError{msg: format!("failed to resolve the following expression: {:?}", n)})
        }
    }
}

impl<'a> Visitor for TypeResolveVisitor<'a> {

    fn visit_appbase(&mut self, ab: &mut AppBase) {
        match ab {
            AppBase::Expr(expr) => expr.accept(self),
            AppBase::Match(matchexpr) => matchexpr.accept(self),
            _ => ()
        }
        self.resolve_ast(ab).unwrap();
    }

    fn visit_binop(&mut self, bo: &mut BinOp) {
        bo.lhs.accept(self);
        bo.rhs.accept(self);
        self.resolve_ast(bo).unwrap();
    }

    fn visit_app(&mut self, a: &mut App) {
        a.left.accept(self);
        a.right.accept(self);
        self.resolve_ast(a).unwrap();
    }

    fn visit_match(&mut self, m: &mut Match) {
        m.expr.accept(self);
        for branch in m.branches.iter_mut() {
            branch.expr.accept(self);
        }
        self.resolve_ast(m).unwrap();
    }

}

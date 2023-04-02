use super::free_var_visit::FreeVarVisitor;
use super::type_env::{FixedTypeEnvStack, TypeEnv};
use super::{PlaceholderGenerator, Type, TypeError};
use crate::ast::*;
use id_arena::Id;
use std::collections::{HashMap, HashSet};
use std::rc::Rc;
use std::result::Result;

pub enum Either<U, V> {
    Found(U),
    NotFound(V),
}

pub struct TypeVisitor {
    pg: PlaceholderGenerator,
    pub types: HashMap<String, Rc<Type>>,
    pub env_stack: FixedTypeEnvStack,
}

impl TypeVisitor {
    pub fn new(fv: FreeVarVisitor) -> TypeVisitor {
        TypeVisitor {
            pg: fv.pg,
            types: HashMap::new(),
            env_stack: fv.env_stack.to_fixed(),
        }
    }

    pub fn new_placeholder(&mut self) -> Type {
        return self.pg.new_placeholder();
    }

    pub fn new_function(&mut self) -> Type {
        Type::Function(
            Rc::new(self.new_placeholder()),
            Rc::new(self.new_placeholder()),
        )
    }

    pub fn resolve(&self, t: Rc<Type>) -> Either<Rc<Type>, (String, Rc<Type>)> {
        let mut curr_type = Rc::clone(&t);
        print!("resolve {:?} => ", curr_type);

        let mut ctr: usize = 0;
        while let Type::Placeholder(id) = &*curr_type {
            if let Some(found_type) = self.types.get(id) {
                if ctr > 100 {
                    panic!("hit resolve limit")
                } else {
                    ctr += 1;
                }
                print!("{:?} => ", found_type);
                curr_type = Rc::clone(found_type);
            } else {
                println!("not found");
                return Either::NotFound((id.clone(), Rc::clone(&curr_type)));
            }
        }
        println!("found: {:?}", curr_type);
        Either::Found(curr_type)
    }

    pub fn unify(&mut self, l: Rc<Type>, r: Rc<Type>) -> Result<(), TypeError> {
        println!("unify: {:?}, {:?}", l, r);
        let lres = self.resolve(Rc::clone(&l));
        let rres = self.resolve(Rc::clone(&r));

        match (lres, rres) {
            (Either::NotFound((n, _)), _) => {
                self.bind(n, r);
                Ok(())
            }
            (_, Either::NotFound((n, _))) => {
                self.bind(n, l);
                Ok(())
            }
            (Either::Found(ltype), Either::Found(rtype)) => match (&*ltype, &*rtype) {
                (Type::Function(ll, lr), Type::Function(rl, rr)) => {
                    self.unify(Rc::clone(ll), Rc::clone(rl))?;
                    self.unify(Rc::clone(lr), Rc::clone(rr))?;
                    Ok(())
                }
                (Type::Base(ln, _), Type::Base(rn, _)) => {
                    if ln == rn {
                        Ok(())
                    } else {
                        Err(TypeError {
                            msg: format!("could not resolve base types {} and {}", ln, rn),
                        })
                    }
                }
                _ => Err(TypeError {
                    msg: format!("cannot unify {:?} and {:?}", ltype, rtype),
                }),
            },
        }
    }

    pub fn bind(&mut self, name: String, t: Rc<Type>) {
        println!("bound {} to {:?}", name, t);
        if let Type::Placeholder(id) = &*t {
            if *name == *id {
                return;
            }
        }
        self.types.insert(name, t);
    }

    pub fn visit_func_defn(&mut self, fd: &mut FuncDefinition) {
        let body_type = fd.body.type_accept(self);
        self.unify(Rc::clone(fd.return_type.as_ref().unwrap()), body_type)
            .unwrap();
    }

    // Try to generalize a function's type as much as possible (for polymorphism)
    pub fn generalize_func_type(&mut self, env_id: Id<TypeEnv>, name: &String) {
        if let Some(scheme) = self.env_stack.arena.get(env_id).unwrap().names.get(name) {
            if !scheme.borrow().forall.is_empty() {
                let _: () = Err(TypeError {
                    msg: format!(
                        "cannot generalize type of function \"{}\" multiple times",
                        name
                    ),
                })
                .unwrap();
            }
            let mut free_vars = HashSet::new();
            self.find_free_vars(&scheme.borrow().monotype, &mut free_vars);
            for free_var in free_vars {
                scheme.borrow_mut().forall.push(free_var);
            }
        } else {
            let _: () = Err(TypeError {
                msg: format!(
                    "cannot generalize type of non-existent function \"{}\"",
                    name
                ),
            })
            .unwrap();
        }
    }

    // Find free type variables for generalizing a function's type.
    pub fn find_free_vars(&self, t: &Rc<Type>, free_vars: &mut HashSet<String>) {
        match self.resolve(Rc::clone(t)) {
            Either::NotFound((placeholder_name, _)) => {
                free_vars.insert(placeholder_name);
            }
            Either::Found(found_type) => {
                if let Type::Function(l, r) = &*found_type {
                    self.find_free_vars(l, free_vars);
                    self.find_free_vars(r, free_vars);
                }
            }
        }
    }

    pub fn print_global_names(&self) {
        let global_id = self.env_stack.global_env_id;
        for (name, type_scheme) in &self.env_stack.get_env(global_id).names {
            println!("{}: {}", name, type_scheme.borrow().format(self));
        }
    }

    pub fn visit_appbase(&mut self, ab: &mut AppBase) -> Rc<Type> {
        match &mut ab.data {
            AppBaseData::Int(_) => Rc::new(Type::Base(String::from("Int"), None)),
            AppBaseData::String(_) => Rc::new(Type::Base(String::from("String"), None)),
            AppBaseData::LowerId(name) => {
                let type_scheme = self
                    .env_stack
                    .lookup(&(*name).to_owned(), ab.mtype_env.unwrap())
                    .expect(&format!("{} is not a known function or symbol", name));
                let borrowed = type_scheme.borrow();
                borrowed.instantiate(self)
            }
            AppBaseData::UpperId(name) => {
                let type_scheme = self
                    .env_stack
                    .lookup(&(*name).to_owned(), ab.mtype_env.unwrap())
                    .expect(&format!("{} is not a known data constructor", name));
                let borrowed = type_scheme.borrow();
                borrowed.instantiate(self)
            }
            AppBaseData::Expr(expr) => expr.type_accept(self),
            AppBaseData::Match(matchexpr) => matchexpr.type_accept(self),
        }
    }

    pub fn visit_binop(&mut self, bo: &mut BinOp) -> Rc<Type> {
        let (ltype, rtype) = (bo.lhs.type_accept(self), bo.rhs.type_accept(self));
        let func_name = bo.kind.name();
        let type_scheme = self.env_stack.lookup(&func_name, bo.mtype_env.unwrap());

        if type_scheme.is_none() {
            let _: () = Err(TypeError {
                msg: format!("\"{}\" is not a valid binary operation", func_name),
            })
            .unwrap();
        }

        let type_scheme = type_scheme.unwrap();
        let func_type = type_scheme.borrow().instantiate(self);
        let return_type = Rc::new(self.new_placeholder());
        let right_arrow = Rc::new(Type::Function(rtype, Rc::clone(&return_type)));
        let left_arrow = Rc::new(Type::Function(ltype, right_arrow));
        self.unify(left_arrow, func_type).unwrap();

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
        println!("match expr type: {:?}", match_type);
        let match_type = match self.resolve(match_type) {
            Either::Found(found_type) => found_type,
            Either::NotFound((_, placeholder_type)) => placeholder_type,
        };
        let branch_type = Rc::new(self.new_placeholder());
        println!("match result type: {:?}", branch_type);
        for branch in &mut m.branches {
            self.typecheck_match(
                Rc::clone(&match_type),
                &branch.pat,
                branch.expr.get_type_env().unwrap(),
            );
            let curr_branch_type = branch.expr.type_accept(self);
            println!(
                "about to unify branch result type {:?} and current branch type {:?}",
                branch_type, curr_branch_type
            );
            self.unify(Rc::clone(&branch_type), curr_branch_type)
                .unwrap();
        }

        let resolved_type = match self.resolve(match_type) {
            Either::Found(found_type) => found_type,
            Either::NotFound((_, placeholder_type)) => placeholder_type,
        };
        if let Type::Base(_, Some(_)) = &*resolved_type {
        } else {
            let _: () = Err(TypeError {
                msg: format!("cannot match non-sum type"),
            })
            .unwrap();
        }
        m.input_type = Some(resolved_type);
        branch_type
    }

    fn typecheck_match(&mut self, match_type: Rc<Type>, p: &Pattern, branch_env: Id<TypeEnv>) {
        match p {
            Pattern::Var(name) => {
                let type_scheme = self
                    .env_stack
                    .lookup(&((*name).to_owned()), branch_env)
                    .unwrap();
                let branch_type = type_scheme.borrow().instantiate(self);
                self.unify(branch_type, match_type).unwrap()
            }
            Pattern::Constr(name, params) => {
                let type_scheme = self.env_stack.lookup(&(*name).to_owned(), branch_env);
                if type_scheme.is_none() {
                    let _: () = Err(TypeError {
                        msg: format!("cannot match on invalid constructor  \"{}\"", name),
                    })
                    .unwrap();
                }
                let type_scheme = type_scheme.unwrap();
                let mut constr_type = type_scheme.borrow().instantiate(self);

                for param in params {
                    if let Type::Function(l, r) = &*constr_type {
                        //self.env_stack.bind((*param).to_owned(), Rc::clone(l));
                        let branch_scheme = self
                            .env_stack
                            .lookup(&(*param).to_owned(), branch_env)
                            .unwrap();
                        let param_type = branch_scheme.borrow().instantiate(self);
                        self.unify(param_type, Rc::clone(l)).unwrap();
                        constr_type = Rc::clone(r);
                    } else {
                        let _: () = Err(TypeError {
                            msg: format!(
                                "\"{}\" is not a valid parameter for pattern constructor \"{}\"",
                                param, name
                            ),
                        })
                        .unwrap();
                    }
                }

                self.unify(match_type, Rc::clone(&constr_type)).unwrap();
            }
        }
    }
}

/*pub struct TypeResolveVisitor<'a> {
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
        match &mut ab.data {
            AppBaseData::Expr(expr) => expr.accept(self),
            AppBaseData::Match(matchexpr) => matchexpr.accept(self),
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
*/

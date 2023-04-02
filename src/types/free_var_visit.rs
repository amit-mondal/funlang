use super::type_env::TypeEnvStack;
use super::{PlaceholderGenerator, Type};
use crate::ast::*;
use std::collections::HashSet;
use std::rc::Rc;

pub struct FreeVarVisitor {
    pub pg: PlaceholderGenerator,
    pub env_stack: TypeEnvStack,
    free_vars: HashSet<String>,
}

impl FreeVarVisitor {
    pub fn new() -> FreeVarVisitor {
        FreeVarVisitor {
            pg: PlaceholderGenerator::new(),
            env_stack: TypeEnvStack::new(),
            free_vars: HashSet::new(),
        }
    }

    pub fn visit_func_defn(&mut self, fd: &mut FuncDefinition) {
        // To ensure that the swap at the end actually left us with a fresh vector.
        assert!(self.free_vars.is_empty());
        fd.mtype_env = self.env_stack.curr_env_id();
        self.env_stack.push(); // This env is for local function variables.
        fd.var_mtype_env = self.env_stack.curr_env_id();
        let mut full_type = Rc::new(self.pg.new_placeholder());
        fd.return_type = Some(Rc::clone(&full_type));

        for param in fd.params.iter().rev() {
            let param_type = Rc::new(self.pg.new_placeholder());
            full_type = Rc::new(Type::Function(Rc::clone(&param_type), full_type));
            self.env_stack
                .bind_from_type((*param).to_owned(), param_type);
        }
        fd.full_type = Some(full_type);
        fd.body.accept(self);
        self.env_stack.pop();

        // Ideally, we'd just pass a reference to the free_vars owned by the FuncDefinition, since
        // ultimately that's where we want free vars to end up. However, that would get really
        // messy with lifetimes and using Option, so instead we simply do a swap here with the
        // FuncDefinition's member, which is empty when this is called.
        std::mem::swap(&mut self.free_vars, &mut fd.free_vars);
    }
}

impl Visitor for FreeVarVisitor {
    fn visit_appbase(&mut self, ab: &mut AppBase) {
        ab.mtype_env = Some(self.env_stack.curr_env_id().unwrap());

        match &mut ab.data {
            AppBaseData::LowerId(s) => {
                let s = s.to_owned();
                if self.env_stack.lookup(&s).is_none() {
                    self.free_vars.insert(s);
                }
            }
            AppBaseData::Expr(e) => e.accept(self),
            AppBaseData::Match(e) => e.accept(self),
            _ => (),
        }
    }

    fn visit_binop(&mut self, bo: &mut BinOp) {
        bo.mtype_env = Some(self.env_stack.curr_env_id().unwrap());
        bo.lhs.accept(self);
        bo.rhs.accept(self);
    }

    fn visit_app(&mut self, a: &mut App) {
        a.mtype_env = Some(self.env_stack.curr_env_id().unwrap());
        a.left.accept(self);
        a.right.accept(self);
    }

    fn visit_match(&mut self, m: &mut Match) {
        m.mtype_env = Some(self.env_stack.curr_env_id().unwrap());
        m.expr.accept(self);
        for branch in &mut m.branches {
            self.env_stack.push();
            branch.pat.insert_bindings(self);
            branch.expr.accept(self);
            self.env_stack.pop();
        }
    }
}

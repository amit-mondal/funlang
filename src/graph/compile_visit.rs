use crate::ast::*;
use crate::types::Type;
use super::SemanticError;
use super::stack_env::{StackEnv, OffsetEnv, VarEnv};
use super::instructions::{Instruction, JumpInstruction};

pub struct CompileVisitor {
    insn_stack: Vec<Vec<Instruction>>,
    curr_env: Option<Box<dyn StackEnv>>
}


impl CompileVisitor {
    pub fn new() -> CompileVisitor {
        CompileVisitor { insn_stack: Vec::new(), curr_env: None }
    }

    pub fn env_get_offset(&self, name: &str) -> Option<usize> {
        self.curr_env.as_ref().unwrap().get_offset(name)
    }

    pub fn push_offset_env(&mut self, offset: usize) {
        let new_env = Box::new(OffsetEnv::from_parent(offset, self.curr_env.take()));
        self.curr_env = Some(new_env);
    }

    pub fn push_var_env(&mut self, name: String) {
        let new_env = Box::new(VarEnv::from_parent(name, self.curr_env.take()));
        self.curr_env = Some(new_env);
    }

    pub fn pop_env(&mut self) {
        let old_env = self.curr_env.take().unwrap().take_parent();
        self.curr_env = old_env;
    }

    fn insns(&mut self) -> &mut Vec<Instruction> {
        self.insn_stack.last_mut().unwrap()
    }

    pub fn push_insns(&mut self) {
        self.insn_stack.push(Vec::new());
    }

    pub fn pop_insns(&mut self) -> Option<Vec<Instruction>> {
        self.insn_stack.pop()
    }
}

impl Visitor for CompileVisitor {
    
    fn visit_appbase(&mut self, ab: &mut AppBase) {
        match ab {
            AppBase::Int(i) => self.insns().push(Instruction::PushInt(*i)),
            AppBase::LowerId(name, _) =>
                    if let Some(offset) = self.env_get_offset(name) {
                        self.insns().push(Instruction::Push(offset))
                    } else {
                        self.insns().push(Instruction::PushGlobal((*name).to_owned()))
                    },
            AppBase::UpperId(name, _) => self.insns().push(Instruction::PushGlobal((*name).to_owned())),
            AppBase::Expr(expr) => expr.accept(self),
            AppBase::Match(matchexpr) => matchexpr.accept(self)
        }
    }

    fn visit_binop(&mut self, bo: &mut BinOp) {
        bo.rhs.accept(self);
        self.push_offset_env(1);
        bo.lhs.accept(self);
        self.pop_env(); 
        self.insns().push(Instruction::PushGlobal(bo.kind.action()));
        self.insns().push(Instruction::MkApp);
        self.insns().push(Instruction::MkApp);
    }

    fn visit_app(&mut self, a: &mut App) {
        a.right.accept(self);
        self.push_offset_env(1);
        a.left.accept(self);
        self.pop_env();
        self.insns().push(Instruction::MkApp);
    }

    fn visit_match(&mut self, m: &mut Match) {
        let expr_type = m.expr.get_type().unwrap();
        /* This should always be true, the typechecking pass ensures that match expression types
        are base types with valid pattern constructors */
        if let Type::Base(type_name, Some(type_data)) = &*expr_type {
            m.expr.accept(self);
            self.insns().push(Instruction::Eval);
            
            //let mut jump_insn = self.insns().last_mut().unwrap();
            let placeholder_idx = self.insns().len();
            self.insns().push(Instruction::JumpPlaceholder);
            let mut jump_insn = JumpInstruction::new();

            for branch in m.branches.iter_mut() {
                /* Each branch gets its own set of instructions to jump to */
                self.push_insns();
                match &branch.pat {
                    Pattern::Var(_) => {
                        self.push_offset_env(1);
                        branch.expr.accept(self);
                        self.pop_env();

                        for (_, tag) in type_data.borrow().constr_tags.iter() {
                            if jump_insn.tag_mappings.contains_key(&tag) {
                                break;
                            } else {
                                jump_insn.tag_mappings.insert(*tag, jump_insn.branches.len());
                            }
                        }
                    }
                    Pattern::Constr(constr_name, params) => {
                        for param in params.iter().rev() {
                            self.push_var_env((*param).to_owned());
                        }

                        self.insns().push(Instruction::Split(params.len()));
                        branch.expr.accept(self);

                        for _ in 0..params.len() {
                            self.pop_env();
                        }

                        self.insns().push(Instruction::Slide(params.len()));
                        
                        let type_data_ref = type_data.borrow();
                        let new_tag = type_data_ref.constr_tags.get(&(*constr_name).to_owned()).unwrap();
                        if jump_insn.tag_mappings.contains_key(new_tag) {
                            let _: () = Err(SemanticError{msg: format!("cannot reach pattern \"{}\" because it is a duplicate pattern", constr_name)}).unwrap();
                        }

                        jump_insn.tag_mappings.insert(*new_tag, jump_insn.branches.len());
                    }               
                }
                jump_insn.branches.push(self.pop_insns().unwrap());
            }
            
            for (constr_name, tag) in type_data.borrow().constr_tags.iter() {
                if !jump_insn.tag_mappings.contains_key(tag) {
                    let _: () = Err(SemanticError{msg: format!("match on type {} does not contain the pattern {}", type_name, constr_name)}).unwrap();
                }
            }
            
            // Replace the jump instruction placeholder now that we're done making the instruction.
            self.insns()[placeholder_idx] = Instruction::Jump(jump_insn);
        } else {
            panic!("Expected Base(_, Some(_)), found {:?}", expr_type)
        }
    }
}

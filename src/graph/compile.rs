use super::compile_visit::CompileVisitor;
use super::instructions::Instruction;
use crate::ast::{Definition, FuncDefinition, Program};

pub struct CompileContext {
    visitor: CompileVisitor
}


impl CompileContext {

    pub fn new() -> CompileContext {
        let mut cv = CompileVisitor::new();
        cv.push_offset_env(0);

        CompileContext { visitor: cv }
    }

    pub fn compile(&mut self, p: &mut Program) -> Vec<Vec<Instruction>> {
        let mut res = Vec::new();

        for def in p.defns.iter_mut() {
            if let Definition::Func(fd) = def {
                res.push(self.compile_func_definition(fd))
            }
        }

        res
    }
    
    fn compile_func_definition(&mut self, fd: &mut FuncDefinition) -> Vec<Instruction> {
        self.visitor.push_insns();

        for param in fd.params.iter().rev() {
            self.visitor.push_var_env((*param).to_owned());
        }
        
        fd.body.accept(&mut self.visitor);
        for _ in 0..fd.params.len() {
            self.visitor.pop_env();
        }

        let mut res = self.visitor.pop_insns().unwrap();

        res.push(Instruction::Update(fd.params.len()));
        res.push(Instruction::Pop(fd.params.len()));

        res
    }
    
}

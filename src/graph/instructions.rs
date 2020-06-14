
use std::collections::HashMap;
use crate::ast::BinOpType;

#[derive(Debug)]
pub struct JumpInstruction {
    pub branches: Vec<Vec<Instruction>>,
    pub tag_mappings: HashMap<i32, usize>
}

impl JumpInstruction {
    pub fn new() -> JumpInstruction {
        JumpInstruction { branches: Vec::new(), tag_mappings: HashMap::new() }
    }
}

#[derive(Debug)]
pub enum Instruction {
    PushInt(i32),
    PushGlobal(String),
    Push(usize),
    Pop(usize),
    MkApp,
    Update(usize),
    Pack(usize, i32),
    Split(usize),
    Jump(JumpInstruction),
    JumpPlaceholder,
    Slide(usize),
    BinOp(BinOpType),
    Eval,
    Alloc(usize),
    Unwind
}


mod compile_visit;
mod stack_env;
pub mod compile;
pub mod instructions;

use std::fmt;
use std::error::Error;

#[derive(Debug)]
pub struct SemanticError {
    msg: String
}

impl fmt::Display for SemanticError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "SemanticError: {}", self.msg)
    }
}

impl Error for SemanticError {}

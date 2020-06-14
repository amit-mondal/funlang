
#[macro_use] extern crate lalrpop_util;

lalrpop_mod!(pub fun);

mod types;
mod ast;
mod graph;
mod codegen;

use types::typecheck::TypecheckContext;
use graph::compile::CompileContext;
use inkwell::context::Context;
use codegen::llvm_gen::LLVMGenerator;


fn main() {

    let mut tree = fun::ProgramParser::new().parse("

type List = {
    Cons Int List, Nil
}

fun applyToList fn l i = {
    match l with {
        Cons x xs => {
            Cons (fn x i) xs
        }
        Nil => { Nil }
    }
}

fun add x y = {
    x + y
}

fun ones = { Cons 1 ones }

fun fst l = {
    match l with {
        Cons x xs => { x }
        Nil => { 0 }
    }
}

fun main = {
    fst (applyToList add ones 2)
}

").unwrap();

//length (Cons 5 (Cons 4 (Cons 3 (Cons 2 (Cons 1 Nil)))))

    
    TypecheckContext::new().typecheck(&mut tree);
    let instructions = CompileContext::new().compile(&mut tree);

    println!("{:?}", instructions);

    let ctx = Context::create();
    let mut llvmgen = LLVMGenerator::new(&ctx);
    llvmgen.generate(&mut tree, &instructions, Some("out.ll"), "out.o").unwrap();
}

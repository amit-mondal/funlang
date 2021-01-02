
#[macro_use] extern crate lalrpop_util;

lalrpop_mod!(pub fun);

mod types;
mod ast;
mod graph;
mod codegen;

use clap::{App, Arg};
use std::fs;

use types::typecheck::TypecheckContext;
use graph::compile::CompileContext;
use inkwell::context::Context;
use codegen::llvm_gen::{self, LLVMGenerator};



fn main() {

    let matches = App::new("funlangc")
                            .version("1.0")
                            .author("Amit M.")
                            .about("LLVM compiler for funlang")
                            .arg(Arg::with_name("INPUT")
                                .help("Sets the input file to use")
                                .required(true)
                                .index(1))
                            .arg(Arg::with_name("output_file")
                                .short("o")
                                .long("output")
                                .value_name("FILE")
                                .help("Sets the name of the output object file")
                                .takes_value(true)
                                .default_value("out.o"))
                            .arg(Arg::with_name("llvm_file")
                                .short("lo")
                                .long("llvm-out")
                                .value_name("LLVMFILE")
                                .help("Set then name of the output LLVM bitcode file")
                                .takes_value(true)) 
                            .arg(Arg::with_name("print_instructions")
                                .short("pi")
                                .long("print-instructions")
                                .help("Print the intermediate G-machine instructions"))
                            .get_matches();

    let source_file = matches.value_of("INPUT").unwrap();
    let output_file = matches.value_of("output_file").unwrap();
    let llvmout_file_opt = matches.value_of("llvm_file");

    let source = fs::read_to_string(source_file).
        expect(&format!("Failed to read input file {}", source_file));

    let mut tree = fun::ProgramParser::new().parse(&source).unwrap();

    TypecheckContext::new().typecheck(&mut tree);
    let instructions = CompileContext::new().compile(&mut tree);

    if matches.is_present("print_instructions") {
        println!("{:?}", instructions);
    }

    let ctx = Context::create();
    let mut llvmgen = LLVMGenerator::new(&ctx);
    llvmgen.generate(&mut tree, &instructions, llvmout_file_opt, output_file).unwrap();
}

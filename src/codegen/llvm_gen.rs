use super::{CustomFunc, ExternFunc, GenContext};
use crate::ast::{BinOpType, ExternDecl, FuncDefinition, Program, VariantDefinition};
use crate::graph::instructions::{Instruction, JumpInstruction};
use inkwell::basic_block::BasicBlock;
use inkwell::context::Context;
use inkwell::targets::{
    CodeModel, FileType, InitializationConfig, RelocMode, Target, TargetMachine,
};
use inkwell::values::{FunctionValue, IntValue};
use inkwell::OptimizationLevel;
use std::collections::HashMap;
use std::path::Path;

pub struct LLVMGenerator<'ctx> {
    gc: GenContext<'ctx>,
    custom_funcs: HashMap<String, CustomFunc<'ctx>>,
    generated_funcs: Vec<FunctionValue<'ctx>>,
    extern_funcs: Vec<ExternFunc<'ctx>>
}

impl<'ctx> LLVMGenerator<'ctx> {
    pub fn new(ctx: &'ctx Context) -> LLVMGenerator<'ctx> {
        LLVMGenerator {
            gc: GenContext::new(ctx),
            custom_funcs: HashMap::new(),
            generated_funcs: Vec::new(),
            extern_funcs: Vec::new(),
        }
    }

    fn generate_llvm(&self, i: &Instruction, f: FunctionValue<'ctx>) {
        match i {
            Instruction::PushInt(i) => {
                self.gc
                    .create_push(f, self.gc.create_num(f, self.gc.create_i32(*i).into()));
            }
            Instruction::PushString(s) => {
                self.gc.create_push(
                    f,
                    self.gc.create_str(
                        f,
                        self.gc.create_const_str_as_ptr(s).into(),
                        self.gc.create_i32(s.len() as i32).into(),
                    ),
                );
            }
            Instruction::PushGlobal(n) => {
                let foo = self
                    .custom_funcs
                    .iter()
                    .map(|(name, _)| name)
                    .collect::<Vec<_>>();
                let global_func = self.custom_funcs.get(&(String::from("f_") + &n)).unwrap();
                let arity_val = self.gc.create_i32(global_func.arity as i32);
                let global_func_as_ptr = global_func.func.as_global_value().as_pointer_value();
                self.gc.create_push(
                    f,
                    self.gc
                        .create_global(f, global_func_as_ptr.into(), arity_val.into()),
                );
            }
            Instruction::Push(o) => {
                self.gc
                    .create_push(f, self.gc.create_peek(f, self.gc.create_size(*o).into()));
            }
            Instruction::Pop(c) => {
                self.gc.create_popn(f, self.gc.create_size(*c).into());
            }
            Instruction::MkApp => {
                let l = self.gc.create_pop(f);
                let r = self.gc.create_pop(f);
                self.gc.create_push(f, self.gc.create_app(f, l, r));
            }
            Instruction::Update(o) => {
                self.gc.create_update(f, self.gc.create_size(*o).into());
            }
            Instruction::Pack(size, tag) => {
                self.gc.create_pack(
                    f,
                    self.gc.create_size(*size).into(),
                    self.gc.create_i8(*tag as i8).into(),
                );
            }
            Instruction::Split(size) => {
                self.gc.create_split(f, self.gc.create_size(*size).into());
            }
            Instruction::Jump(ji) => {
                self.jump_generate_llvm(&ji, f);
            }
            Instruction::Slide(o) => {
                self.gc.create_slide(f, self.gc.create_size(*o).into());
            }
            Instruction::BinOp(op) => {
                self.binop_generate_llvm(op, f);
            }
            Instruction::Eval => {
                //self.gc.create_push(f, self.gc.create_eval(self.gc.create_pop(f)));
                self.gc.create_unwind(f);
            }
            Instruction::Alloc(amt) => {
                self.gc.create_alloc(f, self.gc.create_size(*amt).into());
            }
            Instruction::Unwind => (),
            Instruction::JumpPlaceholder => panic!("Found placeholder instruction!"),
        }
    }

    fn jump_generate_llvm(&self, ji: &JumpInstruction, f: FunctionValue<'ctx>) {
        let top_node = self.gc.create_peek(f, self.gc.create_size(0).into());
        let tag = self
            .gc
            .unwrap_data_tag(top_node.into_pointer_value())
            .into_int_value();

        let curr_block = self.gc.builder.get_insert_block().unwrap();
        let safety_block = self.gc.ctx.append_basic_block(f, "safety_block");

        let branch_blocks: Vec<BasicBlock> = ji
            .branches
            .iter()
            .map(|branch| {
                let block = self.gc.ctx.append_basic_block(f, "match_branch");
                self.gc.builder.position_at_end(block);
                for instruction in branch {
                    self.generate_llvm(instruction, f);
                }
                self.gc.builder.build_unconditional_branch(safety_block);
                block
            })
            .collect();

        let cases: Vec<(IntValue, BasicBlock)> = ji
            .tag_mappings
            .iter()
            .map(|(tag, idx)| (self.gc.create_i8(*tag as i8).into(), branch_blocks[*idx]))
            .collect();

        self.gc.builder.position_at_end(curr_block); // Place the switch insn at the end of the entry block.
        self.gc
            .builder
            .build_switch(tag.into(), safety_block, &cases);
        self.gc.builder.position_at_end(safety_block);
    }

    fn binop_generate_llvm(&self, op: &BinOpType, f: FunctionValue<'ctx>) {
        let left = self
            .gc
            .unwrap_num(self.gc.create_pop(f).into_pointer_value())
            .into_int_value();
        let right = self
            .gc
            .unwrap_num(self.gc.create_pop(f).into_pointer_value())
            .into_int_value();

        let op_val: IntValue = match op {
            BinOpType::Plus => self.gc.builder.build_int_add(left, right, "int_add"),
            BinOpType::Minus => self.gc.builder.build_int_sub(left, right, "int_sub"),
            BinOpType::Times => self.gc.builder.build_int_mul(left, right, "int_mul"),
            BinOpType::Divide => self
                .gc
                .builder
                .build_int_signed_div(left, right, "int_sdiv"),
        };

        self.gc.create_push(f, self.gc.create_num(f, op_val.into()));
    }

    fn type_generate_llvm(&mut self, td: &VariantDefinition) {
        for constr in td.constructors.iter() {
            let constr_func = self.gc.create_custom_func(
                &mut self.custom_funcs,
                constr.name.to_owned(),
                constr.types.len(),
            );

            self.gc
                .builder
                .position_at_end(constr_func.get_last_basic_block().unwrap());

            [
                Instruction::Pack(constr.types.len(), constr.tag),
                Instruction::Update(0),
            ]
            .iter()
            .for_each(|insn| self.generate_llvm(insn, constr_func));

            self.gc.builder.build_return(None);
        }
    }

    fn func_declare_llvm(&mut self, fd: &FuncDefinition) {
        self.generated_funcs.push(self.gc.create_custom_func(
            &mut self.custom_funcs,
            fd.name.to_owned(),
            fd.params.len(),
        ));
    }

    fn extern_func_declare_llvm(&mut self, ed: &ExternDecl) {
        let arity = ed.type_decl.arrow_separated.len() - 1;
        self.extern_funcs.push(self.gc.create_extern_func(
            &mut self.custom_funcs,
            ed.name.to_owned(),
            &ed.extern_name,
            arity,
        ));
    }

    fn func_instructions_generate(
        &self,
        func_insns: &Vec<Instruction>,
        generated_func: FunctionValue<'ctx>,
    ) {
        self.gc
            .builder
            .position_at_end(generated_func.get_last_basic_block().unwrap());
        for insn in func_insns.iter() {
            self.generate_llvm(insn, generated_func);
        }
        self.gc.builder.build_return(None);
    }

    fn extern_func_instructions_generate(
        &self,
        extern_func: &ExternFunc<'ctx>
    ) {
        self.gc
            .builder
            .position_at_end(extern_func.internal_func.get_last_basic_block().unwrap());
        for _ in 0..extern_func.arity {
            self.generate_llvm(&Instruction::Push(extern_func.arity - 1), extern_func.internal_func);
            self.generate_llvm(&Instruction::Eval, extern_func.internal_func);
        }
        let gmachine_ptr = extern_func.internal_func.get_first_param().unwrap();
        let args = {
            let mut args = Vec::with_capacity(extern_func.arity + 1);
            args.push(gmachine_ptr.into());
            for _ in 0..extern_func.arity {
                args.push(self.gc.create_pop(extern_func.internal_func).into())
            }
            args
        };
        print!("extern name: {}", extern_func.external_name);
        let res = self
            .gc
            .builder
            .build_call(extern_func.external_func, &args, &extern_func.external_name)
            .try_as_basic_value()
            .left()
            .unwrap();
        self.gc.create_push(extern_func.internal_func, res);
        self.generate_llvm(&Instruction::Update(extern_func.arity), extern_func.internal_func);
        self.generate_llvm(&Instruction::Pop(extern_func.arity), extern_func.internal_func);
        self.gc.builder.build_return(None);
    }

    fn define_internal_binop(&mut self, op: BinOpType) {
        let new_func = self
            .gc
            .create_custom_func(&mut self.custom_funcs, op.action(), 2);
        self.gc
            .builder
            .position_at_end(new_func.get_last_basic_block().unwrap());

        [
            Instruction::Push(1),
            Instruction::Eval,
            Instruction::Push(1),
            Instruction::Eval,
            Instruction::BinOp(op),
            Instruction::Update(2),
            Instruction::Pop(2),
        ]
        .iter()
        .for_each(|instruction| self.generate_llvm(instruction, new_func));

        self.gc.builder.build_return(None);
    }

    pub fn generate(
        &mut self,
        p: &Program,
        insns: &Vec<(String, Vec<Instruction>)>,
        ir_out_file: Option<&str>,
        bin_out_file: &str,
    ) -> Result<(), String> {
        [
            BinOpType::Plus,
            BinOpType::Minus,
            BinOpType::Times,
            BinOpType::Divide,
        ]
        .iter()
        .for_each(|op| self.define_internal_binop(*op));

        for (_, type_defn) in &p.type_defns {
            self.type_generate_llvm(type_defn);
        }

        for (func_name, _) in insns {
            let func_defn = p.func_defns.get(func_name).unwrap();
            self.func_declare_llvm(func_defn);
        }

        for (_, extern_decl) in p.extern_decls.iter() {
            self.extern_func_declare_llvm(extern_decl)
        }

        for ((_, func_insns), generated_func) in insns.iter().zip(self.generated_funcs.iter()) {
            self.func_instructions_generate(func_insns, *generated_func);
        }

        for extern_func in &self.extern_funcs {
            self.extern_func_instructions_generate(extern_func)
        }

        if let Some(ir_file) = ir_out_file {
            self.gc.module.print_to_file(Path::new(ir_file)).unwrap();
        }

        self.output_binary(bin_out_file)
    }

    fn output_binary(&self, bin_out_file: &str) -> Result<(), String> {
        let default_triple = TargetMachine::get_default_triple();
        let init_config = InitializationConfig::default();

        Target::initialize_native(&init_config)?;
        let target = Target::from_triple(&default_triple).map_err(|l| l.to_string())?;
        let target_machine = target
            .create_target_machine(
                &default_triple,
                "generic",
                "",
                OptimizationLevel::Default,
                RelocMode::Default,
                CodeModel::Default,
            )
            .expect("failed to create generic target machine");

        self.gc
            .module
            .set_data_layout(&target_machine.get_target_data().get_data_layout());
        self.gc.module.set_triple(&default_triple);

        self.gc.module.verify().map_err(|l| l.to_string())?;

        target_machine
            .write_to_file(&self.gc.module, FileType::Object, &Path::new(bin_out_file))
            .map_err(|l| l.to_string())?;

        Ok(())
    }
}

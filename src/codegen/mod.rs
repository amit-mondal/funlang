use std::collections::HashMap;
use std::mem::size_of;

use inkwell::builder::Builder;
use inkwell::context::Context;
use inkwell::module::{Linkage, Module};
use inkwell::types::{FunctionType, IntType, PointerType, StructType};
use inkwell::values::{BasicValueEnum, FunctionValue, IntValue, PointerValue};
use inkwell::AddressSpace;

pub mod llvm_gen;

pub struct CustomFunc<'ctx> {
    func: FunctionValue<'ctx>,
    arity: usize,
}

struct GenContextTypes<'ctx> {
    struct_types: HashMap<String, StructType<'ctx>>,
    sizet_type: IntType<'ctx>,
    gmachine_type: StructType<'ctx>,
    gmachine_ptr_type: PointerType<'ctx>,
    stack_type: StructType<'ctx>,
    stack_ptr_type: PointerType<'ctx>,
    node_ptr_type: PointerType<'ctx>,
    tag_type: IntType<'ctx>,
    func_type: FunctionType<'ctx>,
}

pub struct GenContext<'ctx> {
    pub ctx: &'ctx Context,
    pub builder: Builder<'ctx>,
    module: Module<'ctx>,
    funcs: HashMap<String, FunctionValue<'ctx>>,
    types: GenContextTypes<'ctx>,
}

impl<'ctx> GenContext<'ctx> {
    fn init_types(ctx: &Context) -> GenContextTypes {
        let mut struct_types = HashMap::new();

        let sizet_type = match size_of::<usize>() {
            4 => ctx.i32_type(),
            8 => ctx.i64_type(),
            _ => panic!("usize is not 32 or 64 bits"),
        };

        let gmachine_type = ctx.opaque_struct_type("gmachine");

        let stack_type = ctx.opaque_struct_type("stack");
        let stack_ptr_type = stack_type.ptr_type(AddressSpace::Generic);

        let node_base = ctx.opaque_struct_type("node_base");
        let node_ptr_type = node_base.ptr_type(AddressSpace::Generic);

        

        // Warning! For some reason moving the node_base set_body call into the array below will cause
        // unwrap_node_val calls to segfault. Presumably they must be set before any instances of node_base are
        // used.
        node_base.set_body(&[ctx.i32_type().into(), ctx.i8_type().into(), node_ptr_type.into()], false);
        stack_type.set_body(
            &[sizet_type.into(), sizet_type.into(), node_ptr_type.ptr_type(AddressSpace::Generic).into()],
            false
        );
        gmachine_type.set_body(
            &[stack_type.into(), node_ptr_type.into(), ctx.i64_type().into(), ctx.i64_type().into()],
            false);

        let gmachine_ptr_type = gmachine_type.ptr_type(AddressSpace::Generic);
        let func_type = ctx.void_type().fn_type(&[gmachine_ptr_type.into()], false);

        [
            (
                "node_app",
                vec![node_base.into(), node_ptr_type.into(), node_ptr_type.into()],
            ),
            ("node_num", vec![node_base.into(), ctx.i32_type().into()]),
            ("node_global", vec![node_base.into(), ctx.i32_type().into()]),
            ("node_ind", vec![node_base.into(), node_ptr_type.into()]),
            (
                "node_data",
                vec![
                    node_base.into(),
                    ctx.i8_type().into(),
                    node_ptr_type.ptr_type(AddressSpace::Generic).into(),
                ],
            ),
        ]
        .iter()
        .for_each(|(name, field_types)| {
            let s = ctx.opaque_struct_type(name);
            s.set_body(&field_types, false);
            struct_types.insert((*name).to_owned(), s);
        });

        GenContextTypes {
            sizet_type,
            struct_types,
            gmachine_type,
            gmachine_ptr_type,
            stack_type,
            stack_ptr_type,
            node_ptr_type,
            tag_type: ctx.i8_type(),
            func_type,
        }
    }

    fn init_funcs(&mut self) {
        let ctx = self.ctx;
        let void_type = ctx.void_type();
        let sizet_type = self.types.sizet_type;
        let stack_ptr_type = self.types.stack_ptr_type;
        let gmachine_ptr_type = self.types.gmachine_ptr_type;
        let node_ptr_type = self.types.node_ptr_type;
        let func_ptr_type = self.types.func_type.ptr_type(AddressSpace::Generic);

        let basic_stack_fn = |name| {
            (name, void_type.fn_type(&[stack_ptr_type.into(), sizet_type.into()], false))};

        let basic_gmachine_fn = |name| {
            (name, void_type.fn_type(&[gmachine_ptr_type.into(), sizet_type.into()], false))
        };

        [
            (
                "stack_init",
                void_type.fn_type(&[stack_ptr_type.into()], false),
            ),
            (
                "stack_free",
                void_type.fn_type(&[stack_ptr_type.into()], false),
            ),
            (
                "stack_push",
                void_type.fn_type(&[stack_ptr_type.into(), node_ptr_type.into()], false),
            ),
            (
                "stack_pop",
                node_ptr_type.fn_type(&[stack_ptr_type.into()], false),
            ),
            (
                "stack_peek",
                node_ptr_type.fn_type(&[stack_ptr_type.into(), sizet_type.into()], false),
            ),
            basic_stack_fn("stack_popn"),
            (
                "alloc_app",
                node_ptr_type.fn_type(&[node_ptr_type.into(), node_ptr_type.into()], false),
            ),
            (
                "alloc_num",
                node_ptr_type.fn_type(&[ctx.i32_type().into()], false),
            ),
            (
                "alloc_global",
                node_ptr_type.fn_type(&[func_ptr_type.into(), ctx.i32_type().into()], false),
            ),
            (
                "alloc_ind",
                node_ptr_type.fn_type(&[node_ptr_type.into()], false),
            ),
            (
                "unwind",
                void_type.fn_type(&[gmachine_ptr_type.into()], false)
            ),
            (
                "gmachine_init",
                void_type.fn_type(&[gmachine_ptr_type.into()], false)
            ),
            (
                "gmachine_free",
                void_type.fn_type(&[gmachine_ptr_type.into()], false)
            ),
            basic_gmachine_fn("gmachine_slide"),
            basic_gmachine_fn("gmachine_update"),
            basic_gmachine_fn("gmachine_alloc"),
            (
                "gmachine_pack",
                void_type.fn_type(&[gmachine_ptr_type.into(), sizet_type.into(), ctx.i8_type().into()], false)
            ),
            basic_gmachine_fn("gmachine_split"),
            (
                "gmachine_track",
                node_ptr_type.fn_type(&[gmachine_ptr_type.into(), node_ptr_type.into()], false)
            )
        ]
        .into_iter()
        .for_each(|(name, func_type)| {
            let func = self
                .module
                .add_function(name, *func_type, Some(Linkage::External));
            self.funcs.insert((*name).to_owned(), func);
        });
    }

    pub fn new(ctx: &'ctx Context) -> GenContext<'ctx> {
        let mut g = GenContext {
            ctx: ctx,
            builder: ctx.create_builder(),
            module: ctx.create_module("funlang"),
            funcs: HashMap::new(),
            types: GenContext::init_types(&ctx),
        };

        g.init_funcs();
        g
    }

    pub fn create_custom_func(
        &self,
        custom_funcs: &mut HashMap<String, CustomFunc<'ctx>>,
        name: String,
        arity: usize,
    ) -> FunctionValue<'ctx> {
        let new_name = "f_".to_owned() + &name;
        let new_func =
            self.module
                .add_function(&new_name, self.types.func_type, Some(Linkage::External));

        self.ctx.append_basic_block(new_func, "entry");
        let custom_func = CustomFunc {
            func: new_func,
            arity,
        };
        custom_funcs.insert(new_name, custom_func);

        new_func
    }

    pub fn create_i8(&self, i: i8) -> IntValue<'ctx> {
        self.ctx.i8_type().const_int(i as u64, true)
    }

    pub fn create_i32(&self, i: i32) -> IntValue<'ctx> {
        self.ctx.i32_type().const_int(i as u64, true)
    }

    pub fn create_size(&self, s: usize) -> IntValue<'ctx> {
        match size_of::<usize>() {
            4 => self.ctx.i32_type(),
            8 => self.ctx.i64_type(),
            _ => panic!("usize is not 32 or 64 bits"),
        }
        .const_int(s as u64, true)
    }

    pub fn create_pop(&self, f: FunctionValue<'ctx>) -> BasicValueEnum<'ctx> {
        let func = self.funcs.get("stack_pop").unwrap();
        let stack_ptr = self.unwrap_gmachine_stack_ptr(f.get_first_param().unwrap().into_pointer_value());
        self.builder
            .build_call(*func, &[stack_ptr], "call_pop")
            .try_as_basic_value()
            .left()
            .unwrap()
    }

    pub fn create_peek(&self, f: FunctionValue<'ctx>, off: BasicValueEnum<'ctx>) -> BasicValueEnum<'ctx> {
        let func = self.funcs.get("stack_peek").unwrap();
        let stack_ptr = self.unwrap_gmachine_stack_ptr(f.get_first_param().unwrap().into_pointer_value());
        self.builder
            .build_call(*func, &[stack_ptr, off], "call_peek")
            .try_as_basic_value()
            .left()
            .unwrap()
    }

    pub fn create_push(&self, f: FunctionValue<'ctx>, v: BasicValueEnum<'ctx>) {
        let func = self.funcs.get("stack_push").unwrap();
        let stack_ptr = self.unwrap_gmachine_stack_ptr(f.get_first_param().unwrap().into_pointer_value());
        self.builder.build_call(*func, &[stack_ptr, v], "call_push");
    }

    pub fn create_popn(&self, f: FunctionValue<'ctx>, off: BasicValueEnum<'ctx>) {
        let func = self.funcs.get("stack_popn").unwrap();
        let stack_ptr = self.unwrap_gmachine_stack_ptr(f.get_first_param().unwrap().into_pointer_value());
        self.builder
            .build_call(*func, &[stack_ptr, off], "call_popn");
    }

    pub fn create_update(&self, f: FunctionValue<'ctx>, off: BasicValueEnum<'ctx>) {
        let func = self.funcs.get("gmachine_update").unwrap();
        self.builder.build_call(*func, &[f.get_first_param().unwrap(), off], "call_update");
    }

    pub fn create_pack(
        &self,
        f: FunctionValue<'ctx>,
        c: BasicValueEnum<'ctx>,
        t: BasicValueEnum<'ctx>,
    ) {
        let func = self.funcs.get("gmachine_pack").unwrap();
        self.builder
            .build_call(*func, &[f.get_first_param().unwrap(), c, t], "call_pack");
    }

    pub fn create_split(&self, f: FunctionValue<'ctx>, c: BasicValueEnum<'ctx>) {
        let func = self.funcs.get("gmachine_split").unwrap();
        self.builder
            .build_call(*func, &[f.get_first_param().unwrap(), c], "call_split");
    }

    pub fn create_slide(&self, f: FunctionValue<'ctx>, off: BasicValueEnum<'ctx>) {
        let func = self.funcs.get("gmachine_slide").unwrap();
        self.builder
            .build_call(*func, &[f.get_first_param().unwrap(), off], "call_slide");
    }

    pub fn create_alloc(&self, f: FunctionValue<'ctx>, n: BasicValueEnum<'ctx>) {
        let func = self.funcs.get("gmachine_alloc").unwrap();
        self.builder
            .build_call(*func, &[f.get_first_param().unwrap(), n], "call_alloc");
    }

    pub fn create_track( &self, f: FunctionValue<'ctx>, n: BasicValueEnum<'ctx>) -> BasicValueEnum<'ctx> {
        let func = self.funcs.get("gmachine_track").unwrap();
        self.builder.build_call(*func, &[f.get_first_param().unwrap(), n], "call_track")
            .try_as_basic_value()
            .left()
            .unwrap()
    }

    pub fn create_unwind(&self, f: FunctionValue<'ctx>) {
        let func = self.funcs.get("unwind").unwrap();
        self.builder.build_call(*func, &[f.get_first_param().unwrap()], "call_unwind");
    }

    pub fn unwrap_node_val(
        &self,
        v: PointerValue<'ctx>,
        node_type: &str,
        val_offset: i32,
    ) -> BasicValueEnum<'ctx> {
        let node_ptr_type = self
            .types
            .struct_types
            .get(node_type)
            .unwrap()
            .ptr_type(AddressSpace::Generic);
        let type_name = node_type.to_owned();
        let cast = self.builder.build_pointer_cast(
            v.into(),
            node_ptr_type,
            &(type_name.clone() + "_cast"),
        );
        let (offset0, offset1) = (self.create_i32(0), self.create_i32(val_offset));
        let val_ptr = unsafe {
            self.builder
                .build_gep(cast, &[offset0, offset1], &(type_name.clone() + "_gep"))
        };
        self.builder.build_load(val_ptr, &(type_name + "_mem_load"))
    }

    /*  This function is equivalent to *(&((struct node_num*) v)[0].val) */
    pub fn unwrap_num(&self, v: PointerValue<'ctx>) -> BasicValueEnum<'ctx> {
        self.unwrap_node_val(v, "node_num", 1)
    }

    pub fn create_num(&self, f: FunctionValue<'ctx>, v: BasicValueEnum<'ctx>) -> BasicValueEnum<'ctx> {
        let func = self.funcs.get("alloc_num").unwrap();
        let alloc_num_call = self.builder
            .build_call(*func, &[v], "call_alloc_num")
            .try_as_basic_value()
            .left()
            .unwrap();
        self.create_track(f, alloc_num_call)
    }

    pub fn unwrap_data_tag(&self, v: PointerValue<'ctx>) -> BasicValueEnum<'ctx> {
        self.unwrap_node_val(v, "node_data", 1)
    }

    pub fn create_global(
        &self,
        f: FunctionValue<'ctx>,
        gf: BasicValueEnum<'ctx>,
        a: BasicValueEnum<'ctx>,
    ) -> BasicValueEnum<'ctx> {
        let func = self.funcs.get("alloc_global").unwrap();
        let alloc_app_call = self.builder
            .build_call(*func, &[gf, a], "call_alloc_global")
            .try_as_basic_value()
            .left()
            .unwrap();
        self.create_track(f, alloc_app_call)
    }

    pub fn create_app(
        &self,
        f: FunctionValue<'ctx>,
        l: BasicValueEnum<'ctx>,
        r: BasicValueEnum<'ctx>,
    ) -> BasicValueEnum<'ctx> {
        let func = self.funcs.get("alloc_app").unwrap();
        let alloc_app_call = self.builder
            .build_call(*func, &[l, r], "call_alloc_app")
            .try_as_basic_value()
            .left()
            .unwrap();
        self.create_track(f, alloc_app_call)
    }

    pub fn unwrap_gmachine_stack_ptr(&self, v: PointerValue<'ctx>) -> BasicValueEnum<'ctx> {
        let offset0 = self.create_i32(0);
        unsafe {
            self.builder
                .build_gep(v, &[offset0, offset0], "gmachine_stack_ptr_gep").into()
        }
    }
}


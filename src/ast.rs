
use std::rc::Rc;
use std::cell::RefCell;
use std::collections::{HashSet, HashMap};
use crate::types::{Type, TypeData};
use crate::types::type_visit::TypeVisitor;
use crate::types::type_env::TypeEnv;
use crate::types::free_var_visit::FreeVarVisitor;
use id_arena::Id;

pub type ASTBox<'input> = Box<dyn AST + 'input>;

pub trait Visitor {
    fn visit_appbase(&mut self, ab: &mut AppBase);
    fn visit_binop(&mut self, bo: &mut BinOp);
    fn visit_app(&mut self, a: &mut App);
    fn visit_match(&mut self, m: &mut Match);
}

pub trait AST: std::fmt::Debug {
    fn type_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type>;
    fn accept(&mut self, v: &mut dyn Visitor);
    fn get_type_env(&self) -> Option<Id<TypeEnv>>;
}

#[derive(Debug)]
pub enum TypeTerm<'input> {
    Base(&'input str),
    Nested(TypeDeclaration<'input>)
}

impl<'input> TypeTerm<'input> {
    fn to_type(&self, v: &FreeVarVisitor) -> Result<Rc<Type>, String> {
        match self {
            Self::Base(type_name) =>
                v.env_stack.lookup_type(&(*type_name).to_owned()).ok_or(format!("Could not find type {} in external type declaration", *type_name)),
            Self::Nested(typedecl) => typedecl.to_type(v)
        }
    }
}

#[derive(Debug)]
pub struct ExternDecl<'input> {
    pub name: &'input str,
    pub extern_name: String,
    pub type_decl: TypeDeclaration<'input>
}

impl<'input> ExternDecl<'input> {
    pub fn to_type(&self, v: &FreeVarVisitor) -> Result<Rc<Type>, String> {
        self.type_decl.to_type(v)
    }
}

#[derive(Debug)]
pub struct TypeDeclaration<'input> {
    pub arrow_separated: Vec<TypeTerm<'input>>
}

impl<'input> TypeDeclaration<'input> {
    fn to_type_helper(terms: &[TypeTerm], v: &FreeVarVisitor) -> Result<Rc<Type>, String> {
        match terms {
            [] => Err("Type declaration is empty".to_owned()),
            [ hd ] => hd.to_type(v),
            [ hd, tl@..] => {
                let lhs_type = hd.to_type(v)?;
                let rhs_type = Self::to_type_helper(tl, v)?;
                Ok(Rc::new(Type::Function(lhs_type, rhs_type)))
            }
        }
    }

    fn to_type(&self, v: &FreeVarVisitor) -> Result<Rc<Type>, String> {
        Self::to_type_helper(&self.arrow_separated[..], v)
    }
}

#[derive(Debug)]
pub struct VariantConstructor<'input> {
    pub name: &'input str,
    pub types: Vec<&'input str>,
    pub tag: i32
}


#[derive(Debug)]
pub enum Pattern<'input> {
    Var(&'input str),
    Constr(&'input str, Vec<&'input str>)
}

impl<'input> Pattern<'input> {
    pub fn insert_bindings(&self, fv: &mut FreeVarVisitor) {
        match self {
            Pattern::Var(name) => {
                let new_type = Rc::new(fv.pg.new_placeholder());
                fv.env_stack.bind_from_type((*name).to_owned(), new_type);
            }
            Pattern::Constr(_, params) => {
                for param in params {
                    let new_type = Rc::new(fv.pg.new_placeholder());
                    fv.env_stack.bind_from_type((*param).to_owned(), new_type);
                }
            }
        }
    }
}


#[derive(Debug)]
pub struct Branch<'input> {
    pub pat: Pattern<'input>,
    pub expr: ASTBox<'input>
}


#[derive(Debug)]
pub struct App<'input> {
    pub left: ASTBox<'input>,
    pub right: AppBase<'input>,
    pub mtype: Option<Rc<Type>>,
    pub mtype_env: Option<Id<TypeEnv>>
}

impl<'input> App<'input> {
    pub fn new(left: ASTBox<'input>, right: AppBase<'input>) -> App<'input> {
        App {left, right, mtype: None, mtype_env: None}
    }
}

impl<'input> AST for App<'input> {    
    fn type_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        tv.visit_app(self)
    }

    fn accept(&mut self, v: &mut dyn Visitor) {
        v.visit_app(self)
    }

    fn get_type_env(&self) -> Option<Id<TypeEnv>> {
        self.mtype_env
    }
}

#[derive(Debug)]
pub enum AppBaseData<'input> {
    Int(i32),
    String(String),
    LowerId(&'input str),
    UpperId(&'input str),
    Expr(ASTBox<'input>),
    Match(ASTBox<'input>)
}

#[derive(Debug)]
pub struct AppBase<'input> {
    pub data: AppBaseData<'input>,
    pub mtype: Option<Rc<Type>>,
    pub mtype_env: Option<Id<TypeEnv>>
}

impl<'input> AST for AppBase<'input> {
    fn type_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        tv.visit_appbase(self)
    }

    fn accept(&mut self, v: &mut dyn Visitor) {
        v.visit_appbase(self)
    }

    fn get_type_env(&self) -> Option<Id<TypeEnv>> {
        self.mtype_env
    }
}


#[derive(Debug, Clone, Copy)]
pub enum BinOpType {
    Plus,
    Minus,
    Times,
    Divide
}

impl BinOpType {
    pub fn name(&self) -> String {
        String::from(match self {
            BinOpType::Plus => "+",     
            BinOpType::Minus => "-",
            BinOpType::Times => "*",
            BinOpType::Divide => "/"
        })      
    }

    pub fn action(&self) -> String {
        String::from(match self {
            BinOpType::Plus => "plus",
            BinOpType::Minus => "minus",
            BinOpType::Times => "times",
            BinOpType::Divide => "divide"
        })      
    }
}

#[derive(Debug)]
pub struct BinOp<'input> {
    pub kind: BinOpType,
    pub lhs: ASTBox<'input>,
    pub rhs: ASTBox<'input>,
    pub mtype: Option<Rc<Type>>,
    pub mtype_env: Option<Id<TypeEnv>>
}

impl<'input> BinOp<'input> {
    pub fn new(kind: BinOpType, lhs: ASTBox<'input>, rhs: ASTBox<'input>) -> BinOp<'input> {
        BinOp {
            kind, lhs, rhs, mtype: None, mtype_env: None
        }
    }
}

impl<'input> AST for BinOp<'input> {
    fn type_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        tv.visit_binop(self)
    }

    fn accept(&mut self, v: &mut dyn Visitor) {
        v.visit_binop(self)
    }

    fn get_type_env(&self) -> Option<Id<TypeEnv>> {
        self.mtype_env
    }
}


#[derive(Debug)]
pub struct Match<'input> {
    pub expr: ASTBox<'input>,
    pub branches: Vec<Branch<'input>>,
    pub input_type: Option<Rc<Type>>,
    pub mtype_env: Option<Id<TypeEnv>>
}

impl<'input> Match<'input> {
    pub fn new(expr: ASTBox<'input>, branches: Vec<Branch<'input>>) -> Match<'input> {
        Match {expr, branches, input_type: None, mtype_env: None}
    }
}

impl<'input> AST for Match<'input> {    
    fn type_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        tv.visit_match(self)
    }

    fn accept(&mut self, v: &mut dyn Visitor) {
        v.visit_match(self)
    }

    fn get_type_env(&self) -> Option<Id<TypeEnv>> {
        self.mtype_env
    }
}


#[derive(Debug)]
pub struct VariantDefinition<'input> {
    pub name: &'input str,
    pub constructors: Vec<VariantConstructor<'input>>,
    pub mtype_env: Option<Id<TypeEnv>>
}

impl<'input> VariantDefinition<'input> {
    pub fn new(name: &'input str, constructors: Vec<VariantConstructor<'input>>) -> VariantDefinition<'input> {
        VariantDefinition{name, constructors, mtype_env: None}
    }

    pub fn insert_types(&mut self, v: &mut FreeVarVisitor) {
        self.mtype_env = Some(v.env_stack.curr_env_id().unwrap());
        let this_type = Rc::new(
            Type::Base(self.name.to_owned(), 
            Some(RefCell::new(TypeData::new()))));
        v.env_stack.bind_type(self.name.to_owned(), this_type);
    }

    pub fn insert_constructors(&mut self, v: &mut FreeVarVisitor) {
        let return_type = v.env_stack.lookup_type(&self.name.to_owned()).unwrap();
        /* This if-statement always evaluates to true. It's only needed to get at the internals of
           the return_type variable we just made */
        if let Type::Base(_, Some(type_data)) = &*Rc::clone(&return_type) {
            let mut curr_tag = 0;               
            for constructor in self.constructors.iter_mut() {
                /* Store unique tag for each constructor in the Type enum itself */
                constructor.tag = curr_tag;
                type_data.borrow_mut().constr_tags.insert(constructor.name.to_owned(), curr_tag);
                curr_tag += 1;
                
                let mut full_type = Rc::clone(&return_type);
                /* Type parameters are read in forward, so we must iterate backwards to
                create a right-recursive type definition for the full type */
                for type_name in constructor.types.iter().rev() {
                    //let curr_type = Rc::new(Type::Base((*type_name).to_owned(), None));
                    if let Some(curr_type) = v.env_stack.lookup_type(&(*type_name).to_owned()) {
                        full_type = Rc::new(Type::Function(Rc::clone(&curr_type), full_type));
                    } else {
                        panic!("expected {} to be defined in typecheck context", type_name)
                    }
                }

                v.env_stack.bind_from_type(constructor.name.to_owned(), full_type);
            }
        } else {
            panic!("expected Base(_, Some(_)), got {:?}", return_type);             
        }
    }
}


#[derive(Debug)]
pub struct FuncDefinition<'input> {
    pub name: &'input str,
    pub params: Vec<&'input str>,
    pub body: ASTBox<'input>,
    pub return_type: Option<Rc<Type>>,
    pub full_type: Option<Rc<Type>>,
    pub param_types: Vec<Rc<Type>>,
    pub mtype_env: Option<Id<TypeEnv>>,
    pub var_mtype_env: Option<Id<TypeEnv>>,
    pub free_vars: HashSet<String>
}

impl<'input> FuncDefinition<'input> {
    pub fn new(name: &'input str, params: Vec<&'input str>, body: ASTBox<'input>) -> FuncDefinition<'input> {
        FuncDefinition {name, params, body, 
            return_type: None,
            full_type: None,
            param_types: Vec::new(), 
            mtype_env: None,
            var_mtype_env: None,
            free_vars: HashSet::new()
        }
    }

    pub fn insert_types(&self, v: &mut FreeVarVisitor) {
        let full_type = Rc::clone(self.full_type.as_ref().unwrap());
        v.env_stack.bind_from_type((*self.name).to_owned(), full_type);
    }
}

#[derive(Debug)]
pub enum Definition<'input> {
    Func(FuncDefinition<'input>),
    ExternFunc(ExternDecl<'input>),
    Variant(VariantDefinition<'input>)
}

#[derive(Debug)]
pub struct Program<'input> {
    pub func_defns: HashMap<String, FuncDefinition<'input>>,
    pub extern_decls: HashMap<String, ExternDecl<'input>>,
    pub type_defns: HashMap<String, VariantDefinition<'input>>
}


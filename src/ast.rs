
use std::rc::Rc;
use crate::types::Type;
use crate::types::type_visit::TypeVisitor;

pub type ASTBox<'input> = Box<dyn AST + 'input>;

pub trait Visitor {
    fn visit_appbase(&mut self, ab: &mut AppBase);
    fn visit_binop(&mut self, bo: &mut BinOp);
    fn visit_app(&mut self, a: &mut App);
    fn visit_match(&mut self, m: &mut Match);
}

pub trait AST: std::fmt::Debug {
    fn type_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        let ast_type = self.typegen_accept(tv);
        self.set_type(Rc::clone(&ast_type));
        ast_type
    }
    fn typegen_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type>;     
    fn set_type(&mut self, t: Rc<Type>);
    fn get_type(&self) -> Option<Rc<Type>>;
    fn accept(&mut self, v: &mut dyn Visitor);
}

#[derive(Debug)]
pub struct TypeConstructor<'input> {
    pub name: &'input str,
    pub types: Vec<&'input str>,
    pub tag: i32
}

#[derive(Debug)]
pub struct TypeDefinition<'input> {
    pub name: &'input str,
    pub constructors: Vec<TypeConstructor<'input>>
}


#[derive(Debug)]
pub enum Pattern<'input> {
    Var(&'input str),
    Constr(&'input str, Vec<&'input str>)
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
    pub mtype: Option<Rc<Type>>
}

impl<'input> AST for App<'input> {
    fn set_type(&mut self, t: Rc<Type>) {
        self.mtype = Some(t)
    }

    fn get_type(&self) -> Option<Rc<Type>> {
        self.mtype.as_ref().map(|t| Rc::clone(t))
            //Rc::clone(self.mtype.as_ref().unwrap())
    }
    
    fn typegen_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        tv.visit_app(self)
    }

    fn accept(&mut self, v: &mut dyn Visitor) {
        v.visit_app(self)
    }
}


#[derive(Debug)]
pub enum AppBase<'input> {
    Int(i32),
    LowerId(&'input str, Option<Rc<Type>>),
    UpperId(&'input str, Option<Rc<Type>>),
    Expr(ASTBox<'input>),
    Match(ASTBox<'input>)
}

impl<'input> AST for AppBase<'input> {
    fn set_type(&mut self, t: Rc<Type>) {
        match self {
            AppBase::LowerId(_, mtype) => *mtype = Some(t),
            AppBase::UpperId(_, mtype) => *mtype = Some(t),
            AppBase::Expr(expr) => expr.set_type(t),
            AppBase::Match(matchexpr) => matchexpr.set_type(t),
            _ => ()
        }
    }

    fn get_type(&self) -> Option<Rc<Type>> {
        match self {
            AppBase::Int(_) => Some(Rc::new(Type::Base(String::from("Int"), None))),
            AppBase::LowerId(_, mtype) => mtype.as_ref().map(|t| Rc::clone(t)),
            AppBase::UpperId(_, mtype) => mtype.as_ref().map(|t| Rc::clone(t)),
            AppBase::Expr(expr) => expr.get_type(),
            AppBase::Match(matchexpr) => matchexpr.get_type()
        }       
    }
    
    fn typegen_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        tv.visit_appbase(self)
    }

    fn accept(&mut self, v: &mut dyn Visitor) {
        v.visit_appbase(self)
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
    pub mtype: Option<Rc<Type>>
}

impl<'input> AST for BinOp<'input> {
    fn set_type(&mut self, t: Rc<Type>) {
        self.mtype = Some(t);
    }

    fn get_type(&self) -> Option<Rc<Type>> {    
        //Rc::clone(self.mtype.as_ref().unwrap())
        self.mtype.as_ref().map(|t| Rc::clone(t))  
    }
    
    fn typegen_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        tv.visit_binop(self)
    }

    fn accept(&mut self, v: &mut dyn Visitor) {
        v.visit_binop(self)
    }    
}


#[derive(Debug)]
pub struct Match<'input> {
    pub expr: ASTBox<'input>,
    pub branches: Vec<Branch<'input>>,
    pub mtype: Option<Rc<Type>>
}

impl<'input> AST for Match<'input> {
    fn set_type(&mut self, t: Rc<Type>) {
        self.mtype = Some(t);
    }

    fn get_type(&self) -> Option<Rc<Type>> {
        //Rc::clone(self.mtype.as_ref().unwrap())
        self.mtype.as_ref().map(|t| Rc::clone(t))
    }
    
    fn typegen_accept(&mut self, tv: &mut TypeVisitor) -> Rc<Type> {
        tv.visit_match(self)
    }

    fn accept(&mut self, v: &mut dyn Visitor) {
        v.visit_match(self)
    }
}


#[derive(Debug)]
pub struct FuncDefinition<'input> {
    pub name: &'input str,
    pub params: Vec<&'input str>,
    pub body: ASTBox<'input>,
    pub return_type: Option<Rc<Type>>,
    pub param_types: Vec<Rc<Type>>
}

#[derive(Debug)]
pub enum Definition<'input> {
    Func(FuncDefinition<'input>),
    Type(TypeDefinition<'input>)
}

#[derive(Debug)]
pub struct Program<'input> {
    pub defns: Vec<Definition<'input>>
}


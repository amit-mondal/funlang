

pub trait StackEnv {
    fn take_parent(&mut self) -> Option<Box<dyn StackEnv>>;
    fn get_offset(&self, name: &str) -> Option<usize>;
}


pub struct VarEnv {
    name: String,
    parent_env: Option<Box<dyn StackEnv>>
}

impl VarEnv {
    pub fn from_parent(name: String, parent_env: Option<Box<dyn StackEnv>>) -> VarEnv {
        VarEnv { name, parent_env }
    }    
}

impl StackEnv for VarEnv {
    
    fn get_offset(&self, name: &str) -> Option<usize> {
        if name == self.name {
            Some(0)
        } else {
            if let Some(env) = &self.parent_env {
                env.get_offset(name).map(|offset| offset + 1)
            } else {
                None
            }
        }
    }

    fn take_parent(&mut self) -> Option<Box<dyn StackEnv>> {
        self.parent_env.take()
    }
}


pub struct OffsetEnv {
    offset: usize,
    parent_env: Option<Box<dyn StackEnv>>
}

impl OffsetEnv {
    pub fn from_parent(offset: usize, parent_env: Option<Box<dyn StackEnv>>) -> OffsetEnv {
        OffsetEnv { offset, parent_env }
    }    
}

impl StackEnv for OffsetEnv {
    
    fn get_offset(&self, name: &str) -> Option<usize> { 
        if let Some(env) = &self.parent_env {
            env.get_offset(name).map(|offset| offset + self.offset)
        } else {
            None
        }
    }

    fn take_parent(&mut self) -> Option<Box<dyn StackEnv>> {
        self.parent_env.take()
    }
}

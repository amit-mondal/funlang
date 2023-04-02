extern crate lalrpop;

fn main() {
    println!("cargo:rerun-if-changed=src/fun.lalrpop");
    lalrpop::process_root().unwrap();
}

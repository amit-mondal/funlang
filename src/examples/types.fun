
type Foo = {
    Bar Int,
    Bah String Int String
}

type Holds3 = {
    A Int String Int
}

fun int_to_some_str i = { "my_str" }

extern fun string_concat : String -> String -> String = "extern_strconcat"
extern fun easy_add : Int -> Int -> Int -> Int -> Int = "extern_easyadd"

fun concat3 a b c = {
    string_concat (string_concat a b) c
}

fun hold3 a b c = { A a b c }

fun blah a = {
    match a with {
        Bah a b c => { c }
        Bar foo => { int_to_some_str foo }
    }
}

fun my_bah = {
    Bah "hello"
}

fun hard_add a b c d = {
    a + b + c + d
}

type List = {
    Nil,
    Cons String List
}

fun fold_left l init f = {
    match l with {
        Nil => { init }
        Cons hd tl => {
            fold_left l (f init hd) f
        }
    }
}

fun main = {
    fold_left (Cons "hello" (Cons "goodbye" (Cons "nice" Nil))) "" string_concat
}

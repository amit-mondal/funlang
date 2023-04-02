type List = {
    Nil,
    Cons String List
}

fun fold_left l init f = {
    match l with {
        Nil => { init }
        Cons hd tl => {
            fold_left tl (f init hd) f
        }
    }
}

fun main = {
    5
}

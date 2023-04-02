type List = { Nil, Cons Int List }

fun add x y = { x + y }
fun mul x y = { x * y }

fun foldr f b l = {
    match l with {
        Nil => { b }
        Cons x xs => { f x (foldr f b xs) }
    }
}
fun swap_args b l f = {
    foldr f b l
}

fun curried = {
    swap_args add
}

fun main = {
    foldr add 0 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) +
    foldr mul 1 (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil))))
}

    type Option = {
        Some Int,
        None
    }
    
    type List = {
        Cons Int List, Nil
    }
    
    fun applyToList fn l i = {
        match l with {
            Cons x xs => {
                Cons (fn x i) xs
            }
            Nil => { Nil }
        }
    }
    
    fun add x y = {
        x + y
    }
    
    fun ones = { Cons 1 ones }
    
    fun fst l = {
        match l with {
            Cons x xs => { Some x }
            Nil => { None }
        }
    }

    fun blah = {
        applyToList add ones
    }

    fun main = {
        fst (blah 2)
    }
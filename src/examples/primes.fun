type List = { Nil, Cons Nat List }
type Bool = { True, False }
type Nat = { O, S Nat }

fun if c t e = {
    match c with {
        True => { t }
        False => { e }
    }
}

fun toInt n = {
    match n with {
        O => { 0 }
        S np => { 1 + toInt np }
    }
}

fun lte n m = {
    match m with {
        O => {
            match n with {
                O => { True }
                S np => { False }
            }
        }
        S mp => {
            match n with {
                O => { True }
                S np => { lte np mp }
            }
        }
    }
}

fun minus n m = {
    match m with {
        O => { n }
        S mp => { 
            match n with {
                O => { O }
                S np => {
                    minus np mp
                }
            }
        }
    }
}

fun mod n m = {
    if (lte m n) (mod (minus n m) m) n
}

fun notDivisibleBy n m = {
    match (mod m n) with {
        O => { False }
        S mp => { True }
    }
}

fun filter f l = {
    match l with {
        Nil => { Nil }
        Cons x xs => { if (f x) (Cons x (filter f xs)) (filter f xs) }
    }
}

fun map f l = {
    match l with {
        Nil => { Nil }
        Cons x xs => { Cons (f x) (map f xs) }
    }
}

fun nats = {
    Cons (S (S O)) (map S nats)
}

fun primesRec l = {
    match l with {
        Nil => { Nil }
        Cons p xs => { Cons p (primesRec (filter (notDivisibleBy p) xs)) }
    }
}

fun primes = {
    primesRec nats
}

fun take n l = {
    match l with {
        Nil => { Nil }
        Cons x xs => {
            match n with {
                O => { Nil }
                S np => { Cons x (take np xs) }
            }
        }
    }
}

fun head l = {
    match l with {
        Nil => { O }
        Cons x xs => { x }
    }
}

fun reverseAcc a l = {
    match l with {
        Nil => { a }
        Cons x xs => { reverseAcc (Cons x a) xs }
    }
}

fun reverse l = {
    reverseAcc Nil l
}

fun main = {
    toInt (head (reverse (take ((S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S O))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))) primes)))
}

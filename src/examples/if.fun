type Bool = { True, False }

fun b = { 4 }

fun if c t e = {
    match c with {
        True => { t }
        False => { e }
    }
}

fun main = { if (if True False 5) 11 3 }

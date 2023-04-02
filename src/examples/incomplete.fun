type Bool = { True, False }

fun foo a b c = {
    (a b) + 1
}

fun bar b = {
    b + 1
}

fun id s = {
    s
}

fun plain = {
    foo bar 5 False
}

fun main = {
    id "hello"
}
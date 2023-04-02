
type MyType = {
    Pat1,
    Pat2,
    Pat3
}


fun foo a = {
    match a with {
        Pat1 => { 4 }
        Pat2 => { 4 }
    }
}

fun bar a = {
    match a with {
        Pat1 => { 4 }
        Pat2 => { 3 }
        Pat3 => { 2 }
        Pat1 => { 4 }
    }
}
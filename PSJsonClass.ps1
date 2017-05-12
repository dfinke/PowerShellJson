class book {
    $category
    $author
    $title
    $isbn
    $price
}

class bicycle {
    $color
    $price
}

class store {
    [book[]]$book
    [bicycle]$bicycle
}

class root {
    [store]$store
}

[root](.\PSJson.ps1)
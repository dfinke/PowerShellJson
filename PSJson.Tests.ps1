Describe "this" {
    $data = . "$PSScriptRoot\PSJson.ps1"
    
    It "Should have data" {
        $data | Should  Not Be Null
    }

    It "Should have 4 authors" {
        $actual = $data.store.book.author
        
        $actual.count | Should be 4
    }

    It "Should have these authors" {
        $actual = $data.store.book.author

        $actual[0] | Should Be "Nigel Rees"
        $actual[1] | Should Be "Evelyn Waugh"
        $actual[2] | Should Be "Herman Melville"
        $actual[3] | Should Be "J. R. R. Tolkien"        
    }

    It "Should have 5 prices" {
        $actual = $data.store.psobject.Properties.name| ForEach-Object {$data.store.$_.price}
        $actual.count | Should be 5
    }

    It "Should have these prices" {
        $actual = $data.store.psobject.Properties.name| ForEach-Object {$data.store.$_.price}

        $actual[0] | Should Be 8.95
        $actual[1] | Should Be 12.99
        $actual[2] | Should Be 8.99
        $actual[3] | Should Be 22.99
        $actual[4] | Should Be 19.95
    }

    It "Should have these properties for the 3rd book" {
        $actual = $data.store.book[2]

        $actual.category | Should Be "fiction"
        $actual.author   | Should Be "Herman Melville"
        $actual.title    | Should Be "Moby Dick"
        $actual.isbn     | Should Be "0-553-21311-3"
        $actual.price    | Should Be 8.99
    }

    It "Should have these properties for the last book via subscript" {
        $actual = $data.store.book[($data.store.book.count - 1)]
        
        $actual.category | Should Be "fiction"
        $actual.author   | Should Be "J. R. R. Tolkien"
        $actual.title    | Should Be "The Lord of the Rings"
        $actual.isbn     | Should Be "0-395-19395-8"
        $actual.price    | Should Be 22.99
    }
    
    It "Should have these properties for the last book via array slicing" {
        $actual = $data.store.book[-1]
        
        $actual.category | Should Be "fiction"
        $actual.author   | Should Be "J. R. R. Tolkien"
        $actual.title    | Should Be "The Lord of the Rings"
        $actual.isbn     | Should Be "0-395-19395-8"
        $actual.price    | Should Be 22.99
    }

    It "Should get first 2 books" {
        $actual = $data.store.book[0..1]
        
        $actual.count | Should Be 2
        
        $actual[0].category | Should Be "reference"
        $actual[0].author   | Should Be "Nigel Rees"
        $actual[0].title    | Should Be "Sayings of the Century"
        $actual[0].price    | Should Be 8.95

        $actual[1].category | Should Be "fiction"
        $actual[1].author   | Should Be "Evelyn Waugh"
        $actual[1].title    | Should Be "Sword of Honour"
        $actual[1].price    | Should Be 12.99
    }    
    
    It "Should Filter all books with isbn number" {
        $actual = $data.store.book | ? isbn
        $actual.count | Should Be 2
        
        #fiction  Herman Melville  Moby Dick             0-553-21311-3  8.99
        $actual[0].category | Should Be "fiction"
        $actual[0].author   | Should Be "Herman Melville"
        $actual[0].title    | Should Be "Moby Dick"
        $actual[0].isbn    | Should Be "0-553-21311-3"
        $actual[0].price    | Should Be 8.99

        #fiction  J. R. R. Tolkien The Lord of the Rings 0-395-19395-8 22.99
        $actual[1].category | Should Be "fiction"
        $actual[1].author   | Should Be "J. R. R. Tolkien"
        $actual[1].title    | Should Be "The Lord of the Rings"
        $actual[1].isbn     | Should Be "0-395-19395-8"
        $actual[1].price    | Should Be 22.99
    }

    It "Filter all books cheaper than 10" {
        $actual = $data.store.book | ? price -lt 10
        $actual.count | Should Be 2
    }

    It "Filter all books that cost 8.95" {
        $actual = @($data.store.book | ? price -eq 8.95)
        $actual.count | Should Be 1
    }

    It "Filter all fiction books cheaper than 30" {
        $actual = $data.store.book | ? {$_.price -lt 30 -and $_.category -eq 'fiction'}
        $actual.count | Should Be 3
    }
}
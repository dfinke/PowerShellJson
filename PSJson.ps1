@"
{
  "store": {
    "book": [ 
      {
        "category": "reference",
        "author": "Nigel Rees",
        "title": "Sayings of the Century",
        "price": 8.95
      }, {
        "category": "fiction",
        "author": "Evelyn Waugh",
        "title": "Sword of Honour",
        "price": 12.99
      }, {
        "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "isbn": "0-553-21311-3",
        "price": 8.99
      }, {
         "category": "fiction",
        "author": "J. R. R. Tolkien",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99
      }
    ],
    "bicycle": {
      "color": "red",
      "price": 19.95
    }
  }
}
"@ | ConvertFrom-Json

#cls
#$data = $json | ConvertFrom-Json
# $data.store.book.author | clip
# $data.store | Format-List | clip
#$data.store.psobject.Properties.name | ForEach-Object {$data.store.$_.price} | clip
#$data.store.book[2] | clip
#$data.store.book[($data.store.book.count-1)] 
#$data.store.book[0..1] |clip
#$data.store.book | ? isbn  | ft | clip
#$data.store.book | ? price -lt 10 | clip
#$data.store.book | ? price -eq 8.95 | clip
# $data.store.book | ? { $_.price -lt 30 -and $_.category -eq 'fiction' } | clip
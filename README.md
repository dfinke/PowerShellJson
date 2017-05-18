Inspired and ported from here https://github.com/dchester/jsonpath

Comes with:

* [Pester](https://github.com/pester/Pester) tests
* PowerShell classes for casting the JSON


# Query Example

```powershell
$cities=@"
[
  { name: "London", "population": 8615246 },
  { name: "Berlin", "population": 3517424 },
  { name: "Madrid", "population": 3165235 },
  { name: "Rome",   "population": 2870528 }
]
"@ | ConvertFrom-Json

$cities.name | ConvertTo-Json -Compress
```

```json
["London","Berlin","Madrid","Rome"]
```

# Example Expressions
Query JSON with PowerShell

### The sample JSON

```json
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
```
### Cast to a Class in PowerShell
You can create Claseses in PowerShell and you can cast JSON to them like this.

```powershell
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
```
This approach enables you to validate that the incoming data has correct objects and fields associated with it.

### Generate the Classes From the Data

```powershell
$PSObjs = & .\PSJson.ps1
New-ClassDefinitionFromObject -InputObject $PSObjs
```

Do this on a dataset beforehand to pre-generate the classes so you don't have to create them all by hand.
Tweak as needed if the sample dataset you fed it didn't cover all possibilities.

`New-ClassDefinitionFromObject` can also be told to convert some properties into an `enum` instead with the `-EnumType` parameter (wildcards supported):

```powershell
New-ClassDefinitionFromObject -InputObject $PSObjs -EnumType categ*
```

And the actual generated code from the above command:

```powershell
enum category
{
	reference;fiction
}

class book
{
	[category]$category
	[System.String]$author
	[System.String]$title
	[System.Decimal]$price
	[System.String]$isbn
}

class bicycle
{
	[System.String]$color
	[System.Decimal]$price
}

class store
{
	[book[]]$book
	[bicycle]$bicycle
}

class root
{
	[store]$store
}
```

### Queries

| PowerShell | Description |
| --- | --- |
| `$data.store.book.author` | The authors of all books in the store |

```
Nigel Rees
Evelyn Waugh
Herman Melville
J. R. R. Tolkien
```

| PowerShell | Description |
| --- | --- |
| `$data.store \| Format-List` | All the things in the store |

```
book    : {@{category=reference; author=Nigel Rees; title=Sayings of the Century; price=8.95}, @{category=fiction; author=Evelyn Waugh; title=Sword of Honour; 
          price=12.99}, @{category=fiction; author=Herman Melville; title=Moby Dick; isbn=0-553-21311-3; price=8.99}, @{category=fiction; author=J. R. R. Tolkien; 
          title=The Lord of the Rings; isbn=0-395-19395-8; price=22.99}}
bicycle : @{color=red; price=19.95}
```

| PowerShell | Description |
| --- | --- |
| `$data.store.psobject.Properties.name \| ForEach-Object {$data.store.$_.price} ` | The price of everything in the store |

```
8.95
12.99
8.99
22.99
19.95
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book[2]` | The third book |

```
category : fiction
author   : Herman Melville
title    : Moby Dick
isbn     : 0-553-21311-3
price    : 8.99
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book[($data.store.book.count-1)] ` | The last book via subscript |

```
category : fiction
author   : J. R. R. Tolkien
title    : The Lord of the Rings
isbn     : 0-395-19395-8
price    : 22.99
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book[-1]` | The last book via array slicing |

```
category : fiction
author   : J. R. R. Tolkien
title    : The Lord of the Rings
isbn     : 0-395-19395-8
price    : 22.99
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book[0..1]` | The first two books |

```
category  author       title                  price
--------  ------       -----                  -----
reference Nigel Rees   Sayings of the Century  8.95
fiction   Evelyn Waugh Sword of Honour        12.99
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book \| ? isbn` | Filter all books with isbn number |

```
category author           title                 isbn          price
-------- ------           -----                 ----          -----
fiction  Herman Melville  Moby Dick             0-553-21311-3  8.99
fiction  J. R. R. Tolkien The Lord of the Rings 0-395-19395-8 22.99
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book \| ? price -lt 10` | Filter all books cheaper than 10 |

```
category  author          title                  price
--------  ------          -----                  -----
reference Nigel Rees      Sayings of the Century  8.95
fiction   Herman Melville Moby Dick               8.99
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book \| ? price -eq 8.95` | Filter all books that cost 8.95 |

```
category  author     title                  price
--------  ------     -----                  -----
reference Nigel Rees Sayings of the Century  8.95
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book \| Measure-Object price -Sum` | Sum all book prices |

```
Count    : 4
Average  :
Sum      : 53.92
Maximum  :
Minimum  :
Property : price
```

| PowerShell | Description |
| --- | --- |
| `$data.store.book \| ? {$_.price -lt 30 -and $_.category -eq 'fiction'}` | Filter all fiction books cheaper than 30 |

```
category author           title                 price
-------- ------           -----                 -----
fiction  Evelyn Waugh     Sword of Honour       12.99
fiction  Herman Melville  Moby Dick              8.99
fiction  J. R. R. Tolkien The Lord of the Rings 22.99
```

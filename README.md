Inspired and ported from here https://github.com/dchester/jsonpath

Comes with:

* [Pester](https://github.com/pester/Pester) tests
* PowerShell classes for casting the JSON


<!-- CHAPTER START -->
# PowerShell and the Azure CLI

**Example az cli:**

```ps
az vm list
```

**Example Result:**

Here is a pruned down output from ~90 lines of JSON information.

```
  {
    "additionalProperties": {},
    "availabilitySet": null,
    "diagnosticsProfile": {
      "additionalProperties": {},
      "bootDiagnostics": {
        "additionalProperties": {}
      }
    },
    "hardwareProfile": {
    }
    .
    .
    .
    "identity": null,
    "licenseType": null,
    "location": "eastus",
    "name": "TestServer1",
    "osProfile": {
      "additionalProperties": {}
    }

  }
```

**Example az cli:**

Pipe the result from `az cli` to PowerShell's `ConvertFrom-Json`, it gets converted to an array of objects, and then you pipe it to the Select-Object cmdlet to display the name property.

[![Launch Cloud Shell](https://shell.azure.com/images/launchcloudshell.png "Launch Cloud Shell")](https://shell.azure.com/powershell)

<!-- <a style="cursor:pointer" onclick='javascript:window.open("https://shell.azure.com", "_blank", "toolbar=no,scrollbars=yes,resizable=yes,menubar=no,location=no,status=no")'><image src="https://shell.azure.com/images/launchcloudshell.png" /></a> -->

```ps
(az vm list | ConvertFrom-Json) | Select-Object name
```

**Example Result:**

PowerShell easily iterates over just the names of the VMs.

```
name
----
TestServer1
TestServer2
TestServer3
TestServer4
TestServer5
TestServer6
TestServer7
TestServer8
```

**Example az cli:**

Now, grab more than one property.

```ps
(az vm list | ConvertFrom-Json) | Select-Object resourcegroup, name
```

**Example Result:**

That lines converts the az cli JSON to an array of PowerShell objects and you pick off the two properties by name.

```
resourceGroup  name
-------------  ----
TESTSERVER1-RG TestServer1
TESTSERVER2-RG TestServer2
TESTSERVER3-RG TestServer3
TESTSERVER4-RG TestServer4
TESTSERVER5-RG TestServer5
TESTSERVER6-RG TestServer6
TESTSERVER7-RG TestServer7
TESTSERVER8-RG TestServer8
```

**Example az cli:**

Or, do custom transformations.

```ps
(az vm list | ConvertFrom-Json) | ForEach-Object {

    $details = $_.storageProfile.imageReference | Select-Object offer, publisher, sku, version
    [PSCustomObject][Ordered]@{
        ResourceGroup = $_.ResourceGroup
        Name          = $_.Name
        Offer         = $details.Offer
        Publisher     = $details.Publisher
        Sku           = $details.Sku
        Version       = $details.Version
    }
}
```

**Example Result:**

PowerShell makes it easy to traverse nested JSON and flattened the results.

```
ResourceGroup  Name        Offer        Publisher  Sku       Version
-------------  ----        -----        ---------  ---       -------
TESTSERVER1-RG TestServer1 UbuntuServer Canonical  16.04-LTS latest
TESTSERVER2-RG TestServer2 RHEL         RedHat     7.2       latest
TESTSERVER3-RG TestServer3 kali-linux   kali-linux kali      latest
TESTSERVER4-RG TestServer4 UbuntuServer Canonical  16.04-LTS latest
TESTSERVER5-RG TestServer5 UbuntuServer Canonical  16.04-LTS latest
TESTSERVER6-RG TestServer6 UbuntuServer Canonical  16.04-LTS latest
TESTSERVER7-RG TestServer7 UbuntuServer Canonical  16.04-LTS latest
TESTSERVER8-RG TestServer8 UbuntuServer Canonical  16.04-LTS latest
```

<!-- CHAPTER END -->

<!-- CHAPTER START -->
# Query Example

```ps
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
<!-- CHAPTER END -->


```json
["London","Berlin","Madrid","Rome"]
```

<!-- CHAPTER START -->
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
<!-- CHAPTER END -->

<!-- CHAPTER START -->
### Cast to a Class in PowerShell

You can create Classes in PowerShell and you can cast JSON to them like this.

<!-- EXCLUDE CODE START -->
```ps
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
<!-- EXCLUDE CODE END -->


This approach enables you to validate that the incoming data has correct objects and fields associated with it.

<!-- CHAPTER END -->

<!-- CHAPTER START -->

### Generate the Classes From the Data

```ps
$PSObjs = & .\PSJson.ps1
New-ClassDefinitionFromObject -InputObject $PSObjs
```

Do this on a dataset beforehand to pre-generate the classes so you don't have to create them all by hand.
Tweak as needed if the sample dataset you fed it didn't cover all possibilities.

`New-ClassDefinitionFromObject` can also be told to convert some properties into an `enum` instead with the `-EnumType` parameter (wildcards supported):

```ps
New-ClassDefinitionFromObject -InputObject $PSObjs -EnumType categ*
```

And the actual generated code from the above command:

```ps
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
<!-- CHAPTER END -->

<!-- CHAPTER START -->

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
<!-- CHAPTER END -->
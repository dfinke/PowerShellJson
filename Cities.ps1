$cities=@"
[
  { name: "London", "population": 8615246 },
  { name: "Berlin", "population": 3517424 },
  { name: "Madrid", "population": 3165235 },
  { name: "Rome",   "population": 2870528 }
]
"@ | ConvertFrom-Json

$cities.name | ConvertTo-Json -Compress
function New-ClassDefinitionFromObject {
[CmdletBinding()]
param(
    [Parameter(
        Mandatory
    )]
    [object]
    $InputObject ,

    [Parameter()]
    [SupportsWildcards()]
    [String[]]
    $EnumType
)
    End {
        function helper {
        [CmdletBinding()]
        param(
            [Parameter(
                Mandatory,
                ValueFromPipeline
            )]
            [object]
            $InputObject ,

            [Parameter()]
            [ValidateRange(1,99)] # ConvertFrom-Json supports depth up to 99
            [uint16]
            $Depth = 1 ,
                        
            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [String]
            $ParentKey = 'root' ,
                        
            [Parameter(
                Mandatory
            )]
            [hashtable]
            $DataData ,

            [Parameter()]
            [SupportsWildcards()]
            [String[]]
            $EnumType
        )

            Process {
                $InputObject.PSObject.Properties.ForEach({
                    $prop = $_

                    $propData = @{
                        Name = $prop.Name
                        Type = @()
                        IsObject = $prop.Value -is [PSObject]
                        IsArray = $prop.Value -is [Array]
                        IsEnum = $EnumType -and $prop.Name -ilike $EnumType
                        Depth = $Depth
                        ParentKey = $ParentKey
                    }

                    if ($propData.IsArray) {
                        $prop.Value | helper -Depth ($Depth+1) -DataData $DataData -EnumType $EnumType -ParentKey $propData.Name
                        if ($DataData.classes.ParentKey -contains $propData.Name) {
                            $propData.IsObject = $true
                        }
                    }
                    
                    $propData.Type += $prop.TypeNameOfValue

                    if (
                            $prop.IsEnum -and (
                                $prop.Value -isnot [String] -or 
                                $prop.Value -notmatch '^[a-zA-Z][a-zA-Z0-9_]*$'
                            )
                        ) {                    
                        throw [System.InvalidOperationException]"The property '$($propData.Name)' cannot be an enum because one its values is not valid for an enum."
                    }

                    if ($propData.IsObject) {
                        $prop.Value | helper -Depth ($Depth+1) -DataData $DataData -EnumType $EnumType -ParentKey $propData.Name
                    }

                    if ($propData.IsEnum) {
                        if ($DataData.enums.ContainsKey($propData.Name)) {
                            if ($DataData.enums[$propData.Name] -notcontains $prop.Value) {
                                $DataData.enums[$propData.Name] += $prop.Value
                            }
                        } else {
                            $DataData.enums[$propData.Name] = @($prop.Value)
                        }
                    }

                    if ($DataData.classes.Where({$_.Name -eq $propData.Name -and $_.ParentKey -eq $propData.ParentKey})) {
                        return # Naively skip it (for now?)
                    }

                    $DataData.classes += [PSCustomObject]$propData
                })
            }
        }

        $NL = [System.Environment]::NewLine

        $data = @{
            classes = @()
            enums = @{}
        }

        helper -InputObject $InputObject -DataData $data -EnumType $EnumType

        $data.classes += [PSCustomObject]@{
            Name = 'root'
            Depth = 0
            IsObject = $true
        }

        $defs = @{
            classes = @()
            enums = @()
        }

        $data.classes | Sort-Object -Property Depth -Descending | ForEach-Object -Process {
            $class = $_
            if ($class.IsEnum) {
                $defs.enums += "enum $($class.Name)$NL{$NL`t$($data.enums[$class.Name] -join ';')$NL}$NL"
            }

            if ($class.IsObject) {
                $params = $data.classes.Where({$_.ParentKey -eq $class.Name}).ForEach({
                    $type = if ($_.IsEnum -or $_.IsObject) {
                        $_.Name
                    } else {
                        $_.Type[0]
                    }
                    if ($_.IsArray) {
                        $type = "$type[]"
                    }
                    $type = "[$type]"
                    $name = $_.Name
                    "`t$type`$$name"
                }) -join $NL
                $defs.classes += "class $($class.Name)$NL{$NL$params$NL}$NL"
            }
        }

        "$($defs.enums -join $NL)$NL$($defs.classes -join $NL)"
    }
}
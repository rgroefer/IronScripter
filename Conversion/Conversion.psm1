function ConvertTo-ClassDefinition {
    param (
        [Parameter(ValueFromPipeline=$true)]
        $InputObject
        ,

        [Parameter()]
        [string[]]
        $ExcludeProperty
        ,

        [Parameter()]
        [string[]]
        $ExcludeMethod
        ,

        [Parameter(HelpMessage="Key is the method name, Value is the code for the method.")]
        [hashtable]
        $MethodCode
        ,

        [Parameter(DontShow)]
        $NewClassText
    )
    Begin 
    {
        if($PSBoundParameters.ContainsKey('ExcludeProperty'))
        {
            Write-Verbose "Excluding $($ExcludeProperty -join ', ')"
        }
        if($PSBoundParameters.ContainsKey('ExcludeMethod'))
        {
            Write-Verbose "Excluding $($ExcludeMethod -join ', ')"
        }
        New-Variable -Name Methods    -Value (New-Object -TypeName System.Collections.Generic.List[Microsoft.PowerShell.Commands.MemberDefinition])
        New-Variable -Name Properties -Value (New-Object -TypeName System.Collections.Generic.List[Microsoft.PowerShell.Commands.MemberDefinition])
    }
    Process 
    {

        # If more than one object, grab just the first one
        if(($InputObject | Measure-Object).Count -gt 1)
        {
            $InputObject = $InputObject | Select-Object -First 1
        }

        #region Grab and sort all members of the input object
        $allMembers = $InputObject | Get-Member
        $derivedTypeName = ($allMembers | Select-Object -First 1)
        foreach($member in $allMembers)
        {
            switch -Regex ($member.MemberType)
            {
                'Method' {
                    if($ExcludeMethod)
                    {
                        if($member.Name -notin $ExcludeMethod)
                        {
                            Write-Verbose "Method: $($member.Name)"
                            $Methods.Add($member)
                        }else{
                            Write-Verbose "Excluding $($member.Name)"
                        }
                    }else{
                        Write-Verbose "Method: $($member.Name)"
                        $Methods.Add($member)
                    }
                    break
                }
                'Property' {
                    if($ExcludeProperty)
                    {
                        if($member.Name -notin $ExcludeProperty)
                        {
                            Write-Verbose "Property: $($member.Name)"
                            $Properties.Add($member)
                        }else{
                            Write-Verbose "Excluding $($member.Name)"
                        }
                    }else{
                        Write-Verbose "Property: $($member.Name)"
                        $Properties.Add($member)
                    }
                    break
                }
            }
        }
        #endRegion


        #region Create method objects, including overrides
        $methodObjects = ForEach($method in ($Methods | Sort-Object -Property Name))
        {
            $methodOverrides, $methodName , $methodCodeThisMethod = $null

            # Remove (, ),
            # Split on newline chars
            # Trim spaces and semicolons
            $methodOverrides = $method.Definition.Replace(')',$(")`n")).Split("`n").Trim(',').Trim(' ').Trim(';') |
            Where-Object {'' -ne $_}
            
            [string]$methodName = $method.Name

            # Add method code provided by the user
            if($PSBoundParameters.ContainsKey('MethodCode'))
            {
                if($MethodCode.ContainsKey($methodName))
                {
                    $methodCodeThisMethod = $MethodCode.$methodName
                }
                else {
                    $methodCodeThisMethod = ''
                }
            }
            else {
                $methodCodeThisMethod = ''
            }

            # Build another method definition for each override discovered
            ForEach($override in $methodOverrides)
            {
                # Clear out variable values
                $splitParts, $returnType, $methodParameters, $methodParameterStrings = $null


                $splitParts = $override.Split($methodName).Trim() | Where-Object {'' -ne $_}
                $returnType = $splitParts[0]
                $methodParameters = $splitParts[1].Replace('(','').Replace(')','')
                if($methodParameters -ne '')
                {
                    $methodParameterStrings = ForEach($parameterFound in ($methodParameters.Split(',')))
                    {
                        "[$($parameterFound.Split(' ')[0])] $($parameterFound.Split(' ')[1])"
                    }
                    $methodParameterStrings = $methodParameterStrings -join ', '
                }

                [PSCustomObject]@{
                    Returntype = $returntype
                    MethodName = $methodName
                    Parameters = $methodParameterStrings
                    MethodCode = $methodCodeThisMethod
                }
            }
        }
        #endRegion


        #region Create Class Text
        $newClassName = $InputObject.GetType().Name
        $NewClassText = @"
# Class derived from $($derivedTypeName.TypeName)
class My$newClassname {
$("`t")#Properties
$( ForEach($property in ($Properties | Sort-Object -Property Name))
{
    "$("`t")[$($property.Definition.Split(' ')[0])] `$$($property.Name)$("`n")"
})
$("`t")#Methods
$( 
    ForEach($method in ($methodObjects) | Sort-Object -Property Name)
    {
        "$("`t")[$( $method.ReturnType )] $( $method.MethodName )($( $method.Parameters )) {$( $method.MethodCode )}$("`n")"
    })
$("`t")#Constructor
$("`t")$newClassName() {
$("`t")$("`t")#insert constructor code here
$("`t")}
}
"@
        #endRegion
    }
    End 
    {
        Write-Verbose "Created class definition for My$newClassname"
        Write-Output $NewClassText
    }
}
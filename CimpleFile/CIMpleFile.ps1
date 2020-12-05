# Create a Get-ChildItem type function using CIM

function Get-CIMFile
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Path
        ,
        [Parameter()]
        [switch]
        $Recurse
        ,
        [Parameter(DontShow)]
        [string]
        $DriveQualifier
        ,
        [Parameter(DontShow)]
        [string]
        $PathQualifier
        ,
        [Parameter(DontShow)]
        [string]
        $FilterString
        ,
        [Parameter(DontShow)]
        [string]
        $PathOperator
        ,
        [Parameter(DontShow)]
        [string]
        $PathEnding
    )
    Begin{}
    Process{
        # Set Path Search Operator and Ending
        $PathOperator = "="
        $PathEnding = "\\"
        if($Recurse)
        {
            $PathOperator = "LIKE"
            $PathEnding = "\\%"
        }

        # Evaluate Path for absolute or relative
        if($Path | Split-Path -IsAbsolute)
        {
            $DriveQualifier = $Path | Split-Path -Qualifier
            Write-Debug "Drive: $DriveQualifier"
        }

        # Format the path string
        $PathQualifier = ($Path | Split-Path -NoQualifier).Replace('\','\\') + $PathEnding
        if($DriveQualifier)
        {
            $FilterString = "Drive = `'$DriveQualifier`' AND Path $PathOperator `'$PathQualifier`'"
        }else{
            $FilterString = "Path $PathOperator `'$PathQualifier`'"
        }
        

        # Get the files
        $gcimParams = @{
            ClassName = 'CIM_LogicalFile'
            Filter = $FilterString
        }
        

        Write-Debug ($gcimParams | Out-String)
        Get-CimInstance @gcimParams
    }
    End{}
}
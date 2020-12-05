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
    Begin
    {
        Write-Verbose -Message "Reading files using the following parameters $($PSBoundParameters | Out-String)"
    }
    Process{
        # Set Path Search Operator and Ending
        $PathOperator = "="
        $PathEnding = "\\"

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
        $files = Get-CimInstance @gcimParams | ForEach-Object {
            [System.IO.FileInfo]::new($_.Name)
        }
        Write-Output $files
        if($Recurse)
        {
            $Folders = $files | Where-Object {$_.Attributes -match 'Directory'}
            Write-Debug "Folder Count: $($Folders | Measure-Object | Select-Object -ExpandProperty Count)"
            Write-Debug "$($Folders.Name | Out-String)"
            foreach($directory in $Folders)
            {
                Write-Debug "Searching $($directory.FullName)"
                Get-CIMFile -Path $directory.FullName -Recurse
            }
        }
    }
    End{}
}
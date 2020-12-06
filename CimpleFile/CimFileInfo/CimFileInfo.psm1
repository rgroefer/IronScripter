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
        if(-not $PSBoundParameters.ContainsKey('Path'))
        {
            $Path = (Get-Location).Path
        }
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

        # Format the path string and Filter string
        $PathQualifier = ($Path | Split-Path -NoQualifier).Replace('\','\\')
        if(-not $PathQualifier.EndsWith('\\'))
        {
            $PathQualifier = $PathQualifier + $PathEnding
        }
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
        
        # Get the files and create the new CimFileInfo object for custom formatting
        $files = Get-CimInstance @gcimParams | ForEach-Object {
            [CimFileInfo]::new($_.Filename, $_.FileSize, $_.Name, $_.Hidden, $_.Compressed, $_.Encrypted, ($_.CimClass.CimClassName -match 'Directory'))
        }
        Write-Output $files

        # Dig deeper if Recurse is called
        if($Recurse)
        {
            # Enumerate only the directories
            $Folders = $files | Where-Object {$_.Directory}
            foreach($directory in $Folders)
            {
                Get-CIMFile -Path $directory.Path -Recurse
            }
        }
    }
    End{}
}

# CimFileInfo class
# Has a custom format and custom type ps1xml file
class CimFileInfo
{
    [string]$Name
    [float]$FileSize
    [string]$Path
    [bool]$Hidden
    [bool]$Compressed
    [bool]$Encrypted
    [bool]$Directory

    CimFileInfo ($Name,$FileSize,$Path,$Hidden,$Compressed,$Encrypted,$Directory)
    {
        $this.Name = $Name
        $this.FileSize = $FileSize
        $this.Path = $Path
        $this.Hidden = $Hidden
        $this.Compressed = $Compressed
        $this.Encrypted = $Encrypted
        $this.Directory = $Directory
    }
}
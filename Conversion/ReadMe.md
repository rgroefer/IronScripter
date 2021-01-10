# PowerShell Class Conversion
---
###Iron Scripter Challenge
Created as a response to the **[Iron Scripter Challenge](https://ironscripter.us/a-powershell-conversion-challenge/)** calling for us to create a tool that will accept an object and create a PowerShell based class definition from it.

## Purpose
This tools accepts an object in the pipeline or by parameter and examines it for properties and methods.  Then it creates a PowerShell based class definition.

## Usage
This tool can accept the object in the pipeline, but you should limit that to a single object.  Otherwise it will continue to provide a class definition for each object.  You may also provide the object as a parameter value.  The class will output as text.

## Notes

### Properties
The class properties are defined by type and name.  This was the focus of the challenge.

### Methods
Methods were a secondary requirement that didn't need defined method code.  The methods are simply defined, with parameters where discovered, and then empty curly braces.

### Constructor
The class constructors will be empty curly braces and no real constructor code.  You would have to provide this on your own.

## Examples
### Example 1 : Service

```pwsh
Get-Service | Select-Object -First 1 | ConvertTo-ClassDefinition
```

### Example 2 : FileInfo

```pwsh
Get-ChildItem | Select-Object -First 1 | ConvertTo-ClassDefinition

# Class derived from System.IO.FileInfo
class MyFileInfo {
        #Properties
        [System.IO.FileAttributes] $Attributes
        [System.Object] $BaseName
        [datetime] $CreationTime
        [datetime] $CreationTimeUtc
        [System.IO.DirectoryInfo] $Directory
        ...

        #Methods
        [System.IO.StreamWriter] AppendText() {}
        [System.IO.FileInfo] Replace([string] destinationFileName, [] string) {}
        [void] Refresh() {}
        [System.IO.FileStream] OpenWrite() {}
        [System.IO.StreamReader] OpenText() {}
        [System.IO.FileStream] OpenRead() {}
        [System.IO.FileStream] Open([System.IO.FileMode] mode, [] System.IO.FileAccess, [] System.IO.FileShare) {}
        [System.IO.FileStream] Open([System.IO.FileMode] mode, [] System.IO.FileAccess) {}
        [System.IO.FileStream] Open([System.IO.FileMode] mode) {}
        ...

        #Constructor
        FileInfo() {
                #insert constructor code here
        }
}
```

### Example 3 : FileInfo and providing method code

```pwsh
Get-ChildItem | select -First 1 | ConvertTo-ClassDefinition -MethodCode @{Delete = 'Get-Item -Path $this.FullName | Remove-Item'}

# Class derived from System.IO.FileInfo
class MyFileInfo {
        #Properties
        [System.IO.FileAttributes] $Attributes
        [System.Object] $BaseName
        [datetime] $CreationTime
        [datetime] $CreationTimeUtc
        [System.IO.DirectoryInfo] $Directory
        ...

        #Methods
        [System.IO.StreamWriter] AppendText() {}
        [System.IO.FileInfo] Replace([string] destinationFileName, [] string) {}
        [void] Refresh() {}
        [System.IO.FileStream] OpenWrite() {}
        [System.IO.StreamReader] OpenText() {}
        [void] Encrypt() {}
        [void] Delete() {Get-Item -Path $this.FullName | Remove-Item}
        ...
}
```
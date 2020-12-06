# CIMple File

## Overview

__CIMple File__ is a fun [Iron Scripter challenge](https://ironscripter.us/a-cim-ple-powershell-challenge/) and this is my response.

The module contains a single function called __Get-CIMFile__ that uses CIM classes to retrieve the files and directories.

The challenge was to create a CIM-based alternative to Get-ChildItem.  The user should be able to specify a location, with a default to the current location.

Bonus points for 
1. supporting a recursive listing
2. format the output as a standard directory listing to Get-ChildItem
3. Support listing a folder from a remote Windows computer and/or CIMSession
4. Show hidden, compressed, and encrypted files or folders in a different color

## Methodology

### CIM Class

The __CIM_LogicalFile__ class seemed, well, logical.  It provided the properties needed to complete the task.  Also, it was the first one I came across that checked all the boxes.  I'm really not sure if there is a better one since I stopped searching after I found this one.

### Recurse

I went through several variations of the recursive functionality.  The results return all at once with Get-CimInstance and that can take a while if you recurse from say, C:\.  Unless you break it up, of course.  If you just add a wildcard to the Path property when you want the recursive action, the wait can be long, but it's a single call to Get-CimInstance and you're done.  I chose to go another way because the length of time it took to return all the results using such a wildcard.  I chose to call my custom function again in a recursive action passing all the directories at each level.  This quick response time at each level was nicer than waiting for the entire result set.  Maybe I'll add a depth parameter to stop searching after a certain number of folders down.

```pwsh
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
```
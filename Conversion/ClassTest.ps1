class Something {
    [string] $Name
    [int] $Num
    hidden [string] $Nope

    [void] SetName([string]$newName)
    {
        $this.Name = $newName
    }

    [void] SetName([string[]]$newNames)
    {
        $this.Name = ($newNames -join ', ')
    }

    Something(){
        $this.Name = 'New'
        $this.Num = 0
    }
}

$VMTags = @()
$object = New-Object PSObject


function get-vmpath($vmname, $depth=5)
{
$FolderName= $null
$CurrentFolder = $null
$Parent = $null
$path = $null
$Level = 0


$FolderName= Get-VM -name $VMName | Select Folder

$CurrentFolder=$FolderName.Folder

While ($Level -lt $depth)
{ 
     #Write-host "Level($Level) : $CurrentFolder"
     $Parent= Get-Folder $CurrentFolder | Select parent
     $Path=$CurrentFolder.name + "\" + $Path
     $CurrentFolder=$Parent.Parent
     if ($CurrentFolder.count -gt 0 )
     {$currentFolder= $CurrentFolder[0]
     }
     $Level=$Level + 1
 }
 
 return $path
}

Get-VM | foreach {

$taginfo = get-vm $_.name | Get-TagAssignment
$object = New-Object PSObject
write-host "Working on: " $_.name
$vmpath = get-vmpath -vmname $_.name
Add-Member -InputObject $object -MemberType NoteProperty -Name 'VM Name' -Value $_.name
if($taginfo.count -gt 0) #Skip empty tags
{
    Add-Member -InputObject $object -MemberType NoteProperty -Name 'Category-Contact' -Value $taginfo[0].Tag.Category.Name
    Add-Member -InputObject $object -MemberType NoteProperty -Name 'COntact-Value' -Value  $taginfo[0].Tag.name
    Add-Member -InputObject $object -MemberType NoteProperty -Name 'Category-Platform' -Value $taginfo[1].Tag.Category.Name
    Add-Member -InputObject $object -MemberType NoteProperty -Name 'Platform-Value' -Value  $taginfo[1].Tag.name
    Add-Member -InputObject $object -MemberType NoteProperty -Name 'Category-Platform-Svc' -Value $taginfo[2].Tag.Category.Name
    Add-Member -InputObject $object -MemberType NoteProperty -Name 'Platform-Svc-Value' -Value  $taginfo[2].Tag.name
}
else{
Write-Host "No Tag information found" -ForegroundColor Cyan }

Add-Member -InputObject $object -MemberType NoteProperty -Name 'Path' -Value  $vmpath

$VMTags += $object

}




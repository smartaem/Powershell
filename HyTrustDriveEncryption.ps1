
<#
.SYNOPSIS
  This is a custom script to initiate Hytrust drive encryption
.DESCRIPTION
  This script iterates through all the logical drives on given system and runs the command "hcl encrypt -o <drive letter>
.PARAMETER <Parameter_Name>
    None
.INPUTS
  None
.OUTPUTS
  Log file stored in C:\tmp\HyEncrypt-SL-<computername>.log
.NOTES
  Version:        1.0
  Author:         Smart Emereonye
  Creation Date:  12/23/15
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\HyTrustDriveEncryption.ps1
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
#$ErrorActionPreference = "SilentlyContinue"



#----------------------------------------------------------[Declarations]----------------------------------------------------------


#Log File Info
$LogPath = "C:\tmp"

if(!(Test-Path $LogPath)){New-Item -path $LogPath -ItemType directory}
$LogName = "HyEncrypt-$(hostname).log"
$LogFile = Join-Path -Path $LogPath -ChildPath $LogName
$drives = $null
$HCL_EXE = ""
#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Logging{
[cmdletbinding()]
param ([Parameter(Mandatory=$false)][switch] $StopLog,[Parameter(Mandatory=$false)][switch] $StartLog)
    If(!(Test-Path -Path $LogFile)){
        New-Item -Path $LogPath -Value $LogName -ItemType File -ErrorAction SilentlyContinue
    }
    if($StartLog)
    {
        Add-Content -Path $LogFile -Value "***************************************************************************************************"
        Add-Content -Path $LogFile -Value "Started processing at [$([DateTime]::Now)]."
        Add-Content -Path $LogFile -Value "***************************************************************************************************`n"
   
  
        #Write to screen for debug mode
        Write-Debug "***************************************************************************************************"
        Write-Debug "Started processing at [$([DateTime]::Now)]."
        Write-Debug "***************************************************************************************************`n"
    }
    if($StopLog)
    {
        Add-Content -Path $LogFile -Value ""
        Add-Content -Path $LogFile -Value "***************************************************************************************************"
        Add-Content -Path $LogFile -Value "Finished processing at [$([DateTime]::Now)]."
        Add-Content -Path $LogFile -Value "***************************************************************************************************"
  
        #Write to screen for debug mode
        Write-Debug ""
        Write-Debug "***************************************************************************************************"
        Write-Debug "Finished processing at [$([DateTime]::Now)]."
        Write-Debug "***************************************************************************************************`n"
    }
   
}
Function Log-Write{
 
  [CmdletBinding()]
  Param ([Parameter(Mandatory=$true)][string]$LineValue)
  
  Process{
    Add-Content -Path $LogFile -Value  "[$([DateTime]::Now)] $LineValue"
  
    #Write to screen for debug mode
    Write-Debug "[$([DateTime]::Now)] $LineValue"
  }
}

function HyEncrypt{

<#
.Example

    To encrypt only the C: drive: HyEncrypt -CDriveOnly

    To encrypt all the drives except the C: drive: HyEncrypt -ExceptCDrive

    To encrypt all the drives found on the system: HyEncrypt -AllDrives
#>
    [CmdletBinding()]
    Param ([Parameter(Mandatory=$false)][switch]$CDriveOnly,[Parameter(Mandatory=$false)][switch]$ExceptCDrive,[Parameter(Mandatory=$false)][switch]$AllDrives)
    Begin{
        $drives = Get-WmiObject –query "SELECT * from win32_logicaldisk where DriveType = 3" |  select DeviceID 
        $noCDrive = $drives | Where-Object {$_.DeviceID -ne "C:"} | select DeviceID
        $Cdrive = $drives | Where-Object {$_.DeviceID -eq "C:"} | select DeviceID
    }
  
    Process{
          Try{
           if($drives)
           {
                Log-Write -LineValue "`nThe following Logical drive(s) were found on the system:`n $($drives.DeviceID)"
                
                if($CDriveOnly) #Encrypt only the C: drive
                {
                    Log-Write -LineValue "Encrypting Only [$($Cdrive.DeviceID)]"
                    Log-Write -LineValue "`nProcessing Drive: [$($Cdrive.DeviceID)]"
                    #$commandoutput = &$HCL_EXE encrypt  –o $Cdrive.deviceid  
                    # out-file $LogFile -Append -InputObject $commandoutput -encoding ASCII
                }
                elseif($ExceptCDrive)  #Encrypt every other Drive that is not C:
                {
                    Log-Write -LineValue "Encrypting Only the following drive(s) [$($noCDrive.DeviceID)]"
                    foreach($drive in $noCDrive){
                        Log-Write -LineValue "`nProcessing Drive: [$($drive.DeviceID)]"
                    
                        #$commandoutput = &$HCL_EXE encrypt  –o $drive.deviceid  
                        # out-file $LogFile -Append -InputObject $commandoutput -encoding ASCII
                        #$test = Get-Process
                        #out-file $LogFile -Append -InputObject $test -encoding ASCII
                    }
                }
                elseif($AllDrives) #Encrypt all the drives on the system
                {
                    Log-Write -LineValue "Encrypting All drives on the system [$($Drives.DeviceID)]"
                    foreach($drive in $Drives){
                        Log-Write -LineValue "`nProcessing Drive: [$($drive.DeviceID)]"
                    
                        #$commandoutput = &$HCL_EXE encrypt  –o $drive.deviceid  
                        # out-file $LogFile -Append -InputObject $commandoutput -encoding ASCII
                        #$test = Get-Process
                        #out-file $LogFile -Append -InputObject $test -encoding ASCII
                    }
                }
           }
        }
    
        Catch{
            Log-Write -LineValue  $_.Exception
            Break
        }
    }
  
    End{
        If($?){
            Log-Write -LineValue "Completed Successfully.`n`n"
           
        }
    }
}


#>

#-----------------------------------------------------------[Execution]------------------------------------------------------------

logging -StartLog

HyEncrypt -CDriveOnly

#HyEncrypt -ExceptCDrive

#HyEncrypt -AllDrives

Logging -Stoplog
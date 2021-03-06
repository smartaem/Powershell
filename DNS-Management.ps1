
<# 
.SYNOPSIS 
    Automated DNS Entry Management/creation
.DESCRIPTION 
    The purpose of this script is to bult DNS entries to the specified DNS Server.
	The scripts accepts CSV file containing the following fields from the users (IP, COMPUTER, DOMAIN) and create DNS entries based on the data
	If the reverse lookup zone does not exist, it also creates it.
 
.NOTES 
    Author     : Smart Emereonye - smarte@liaison.com 
.LINK 
    
#> 

$console = $host.UI.RawUI
$buffer = $console.BufferSize
$buffer.Width = 130
$buffer.Height = 2000
$console.BufferSize = $buffer
$size = $console.WindowSize
$size.Width = 120
$size.Height = 50
$console.WindowSize = $size

function Select-FileDialog 
{
	param([string]$Title,[string]$Directory,[string]$Filter="CSV Files (*.csv)|*.csv")
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	$objForm = New-Object System.Windows.Forms.OpenFileDialog
	$objForm.InitialDirectory = $Directory
	$objForm.Filter = $Filter
	$objForm.Title = $Title
	$objForm.ShowHelp = $true
	$Show = $objForm.ShowDialog()
	If ($Show -eq "OK")
	{Return $objForm.FileName}
	Else
	{
		Write-Host ""
		Write-Host "No input CSV file selected"  -ForegroundColor Red
		Write-Host "`nExiting" -ForegroundColor Red
		Start-Sleep 5
		Exit
	}
}

$version_DNS_AD = "DNS-AD-Management.ps1"
$global:scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

function ReturnToMain()
{
	#runs the main applicatoin
	. "$global:scriptDir\..\$version_DNS_AD"
}

Function run()
{
    Clear-Host
    Write-Host "---------------------------------------------------------------------------------------------------------------------"
    Write-Host "`t`t`t`t`tDNS Management 1.0" -ForegroundColor Cyan
    Write-Host "---------------------------------------------------------------------------------------------------------------------`n"

    Write-Host "`n`n"
    Write-host "Use this program to add entries to DNS servers. To run this program please press [Enter] and you will be" -ForegroundColor Cyan
    write-host  "prompted to Import a CSV file. Once imported, you will then be asked for the DNS server FQDN or IP " -ForegroundColor Cyan
    write-host "CSV field format: Computer, IP, domain" -ForegroundColor Cyan
    read-host "`n[Import CSV]"

    Write-host "`n[DNS Server]"
    $CSVFile = Select-FileDialog -Title "DNS CSV Entries" -Directory "c:\"
    $ServerName = Read-host "Please enter the DNS server FQDN or IP"  #$ServerName = read-host "liaisonproddc1.liaison.prod" 

    #$domain = "liaison.prod" 
    Import-Csv $CSVFile | ForEach-Object { 

        try
        {
            $domain = $_.Domain 
            #Def variable 
            $Computer = "$($_.Computer).$domain" 
            $addr = $_.IP -split "\." 
            $rzone = "$($addr[2]).$($addr[1]).$($addr[0]).in-addr.arpa" 
 
            Write-host "`n-----------------------------------------------------------------------"
            #Create Dns entries 
            try
            {
                dnscmd $Servername /recordadd $domain "$($_.Computer)" A "$($_.IP)" 
            }
            catch
            {
                write-host "There was an error adding the A record. This could mean that the record already exists or the zone does not exist or incorrect"
            }
        
            #Create New Reverse Zone if zone already exist, system return a normal error 
            try
            {
                dnscmd $Servername /zoneadd $rzone /dsprimary
                #Create reverse DNS 
                dnscmd $Servername /recordadd $rzone "$($addr[3])" PTR $Computer  
            }
            catch
            {
                write-host "There was an error adding the reverse DNS  record. This could mean that the record already exists or the zone does not exist or incorrect"
            }
        
        }
        catch
        {
            Write-host "There was an error processing the CSV or adding the entries to DNS. Please varify that the CSV file is in correct format"
        }
        Write-host "`n-----------------------------------------------------------------------`n`n"
     }

     $choice = read-host "Execution has completed. Process another CSV (Y/N or Enter to return to main menu)"
     
     if ($choice -eq 'y' -or $choice -eq 'Y')
     {run}
	elseif($choice -eq 'n' -or $choice -eq 'N')
	{
	  Write-Host "`nExiting" -ForegroundColor Red
		Start-Sleep 5
		Exit
	}
     else
     {
        ReturnToMain
     }
     
}
run
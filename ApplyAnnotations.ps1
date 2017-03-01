﻿# *******************************************************************************************************************
# *******************************************************************************************************************
# Purpose of Script:
#    Helps with the migration of VMware Hosts from one vCenter to another by
#    Appling the Annotations captured with "GatherAnnotations.ps1" to the new vCenter
#    once the VMware Host has been added to it
#   
#    Prompted inputs:               vCenterName, VMHostName
#    Uses files which where generated by
#    "GatherAnnotations.ps1":       $USERPROFILE$\Documents\VMAnnotations-<VHostName>.csv
#                                   $USERPROFILE$\Documents\VMHost-<VHostName>.csv
# *******************************************************************************************************************  
# Authored Date:    Oct 2014
# Original Author:  Graham Jensen
# *************************
# ===================================================================================================================
# Update Log:   Please use this section to document changes made to this script
# ===================================================================================================================
# -----------------------------------------------------------------------------
# Update <Date>
#    Author:    <Name>
#    Description of Change:
#       <Description>
# -----------------------------------------------------------------------------
# *******************************************************************************************************************


# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Operational Notes
# -----------------
# ****Location of other scripts called:  ****
# 
# Expects that "GatherAnnotations.ps1" has already been run against the
# old vCenter and that the following files are available
#          - $USERPROFILE$\Documents\VMAnnotations-<VHostName>.csv
#          - $USERPROFILE$\Documents\VMHost-<VHostName>.csv
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

# **** Path Variable, modify for your use ****
$CSVPath = $env:USERPROFILE+"\Documents"

#Prompt User for vCenter
$VCName = Read-Host "Enter the name of the vCenter you wish to connect to"

#Prompt User for ESXi Host
$VHostName = Read-Host "Enter the name of the ESXi host you are migrating"

#Connect to VC using input from above
Connect-VIServer $VCName

#Search and replace strings in the exported Host Annotations to conform to new Annotation Names
#$lines=Get-Content $CSVPath\VMHost-$VHostName.csv | ForEach-Object{$_ -replace 'Contact','Site Contact'};$lines | Set-Content $CSVPath\VMHost-$VHostName.csv
$lines=Get-Content $CSVPath\VMHost-$VHostName.csv | ForEach-Object{$_ -replace 'Description','2 VM Notes'};$lines | Set-Content $CSVPath\VMHost-$VHostName.csv
$lines=Get-Content $CSVPath\VMHost-$VHostName.csv | ForEach-Object{$_ -replace 'Purpose','VM Detail'};$lines | Set-Content $CSVPath\VMHost-$VHostName.csv

#Import values for Host Annotations from CSV and apply to new VC
Import-Csv -Path $CSVPath\VMHost-$VHostName.csv | Where-Object {$_.Value} | ForEach-Object {
Get-VMHOST $_.VM | Set-Annotation -CustomAttribute $_.Name -Value $_.Value
}

#Import values for VM Annotations from CSV and apply to new VC
Import-Csv -Path $CSVPath\VMAnnotations-$VHostName.csv | Where-Object {$_.Value} | ForEach-Object {
Get-VM $_.VM | Set-Annotation -CustomAttribute $_.Name -Value $_.Value
}


# Disconnect from VC
Disconnect-VIServer -Server $VCName -Confirm:$false

# *******************************************************************************************************************
# *******************************************************************************************************************
# Purpose of Script:
#    Helps with the migration of VMware Hosts from one vCenter to another by
#    pulling the Annotations for a VMware Host and any VMs running on the host 
#    and writing them to a file.
#
#    Prompted inputs:  vCenterName, VMHostName
#    Outputs:          $USERPROFILE$\Documents\VMAnnotations-<VHostName>.csv
#                      $USERPROFILE$\Documents\VMHost-<VHostName>.csv
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


# **** Path Variable, modify for your use ****
$CSVPath = $env:USERPROFILE+"\Documents"

#Prompt User for vCenter
$VCName = Read-Host "Enter the name of the vCenter you wish to connect to"

#Prompt User for ESXi Host
$VHostName = Read-Host "Enter the name of the ESXi host you are migrating"

#Connect to VC using input from above
Connect-VIServer $VCName

# Extract Host Annotations and write them to CSV file
Get-VMHost -Name $VHostName | ForEach-Object {
$VM = $_
$VM | Get-Annotation |`
ForEach-Object {
$Report = "" | Select-Object VM,Name,Value
$Report.VM = $VM.Name
$Report.Name = $_.Name
$Report.Value = $_.Value
$Report
}
} | Export-Csv -Path $CSVPath\VMHost-$VHostName.csv -NoTypeInformation

#Extract VM Annotations and write them to CSV File
Get-VMHost -Name $VHostName | Get-VM | ForEach-Object {
$VM = $_
$VM | Get-Annotation |`
ForEach-Object {
$Report = "" | Select-Object VM,Name,Value
$Report.VM = $VM.Name
$Report.Name = $_.Name
$Report.Value = $_.Value
$Report
}
} | Export-Csv -Path $CSVPath\VMAnnotations-$VHostName.csv -NoTypeInformation

#Disconnect from VC
Disconnect-VIServer -Server $VCName -Confirm:$false

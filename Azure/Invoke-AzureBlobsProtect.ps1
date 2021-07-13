#Requires -Modules Rubrik

<#
.SYNOPSIS
    AzCopy contents of a given Azure Blobs Container to a Rubrik Managed Volume (EAS).

.DESCRIPTION

.PARAMETER RubrikServer
    Rubrik server address.

.PARAMETER RubrikCred
    Rubrik user credentials.

.PARAMETER MVName
    Managed Volume Name.

.PARAMETER SourceBlobsContainer
    Azure Blobs Container URL (including shared access signature).

.PARAMETER TargetMV
    Target Managed Volume Address.

.PARAMETER AzCopyPath
    Path to AzCopy.exe.

.INPUTS
.OUTPUTS
.EXAMPLE
.LINK
.NOTES
    Author  : Max Samuelson <max.samuelson@rubrik.com>
    Created : May 21, 2019
    Company : Rubrik Inc
#>

param
(
    [Parameter(Mandatory = $true, HelpMessage="The Rubrik server address.")] 
    [string] $RubrikServer,
    
    [Parameter(Mandatory = $true, HelpMessage="Rubrik user credentials.")]
    [pscredential] $RubrikCred,

    [Parameter(Mandatory = $true, HelpMessage="Managed Volume Name.")] 
    [string] $MVName,

    [Parameter(Mandatory = $true, HelpMessage="Azure Blobs Container URL (including shared access signature).")]
    [string] $SourceBlobsContainer,
    
    [Parameter(Mandatory = $true, HelpMessage="Target Managed Volume Address.")] 
    [string] $TargetMV,
    
    [Parameter(Mandatory = $false, HelpMessage="Full path to AzCopy.exe.")]
    [string] $AzCopyPath
)

Connect-Rubrik $RubrikServer -Credential $RubrikCred

$mv = Get-RubrikManagedVolume -Name $MVName
$mv | Start-RubrikManagedVolumeSnapshot

$AzCopyFullPath = ".\azcopy.exe"
if ($AzCopyPath) {
    $AzCopyFullPath = Join-Path -Path $AzCopyPath -ChildPath "AzCopy.exe"
}

$Command = "$AzCopyFullPath copy '$SourceBlobsContainer' '$TargetMV' --recursive"
Invoke-Expression $Command

$mv | Stop-RubrikManagedVolumeSnapshot

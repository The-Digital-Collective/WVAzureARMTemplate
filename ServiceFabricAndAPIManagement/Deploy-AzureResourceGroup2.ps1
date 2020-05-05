#Requires -Version 3.0

Param(
    [string] [Parameter(Mandatory=$true)] $resourceGroupName,
    [string] [Parameter(Mandatory=$true)] $location,
    [string] [Parameter(Mandatory=$true)] $keyVaultName,
    [string] $emailAddress = 'venkatesh.anbazhagan@worldvision.org.uk',
    [string] $certificateName = 'worldvisioncert',
    [string] $certSubjectName = 'CN=contoso.com',
    
)

# The resource group that will contain the Key Vault to create to contain the Key Vault
 $resourceGroupName = 'chosen-sandbox-APIM-RG'

# The name of the Key Vault to install
  $keyVaultName = 'chosen-sandbox-keyvalut'

# The Azure data center to install the Key Vault to
 $location = 'North Europe'

$emailAddress = 'venkatesh.anbazhagan@worldvision.org.uk'

$certificateName = 'worldvisioncert'

$certSubjectName = 'CN=worldvision.com'

# Create the Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create the Key Vault (enabling it for Disk Encryption, Deployment and Template Deployment)
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $location -EnabledForDiskEncryption -EnabledForDeployment -EnabledForTemplateDeployment

#Add Access policy
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $resourceGroupName `
  -EmailAddress $emailAddress `
  -PermissionsToKeys list,get,encrypt,decrypt,wrapKey,unwrapKey,sign,verify,create,update,import,delete,backup,restore,recover,purge `
  -PermissionsToSecrets list,get,set,delete,backup,restore,recover,purge `
  -PermissionsToCertificates list,get,delete,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore

# Generate certificate   
$Policy = New-AzKeyVaultCertificatePolicy -SecretContentType "application/x-pkcs12" -SubjectName $certSubjectName -IssuerName "Self" -ValidityInMonths 6 -ReuseKeyOnRenewal
Add-AzKeyVaultCertificate -VaultName $keyVaultName -Name $certificateName -CertificatePolicy $Policy  

# Generate secret value for keyvalut      
$Secret = ConvertTo-SecureString -String 'Sup3rS3cr3tP4ss' -AsPlainText -Force
$Expires = (Get-Date).AddYears(2).ToUniversalTime()
$NBF =(Get-Date).ToUniversalTime()
$Tags = @{ 'Severity' = 'medium'; 'IT' = 'true'}
$ContentType = 'txt'
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'ITSecret' -SecretValue $Secret -Expires $Expires -NotBefore $NBF -ContentType $ContentType -Disable -Tags $Tags   

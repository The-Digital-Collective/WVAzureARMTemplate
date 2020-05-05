# The resource group that will contain the Key Vault to create to contain the Key Vault
$resourceGroupName = 'app-keyvalut-rg'

# The name of the Key Vault to install
$keyVaultName = 'ContosoKV0112'

# The Azure data center to install the Key Vault to
$location = 'East US'


# Create the Resource Group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create the Key Vault (enabling it for Disk Encryption, Deployment and Template Deployment)
New-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -Location $location -EnabledForDiskEncryption -EnabledForDeployment -EnabledForTemplateDeployment

#Add Access policy
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $resourceGroupName `
  -UserPrincipalName 'venkatesh.anbazhagan@worldvision.org.uk' `
  -PermissionsToSecrets list,get,set,delete,backup,restore,recover,purge `
  -PermissionsToKeys list,get,encrypt,decrypt,wrapKey,unwrapKey,sign,verify,create,update,import,delete,backup,restore,recover,purge `
  -PermissionsToCertificates list,get,delete,create,import,update,managecontacts,getissuers,listissuers,setissuers,deleteissuers,manageissuers,recover,purge,backup,restore

# Generate certiticate   
$Policy = New-AzureKeyVaultCertificatePolicy -SecretContentType "application/x-pkcs12" -SubjectName "CN=contoso.com" -IssuerName "Self" -ValidityInMonths 6 -ReuseKeyOnRenewal
Add-AzureKeyVaultCertificate -VaultName $keyVaultName -Name "TestCert01" -CertificatePolicy $Policy  

   
Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'MyAdminPassword' `
  -SecretValue (ConvertTo-SecureString -String 'Sup3rS3cr3tP4ss!' -AsPlainText -Force) `
  -ContentType 'txt' `
  -NotBefore ((Get-Date).ToUniversalTime()) `
  -Expires ((Get-Date).AddYears(2).ToUniversalTime()) `
  -Disable:$false `
  -Tags @{ 'Risk' = 'High'; }

 
 
<#
.SYNOPSIS
    PowerShell script to automate the creation of a Microsoft 365 user,
    assign a license, copy group memberships from a reference user,
    and provision OneDrive.

.DESCRIPTION
    This script is designed to streamline onboarding for IT administrators.
    It connects to Microsoft Graph, creates a user, assigns a license, copies group memberships,
    and triggers OneDrive provisioning.

.REQUIREMENTS
    - PowerShell 7.x or later (recommended)
    - Required modules:
        * Microsoft.Graph (Install-Module Microsoft.Graph -Scope CurrentUser)
        * Microsoft.Online.SharePoint.PowerShell (Install-Module Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser)
    - Permissions:
        * User.ReadWrite.All
        * Directory.ReadWrite.All
        * GroupMember.ReadWrite.All
    - SharePoint Admin permissions for OneDrive provisioning
    - Global Administrator or equivalent role

.NOTES
    Author: YourNameHere
    Version: 1.0
    Filename: New-M365UserWithLicenseAndGroups.ps1
#>

# ================================
# RECOMMENDED POWERSHELL VERSION
# ================================
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Warning "⚠️ It is recommended to run this script using PowerShell 7 or later for optimal performance."
}

Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# ================================
# VARIABLES - Customize Here
# ================================
$DisplayName        = "Jane Doe"
$FirstName          = "Jane"
$LastName           = "Doe"
$UserPrincipalName  = "janedoe@example.com"
$Password           = "Welcome@123"  # Strong default password
$JobTitle           = "Sales Representative"
$MobilePhone        = "050-0000000"
$UsageLocation      = "US"

# --------------------------------
# Microsoft 365 License SKU ID
# --------------------------------
# To find your available licenses and their SKU IDs, run:
#   Get-MgSubscribedSku | Select-Object SkuPartNumber, SkuId
# Replace with the desired SkuId:
$SkuId              = "f245ecc8-75af-4f8e-b61f-27d8114de5f3"  # Example: M365 Business Standard

# Reference user for group copying
$ReferenceUserUPN   = "templateuser@example.com"

# SharePoint Admin URL
$SharePointAdminUrl = "https://yourtenant-admin.sharepoint.com"

# ================================
# CONNECT TO MICROSOFT GRAPH
# ================================
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All", "GroupMember.ReadWrite.All"

# ================================
# CREATE NEW USER
# ================================
$PasswordProfile = @{
    Password = $Password
    ForceChangePasswordNextSignIn = $true
}

$UserParams = @{
    DisplayName         = $DisplayName
    GivenName           = $FirstName
    Surname             = $LastName
    UserPrincipalName   = $UserPrincipalName
    MailNickname        = ($UserPrincipalName -split "@")[0]
    JobTitle            = $JobTitle
    MobilePhone         = $MobilePhone
    AccountEnabled      = $true
    UsageLocation       = $UsageLocation
    PasswordProfile     = $PasswordProfile
}

$NewUser = New-MgUser @UserParams
if ($NewUser) {
    Write-Host "✅ User created: $UserPrincipalName"
} else {
    Write-Host "❌ Error creating user: $UserPrincipalName"
    exit
}

# ================================
# ASSIGN LICENSE TO USER
# ================================
$NewUserId = (Get-MgUser -UserId $UserPrincipalName).Id

$LicenseBody = @{
    addLicenses    = @(@{skuId = $SkuId })
    removeLicenses = @()
} | ConvertTo-Json -Depth 3

Invoke-MgGraphRequest -Method POST `
    -Uri "https://graph.microsoft.com/v1.0/users/$NewUserId/assignLicense" `
    -Body $LicenseBody `
    -ContentType "application/json"

Write-Host "✅ License assigned to $UserPrincipalName"

# ================================
# COPY GROUP MEMBERSHIPS
# ================================
$Groups = Get-MgUserMemberOf -UserId $ReferenceUserUPN
foreach ($Group in $Groups) {
    try {
        New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $NewUserId
        Write-Host "✅ Added to group: $($Group.DisplayName)"
    }
    catch {
        Write-Host "❌ Error adding to group $($Group.DisplayName): $_"
    }
}

# ================================
# PROVISION ONEDRIVE (Optional)
# ================================
Connect-SPOService -Url $SharePointAdminUrl
Request-SPOPersonalSite -UserEmails $UserPrincipalName
Write-Host "✅ OneDrive provisioning requested for $UserPrincipalName"

# ================================
# DONE
# ================================
Write-Host "🎉 User $UserPrincipalName has been successfully created and configured!"

# New-M365UserWithLicenseAndGroups.ps1

PowerShell script for automating the creation of a Microsoft 365 user, assigning a license, copying group memberships from a reference user, and provisioning OneDrive.

## 🔍 Overview

This script is intended for IT administrators who want to streamline the onboarding process in Microsoft 365. It uses the Microsoft Graph API and SharePoint Online PowerShell to:

- Create a new user with a temporary password
- Assign a Microsoft 365 license
- Copy group memberships from an existing user
- Provision the user's OneDrive

---

## ✅ Requirements

- **PowerShell version:** 7.x or later (recommended)
- **Modules:**
  - `Microsoft.Graph`  
    Install with:  
    ```powershell
    Install-Module Microsoft.Graph -Scope CurrentUser
    ```
  - `Microsoft.Online.SharePoint.PowerShell`  
    Install with:  
    ```powershell
    Install-Module Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser
    ```

- **Permissions (consent required when connecting to Graph):**
  - `User.ReadWrite.All`
  - `Directory.ReadWrite.All`
  - `GroupMember.ReadWrite.All`

- **Roles:**
  - Global Administrator or equivalent
  - SharePoint Admin (for OneDrive provisioning)

---

## ⚙️ How to Find Your License SKU ID

You need to provide the correct `SkuId` for the license you want to assign to new users. To list all available licenses in your tenant:

```powershell
Connect-MgGraph -Scopes "Directory.Read.All"
Get-MgSubscribedSku | Select-Object SkuPartNumber, SkuId
```

Here are some commonly used Microsoft 365 licenses:

| License Name                    | SkuPartNumber             | SkuId (GUID)                                |
|---------------------------------|---------------------------|---------------------------------------------|
| Microsoft 365 Business Standard | O365_BUSINESS_PREMIUM     | `f245ecc8-75af-4f8e-b61f-27d8114de5f3`      |
| Microsoft 365 E3                | ENTERPRISEPACK            | `06ebc4ee-1bb5-47dd-8120-11324bc54e06`      |
| Microsoft Teams Exploratory     | TEAMS_EXPLORATORY         | `0b4c0f3b-0982-4c25-8122-998cd34b14f2`      |

> 💡 The SkuId is public and identical across all tenants — it's safe to use and share.

---

## 🚀 Usage Instructions

1. Clone or download this repository.
2. Open the script in your preferred PowerShell editor.
3. Update the following variables:
   - `$DisplayName`, `$FirstName`, `$LastName`, `$UserPrincipalName`
   - `$Password`, `$JobTitle`, `$MobilePhone`
   - `$UsageLocation` (e.g., `"US"`, `"IL"`)
   - `$SkuId` (see above)
   - `$ReferenceUserUPN` (existing user to copy group memberships from)
   - `$SharePointAdminUrl` (your tenant's SharePoint admin center URL)

4. Run the script using PowerShell 7+:
   ```powershell
   ./New-M365UserWithLicenseAndGroups.ps1
   ```

---

## 📦 Script Capabilities

| Feature                      | Included |
|-----------------------------|----------|
| Create M365 User            | ✅       |
| Assign License              | ✅       |
| Copy Group Memberships      | ✅       |
| Provision OneDrive          | ✅       |
| Force Password Reset        | ✅       |
| Graph Permissions Required  | ✅       |

---

## 🛑 Important Notes

- The default password (`$Password`) should be changed or rotated.
- You can disable the OneDrive provisioning block if not needed.
- The script uses Microsoft Graph and SharePoint Online — ensure your account has the right permissions.

---

## ✍️ Author & License

Created by **YourNameHere**  
MIT License – feel free to fork, reuse, and improve.

---

## 📬 Feedback

If you encounter issues or have suggestions, feel free to open an issue or a pull request. Contributions are welcome!

<#

.SYNOPSIS
Creates a networkshare and set the permissions

.Description
Creates a networkshare and set the permissions

.EXAMPLE
New-NetworkShare -path "C:\test" -sharename "test" -AccessGroup "Lowell2\Domain Admins" -permissions "FullControl"

.NOTES
Daryl Bizsley 2016

#>

Function Add-ACL {
  param (
    $path,
    $AccessGroup,
    $permissions
  )
  $acl = get-acl $($path)
  $permission = "$($AccessGroup)","$($permissions)","ContainerInherit,ObjectInherit","None","Allow"
  $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
  $acl.SetAccessRule($accessrule)
  $acl | Set-ACL $($path)
}
Function Set-SharePermissions {
  param(
    $sharename
  )
  Get-WmiObject -Class Win32_LogicalShareSecuritySetting -filter "Name=""$($sharename)""" | foreach {
    $newDescriptor = $_.GetSecurityDescriptor().descriptor
    $newDescriptor.dacl = $_.GetSecurityDescriptor().Descriptor.Dacl | Where {$_.trustee.name -ne 'Everyone'}
    $_.SetSecurityDescriptor($newDescriptor)
  }
}
Function New-NetworkShare {
  param (
    $path,
    $sharename,
    $AccessGroup,
    [Validateset("Read","Modify","FullControl")][string]$permissions
  )
  #Create Directory
  try {
    New-item "$($path)" -itemtype Directory -erroraction stop | out-null
  }
  catch [System.IO.IOException]{
    Write-Verbose "Directory $($path) Already Exists"
  }
  #Check it's not already shared.
  $check =  (Get-WmiObject Win32_Share).where({$_.path -eq "$($path)"})
  if ($check) {
    Write-Verbose "Directory $($path) already shared as $($check.Name)"
  }
  Else {
    $result = (Get-WmiObject Win32_Share -List).Create("$($path)","$sharename",0)
    if ($result -ne 0) {
      Write-Verbose "Failed to create share return code $($result.returncode)"
    }
  }
  Add-ACL -AccessGroup $AccessGroup -Path $path -permissions $permissions | out-null
  Set-SharePermissions -sharename $sharename | out-null
  return $((Get-WmiObject Win32_Share).where({$_.path -eq "$($path)"}))
}

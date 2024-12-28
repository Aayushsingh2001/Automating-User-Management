# Reads the users.csv file
$users = Import-Csv -Path "C:\Users\as699\OneDrive\Desktop\aayu_DevOps\automating-user-management\users.csv"

$logFile = "C:\Users\as699\OneDrive\Desktop\aayu_DevOps\automating-user-management\user_management_logs.text"

# Function to log actions
function Log-Action {
    param (
        [string]$message
    )
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "$timestamp - $message"
    Add-Content -Path $logFile -Value $logMessage
}

# Reiterate through each user present in the file
foreach ($user in $users) {
    $username = $user.Username
    $password = $user.Password
    $role = $user.Role

    $existingUser = Get-LocalUser -Name $username -ErrorAction SilentlyContinue

    if ($existingUser) {
        Log-Action "User '$username' exists. Updating the account."

        Set-LocalUser -Name $username -Password (ConvertTo-SecureString -AsPlainText $password -Force)

        # Check if the particular user is part of 'Administrator' group or not
        $groupMembers = Get-LocalGroupMember -Group "Administrators"

        if ($role -eq "Administrator") {
            if ($groupMembers -notcontains $username) {
                Add-LocalGroupMember -Group "Administrators" -Member $username
                Log-Action "The user named '$username' is added to the Administrator group."

            } else {
                Log-Action "'$username' is already a member of the 'Admonistrators' group."
            }
        } elseif ($role -eq "Standard User") {
            if ($groupMember -ccontains $username) {
                Remove-LocalGroupMember -Group "Admonistrators" -Member $username
                Log-Action "Removed '$username' from the Administrator group."
            } else {
                Log-Action "'$username' is not a member of the 'Administrator' group."
            }
        }
    } else {
        Log-Action "Creating new user '$username'."

        #Creating new user
        New-LocalUser -Name $username -Password (ConvertTo-SecureString -AsPlainText $password -Force) -FullName $username -Description "Created by script."
        Log-Action "User '$username' created successfully."

        # Assigning the roles now
        if ($role -eq "Administrator") {
            Add-LocalGroupMember -Group "Administrators" -Member $username
            Log-Action "Added '$username' to the 'Administrator' group."
        } elseif ($roel -eq "Standard User") {
            Add-LocalGroupMember -Group "User" -Member $username
            Log-Action "Added '$username' to the 'Users' group."
        }
    }
    
    # Create home directory for the users and set the users and set the permissions
    $homeDir = "C:\Users\$username"
    if (-not (Test-Path -Path $homeDir)) {
        New-Item -Path $homeDir -ItemType Directory
        Log-Action "Created Home directory for '$username' at '$homeDir'."
    }

    # Setting up the permissions
    $acl = Get-Acl -Path $homeDir
    $permission = "$username", "FullControl", "Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($permission)
    $acl.AddAccessRule($accessRule)
    Set-Acl -Path $homeDir -AclObject $acl
    Log-Action "Set Full control permissiions for '$username' on their home directory."

}
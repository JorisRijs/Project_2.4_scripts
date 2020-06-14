# This is a script which creates a administrative user with more account security

# These variables prompt the user to enter some info for the user which is to be created
$username = Read-Host -Prompt "please input the username"
$pw1 = Read-Host -Prompt "please provide a password of the user" -AsSecureString
$pw2 = Read-Host -Prompt "please retype the password for conformation" -AsSecureString
# Converts the secure string passwords to text for the comparison
$pw1_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw1))
$pw2_text = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw2))
# Splits the given name into an arry to be used later as the surname and given name
$NameArray =$username.Split(".")
$AccountPassword = ""
$OUName = "Systeembeheer"
# Defines the base profile path for the new user. Will be used later in the script.
$ProfilePath = "\ITV2G-W16-3\ProfileFolder\$username"
# Checks if the two given passwords are equal to eachother
# This could be done better with comparring the 
If ($pw1_text -ceq $pw2_text){
    Write-Host "the passwords are equal"
    $AccountPassword = $pw1
}
Else{
    Write-Host "The passwords are not equal"
    # If the given passwords are wrong, the script will exit.
    Exit
}

# checks if the given user already exists
If (@(Get-ADUser -Filter {SamAccountName -eq $username}).Count -eq 0){
    Write-Warning -Message "this user does not exists"
    try{
        # Creates the user with all of the wanted parameters
        New-ADUser -Name $username -GivenName $NameArray[0] -Surname $NameArray[1] -UserPrincipalName "$username@zp11g.hanze20" -AccountPassword $AccountPassword -ProfilePath $ProfilePath 
        # Enables the account 
        Enable-ADAccount -Identity $username
        # Moves the user to the correct OU
        $UserObject=Get-ADUser -LDAPFilter "(SamAccountName=$username)"
        $OUObject=Get-ADOrganizationalUnit -LDAPFilter "(name=$OUName)"
        Move-ADObject -TargetPath $OUObject.DistinguishedName -Identity $UserObject.DistinguishedName
        # adds the account to the neccesary user group
        Add-ADGroupMember "Systeembeheerders" $username
        # Gives an overview of the users in the earlier assigned group to check if that went well
        Get-ADGroupMember "Systeembeheerders"
        # Defines two fine grained password policies for the newly created user.
        if (@(Get-ADFineGrainedPasswordPolicy -Identity itmanagementpswd).Count -eq 0){
            New-ADFineGrainedPasswordPolicy -Name "itmanagementpswd" -Precedence 99 -MaxPasswordAge "28.00:00:00" -MinPasswordAge "7.00:00:00" -MinPasswordLength 12 -PasswordHistoryCount 32 -ReversibleEncryptionEnabled $true -Description "The password policy which defines the rules for the passwords of IT management" -DisplayName "IT man base pso"
            Write-Warning -message "The new finegrained password policy"
            get-adfinegrainedpasswordpolicy -identity itmanagementpswd
        }
        else{
            Write-Warning -Message "The finegrained password policy itmanagementpswd is already in place"
        }
        if (@(Get-ADFineGrainedPasswordPolicy -Identity itpswd).count -eq 0){
            New-ADFineGrainedPasswordPolicy -Name "itpswd" -Precedence 100 -ComplexityEnabled $true -Description "The fine grained password policy for system management" -DisplayName "System management PSO" -LockoutDuration "0.12:00:00" -LockoutObservationWindow "0.00:15:00" -LockoutThreshold 5
            Write-warning -Message "The fine grained password policy itpswd has been created"
            get-adfinegrainedpasswordpolicy -identity itpswd
        }
        else{
            Write-Warning -Message "The fine grained password policy itpswd is already in place"
        }
        
        # Applies the fine grained password policies the the created user
        Add-ADFineGrainedPasswordPolicySubject "itpswd" -Subjects $username
        Add-ADFineGrainedPasswordPolicySubject "itmanagementpswd" -Subjects $username
        Write-Warning -Message "The User has been created successfully and has been assigned to the correct group"
    }
    catch{
        # This will show the error which has occured as wel as that something has gone wrong
        $_
        Write-Warning -Message "something went wrong"
    }
}
else{
    Write-Warning -Message "This user already exists"
}


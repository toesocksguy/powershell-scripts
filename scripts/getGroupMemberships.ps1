<#
Author: Marshall Harris
Date: April 2023

Background: This script is a workaround for the errors we are getting with "Get-ADPrincipleGroupMembership" cmdlet.

Description: The script will prompt for SAM account name, get user object (including MemberOf property), separate the principle group memberships from the user object, then output those groups to a relative file path (currently it will write to the Downloads folder of the person who runs the script) with an easily identifiable file name.

Notes:
 - If the file already exists, the script will remove it before writing the new file
#>


# Clear the shell
Clear-Host

# Start try/catch for error handling
try 
{
	# Prompt for SAM Account Name
	$user = Read-Host "`nEnter user SAM Account Name"

	# Initialize output variable to write to script-runners Downloads folder (is there a more appropriate location?)
	$outputFile = "$env:USERPROFILE\Downloads\${user}_groups.txt"

	# Add AD user object to variable, including MemberOf
	$userObject = Get-ADUser $user -Properties MemberOf

	# Add only the MemberOf properties to variable
	$groups = $userObject.MemberOf

	# If the output file already exists, delete it
    if(Test-Path $outputFile){
        Remove-Item $outputFile
    }

	# Loop through each MemberOf entry 
	foreach($group in $groups){
		# Grab only the group name
		# Reference: https://adamtheautomator.com/powershell-regex/
		$match = Select-String 'CN=(.*?),' -InputObject $group
		
		# Append to output file
		$match.Matches.groups[1].Value | Out-File $outputFile -Append
	}
	
	# Output message for success
	Write-Host "`nSuccess. Output file => $env:USERPROFILE\Downloads\${user}_groups.txt"
	Read-Host "`nPress any key to exit"
}

catch 
{
	Write-Host "Enter a valid SAM Account Name"
}

# TODO: implement the "execute indefinitely" bit from https://stackoverflow.com/questions/68056955/user-input-validation-in-powershell to
# continue prompting for SAM account name until a valid option is selected?
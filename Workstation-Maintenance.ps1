# This is a script which automatically makes the configurations for Workstation maintanance
# Author: Joris Rijs
# Email: j.n.j.rijs@st.hanze.nl
# Studentnumber: 
# Class: 
# Creates a directory for the JEAConfig 
New-Item -Path "C:\JEAConfig" -ItemType Directory
# Creates a transscript directory
New-Item -Path "C:\JEAConfig\Transcripts" -ItemType Directory
# all allow cmdlets
$cmdlets = 'Get-NetAdapter', 'Restart-Computer', 'Test-connection', 'set-service', 'start-job', 'stop-computer', 'add-computer', 'import-module', 'get-service'
# Creates a new pssessionconfiguration file with all of the neccesary aatributes
New-PSSessionConfigurationFile -Path "C:\JEAConfig\Workstation-Maintenance.pssc" -Author "J.N.J.Rijs" -SessionType RestrictedRemoteServer -TranscriptDirectory "C:\JEAConfig\Transcripts" -RunAsVirtualAccount -RoleDefinitions @{'ZP11G.hanze20\j.rijs' = @{VisibleCmdlets = $cmdlets}}
# Registers the pssessionconfiguration so it can be accessed
Register-PSSessionConfiguration -Name 'Workstation-Maintenance' -Path 'C:\JEAConfig\Workstation-Maintenance.pssc'
# just gets all of the pssession configurations
Get-PSSessionConfiguration
# creates a directory for the workstation maintenance so it becomes a powershell module
New-item -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAWorkstation-Maintenance' -ItemType Directory
# creates a new module manifest annd also specifies the root module
New-ModuleManifest -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAWorkstation-Maintenance\JEAWorkstation-Maintenance.psd1' -RootModule JEAWorkstation-Maintenance.psm1
#Creates new directories where the rolecapability file will be placed.
New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAWorkstation-Maintenance\JEAWorkstation-Maintenance.psm1' -ItemType File
New-Item -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAWorkstation-Maintenance\RoleCapabilities' -ItemType Directory
# Creates the rolecapabilies file including all allowed cmdlets
New-PSRoleCapabilityFile -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAWorkstation-Maintenance\RoleCapabilities\JEAWorkstation-Maintenance.psrc' -VisibleCmdlets $cmdlets -VisibleExternalCommands 'C:\Windows\system32\cmd.exe' -VisibleAliases 'Dir',’ls’
# Checks to see if the pssession configuration file is valid
Test-PSSessionConfigurationFile -Path C:\JEAConfig\Workstation-Maintenance.pssc
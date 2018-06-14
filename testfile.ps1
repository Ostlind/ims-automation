<#  
.SYNOPSIS  
    Vertically scale (up or down) an Azure SQL Database   
  
.DESCRIPTION  
    This runbook enables one to vertically scale (up or down) an Azure SQL Database using Azure Automation. 
    
    There are many scenarios in which the performance needs of a database follow a known schedule.
    Using the provided runbook, one could automatically schedule a database to a scale-up to a Premium/P1 
    database during peak hours (e.g., 7am to 6pm) and then scale-down the database to a Standard/S0 during
    non peak hours (e.g., 6pm-7am).

 .PARAMETER SqlServerName 
    Name of the Azure SQL Database server (Ex: bzb98er9bp) 
      
.PARAMETER DatabaseName  
    Target Azure SQL Database name

.PARAMETER Edition  
    Desired Azure SQL Database edition {Basic, Standard, Premium}
    For more information on Editions/Performance levels, please 
    see: http://msdn.microsoft.com/en-us/library/azure/dn741336.aspx

.PARAMETER PerfLevel  
    Desired performance level {Basic, S0, S1, S2, P1, P2, P3} 
 
.PARAMETER Credential  
    Credentials for $SqlServerName stored as an Azure Automation credential asset  
    When using in the Azure Automation UI, please enter the name of the 
    credential asset for the "Credential" parameter
    
.EXAMPLE  
    Set-AzureSqlDatabaseEdition 
        -SqlServerName bzb98er9bp  
        -DatabaseName myDatabase
        -Edition Premium
        -PerfLevel P1
        -Credential myCredential 
  
.NOTES  
    Author: Joseph Idziorek   
    Last Updated: 11/22/2014     
#> 

function Set-AzureSqlDatabaseEdition-Ims
{
    param
    (
        # Name of the Azure SQL Database server (Ex: bzb98er9bp)
        [parameter(Mandatory=$true)] 
        [string] $SqlServerName,

        # Target Azure SQL Database name 
        [parameter(Mandatory=$true)] 
        [string] $DatabaseName,

        # Desired Azure SQL Database edition {Basic, Standard, Premium}
        [parameter(Mandatory=$true)] 
        [string] $Edition,

        # Desired performance level {Basic, S0, S1, S2, P1, P2, P3}
        [parameter(Mandatory=$true)] 
        [string] $PerfLevel,

        # Credentials for $SqlServerName stored as an Azure Automation credential asset
        # When using in the Azure Automation UI, please enter the name of the credential asset for the "Credential" parameter
        [parameter(Mandatory=$true)] 
        [PSCredential] $Credential
    )
    
        Write-Output "Begin vertical scaling script..."
        
        #$Credential = Get-AutomationPSCredential -Name 'databaseadmin'
        # Establish credentials for Azure SQL Database server 
        $Servercredential = new-object System.Management.Automation.PSCredential($Credential.UserName, (($Credential).GetNetworkCredential().Password | ConvertTo-SecureString -asPlainText -Force)) 
        
        # Create connection context for Azure SQL Database server
        $CTX = New-AzureSqlDatabaseServerContext -ManageUrl "https://$SqlServerName.database.windows.net" -Credential $ServerCredential
        
        # Get Azure SQL Database context
        $Db = Get-AzureSqlDatabase $CTX -DatabaseName $DatabaseName
        
        # Specify the specific performance level for the target $DatabaseName
        $ServiceObjective = Get-AzureSqlDatabaseServiceObjective $CTX -ServiceObjectiveName $PerfLevel
        
        # Set the new edition/performance level
        Set-AzureSqlDatabase $CTX -Database $Db -ServiceObjective $ServiceObjective -Edition $Edition -Force
        
        # Output final status message
        Write-Output "Scaled the performance level of $DatabaseName to $Edition - $PerfLevel"
        Write-Output "Completed vertical scale"
    
}

$securePass = "QA321ik!" | ConvertTo-SecureString -AsPlainText -Force
$userName = "afadmin"

$cred = New-Object  pscredential -ArgumentList $($userName, $securePass)

Set-AzureSqlDatabaseEdition-Ims -SqlServerName 722610 -DatabaseName DataCollection_Copy_2 -Edition Standard -PerfLevel S3 -Credential $cred
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

workflow scale-database
{
    param
    (
        # Name of the Azure SQL Database server (Ex: bzb98er9bp)
        [parameter(Mandatory = $true)]
        [string] $SqlServerName,

        # Target Azure SQL Database name
        [parameter(Mandatory = $true)]
        [string] $DatabaseName,

        # Desired Azure SQL Database edition {Basic, Standard, Premium}
        [parameter(Mandatory = $true)]
        [string] $Edition,

        # Desired performance level {Basic, S0, S1, S2, P1, P2, P3}
        [parameter(Mandatory = $true)]
        [string] $PerfLevel,

        [parameter(Mandatory = $true)]
        [string] $ResourceGroupName

    )

    $VerbosePreference = 'continue'
    $Conn = Get-AutomationConnection -Name 'AzureRunAsConnection'
    Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
    Select-AzureRmSubscription -SubscriptionName 'Microsoft Azure Enterprise'

    # inlineScript
    # {

    Write-Output "Begin vertical scaling script..."

    # Set the new edition/performance level

    Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -DatabaseName $DatabaseName -ServerName $SqlServerName -Edition $Edition -RequestedServiceObjectiveName $PerfLevel -AsJob

    $progress = Get-AzureRmSqlDatabaseActivity -ServerName $SqlServerName -ResourceGroupName $ResourceGroupName -DatabaseName $DatabaseName | Where-Object -Property State -EQ -Value 'InProgress' | Sort-Object -Property StartTime -Descending | Select-Object -First 1
    $previousProgressValue = -1

    while ($progress.State -eq 'InProgress')
    {  

        Write-Output "Percent completed: $($progress.PercentComplete)"

        $progress = Get-AzureRmSqlDatabaseActivity -ServerName $SqlServerName -ResourceGroupName $ResourceGroupName -DatabaseName $DatabaseName | Where-Object -Property State -EQ -Value 'InProgress' | Sort-Object -Property StartTime -Descending | Select-Object -First 1
        $previousProgressValue = $progress.PercentComplete
        Start-Sleep -Seconds 5
    }

    # Output final status message
    Write-Output "Scaled the performance level of $($DatabaseName) to $($Edition) - $($PerfLevel)"

    Write-Output "Completed vertical scale"

    # }
}



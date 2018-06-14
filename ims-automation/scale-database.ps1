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
   
    #Connect to azure account

    Write-Output "Login in to azure..."
    $null = Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
    

    # Selecting subscription Microsoft Azure Enterprise
    Write-Output "Selecting Microsoft Azure Enterprise Subscription..."
    $null = Select-AzureRmSubscription -SubscriptionName 'Microsoft Azure Enterprise'

    Write-Output "Begin scale the performance level of $($DatabaseName) to $($Edition) - $($PerfLevel)"

    # Set the new edition/performance level
    Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -DatabaseName $DatabaseName -ServerName $SqlServerName -Edition $Edition -RequestedServiceObjectiveName $PerfLevel

    # Output final status message
    
    Write-Output "Scaled the performance level of $($DatabaseName) to $($Edition) - $($PerfLevel)"

    Write-Output "Completed vertical scale..."

}



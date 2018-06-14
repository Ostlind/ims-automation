workflow Delete-Ims-Data
{
    <#
.SYNOPSIS
    Outputs the number of records in the specified SQL Server database table.

.DESCRIPTION
	This runbook demonstrates how to communicate with a SQL Server. Specifically, this runbook
    outputs the number of records in the specified SQL Server database table.

    In order for this runbook to work, the SQL Server must be accessible from the runbook worker
    running this runbook. Make sure the SQL Server allows incoming connections from Azure services
	by selecting 'Allow Windows Azure Services' on the SQL Server configuration page in Azure.

    This runbook also requires an Automation Credential asset be created before the runbook is
    run, which stores the username and password of an account with access to the SQL Server.
    That credential should be referenced for the SqlCredential parameter of this runbook.

.PARAMETER SqlServer
    String name of the SQL Server to connect to

.PARAMETER SqlServerPort
    Integer port to connect to the SQL Server on

.PARAMETER Database
    String name of the SQL Server database to connect to

.PARAMETER Table
    String name of the database table to output the number of records of

.PARAMETER SqlCredential
    PSCredential containing a username and password with access to the SQL Server

.EXAMPLE
    Use-SqlCommandSample -SqlServer "somesqlserver.cloudapp.net" -SqlServerPort 1433 -Database "SomeDatabaseName" -Table "SomeTableName" - SqlCredential $SomeSqlCred

.NOTES
    AUTHOR: System Center Automation Team
    LASTEDIT: Jan 31, 2014
#>

        param(
            [parameter(Mandatory = $true)]
            [string] $SqlServerName,

            [parameter(Mandatory = $false)]
            [int] $SqlServerPort = 1433,

            [parameter(Mandatory = $true)]
            [string] $DatabaseName ,

            [parameter(Mandatory = $true)]
            [string] $TableName,

            [parameter(Mandatory = $True)]
            [PSCredential] $SqlCredential
        )

$SqlCredential = Get-AutomationPSCredential -Name 'afadmin'
        
Set-AzureSqlDatabaseEdition-Ims `
		-SqlServerName $SqlServerName `
		-Credential $SqlCredential `
		-databaseName $DatabaseName `
		-Edition "Standard" `
		-PerfLevel "S3"


        #$params = @{"SqlServerName" = $SqlServerName; "Credential" = $SqlCredential; "DatabaseName" = $DatabaseName; "Edition" = "Standard"; "PerfLevel" = "S3" }
        #$joboutput = Start-AzureRmAutomationRunbook –AutomationAccountName "ims-automation" –Name "Set-AzureSqlDatabaseEdition-Ims" -ResourceGroupName "af-722610-shared-rg-we" –Parameters $params -Wait
        #Set-AzureSqlDatabaseEdition-Ims -SqlServerName $SqlServerName -Credential $SqlCredential -databaseName $DatbaseName -Edition "Standard" -PerfLevel "S3"

        InlineScript
        {



            $SqlUsername = $Using:SqlCredential.UserName
            $SqlPass = ($Using:SqlCredential).GetNetworkCredential().Password
            $connectionString = "Server=tcp:$Using:SqlServerName.database.windows.net,$Using:SqlServerPort;Database=$Using:DatabaseName;User ID=$SqlUsername;Password=$SqlPass;Trusted_Connection=False;;MultipleActiveResultSets=False;Encrypt=True;Connection Timeout=30;"
            # Define the connection to the SQL Database
            $Conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
            # Open the SQL connection
            $Conn.Open()
            # Define the SQL command to run. In this case we are getting the number of rows in the table

            # Query

            $query = "delete FROM $Using:TableName where [Timestamp] < '$((Get-Date).AddMonths(-3).ToString('yyy-MM-dd'))'"

            $Cmd = new-object system.Data.SqlClient.SqlCommand($query, $Conn)
            $Cmd.CommandTimeout = 0

            # Execute the SQL command

            $watch = [System.Diagnostics.Stopwatch]::StartNew()
            $rowsDeleted = $Cmd.ExecuteNonQuery()
            $watch.stop()
            $ts = $watch.Elapsed
            $elapsedTime = [string]::Format("{0:00}:{1:00}:{2:00}.{3:00}",
                $ts.Hours, $ts.Minutes, $ts.Seconds,
                $ts.Milliseconds / 10);


            # Close the SQL connection
            $Conn.Close()

            Write-Output "Number of rows: {0} deleted in {1}" -f $rowsDeleted, $elapsedTime
        }

Set-AzureSqlDatabaseEdition-Ims `
		-SqlServerName $SqlServerName `
		-Credential $SqlCredential `
		-databaseName $DatabaseName `
		-Edition "Standard" `
		-PerfLevel "S1"


        #$params = @{"SqlServerName" = $SqlServerName; "Credential" = $SqlCredential; "DatabaseName" = $DatabaseName; "Edition" = "Standard"; "PerfLevel" = "S1" }
        #$joboutput = Start-AzureRmAutomationRunbook –AutomationAccountName "ims-automation" –Name "Set-AzureSqlDatabaseEdition-Ims" -ResourceGroupName "af-722610-shared-rg-we" –Parameters $params

    }
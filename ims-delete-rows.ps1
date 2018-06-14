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
workflow Delete-Ims-Records {

    param(
        [parameter(Mandatory=$False)]
        [string] $SqlServer = 'tcp:722610.database.windows.net',
        
        [parameter(Mandatory=$False)]
        [int] $SqlServerPort = 1433,
        
        [parameter(Mandatory=$False)]
        [string] $Database = 'DataCollection_Copy',
        
        [parameter(Mandatory=$False)]
        [string] $Table = 'dbo.Facts',
        
        [parameter(Mandatory=$False)]
        [string] $Username = "afadmin",
        
        [parameter(Mandatory=$False)]
        [string] $Password = 'QA321ik!'
    )


    # Get the username and password from the SQL Credential
    $secpasswd = ConvertTo-SecureString "$Password" -AsPlainText -Force
    $SqlCredential = New-Object System.Management.Automation.PSCredential ($UserName, $secpasswd)


    $SqlUsername = $SqlCredential.UserName
    $SqlPass = $SqlCredential.GetNetworkCredential().Password
    $connectionString = "Server=$SqlServer,$SqlServerPort;Database=$Database;User ID=$SqlUsername;Password=$SqlPass;Trusted_Connection=False;;MultipleActiveResultSets=False;Encrypt=True;Connection Timeout=30;"
    # Define the connection to the SQL Database
    $Conn = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    # Open the SQL connection
    $Conn.Open()
    # Define the SQL command to run. In this case we are getting the number of rows in the table

    # Query

    $query = "delete FROM $Table where [Timestamp] < '$((Get-Date).AddMonths(-3).ToString('yyy-MM-dd'))'"

    $Cmd=new-object system.Data.SqlClient.SqlCommand($query, $Conn)
    $Cmd.CommandTimeout=0
    
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
import-module AzureRM.Automation -Verbose

$context = Get-AzureRmContext

if($context.Subscription -eq $null)
{
    Connect-AzureRmAccount 
    Select-AzureRmSubscription -SubscriptionName "Microsoft Azure Enterprise"
}

$securePass = "QA321ik!" | ConvertTo-SecureString -AsPlainText -Force
$userName = "afadmin"
$cred = New-Object  pscredential -ArgumentList $($userName, $securePass)
$automationAccount = Get-AzureRmAutomationAccount | Select-Object -First 1

$runbook = (Get-AzureRmAutomationRunbook -ResourceGroupName $automationAccount.ResourceGroupName `
        -AutomationAccountName $automationAccount.AutomationAccountName  | Select-Object -Property Name )[1]

$params = @{SqlServerName="722610"
            Credential=$cred
            DatabaseName="DataCollection_Copy_2"
            Edition="Standard"
            PerfLevel="S3" }

Start-AzureRmAutomationRunbook -AutomationAccountName "ims-automation" `
    -Name $runbook.Name `
    -ResourceGroupName  $automationAccount.ResourceGroupName `
    -Parameters $params `
    -Wait



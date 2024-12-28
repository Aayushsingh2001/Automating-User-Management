$logFilePath = "C:\Users\as699\onedrive\desktop\aayu_devops\automating-user-management\user_management_logs.text"
$reportPath = "C:\Users\as699\onedrive\desktop\aayu_devops\automating-user-management\log_report.csv"

# Reading the logs of the file as well as creating the filters
function AnalyzeLogs {
    param (
        [string]$logFilePath,
        [string]$dateFilter = "",
        [string]$timeFilter = ""
    )

    $logEntries = Get-Content $logFilePath | Where-Object {
        if ($dateFilter -ne ""){
            $_ -match "$dateFilter"
        }
        elseif ($dateFilter -ne "") {
            $_ -match "$timeFilter"
        }
        else {
            $true
        }
    }

    $logSummery = @()

    foreach ($log in $logEntries) {
        $date = ($log -split ' ')[0]  # Extracting the date
        $time = ($log -split ' ')[1]  # Extracting the time
        $description = ($log -split ' - ')[1] # Extracting the description og the logs

        $logSummery += [PSCustomObject]@{
            Date = $date
            Time = $time
            Description = $description
        }
    }

    return $logSummery
    
}

# Generate CSV report
$dateFilter = ""  # you can provide your date filter here
$timeFilter = ""  # you can provide your time filter here

$analysisResults = AnalyzeLogs -logFilePath $logFilePath -dateFilter $dateFilter -timeFilter $timeFilter

$analysisResults | Export-Csv -Path $reportPath -NoTypeInformation

Write-Host "Log Analysis is completed. Report is generated at: $reportPath"
# Define the log file path
$logFilePath = "C:\path\to\your\logfile.csv"

# Get the current date and time
$currentDate = Get-Date -Format "yyyy-MM-dd"
$currentTime = Get-Date -Format "HH:mm:ss"

# Check if the log file exists
if (-Not (Test-Path -Path $logFilePath)) {
    # Create the log file and add headers
    "Date,TimeIn,TimeOut" | Out-File -FilePath $logFilePath -Force
}

# Read the log file data
$logData = Import-Csv -Path $logFilePath

# Define the action (TimeIn or TimeOut)
$Action = $args[0]

if ($Action -eq "TimeIn") {
    # Check if "Time In" already exists for today
    $todayLog = $logData | Where-Object { $_.Date -eq $currentDate }
    if ($todayLog) {
        Write-Host "You have already logged Time In for today!" -ForegroundColor Yellow
    } else {
        # Add a new entry for "Time In"
        Add-Content -Path $logFilePath -Value "$currentDate,$currentTime,"
        Write-Host "Time In logged successfully at $currentTime." -ForegroundColor Green
    }
} elseif ($Action -eq "TimeOut") {
    # Check if "Time In" exists for today and "Time Out" is empty
    $todayLog = $logData | Where-Object { $_.Date -eq $currentDate }
    if ($todayLog) {
        if ($todayLog.TimeOut -eq "") {
            # Update "Time Out" for today
            $updatedLog = $logData | ForEach-Object {
                if ($_.Date -eq $currentDate) {
                    "$($_.Date),$($_.TimeIn),$currentTime"
                } else {
                    "$($_.Date),$($_.TimeIn),$($_.TimeOut)"
                }
            }
            $updatedLog | Out-File -FilePath $logFilePath -Force
            Write-Host "Time Out logged successfully at $currentTime." -ForegroundColor Green
        } else {
            Write-Host "You have already logged Time Out for today!" -ForegroundColor Yellow
        }
    } else {
        Write-Host "No Time In record found for today. Please log Time In first." -ForegroundColor Red
    }
}
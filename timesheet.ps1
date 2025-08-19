# Define the path to store time logs
$logFilePath = "$PSScriptRoot\TimeLog.csv"

# Ensure the log file exists
if (-not (Test-Path -Path $logFilePath)) {
    @"
Date,TimeIn,TimeOut
"@ | Out-File -FilePath $logFilePath
}

# Function to log time
function Log-Time {
    param (
        [string]$Action
    )
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $currentTime = Get-Date -Format "HH:mm:ss"
    $logData = Import-Csv -Path $logFilePath

    if ($Action -eq "TimeIn") {
        # Check if "Time In" is already logged for today
        if ($logData | Where-Object { $_.Date -eq $currentDate }) {
            Write-Host "You already logged Time In for today!" -ForegroundColor Yellow
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
}

# Function to display dashboard in GridView
function Show-Dashboard {
    $logData = Import-Csv -Path $logFilePath

    if ($logData.Count -eq 0) {
        Write-Host "No logs available to display." -ForegroundColor Yellow
    } else {
        # Display data in an interactive grid view
        $logData | Out-GridView -Title "Time Tracker Dashboard"
    }
}

# Main Menu
function Show-Menu {
    cls
    Write-Host "========================================="
    Write-Host "          Time In/Time Out Tracker        "
    Write-Host "========================================="
    Write-Host "1. Log Time In"
    Write-Host "2. Log Time Out"
    Write-Host "3. Show Dashboard"
    Write-Host "4. Exit"
    Write-Host "========================================="
    $choice = Read-Host "Enter your choice (1-4)"
    switch ($choice) {
        1 {
            Log-Time -Action "TimeIn"
        }
        2 {
            Log-Time -Action "TimeOut"
        }
        3 {
            Show-Dashboard
        }
        4 {
            Write-Host "Exiting the tracker. Have a good day!" -ForegroundColor Cyan
            exit
        }
        default {
            Write-Host "Invalid option. Please select again!" -ForegroundColor Red
        }
    }
}

# Infinite loop to keep showing the menu
while ($true) {
    Show-Menu
    Start-Sleep -Seconds 1
}
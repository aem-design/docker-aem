#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Fetches the latest GitHub Actions workflow logs using GitHub CLI
.DESCRIPTION
    Retrieves and displays logs from GitHub Actions workflow runs using gh CLI
.PARAMETER Limit
    Number of recent runs to show (default: 5)
.PARAMETER Workflow
    Filter by workflow file name (e.g., "build.yml")
.PARAMETER Status
    Filter by status: completed, action_required, cancelled, failure, neutral, skipped, stale, success, timed_out, in_progress, queued, requested, waiting
.PARAMETER ViewLogs
    View full logs of the latest/specified run
.PARAMETER Download
    Download logs as zip file
.PARAMETER RunId
    Specific run ID to view/download
.PARAMETER Watch
    Watch a running workflow in real-time
.PARAMETER WaitForCompletion
    Wait for the latest/specified workflow run to complete, then show results
.PARAMETER PollInterval
    Seconds between status checks when waiting for completion (default: 10)
.PARAMETER CurrentCommit
    Find workflow runs for the current git HEAD commit
.PARAMETER ShowLogs
    Automatically show logs when finding current commit's pipeline (only works with single run)
.PARAMETER SaveLogs
    Save logs to logs/ folder (default: true, use -SaveLogs:$false to disable)
.PARAMETER Force
    Force re-download of logs even if they already exist
.EXAMPLE
    .\get-action-logs.ps1
    Finds workflow runs for current git commit and saves logs (skips if already exist)
.EXAMPLE
    .\get-action-logs.ps1 -ShowLogs
    Finds current commit's pipeline, displays logs in console, and saves to file
.EXAMPLE
    .\get-action-logs.ps1 -Force
    Re-downloads logs even if they already exist
.EXAMPLE
    .\get-action-logs.ps1 -SaveLogs:$false
    Finds current commit's pipeline without saving logs to file
.EXAMPLE
    .\get-action-logs.ps1 -CurrentCommit
    Finds workflow runs for the current git commit
.EXAMPLE
    .\get-action-logs.ps1 -Limit 10 -Status failure
    Lists the 10 most recent failed runs
.EXAMPLE
    .\get-action-logs.ps1 -ViewLogs
    Shows logs for the latest run
.EXAMPLE
    .\get-action-logs.ps1 -RunId 12345678 -ViewLogs
    Shows logs for specific run
.EXAMPLE
    .\get-action-logs.ps1 -Watch
    Watches the currently running workflow
.EXAMPLE
    .\get-action-logs.ps1 -WaitForCompletion
    Waits for the latest workflow to complete and shows results
.EXAMPLE
    .\get-action-logs.ps1 -RunId 12345678 -WaitForCompletion -ViewLogs
    Waits for specific run to complete, then shows logs
#>

param(
    [int]$Limit = 5,
    [string]$Workflow = "",
    [string]$Status = "",
    [switch]$ViewLogs,
    [switch]$Download,
    [string]$RunId = "",
    [switch]$Watch,
    [switch]$WaitForCompletion,
    [int]$PollInterval = 10,
    [switch]$CurrentCommit,
    [switch]$ShowLogs,
    [bool]$SaveLogs = $true,
    [switch]$Force
)

# Color output functions
function Write-Info {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Green
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Red
}

# Check if gh CLI is installed
try {
    $ghVersion = gh --version 2>$null
    if (-not $ghVersion) {
        throw "gh not found"
    }
} catch {
    Write-ErrorMsg "ERROR: GitHub CLI (gh) is not installed or not in PATH"
    Write-Info "Install from: https://cli.github.com/"
    Write-Info "Or use: winget install --id GitHub.cli"
    exit 1
}

# Check authentication
try {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorMsg "ERROR: Not authenticated with GitHub"
        Write-Info "Run: gh auth login"
        exit 1
    }
} catch {
    Write-ErrorMsg "ERROR: Failed to check authentication status"
    exit 1
}

# Function to wait for workflow completion
function Wait-ForWorkflowCompletion {
    param(
        [string]$RunId,
        [int]$PollInterval
    )

    $startTime = Get-Date
    $spinner = @('|', '/', '-', '\')
    $spinnerIndex = 0

    Write-Info "Waiting for workflow run to complete..."
    Write-Info "Run ID: ${RunId}"
    Write-Info "Poll interval: ${PollInterval} seconds`n"

    while ($true) {
        # Get run status
        $runStatus = gh run view $RunId --json status,conclusion,displayTitle,workflowName | ConvertFrom-Json

        $elapsed = [math]::Round(((Get-Date) - $startTime).TotalSeconds)
        $elapsedMin = [math]::Floor($elapsed / 60)
        $elapsedSec = $elapsed % 60

        # Show progress with spinner
        $spinChar = $spinner[$spinnerIndex % 4]
        $spinnerIndex++

        Write-Host "`r$spinChar " -NoNewline -ForegroundColor Yellow
        Write-Host "Status: " -NoNewline -ForegroundColor Cyan
        Write-Host "$($runStatus.status) " -NoNewline -ForegroundColor White
        Write-Host "| Elapsed: " -NoNewline -ForegroundColor Cyan
        Write-Host "${elapsedMin}m ${elapsedSec}s " -NoNewline -ForegroundColor White

        # Check if completed
        if ($runStatus.status -eq "completed") {
            Write-Host "`n"

            $conclusionColor = switch ($runStatus.conclusion) {
                "success" { "Green" }
                "failure" { "Red" }
                "cancelled" { "Yellow" }
                default { "Cyan" }
            }

            $conclusionIcon = switch ($runStatus.conclusion) {
                "success" { "✓" }
                "failure" { "✗" }
                "cancelled" { "⊘" }
                default { "●" }
            }

            Write-Host "`n$conclusionIcon Workflow completed!" -ForegroundColor $conclusionColor
            Write-Info "Workflow: $($runStatus.workflowName)"
            Write-Info "Title: $($runStatus.displayTitle)"
            Write-Host "Conclusion: " -NoNewline -ForegroundColor Cyan
            Write-Host "$($runStatus.conclusion)" -ForegroundColor $conclusionColor
            Write-Info "Total time: ${elapsedMin}m ${elapsedSec}s`n"

            return $runStatus.conclusion
        }

        # Wait before next poll
        Start-Sleep -Seconds $PollInterval
    }
}

try {
    # Determine if we should default to current commit mode
    # Default to current commit if no specific action parameters are provided
    $noParamsProvided = (-not $CurrentCommit) -and
                       (-not $WaitForCompletion) -and
                       (-not $Watch) -and
                       (-not $ViewLogs) -and
                       (-not $Download) -and
                       ([string]::IsNullOrEmpty($RunId)) -and
                       ([string]::IsNullOrEmpty($Status)) -and
                       ([string]::IsNullOrEmpty($Workflow)) -and
                       (-not $ShowLogs)

    # If CurrentCommit or ShowLogs explicitly set, use current commit mode
    $shouldUseCurrentCommit = $CurrentCommit -or $ShowLogs

    if ($noParamsProvided) {
        # Check if we're in a git repository
        try {
            $null = git rev-parse HEAD 2>$null
            if ($LASTEXITCODE -eq 0) {
                $shouldUseCurrentCommit = $true
                Write-Info "No parameters specified - defaulting to current commit mode (logs will be saved to logs/ folder)`n"
            }
        } catch {
            # Not in a git repo, will fall through to list mode
        }
    }

    # Current commit mode
    if ($shouldUseCurrentCommit) {
        Write-Info "Getting current git commit..."

        # Check if git is available and we're in a git repo
        try {
            $currentCommitSha = git rev-parse HEAD 2>$null
            if ($LASTEXITCODE -ne 0) {
                throw "Not a git repository"
            }
            $shortSha = git rev-parse --short HEAD
        } catch {
            Write-ErrorMsg "ERROR: Failed to get current commit. Are you in a git repository?"
            exit 1
        }

        Write-Info "Current commit: ${currentCommitSha} (${shortSha})"
        Write-Info "Searching for workflow runs...`n"

        # Search for runs with this commit
        $args = @("run", "list", "--limit", 50, "--json", "databaseId,displayTitle,status,conclusion,headBranch,headSha,event,createdAt,url,workflowName")

        if ($Workflow) {
            $args += @("--workflow", $Workflow)
        }

        $allRuns = & gh @args | ConvertFrom-Json
        $matchingRuns = $allRuns | Where-Object { $_.headSha -eq $currentCommitSha }

        if ($matchingRuns.Count -eq 0) {
            Write-ErrorMsg "No workflow runs found for commit ${shortSha}"
            Write-Info "The commit may not have been pushed yet, or workflows may not have triggered."
            exit 1
        }

        # Fetch and save logs first if needed (for single run) - silently
        $logFiles = @{}
        if ($matchingRuns.Count -eq 1 -and ($ShowLogs -or $SaveLogs)) {
            $run = $matchingRuns[0]

            # Create logs directory if it doesn't exist
            $logsDir = "logs"
            if (-not (Test-Path $logsDir)) {
                New-Item -ItemType Directory -Path $logsDir | Out-Null
            }

            # Generate filename without timestamp (run ID is unique)
            $runId = [string]$run.databaseId
            $workflowName = $run.workflowName -replace '[^a-zA-Z0-9_-]', '_'
            $filename = "${logsDir}/run-${runId}-${shortSha}-${workflowName}-$($run.conclusion).log"
            $logFiles[$run.databaseId] = $filename

            # Check if we need to fetch logs
            $needsFetch = ($SaveLogs -and ((-not (Test-Path $filename)) -or $Force)) -or ($ShowLogs -and -not (Test-Path $filename))

            if ($needsFetch) {
                $logContent = gh run view $run.databaseId --log 2>&1 | Out-String

                # Save if SaveLogs is enabled and (doesn't exist or Force is set)
                if ($SaveLogs -and ((-not (Test-Path $filename)) -or $Force)) {
                    $logContent | Out-File -FilePath $filename -Encoding UTF8
                }
            }
        }

        Write-Success "Found $($matchingRuns.Count) workflow run(s) for commit ${shortSha}:`n"

        foreach ($run in $matchingRuns) {
            Write-Host ("=" * 100) -ForegroundColor Yellow

            # Status icon
            $statusIcon = switch ($run.conclusion) {
                "success" { "✓" }
                "failure" { "✗" }
                "cancelled" { "⊘" }
                "skipped" { "⊖" }
                default { "●" }
            }

            $statusColor = switch ($run.conclusion) {
                "success" { "Green" }
                "failure" { "Red" }
                "cancelled" { "Yellow" }
                "skipped" { "DarkGray" }
                default { "Cyan" }
            }

            Write-Host "  ${statusIcon} " -NoNewline -ForegroundColor $statusColor
            Write-Host "$($run.workflowName)" -ForegroundColor White

            Write-Info "  Run ID       : $($run.databaseId)"
            Write-Info "  Title        : $($run.displayTitle)"
            Write-Info "  Status       : $($run.status)"
            Write-Host "  Conclusion   : " -NoNewline -ForegroundColor Cyan
            Write-Host "$($run.conclusion)" -ForegroundColor $statusColor
            Write-Info "  Branch       : $($run.headBranch)"
            Write-Info "  Event        : $($run.event)"
            Write-Info "  Created      : $($run.createdAt)"
            Write-Info "  URL          : $($run.url)"

            # Show log file path
            $runId = [string]$run.databaseId
            $workflowName = $run.workflowName -replace '[^a-zA-Z0-9_-]', '_'
            $logFilename = "logs/run-${runId}-${shortSha}-${workflowName}-$($run.conclusion).log"
            if (Test-Path $logFilename) {
                Write-Host "  Log file     : " -NoNewline -ForegroundColor Cyan
                Write-Host "$logFilename" -ForegroundColor Green
            } else {
                Write-Host "  Log file     : " -NoNewline -ForegroundColor Cyan
                Write-Host "$logFilename" -ForegroundColor DarkGray
            }

            Write-Host ("=" * 100) -ForegroundColor Yellow
            Write-Host ""
        }

        # If WaitForCompletion is also set, wait for the run(s) to complete
        if ($WaitForCompletion) {
            $incompleteRuns = $matchingRuns | Where-Object { $_.status -ne "completed" }

            if ($incompleteRuns.Count -gt 0) {
                Write-Info "Waiting for $($incompleteRuns.Count) incomplete run(s) to finish...`n"

                foreach ($run in $incompleteRuns) {
                    Write-Info "Waiting for: $($run.workflowName)"
                    $conclusion = Wait-ForWorkflowCompletion -RunId $run.databaseId -PollInterval $PollInterval
                }
            }

            # Show logs if requested
            if ($ViewLogs -and $matchingRuns.Count -eq 1) {
                Write-Info "Fetching logs...`n"
                gh run view $matchingRuns[0].databaseId --log
            }
        }

        # Handle multiple runs case
        if ($matchingRuns.Count -gt 1 -and ($ShowLogs -or $SaveLogs)) {
            Write-Host "`n"
            Write-ErrorMsg "Cannot auto-fetch logs: Multiple workflow runs found for this commit."
            Write-Info "Use -RunId parameter to view logs for a specific run:"
            foreach ($run in $matchingRuns) {
                Write-Host "  .\get-action-logs.ps1 -RunId $($run.databaseId) -ViewLogs  # $($run.workflowName)" -ForegroundColor White
            }
        }

        # Display logs if ShowLogs is set and we have a single run
        if ($ShowLogs -and $matchingRuns.Count -eq 1) {
            $run = $matchingRuns[0]
            $runId = [string]$run.databaseId
            $workflowName = $run.workflowName -replace '[^a-zA-Z0-9_-]', '_'
            $filename = "logs/run-${runId}-${shortSha}-${workflowName}-$($run.conclusion).log"

            if (Test-Path $filename) {
                Write-Host "`n"
                $logContent = Get-Content $filename -Raw
                Write-Host ("=" * 100) -ForegroundColor Yellow
                Write-Output $logContent
                Write-Host ("=" * 100) -ForegroundColor Yellow
            }
        }

        exit 0
    }

    # Wait for completion mode
    if ($WaitForCompletion) {
        # Determine which run to wait for
        $targetRunId = $RunId

        if (-not $targetRunId) {
            # Get the latest run
            Write-Info "Getting latest workflow run..."
            $latestRun = gh run list --limit 1 --json databaseId | ConvertFrom-Json

            if ($latestRun.Count -eq 0) {
                Write-ErrorMsg "No workflow runs found"
                exit 1
            }

            $targetRunId = $latestRun[0].databaseId
        }

        # Wait for completion
        $conclusion = Wait-ForWorkflowCompletion -RunId $targetRunId -PollInterval $PollInterval

        # After completion, optionally view logs or download
        if ($ViewLogs) {
            Write-Info "Fetching logs...`n"
            gh run view $targetRunId --log
        } elseif ($Download) {
            Write-Info "Downloading logs..."
            gh run download $targetRunId
            Write-Success "Logs downloaded!"
        } else {
            # Show summary
            gh run view $targetRunId
        }

        # Exit with appropriate code based on conclusion
        if ($conclusion -eq "success") {
            exit 0
        } else {
            exit 1
        }
    }

    # Watch mode
    if ($Watch) {
        Write-Info "Watching workflow run in real-time..."
        gh run watch
        exit 0
    }

    # Download logs
    if ($Download) {
        if ($RunId) {
            Write-Info "Downloading logs for run ${RunId}..."
            gh run download $RunId
        } else {
            Write-Info "Downloading logs for latest run..."
            gh run download
        }
        Write-Success "Logs downloaded!"
        exit 0
    }

    # View logs
    if ($ViewLogs) {
        if ($RunId) {
            Write-Info "Viewing logs for run ${RunId}..."
            gh run view $RunId --log
        } else {
            Write-Info "Viewing logs for latest run..."
            gh run view --log
        }
        exit 0
    }

    # List runs
    Write-Info "Fetching workflow runs...`n"

    $args = @("run", "list", "--limit", $Limit)

    if ($Workflow) {
        $args += @("--workflow", $Workflow)
    }

    if ($Status) {
        $args += @("--status", $Status)
    }

    # Get runs as JSON for better formatting
    $runsJson = & gh @args --json databaseId,displayTitle,status,conclusion,headBranch,event,createdAt,url,workflowName | ConvertFrom-Json

    if ($runsJson.Count -eq 0) {
        Write-ErrorMsg "No workflow runs found"
        exit 1
    }

    Write-Success "Found $($runsJson.Count) workflow runs:`n"

    foreach ($run in $runsJson) {
        Write-Host ("=" * 100) -ForegroundColor Yellow

        # Status icon
        $statusIcon = switch ($run.conclusion) {
            "success" { "✓" }
            "failure" { "✗" }
            "cancelled" { "⊘" }
            "skipped" { "⊖" }
            default { "●" }
        }

        $statusColor = switch ($run.conclusion) {
            "success" { "Green" }
            "failure" { "Red" }
            "cancelled" { "Yellow" }
            "skipped" { "DarkGray" }
            default { "Cyan" }
        }

        Write-Host "  ${statusIcon} " -NoNewline -ForegroundColor $statusColor
        Write-Host "$($run.workflowName)" -ForegroundColor White

        Write-Info "  Run ID       : $($run.databaseId)"
        Write-Info "  Title        : $($run.displayTitle)"
        Write-Info "  Status       : $($run.status)"
        Write-Host "  Conclusion   : " -NoNewline -ForegroundColor Cyan
        Write-Host "$($run.conclusion)" -ForegroundColor $statusColor
        Write-Info "  Branch       : $($run.headBranch)"
        Write-Info "  Event        : $($run.event)"
        Write-Info "  Created      : $($run.createdAt)"
        Write-Info "  URL          : $($run.url)"

        Write-Host ("=" * 100) -ForegroundColor Yellow
        Write-Host ""
    }

    # Show helpful commands
    Write-Host ("-" * 100) -ForegroundColor DarkGray
    Write-Info "Helpful commands:"
    Write-Host "  Show logs         : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -ShowLogs" -ForegroundColor White
    Write-Host "  Save logs         : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -SaveLogs" -ForegroundColor White
    Write-Host "  Show & save logs  : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -ShowLogs -SaveLogs" -ForegroundColor White
    Write-Host "  Current commit    : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -CurrentCommit" -ForegroundColor White
    Write-Host "  Current & wait    : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -CurrentCommit -WaitForCompletion" -ForegroundColor White
    Write-Host "  View logs         : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -RunId <id> -ViewLogs" -ForegroundColor White
    Write-Host "  Download logs     : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -RunId <id> -Download" -ForegroundColor White
    Write-Host "  Watch live        : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -Watch" -ForegroundColor White
    Write-Host "  Wait for finish   : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -WaitForCompletion" -ForegroundColor White
    Write-Host "  Wait & view logs  : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -WaitForCompletion -ViewLogs" -ForegroundColor White
    Write-Host "  Filter failures   : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -Status failure" -ForegroundColor White
    Write-Host "  List recent runs  : " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\get-action-logs.ps1 -Limit 10" -ForegroundColor White
    Write-Host ("-" * 100) -ForegroundColor DarkGray

} catch {
    Write-ErrorMsg "ERROR: $($_.Exception.Message)"
    exit 1
}

Write-Success "`nDone!"


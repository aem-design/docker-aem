Param(
  [string]$LOG_PATH = "${PWD}\logs",
  [string]$LOG_PEFIX = "docker",
  [string]$LOG_SUFFIX = ".log",
  [string]$TAG = "",
  [string]$FILE = "Dockerfile",
  [string]$FUNCTIONS_URI = "https://github.com/aem-design/aemdesign-docker/releases/latest/download/functions.ps1",
  [string]$COMMAND = ""
)

$SKIP_CONFIG = $true
$PARENT_PROJECT_PATH = "."

. ([Scriptblock]::Create((([System.Text.Encoding]::ASCII).getString((Invoke-WebRequest -Uri "${FUNCTIONS_URI}").Content))))

# Resolve TAG to current git branch if not provided
if ([string]::IsNullOrWhiteSpace($TAG)) {
  try {
    $branch = (git rev-parse --abbrev-ref HEAD 2>$null).Trim()
    if (-not [string]::IsNullOrWhiteSpace($branch) -and $branch -ne "HEAD") {
      $TAG = $branch
    }
  } catch {
    # keep TAG empty and fallback below
  }
}

if ([string]::IsNullOrWhiteSpace($TAG)) {
  $TAG = "sdk-2026.2.24464"
}

if ([string]::IsNullOrWhiteSpace($COMMAND)) {
  $COMMAND = "docker build . -f .\${FILE} -t ${TAG}"
}

printSectionBanner "Loading Debug Image"
printSectionLine "$COMMAND" "warn"

$IMAGENAME=Select-String -path $FILE '.*imagename="(.*)".*' -AllMatches | Foreach-Object {$_.Matches} | Foreach-Object {$_.Groups[1].Value}

docker run -it --rm -v ${PWD}:/build/source:rw aemdesign/centos-java-buildpack bash --login

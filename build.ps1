Param(
  [string]$LOG_PATH = "${PWD}\logs",
  [string]$LOG_PEFIX = "docker",
  [string]$LOG_SUFFIX = ".log",
  [string]$TAG = "jdk8-arm",
  [string]$FILE = "Dockerfile",
  [string]$FUNCTIONS_URI = "https://github.com/aem-design/aemdesign-docker/releases/latest/download/functions.ps1",
  [string]$COMMAND = "docker buildx build --platform linux/arm64 --build-arg JDK_DRIVEID=$env:JDK_DRIVEID . -f .\${FILE} -t ${TAG}"
)

$SKIP_CONFIG = $true
$PARENT_PROJECT_PATH = "."

. ([Scriptblock]::Create((([System.Text.Encoding]::ASCII).getString((Invoke-WebRequest -Uri "${FUNCTIONS_URI}").Content))))

printSectionBanner "Building Image"
printSectionLine ( $COMMAND -replace $JDK_DRIVEID, $( "*" * $JDK_DRIVEID.length ) ) "warn"

Invoke-Expression -Command "$COMMAND" | Tee-Object -Append -FilePath "${LOG_FILE}"




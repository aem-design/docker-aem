Param(
  [string]$LOG_PATH = "${PWD}\logs",
  [string]$LOG_PEFIX = "docker",
  [string]$LOG_SUFFIX = ".log",
  [string]$TAG = "jdk11",
  [string]$FILE = "Dockerfile",
  [string]$GOOGLE_DRIVEID_AEM = "",
  [string]$GOOGLE_DRIVEID_AEM_SP = "",
  [string]$FUNCTIONS_URI = "https://github.com/aem-design/aemdesign-docker/releases/latest/download/functions.ps1",
  [string]$COMMAND = "docker build . -f .\${FILE} -t ${TAG}"
)

$SKIP_CONFIG = $true
$PARENT_PROJECT_PATH = "."

. ([Scriptblock]::Create((([System.Text.Encoding]::ASCII).getString((Invoke-WebRequest -Uri "${FUNCTIONS_URI}").Content))))

printSectionBanner "Building Image"
printSectionLine "$COMMAND" "warn"

Invoke-Expression -Command "$COMMAND" | Tee-Object -Append -FilePath "${LOG_FILE}"



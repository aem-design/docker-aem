Param(
  [string]$LOG_PATH = "${PWD}\logs",
  [string]$LOG_PEFIX = "docker",
  [string]$LOG_SUFFIX = ".log",
  [string]$TAG = "jdk11",
  [string]$FILE = "Dockerfile",
  [string]$FUNCTIONS_URI = "https://github.com/aem-design/aemdesign-docker/releases/latest/download/functions.ps1",
  [string]$COMMAND = "docker build . -f .\${FILE} -t ${TAG}"
)

$SKIP_CONFIG = $true
$PARENT_PROJECT_PATH = "."

. ([Scriptblock]::Create((([System.Text.Encoding]::ASCII).getString((Invoke-WebRequest -Uri "${FUNCTIONS_URI}").Content))))

printSectionBanner "Loading Debug Image"
printSectionLine "$COMMAND" "warn"

$IMAGENAME=Select-String -path $FILE '.*imagename="(.*)".*' -AllMatches | Foreach-Object {$_.Matches} | Foreach-Object {$_.Groups[1].Value}

docker run -it --rm -v ${PWD}:/build/source:rw aemdesign/centos-java-buildpack bash --login

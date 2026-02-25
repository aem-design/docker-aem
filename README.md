## AEM SDK

[![build_status](https://github.com/aem-design/docker-aem/workflows/build/badge.svg?branch=sdk-2026.2.24464)](https://github.com/aem-design/docker-aem/actions?query=workflow%3Abuild+branch%3Asdk-2026.2.24464)
[![github license](https://img.shields.io/github/license/aem-design/aem)](https://github.com/aem-design/aem) 
[![github issues](https://img.shields.io/github/issues/aem-design/aem)](https://github.com/aem-design/aem) 
[![github last commit](https://img.shields.io/github/last-commit/aem-design/aem)](https://github.com/aem-design/aem) 
[![github repo size](https://img.shields.io/github/repo-size/aem-design/aem)](https://github.com/aem-design/aem) 
[![docker stars](https://img.shields.io/docker/stars/aemdesign/aem)](https://hub.docker.com/r/aemdesign/aem) 
[![docker pulls](https://img.shields.io/docker/pulls/aemdesign/aem)](https://hub.docker.com/r/aemdesign/aem) 
[![github release](https://img.shields.io/github/release/aem-design/aem)](https://github.com/aem-design/aem)

Docker image based on [aemdesign/aem-base](https://hub.docker.com/r/aemdesign/aem-base/) with AEM SDK.

One image that can be used for both Author and Publish nodes. No license is included, you will need to register when starting up.

Docker image for linux/amd64 (also runs on Apple Silicon via Rosetta 2).

## Docker Images

Images are available on both registries:
- **Docker Hub**: `aemdesign/aem`
- **GitHub Container Registry**: `ghcr.io/aem-design/aem`

### Tags

- `latest` - Latest build from master branch
- `sdk-2026.2.24464` - Current SDK version branch
- Version tags (pushed when git tags are created)

### AEM Version

Folling base version of AEM jar used for this image, additional packages installed in separate branches.

Version: SDK


### Environment Variables

Following environment variables are available

| Name              | Default Value                 | Notes |
| ---               | ---                           | ---   |
| AEM_VERSION       | "aem-sdk-2023.1.10912.20230130T173736Z-230100"   | only used during build  |
| AEM_JVM_OPTS      | "-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0" -XX:+UseParallelGC --add-opens=java.desktop/com.sun.imageio.plugins.jpeg=ALL-UNNAMED --add-opens=java.base/sun.net.www.protocol.jrt=ALL-UNNAMED --add-opens=java.naming/javax.naming.spi=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xerces.internal.dom=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.loader=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED -Dnashorn.args=--no-deprecation-warning  |  |
| AEM_START_OPTS    | "start -c /aem/crx-quickstart -i launchpad -p 8080 -a 0.0.0.0 -Dsling.properties=conf/sling.properties" |  |
| AEM_JARFILE       | "/aem/crx-quickstart/app/cq-quickstart-cloudready-${AEM_VERSION}-standalone-quickstart.jar" |  |
| AEM_RUNMODE       | "-Dsling.run.modes=author,crx3,crx3tar,nosamplecontent" |  |


### Volumes

Following volumes are exposed

| Path | Notes  |
| ---  | ---    |
| "/aem/crx-quickstart/repository" | |
| "/aem/crx-quickstart/logs" | setup your logs to out put to console |
| "/aem/backup" | |

### Ports

Following Ports are exposed

| Path | Notes  |
| ---  | ---    |
| 8080 | main http port |
| 58242 | debug |
| 57345 | debug |
| 57346 | debug |


### Packages in Bundled

Following bundles are added to container

| File | Notes  |
| ---  | ---    |
|  |  |



### Starting

To start author run the following:

```bash
docker run --name author-sdk-2025-7-21644 -e "TZ=Australia/Sydney" -e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,localdev" -e "AEM_JVM_OPTS=-server -Xms248m -Xmx1524m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0 -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=58242,suspend=n -XX:+UseParallelGC --add-opens=java.desktop/com.sun.imageio.plugins.jpeg=ALL-UNNAMED --add-opens=java.base/sun.net.www.protocol.jrt=ALL-UNNAMED --add-opens=java.naming/javax.naming.spi=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xerces.internal.dom=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.loader=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED -Dnashorn.args=--no-deprecation-warning" -p4502:8080 -p30303:58242 -d aemdesign/aem:sdk-2026.2.24464
```

## Development

### CI/CD Pipeline

The project uses GitHub Actions for continuous integration and deployment:

- **Platform**: Images are built for `linux/amd64`
- **Apple Silicon support**: Works seamlessly on M1/M2/M3/M4 Macs via Docker Desktop's Rosetta 2 emulation
- **Automated testing**: Java version is verified before pushing
- **Image analysis**: Uses `dive` for Docker image layer analysis
- **Dual registry push**: Automatically pushes to Docker Hub and GitHub Container Registry
- **Git tag versioning**: Pushing a git tag automatically creates a corresponding Docker image tag

### Running on Apple Silicon Macs (M1/M2/M3/M4)

This image is built for `linux/amd64` architecture but runs seamlessly on Apple Silicon Macs through **Rosetta 2** emulation in Docker Desktop.

#### Prerequisites

1. **Docker Desktop for Mac** (version 4.25.0 or later recommended)
   - Download from: https://www.docker.com/products/docker-desktop

2. **Rosetta 2** (usually already installed on modern macOS)
   - To verify/install: `softwareupdate --install-rosetta`

#### Enable Rosetta 2 in Docker Desktop

1. Open **Docker Desktop**
2. Go to **Settings** (⚙️ icon) → **General**
3. Enable **"Use Rosetta for x86_64/amd64 emulation on Apple Silicon"**
4. Click **Apply & Restart**

![Docker Desktop Rosetta Setting](https://docs.docker.com/desktop/images/rosetta.png)

#### Verify It's Working

```bash
# Pull and run the image
docker pull aemdesign/aem:latest
docker run --rm aemdesign/aem:latest uname -m

# Expected output: x86_64 (running via Rosetta 2)
```

#### Performance Notes

- **Rosetta 2 emulation** provides near-native performance for most workloads
- First container start may be slightly slower (Rosetta translation cache warmup)
- Subsequent starts are fast
- **No code changes needed** - everything works transparently

### Monitoring Pipeline Status

Use the `get-action-logs.ps1` PowerShell script to monitor GitHub Actions workflow status and logs.

#### Prerequisites

- GitHub CLI (`gh`) must be installed and authenticated
- Install: `winget install --id GitHub.cli`
- Authenticate: `gh auth login`

#### Quick Start

```powershell
# Check current commit's pipeline status (saves logs to logs/ folder by default)
.\get-action-logs.ps1

# Wait for pipeline to complete
.\get-action-logs.ps1 -WaitForCompletion

# Show logs in console
.\get-action-logs.ps1 -ShowLogs

# Force re-download logs
.\get-action-logs.ps1 -Force
```

See full documentation: `Get-Help .\get-action-logs.ps1 -Full`

### Creating a New Release

See [RELEASE.md](RELEASE.md) for the full release runbook.

Quick tag example:

```bash
git tag sdk-2026.2.24464
git push origin sdk-2026.2.24464
```

Tag push automatically builds and publishes versioned Docker images to both registries.

## License

See [LICENSE](LICENSE) file for details.



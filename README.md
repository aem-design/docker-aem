## CentOS 7 with AEM

[![build_status](https://travis-ci.org/aem-design/aem.svg?branch=master)](https://travis-ci.org/aem-design/aem) 
[![github license](https://img.shields.io/github/license/aem-design/aem)](https://github.com/aem-design/aem) 
[![github issues](https://img.shields.io/github/issues/aem-design/aem)](https://github.com/aem-design/aem) 
[![github last commit](https://img.shields.io/github/last-commit/aem-design/aem)](https://github.com/aem-design/aem) 
[![github repo size](https://img.shields.io/github/repo-size/aem-design/aem)](https://github.com/aem-design/aem) 
[![docker stars](https://img.shields.io/docker/stars/aemdesign/aem)](https://hub.docker.com/r/aemdesign/aem) 
[![docker pulls](https://img.shields.io/docker/pulls/aemdesign/aem)](https://hub.docker.com/r/aemdesign/aem) 
[![github release](https://img.shields.io/github/release/aem-design/aem)](https://github.com/aem-design/aem)

This is docker image based on CentOS 7 with Tini
One image that can be used for both Author and Publish nodes
No license is included, you will need to register when starting up

### Included Packages

Following is the list of packages included

* aem                   - for all aem instance types

### Environment Variables

Following environment variables are available

| Name              | Default Value                 | Notes |
| ---               | ---                           | ---   |
| AEM_VERSION       | "6.5.0"   | only used during build  |
| AEM_JVM_OPTS      | "-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0"   |  |
| AEM_START_OPTS    | "start -c /aem/crx-quickstart -i launchpad -p 8080 -a 0.0.0.0 -Dsling.properties=conf/sling.properties" |  |
| AEM_JARFILE       | "/aem/crx-quickstart/app/cq-quickstart-${AEM_VERSION}-standalone-quickstart.jar" |  |
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

### Packages in Bundled Version `aemdesign/aem:6.5.0-bundle`

Following bundles are added to container

| File | Notes  |
| ---  | ---    |
| AEM-6.5.1.0-6.5.1.zip | sp 1 |
| AEM-Forms-6.5.1.0-LX-6.0.88.zip | aem forms |
| aem-compat-cq65-to-cq64-0.18.zip | aem forms backwards compatibility |
| com.adobe.acs.bundles.twitter4j-content-1.0.0.zip | acs twitter |
| acs-aem-commons-content-4.3.2.zip | acs commons |
| core.wcm.components.all-2.6.0.zip | adobe corecomponents |
| accesscontroltool-package-2.3.2.zip | netcentric acl tools |
| accesscontroltool-oakindex-package-2.3.2.zip | netcentric acl tools |
| vanityurls-components-1.0.2.zip | vanity url servlet |
| aemdesign-aem-core-deploy-<LATEST>.zip | aem design core |
| aemdesign-aem-support-deploy-<LATEST>.zip | aem design showcase content |


### Starting

To start local demo AEM 6.5 instance on port 4502

```bash
docker run --name author \
-e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,dev" \
-p4502:8080 -d \
-p30303:58242 -d \
aemdesign/aem
``` 

To start local demo AEM 6.4 instance on port 4512

```bash
docker run --name author64 \
-e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,dev" \
-p4512:8080 -d \
-p30313:58242 -d \
aemdesign/aem:6.4.0
``` 

To start local demo AEM 6.5 instance on port 4502 with Bundled Packages run the following

```bash
docker run --name author \
-e "TZ=Australia/Sydney" \
-e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,dev" \
-e "AEM_JVM_OPTS=-server -Xms248m -Xmx1524m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0 -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=58242,suspend=n" \
-p4502:8080 -d \
-p30303:58242 -d \
aemdesign/aem:6.5.0-bundle
``` 



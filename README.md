## CentOS 7 with AEM

[![build_status](https://github.com/aem-design/docker-aem/workflows/build/badge.svg?branch=6.5.0)](https://github.com/aem-design/docker-aem/actions?query=workflow%3Abuild+branch%3A6.5.0)
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
| AEM_VERSION       | "6.3.0"   | only used during build  |
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

### Packages in Bundled Version `aemdesign/aem:6.3.0-bundle`

Following bundles are added to container

| File | Notes  |
| ---  | ---    |
| [AEM-6.3.3.0-6.3.3.zip](https://www.adobeaemcloud.com/content/companies/public/adobe/packages/cq630/servicepack/AEM-6.3.3.0/jcr%3acontent/package/file.res/AEM-6.3.3.0-6.3.3.zip) | AEM-6.3.3.0 |
| [AEM-CFP-6.3.3.6-6.0.zip](https://www.adobeaemcloud.com/content/companies/public/adobe/packages/cq630/cumulativefixpack/AEM-CFP-6.3.3.6/jcr%3acontent/package/file.res/AEM-CFP-6.3.3.6-6.0.zip) | Cumulative Fix Pack 6.3.3.6 |
| [AEM-Forms-6.3.3.6-LX-4.1.124.zip](https://www.adobeaemcloud.com/content/companies/public/adobe/packages/cq630/servicepack/fd/AEM-Forms-6.3.3.6-LX/jcr%3acontent/package/file.res/AEM-Forms-6.3.3.6-LX-4.1.124.zip) | aem forms |
| [acs-aem-commons-ui.content-4.3.4-min.zip](https://github.com/Adobe-Consulting-Services/acs-aem-commons/releases/download/acs-aem-commons-4.3.4/acs-aem-commons-ui.content-4.3.4-min.zip) | acs commons |
| [acs-aem-commons-ui.apps-4.3.4-min.zip](https://github.com/Adobe-Consulting-Services/acs-aem-commons/releases/download/acs-aem-commons-4.3.4/acs-aem-commons-ui.apps-4.3.4-min.zip) |  |
| [acs-aem-commons-bundle-4.3.4.jar](https://github.com/Adobe-Consulting-Services/acs-aem-commons/releases/download/acs-aem-commons-4.3.4/acs-aem-commons-bundle-4.3.4.jar) |  |
| [core.wcm.components.all-2.7.0.zip](https://github.com/adobe/aem-core-wcm-components/releases/download/core.wcm.components.reactor-2.7.0/core.wcm.components.all-2.7.0.zip) | adobe corecomponents |
| [core.wcm.components.examples-2.7.0.zip](https://github.com/adobe/aem-core-wcm-components/releases/download/core.wcm.components.reactor-2.7.0/core.wcm.components.examples-2.7.0.zip) | adobe corecomponents |
| [accesscontroltool-package-2.4.1](http://repo1.maven.org/maven2/biz/netcentric/cq/tools/accesscontroltool/accesscontroltool-package/2.4.1/accesscontroltool-package-2.4.1.zip) | netcentric acl tools |
| [accesscontroltool-oakindex-package-2.4.1](http://repo1.maven.org/maven2/biz/netcentric/cq/tools/accesscontroltool/accesscontroltool-oakindex-package/2.4.1/accesscontroltool-oakindex-package-2.4.1.zip) | netcentric acl tools |
| [accesscontroltool-exampleconfig-package-2.4.1](http://repo1.maven.org/maven2/biz/netcentric/cq/tools/accesscontroltool/accesscontroltool-exampleconfig-package/2.4.1/accesscontroltool-exampleconfig-package-2.4.1.zip) | netcentric acl tools |
| com.adobe.acs.bundles.twitter4j-content-1.0.0.zip | acs twitter |
| aemdesign-aem-core-deploy-<LATEST>.zip | aem design core |
| aemdesign-aem-support-deploy-<LATEST>.zip | aem design showcase content |
| vanityurls-components-1.0.2.zip | vanity url servlet |
| day/cq60/product:cq-dam-content:2.3.0 |  |
| day/cq60/product:cq-wcm-content:6.3.0 |  |
| day/cq60/product:cq-integration-analytics-content:1.1.0 |  |

### Starting

To start local demo AEM 6.3 instance on port 4502

```bash
docker run --name author \
-e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,dev" \
-p4502:8080 -d \
-p30303:58242 -d \
aemdesign/aem
``` 

To start local demo AEM 6.3 instance on port 4512

```bash
docker run --name author63 \
-e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,dev" \
-p4512:8080 -d \
-p30313:58242 -d \
aemdesign/aem:6.3.0
``` 

To start local demo AEM 6.3 instance on port 4565 with Bundled Packages run the following

```bash
docker run --name author63bundle \
-e "TZ=Australia/Sydney" \
-e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,dev" \
-e "AEM_JVM_OPTS=-server -Xms248m -Xmx1524m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0 -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=58242,suspend=n" \
-p4565:8080 -d \
-p30364:58242 -d \
aemdesign/aem:6.3.0-bundle
``` 


To start local demo AEM 6.3 instance on port 4564 with Bundled Packages run the following

```bash
docker run --name author63bundle \
-e "TZ=Australia/Sydney" \
-e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,dev" \
-e "AEM_JVM_OPTS=-server -Xms248m -Xmx1524m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0 -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=58242,suspend=n" \
-p4564:8080 -d \
-p30364:58242 -d \
aemdesign/aem:6.3.0-bundle
``` 



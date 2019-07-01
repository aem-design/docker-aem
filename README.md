## CentOS 7 with AEM

[![pipeline status](https://gitlab.com/aem.design/aem/badges/master/pipeline.svg)](https://gitlab.com/aem.design/aem/commits/master)

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
| AEM_VERSION       | "6.5.0"   |  |
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

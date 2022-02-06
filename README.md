## Debian with AEM

[![build_status](https://github.com/aem-design/docker-aem/workflows/build/badge.svg?branch=6.5.11.0-jdk11-arm)](https://github.com/aem-design/docker-aem/actions?query=workflow%3Abuild+branch%3A6.5.10.0-jdk11-arm)
[![github license](https://img.shields.io/github/license/aem-design/aem)](https://github.com/aem-design/aem) 
[![github issues](https://img.shields.io/github/issues/aem-design/aem)](https://github.com/aem-design/aem) 
[![github last commit](https://img.shields.io/github/last-commit/aem-design/aem)](https://github.com/aem-design/aem) 
[![github repo size](https://img.shields.io/github/repo-size/aem-design/aem)](https://github.com/aem-design/aem) 
[![docker stars](https://img.shields.io/docker/stars/aemdesign/aem)](https://hub.docker.com/r/aemdesign/aem) 
[![docker pulls](https://img.shields.io/docker/pulls/aemdesign/aem)](https://hub.docker.com/r/aemdesign/aem) 
[![github release](https://img.shields.io/github/release/aem-design/aem)](https://github.com/aem-design/aem)

This is docker image based on [Debian with Tini](https://github.com/aem-design/docker-tini/tree/debian-arm)
One image that can be used for both Author and Publish nodes
No license is included, you will need to register when starting up

### Included Packages

Following is the list of packages included

* aem                   - for all aem instance types

### Environment Variables

Following environment variables are available

| Name           | Default Value                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Notes                  |
|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------|
| AEM_VERSION    | "6.5.0"                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | only used during build |
| AEM_JVM_OPTS   | "-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0"                                                                                                                                                                                                                                                                                                                              |                        |
| AEM_JVM_OPTS   | "${AEM_JVM_OPTS} -XX:+UseParallelGC --add-opens=java.desktop/com.sun.imageio.plugins.jpeg=ALL-UNNAMED --add-opens=java.base/sun.net.www.protocol.jrt=ALL-UNNAMED --add-opens=java.naming/javax.naming.spi=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xerces.internal.dom=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.loader=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED -Dnashorn.args=--no-deprecation-warning" |                        |
| AEM_START_OPTS | "start -c /aem/crx-quickstart -i launchpad -p 8080 -a 0.0.0.0 -Dsling.properties=conf/sling.properties"                                                                                                                                                                                                                                                                                                                                                                             |                        |
| AEM_JARFILE    | "/aem/crx-quickstart/app/cq-quickstart-${AEM_VERSION}-standalone-quickstart.jar"                                                                                                                                                                                                                                                                                                                                                                                                    |                        |
| AEM_RUNMODE    | "-Dsling.run.modes=author,crx3,crx3tar,nosamplecontent"                                                                                                                                                                                                                                                                                                                                                                                                                             |                        |


### Volumes

Following volumes are exposed

| Path                             | Notes                                 |
|----------------------------------|---------------------------------------|
| "/aem/crx-quickstart/repository" |                                       |
| "/aem/crx-quickstart/logs"       | setup your logs to out put to console |
| "/aem/backup"                    |                                       |

### Ports

Following Ports are exposed

| Path  | Notes          |
|-------|----------------|
| 8080  | main http port |
| 58242 | debug          |
| 57345 | debug          |
| 57346 | debug          |

### Packages Container

Following bundles are added to container

| File                    | Notes |
|-------------------------|-------|
| AEM-6.5.11.0-6.5.11.zip | sp 11 |


### Starting

To start local instance

```bash
docker run --name author6511 -e "TZ=Australia/Sydney" -e "AEM_RUNMODE=-Dsling.run.modes=author,crx3,crx3tar,forms,localdev" -e "AEM_JVM_OPTS=-server -Xms248m -Xmx1524m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0 -Xdebug -Xrunjdwp:transport=dt_socket,server=y,address=58242,suspend=n -XX:+UseParallelGC --add-opens=java.desktop/com.sun.imageio.plugins.jpeg=ALL-UNNAMED --add-opens=java.base/sun.net.www.protocol.jrt=ALL-UNNAMED --add-opens=java.naming/javax.naming.spi=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xerces.internal.dom=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.loader=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED -Dnashorn.args=--no-deprecation-warning" -p4502:8080 -p30303:58242 -d aemdesign/aem:6.5.11.0-jdk11-arm
``` 

FROM aemdesign/aem-base:latest

MAINTAINER devops <devops@aem.design>

LABEL   app.version="aem 6.5.0" \
        os.version="centos atomic 7" \
        java.version="oracle 8" \
        container.description="aem instance, will run as author unless specified otherwise"

ARG AEM_VERSION="6.5.0"
ARG AEM_JVM_OPTS="-server -Xms1024m -Xmx1024m -XX:MaxDirectMemorySize=256M -XX:+CMSClassUnloadingEnabled -Djava.awt.headless=true -Dorg.apache.felix.http.host=0.0.0.0"
ARG AEM_START_OPTS="start -c /aem/crx-quickstart -i launchpad -p 8080 -a 0.0.0.0 -Dsling.properties=conf/sling.properties"
ARG AEM_JARFILE="/aem/crx-quickstart/app/cq-quickstart-${AEM_VERSION}-standalone-quickstart.jar"
ARG AEM_RUNMODE="-Dsling.run.modes=author,crx3,crx3tar,nosamplecontent"
ARG CREDS_ADOBE=""
ARG GOOGLE_DRIVEID=""
ARG PACKAGE_PATH="./crx-quickstart/install"

ENV AEM_JVM_OPTS="${AEM_JVM_OPTS}" \
    AEM_START_OPTS="${AEM_START_OPTS}"\
    AEM_JARFILE="${AEM_JARFILE}" \
    AEM_RUNMODE="${AEM_RUNMODE}"

WORKDIR /aem

COPY scripts/*.sh /aem/

RUN ./gdrive.sh "download" "$GOOGLE_DRIVEID" "./aem-quickstart.jar"

#unpack the jar
RUN java -jar aem-quickstart.jar -unpack && \
    rm aem-quickstart.jar

COPY dist/install.first/*.config ./crx-quickstart/install/
COPY dist/install.first/logs/*.config ./crx-quickstart/install/
COPY dist/install.first/conf/sling.properties ./crx-quickstart/conf/sling.properties

RUN ./scripts/download.sh \
"$PACKAGE_PATH/01-" "$CREDS_ADOBE" "https://www.adobeaemcloud.com/content/companies/public/adobe/packages/cq650/servicepack/AEM-6.5.1.0/jcr%3acontent/package/file.res/AEM-6.5.1.0-6.5.1.zip" \
"$PACKAGE_PATH/02-" "$CREDS_ADOBE" "https://www.adobeaemcloud.com/content/companies/public/adobe/packages/cq650/servicepack/fd/AEM-Forms-6.5.1.0-LX/jcr%3acontent/package/file.res/AEM-Forms-6.5.1.0-LX-6.0.88.zip" \
"$PACKAGE_PATH/03-" "$CREDS_ADOBE" "https://www.adobeaemcloud.com/content/companies/public/adobe/packages/cq650/compatpack/aem-compat-cq65-to-cq64/jcr%3acontent/package/file.res/aem-compat-cq65-to-cq64-0.18.zip" \
"$PACKAGE_PATH/04-" "-" "https://github.com/Adobe-Consulting-Services/com.adobe.acs.bundles.twitter4j/releases/download/com.adobe.acs.bundles.twitter4j-1.0.0/com.adobe.acs.bundles.twitter4j-content-1.0.0.zip" \
"$PACKAGE_PATH/05-" "-" "https://github.com/Adobe-Consulting-Services/acs-aem-commons/releases/download/acs-aem-commons-4.3.0/acs-aem-commons-content-4.3.0.zip" \
"$PACKAGE_PATH/06-" "-" "https://github.com/adobe/aem-core-wcm-components/releases/download/core.wcm.components.reactor-2.5.0/core.wcm.components.all-2.5.0.zip" \
"$PACKAGE_PATH/07-" "-" "http://repo1.maven.org/maven2/biz/netcentric/cq/tools/accesscontroltool/accesscontroltool-package/2.3.2/accesscontroltool-package-2.3.2.zip" \
"$PACKAGE_PATH/08-" "-" "http://repo1.maven.org/maven2/biz/netcentric/cq/tools/accesscontroltool/accesscontroltool-oakindex-package/2.3.2/accesscontroltool-oakindex-package-2.3.2.zip" \
"$PACKAGE_PATH/09-" "$CREDS_ADOBE" "https://www.adobeaemcloud.com/content/companies/public/adobe/packages/cq600/component/vanityurls-components/jcr%3acontent/package/file.res/vanityurls-components-1.0.2.zip" \
"$PACKAGE_PATH/10-" "-" "https://github.com/aem-design/aemdesign-aem-core/releases/download/2.0.424/aemdesign-aem-core-deploy-2.0.424.zip"

#expose port
EXPOSE 8080 58242 57345 57346

VOLUME ["/aem/crx-quickstart/repository", "/aem/crx-quickstart/logs", "/aem/backup"]

#ensure script has exec permissions
RUN chmod +x /aem/*.sh

#make java pid 1
ENTRYPOINT ["/bin/tini", "--", "/aem/run-tini.sh"]
